# ─────────────────────────────────────────────────────────────────────────────
# CTD — import the client's vendor master + construction taxonomy.
#
# Reads:  the two workbooks the client supplies (paths below)
# Writes: assets/tools-data.js          window.TOOLS, all 1,463 vendors
#         data/construction-taxonomy.json   Master Trade > Division > Trade > Subtrade
#
# Re-runnable: always regenerates both outputs from scratch. When a newer
# workbook arrives, drop it in and re-run — do not hand-edit the outputs.
#
# Run: powershell -ExecutionPolicy Bypass -File build\import-vendors.ps1
# ─────────────────────────────────────────────────────────────────────────────
param(
  [string]$VendorXlsx   = "$env:USERPROFILE\OneDrive\Desktop\CTD\CTD_Combined_Vendor_Master_1463_HIERARCHY_CLASSIFIED.xlsx",
  [string]$TaxonomyXlsx = "$env:USERPROFILE\Downloads\CTD_Master_Trades_Divisions_Trades_Subtrades (1).xlsx",
  [string]$Root         = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

foreach ($p in @($VendorXlsx, $TaxonomyXlsx)) {
  if (-not (Test-Path $p)) { throw "Missing workbook: $p" }
}

# ── xlsx reading ─────────────────────────────────────────────────────────────
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Open-Xlsx($path) {
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ctdx_" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $tmp -Force | Out-Null
  $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
  foreach ($e in $zip.Entries) {
    if ($e.FullName.EndsWith('/')) { continue }
    $dest = Join-Path $tmp $e.FullName.Replace('/', '\')
    New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $dest, $true)
  }
  $zip.Dispose()
  return $tmp
}

function Get-SharedStrings($dir) {
  $p = Join-Path $dir 'xl\sharedStrings.xml'
  if (-not (Test-Path $p)) { return @() }
  $doc = New-Object System.Xml.XmlDocument
  $doc.Load($p)
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($si in $doc.DocumentElement.ChildNodes) { $out.Add($si.InnerText) }
  return $out
}

# Sheet name -> sheetN.xml, resolved through the workbook rels.
function Get-SheetPath($dir, $sheetName) {
  $wb = New-Object System.Xml.XmlDocument
  $wb.Load((Join-Path $dir 'xl\workbook.xml'))
  $ns = New-Object System.Xml.XmlNamespaceManager($wb.NameTable)
  $ns.AddNamespace('s', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')
  $ns.AddNamespace('r', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
  $node = $wb.SelectSingleNode("//s:sheets/s:sheet[@name='$sheetName']", $ns)
  if (-not $node) { throw "Sheet '$sheetName' not found in $dir" }
  $rid = $node.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')

  $rels = New-Object System.Xml.XmlDocument
  $rels.Load((Join-Path $dir 'xl\_rels\workbook.xml.rels'))
  foreach ($rel in $rels.DocumentElement.ChildNodes) {
    if ($rel.Id -ne $rid) { continue }
    $target = $rel.Target
    # Targets come both ways: "worksheets/sheet2.xml" (relative to xl/) and
    # "/xl/worksheets/sheet2.xml" (absolute from the package root). The two
    # client workbooks differ, so handle both.
    if ($target.StartsWith('/')) { return (Join-Path $dir $target.TrimStart('/').Replace('/', '\')) }
    return (Join-Path $dir ('xl\' + $target.Replace('/', '\')))
  }
  throw "Could not resolve relationship $rid"
}

# Rows as hashtables keyed by header name. Handles shared strings and inline
# strings — the taxonomy workbook uses inline, the vendor workbook uses shared.
function Read-Sheet($dir, $sheetName, [int]$headerRow = 1) {
  $shared = Get-SharedStrings $dir
  $doc = New-Object System.Xml.XmlDocument
  $doc.Load((Get-SheetPath $dir $sheetName))
  $ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
  $ns.AddNamespace('s', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')

  function CellText($c) {
    $t = $c.GetAttribute('t')
    $v = $c.SelectSingleNode('s:v', $ns)
    if ($v) {
      if ($t -eq 's') { return $shared[[int]$v.InnerText] }
      return $v.InnerText
    }
    $is = $c.SelectSingleNode('s:is', $ns)
    if ($is) { return $is.InnerText }
    return ''
  }
  function ColLetter($ref) { return ($ref -replace '\d', '') }

  $rows = @($doc.SelectNodes('//s:sheetData/s:row', $ns))
  if ($rows.Count -lt $headerRow) { return @() }

  $headers = @{}
  foreach ($c in $rows[$headerRow - 1].SelectNodes('s:c', $ns)) {
    $headers[(ColLetter $c.GetAttribute('r'))] = (CellText $c)
  }

  $out = New-Object System.Collections.Generic.List[hashtable]
  for ($i = $headerRow; $i -lt $rows.Count; $i++) {
    $rec = @{}
    foreach ($c in $rows[$i].SelectNodes('s:c', $ns)) {
      $col = ColLetter $c.GetAttribute('r')
      if ($headers.ContainsKey($col) -and $headers[$col]) { $rec[$headers[$col]] = (CellText $c) }
    }
    if ($rec.Count -gt 0) { $out.Add($rec) }
  }
  return $out
}

function Val($rec, $key) {
  if ($rec.ContainsKey($key) -and $null -ne $rec[$key]) { return ([string]$rec[$key]).Trim() }
  return ''
}

# ── 1. Construction taxonomy ─────────────────────────────────────────────────
Write-Host 'Reading taxonomy workbook...' -ForegroundColor Cyan
$taxDir = Open-Xlsx $TaxonomyXlsx

# These sheets carry a title row above the real header.
$masterTrades = Read-Sheet $taxDir 'MASTER_TRADES' 2
$divisions    = Read-Sheet $taxDir 'DIVISIONS'     2
$trades       = Read-Sheet $taxDir 'TRADES'        2
$subtrades    = Read-Sheet $taxDir 'SUBTRADES'     2

$taxonomy = [ordered]@{
  generatedFrom = [System.IO.Path]::GetFileName($TaxonomyXlsx)
  generatedAt   = (Get-Date -Format 'yyyy-MM-dd')
  note          = 'Master Trade > Division > Trade > Subtrade. division_number is a STRING - 00-09 collapse if parsed as integers.'
  masterTrades  = @($masterTrades | ForEach-Object {
      [ordered]@{
        id          = [int](Val $_ 'master_trade_id')
        name        = (Val $_ 'master_trade_name')
        description = (Val $_ 'description')
      } })
  divisions     = @($divisions | ForEach-Object {
      [ordered]@{
        id            = [int](Val $_ 'division_id')
        number        = (Val $_ 'division_number')
        name          = (Val $_ 'division_name')
        masterTradeId = [int](Val $_ 'master_trade_id')
        masterTrade   = (Val $_ 'master_trade_name')
        reserved      = ((Val $_ 'division_name') -like '*Reserved for Future*')
      } })
  trades        = @($trades | ForEach-Object {
      [ordered]@{
        id             = [int](Val $_ 'trade_id')
        name           = (Val $_ 'trade_name')
        divisionId     = [int](Val $_ 'division_id')
        divisionNumber = (Val $_ 'division_number')
        divisionName   = (Val $_ 'division_name')
        masterTradeId  = [int](Val $_ 'master_trade_id')
        masterTrade    = (Val $_ 'master_trade_name')
      } })
  subtrades     = @($subtrades | ForEach-Object {
      [ordered]@{
        id             = [int](Val $_ 'subtrade_id')
        name           = (Val $_ 'subtrade_name')
        tradeId        = [int](Val $_ 'trade_id')
        tradeName      = (Val $_ 'trade_name')
        divisionNumber = (Val $_ 'division_number')
        masterTradeId  = [int](Val $_ 'master_trade_id')
      } })
}

$taxPath = Join-Path $Root 'data\construction-taxonomy.json'
[System.IO.File]::WriteAllText($taxPath, ($taxonomy | ConvertTo-Json -Depth 6), $utf8)

# Browser-side copy for the facet lists. Deliberately excludes the 1,000
# subtrades - the pages only need the three short vocabularies, and shipping
# the full hierarchy would add ~400KB to every page load for no benefit.
$taxJs = [ordered]@{
  masterTrades = @($taxonomy.masterTrades | ForEach-Object { [ordered]@{ id = $_.id; name = $_.name } })
  divisions    = @($taxonomy.divisions    | ForEach-Object { [ordered]@{ number = $_.number; name = $_.name; masterTrade = $_.masterTrade; reserved = $_.reserved } })
  trades       = @($taxonomy.trades       | ForEach-Object { [ordered]@{ name = $_.name; divisionNumber = $_.divisionNumber; masterTrade = $_.masterTrade } })
}
$taxJsPath = Join-Path $Root 'assets\taxonomy-data.js'
[System.IO.File]::WriteAllText($taxJsPath, ("window.CTD_TAXONOMY = " + ($taxJs | ConvertTo-Json -Depth 5 -Compress) + ";`n"), $utf8)
Write-Host ("  master trades {0} | divisions {1} | trades {2} | subtrades {3}" -f `
    $taxonomy.masterTrades.Count, $taxonomy.divisions.Count, $taxonomy.trades.Count, $taxonomy.subtrades.Count)

# Trade -> "NN – Trade Name". Resolved through the taxonomy workbook, never
# through the vendor workbook's own Hierarchy_Reference sheet: that copy is
# redundant and its twelve "Future Scope" rows arrived with broken characters.
# Trade and division are 1:1 across all 50, so one label carries both
# vocabularies and the sidebar needs one control instead of two (spec 3).
$TRADE_LABEL = @{}
foreach ($t in $taxonomy.trades) {
  $TRADE_LABEL[$t.name] = ("{0} – {1}" -f $t.divisionNumber, $t.name)
}

# ── 2. Vendors ───────────────────────────────────────────────────────────────
Write-Host 'Reading vendor workbook...' -ForegroundColor Cyan
$venDir  = Open-Xlsx $VendorXlsx
$vendors = Read-Sheet $venDir 'Combined_Vendors_1463' 1

# Workbook category label -> site slug. The site's display labels differ for two
# of these (construction-leads shows as "Leads, Bids & Estimates",
# procurement-purchasing as "Back Office Operations") - that mapping lives in
# filters.js CM and is deliberately not duplicated here.
$CAT_SLUG = @{
  'Estimating & Takeoff'     = 'estimating-takeoff'
  'Construction Leads'       = 'construction-leads'
  'CRM & Sales'              = 'crm-sales'
  'Field Service & Dispatch' = 'field-service-dispatch'
  'Project Management'       = 'project-management'
  'Accounting & Payroll'     = 'accounting-payroll'
  'Safety & Compliance'      = 'safety-compliance'
  'Fleet & Equipment'        = 'fleet-equipment'
  'Marketing & Reputation'   = 'marketing-reputation'
  'AI & Automation'          = 'ai-automation'
  'Document Management'      = 'document-management'
  'Procurement & Purchasing' = 'procurement-purchasing'
}

function Get-Domain($url) {
  if ([string]::IsNullOrWhiteSpace($url)) { return '' }
  $u = $url.Trim() -replace '^https?://', '' -replace '^www\.', ''
  return ($u -replace '/.*$', '').Trim()
}

function Get-Slug($seoSlug, $name) {
  $s = $seoSlug.Trim('/')
  if ($s) { return ($s -split '/')[-1] }
  $n = $name.ToLower() -replace '[^a-z0-9]+', '-'
  return $n.Trim('-')
}

$tools = New-Object System.Collections.Generic.List[object]
$missingTrade = 0
$missingMt = 0
$unknownCats = @{}
$slugSeen = @{}

foreach ($v in $vendors) {
  $name = Val $v 'company_name'
  if (-not $name) { continue }

  $catLabel = Val $v 'primary_category'
  $catSlug  = $null
  if ($catLabel -and $CAT_SLUG.ContainsKey($catLabel)) { $catSlug = $CAT_SLUG[$catLabel] }
  elseif ($catLabel) { $unknownCats[$catLabel] = $true }

  # slugs must be unique - vendor-profile.html looks vendors up by ?s=<slug>
  $slug = Get-Slug (Val $v 'seo_slug') $name
  if ($slugSeen.ContainsKey($slug)) {
    $slugSeen[$slug]++
    $slug = "$slug-$($slugSeen[$slug])"
  } else { $slugSeen[$slug] = 1 }

  $desc = Val $v 'company_description'
  if (-not $desc) { $desc = Val $v 'what_it_does' }

  $trades = @()
  $trRaw = Val $v 'trades_served'
  if ($trRaw) { $trades = @($trRaw -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }

  $rankRaw = Val $v 'category_rank'
  $rank = 999
  if ($rankRaw -and [int]::TryParse($rankRaw, [ref]$null)) { $rank = [int]$rankRaw }

  # HX-02 - the client's per-vendor hierarchy. master_trade is taken verbatim;
  # the trade is rendered through the taxonomy so the CSI number and the trade
  # name can never drift apart. A trade the taxonomy doesn't know is a hard
  # error - silently dropping it is how a facet quietly empties.
  $mt = Val $v 'master_trade'
  $pt = Val $v 'primary_trade'
  $dv = ''
  if ($pt) {
    if (-not $TRADE_LABEL.ContainsKey($pt)) { throw "Unknown primary_trade '$pt' on $name (row $(Val $v 'vendor_row_id')) - not in the taxonomy workbook." }
    $dv = $TRADE_LABEL[$pt]
  } else { $missingTrade++ }
  if (-not $mt) { $missingMt++ }

  # HX-03 - "All Sizes / Verify" is the client's internal workflow note, not a
  # size. Strip it so the facet reads cleanly and the Verify rows merge with
  # the plain ones already present.
  $sz = (Val $v 'company_size_served') -replace '\s*/\s*Verify\s*$', ''

  # HX-07 - only real answers cross into the site. free_trial_available is
  # "Unknown / Verify" on 1,402 of 1,463 rows; the vendor page used to print
  # "Free Trial: Yes" for every one of them. Emit it only where the workbook
  # actually knows, and let the page drop the row when it's absent.
  $ftRaw = Val $v 'free_trial_available'
  $ft = ''
  if     ($ftRaw -match '^Yes')          { $ft = 'Yes' }
  elseif ($ftRaw -match '^No')           { $ft = 'No'  }
  # pricing_model is populated for all 1,463 and needs no verification flag,
  # so the page can stop deriving it from company size.
  $pm = Val $v 'pricing_model'

  $rec = [ordered]@{
    n   = $name
    s   = $slug
    d   = Get-Domain (Val $v 'website_url')
    x   = $desc
    c   = @(if ($catSlug) { $catSlug })
    sub = Val $v 'subcategory'
    tr  = $trades
    sz  = $sz
    mt  = $mt
    dv  = $dv
    pm  = $pm
    ft  = $ft
    rk  = $rank
  }
  $tools.Add([pscustomobject]$rec)
}

if ($unknownCats.Count) {
  Write-Warning ("Unmapped primary_category values: " + (($unknownCats.Keys) -join '; '))
}

$json = $tools | ConvertTo-Json -Depth 4 -Compress
$js   = "window.TOOLS = $json;`n"
$outPath = Join-Path $Root 'assets\tools-data.js'
[System.IO.File]::WriteAllText($outPath, $js, $utf8)

# ── 3. Cache-bust every local script and stylesheet ──────────────────────────
# Without this a returning visitor keeps the previously cached asset and still
# sees the old vendor count — or worse, new data running against old filter
# code. Stamping all local .js/.css (not just the data files) means one rule
# covers every asset the pages depend on.
$stamp = Get-Date -Format 'yyyyMMddHHmm'
$stamped = 0
foreach ($page in (Get-ChildItem -Path $Root -Filter '*.html' -File)) {
  $html = [System.IO.File]::ReadAllText($page.FullName)
  $new  = [regex]::Replace($html, '(?<file>assets/[A-Za-z0-9_\-]+\.(?:js|css))(\?v=[0-9]+)?', "`${file}?v=$stamp")
  if ($new -ne $html) {
    [System.IO.File]::WriteAllText($page.FullName, $new, $utf8)
    $stamped++
  }
}

$withDomain = @($tools | Where-Object { $_.d }).Count
$withCat    = @($tools | Where-Object { $_.c.Count -gt 0 }).Count
$withMt     = @($tools | Where-Object { $_.mt }).Count
$withDv     = @($tools | Where-Object { $_.dv }).Count
if ($missingTrade -or $missingMt) { Write-Warning ("Rows without a hierarchy: primary_trade {0}, master_trade {1}" -f $missingTrade, $missingMt) }
Write-Host ''
Write-Host '=== Done ===' -ForegroundColor Green
Write-Host ("  vendors written : {0}" -f $tools.Count)
Write-Host ("  with a domain   : {0}  (no domain: {1})" -f $withDomain, ($tools.Count - $withDomain))
Write-Host ("  with a category : {0}" -f $withCat)
Write-Host ("  with master trd : {0}" -f $withMt)
Write-Host ("  with trade/div  : {0}" -f $withDv)
Write-Host ("  unique slugs    : {0}" -f (@($tools | Select-Object -ExpandProperty s -Unique).Count))
Write-Host ("  cache stamp     : {0}  ({1} pages updated)" -f $stamp, $stamped)
Write-Host ("  -> {0}" -f $outPath)
Write-Host ("  -> {0}" -f $taxPath)

Remove-Item $taxDir, $venDir -Recurse -Force -ErrorAction SilentlyContinue
