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
  [string]$VendorXlsx    = "$env:USERPROFILE\OneDrive\Desktop\CTD\CTD_Combined_Vendor_Master_1463_HIERARCHY_CLASSIFIED.xlsx",
  [string]$TaxonomyXlsx  = "$env:USERPROFILE\Downloads\CTD_Master_Trades_Divisions_Trades_Subtrades (1).xlsx",
  # HX-09 - the client's correction, 2026-09-02. Supersedes $TaxonomyXlsx for
  # everything except the division-number lookup - see the HX-09 block below.
  [string]$HierarchyXlsx = "$env:USERPROFILE\OneDrive\Desktop\CTD\CTD_Construction_Hierarchy_VALIDATED_4_LEVEL.xlsx",
  [string]$Root         = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

foreach ($p in @($VendorXlsx, $TaxonomyXlsx, $HierarchyXlsx)) {
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
$trades       = Read-Sheet $taxDir 'TRADES'        2

# HX-09 - correction, 2026-09-02. CTD_Construction_Hierarchy_VALIDATED_4_LEVEL
# supersedes the workbook above for everything except one lookup (below): its
# own DEVELOPER_NOTES Rule 6 states "the former 1,000 synthetic Trade rows
# must not be imported into production", and its 12 Master Trades replace the
# 11 above - several renamed, two split apart (old "Mechanical" -> Plumbing /
# HVAC & Mechanical; old "Electrical & Technology" -> Electrical /
# Communications & Security). See specs/hierarchy-import.md HX-09.
Write-Host 'Reading validated hierarchy workbook...' -ForegroundColor Cyan
$hierDir        = Open-Xlsx $HierarchyXlsx
$masterTrades12 = Read-Sheet $hierDir 'MASTER_TRADES' 2
$divisions50    = Read-Sheet $hierDir 'DIVISIONS'     2

$taxonomy = [ordered]@{
  generatedFrom = [System.IO.Path]::GetFileName($HierarchyXlsx)
  generatedAt   = (Get-Date -Format 'yyyy-MM-dd')
  note          = 'Master Trade > Division, validated. Trade/Subtrade await a licensed MasterFormat 2026 dataset - see HX-09.'
  masterTrades  = @($masterTrades12 | ForEach-Object {
      [ordered]@{
        id          = [int](Val $_ 'Master Trade #')
        name        = (Val $_ 'Master Trade')
        description = (Val $_ 'Description')
      } })
  divisions     = @($divisions50 | ForEach-Object {
      [ordered]@{
        number        = (Val $_ 'Division #')
        name          = (Val $_ 'Division')
        masterTradeId = [int](Val $_ 'Master Trade #')
        masterTrade   = (Val $_ 'Master Trade')
        reserved      = ((Val $_ 'Status') -like '*Reserved*')
      } })
}

$taxPath = Join-Path $Root 'data\construction-taxonomy.json'
[System.IO.File]::WriteAllText($taxPath, ($taxonomy | ConvertTo-Json -Depth 6), $utf8)

# Browser-side copy for the facet lists.
$taxJs = [ordered]@{
  masterTrades = @($taxonomy.masterTrades | ForEach-Object { [ordered]@{ id = $_.id; name = $_.name } })
  divisions    = @($taxonomy.divisions    | ForEach-Object { [ordered]@{ number = $_.number; name = $_.name; masterTrade = $_.masterTrade; reserved = $_.reserved } })
}
$taxJsPath = Join-Path $Root 'assets\taxonomy-data.js'
[System.IO.File]::WriteAllText($taxJsPath, ("window.CTD_TAXONOMY = " + ($taxJs | ConvertTo-Json -Depth 5 -Compress) + ";`n"), $utf8)
Write-Host ("  master trades {0} | divisions {1}" -f $taxonomy.masterTrades.Count, $taxonomy.divisions.Count)

# The one thing still read from the retired workbook: which division number a
# vendor's primary_trade value belongs to. That's arithmetic, not vocabulary -
# each of the old 50 "trade" rows names exactly one division - and is
# independent of the synthetic Trade list Rule 6 retires; it is never exposed
# to the site. Division number -> official name/master trade both come from
# the validated workbook, never from this one.
$TRADE_DIV = @{}
foreach ($t in $trades) { $TRADE_DIV[(Val $t 'trade_name')] = (Val $t 'division_number') }

$DIV_NAME = @{}
$DIV_MT   = @{}
foreach ($d in $taxonomy.divisions) { $DIV_NAME[$d.number] = $d.name; $DIV_MT[$d.number] = $d.masterTrade }

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

  # HX-02/HX-09 - the client's per-vendor hierarchy, at division granularity.
  # dv is resolved through the division-number lookup then rendered with the
  # validated workbook's official name, so the CSI number and the name can
  # never drift apart. mt is recomputed from that same division number
  # against the validated 12 Master Trades - the vendor workbook's own
  # master_trade column is not used; it still carries the old 11-name
  # taxonomy HX-09 retires. A primary_trade the lookup doesn't know is a hard
  # error - silently dropping it is how a facet quietly empties.
  $pt = Val $v 'primary_trade'
  $dv = ''
  $mt = ''
  if ($pt) {
    if (-not $TRADE_DIV.ContainsKey($pt)) { throw "Unknown primary_trade '$pt' on $name (row $(Val $v 'vendor_row_id')) - not in the taxonomy workbook." }
    $divNum = $TRADE_DIV[$pt]
    if (-not $DIV_NAME.ContainsKey($divNum)) { throw "Division '$divNum' (from primary_trade '$pt' on $name) not in the validated hierarchy workbook." }
    $dv = ("{0} – {1}" -f $divNum, $DIV_NAME[$divNum])
    $mt = $DIV_MT[$divNum]
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

Remove-Item $taxDir, $hierDir, $venDir -Recurse -Force -ErrorAction SilentlyContinue
