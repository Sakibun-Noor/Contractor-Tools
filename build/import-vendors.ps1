# ─────────────────────────────────────────────────────────────────────────────
# CTD — import the merged vendor/product database (real multi-product vendors,
# CSI-coded Master Groups > Divisions > Trades, and Market Sector).
#
# Reads:  CTD_Complete_Vendor_Product_Database_1_1381.xlsx (client data, not in
#         this repo — see CTD-product-db/out/), the vendor biographies workbook
#         (CTD-product-db/inputs/, 2026-09-20 client round — one ~100-word bio
#         per Vendor_ID, joined in by that ID), plus the *current*
#         assets/tools-data.js, to carry forward the three fields neither
#         database contains (Company Size, Pricing Model, Free Trial) by domain
#         match. Description (t.x) now comes from the biography workbook first,
#         falling back to the old carried-forward value only when a vendor has
#         no biography.
# Writes: assets/tools-data.js        window.TOOLS, one record per company
#         assets/taxonomy-data.js     Master Groups / Divisions / Market Sectors
#
# Supersedes the HX-01..HX-09 hierarchy-classified workbook import
# (specs/hierarchy-import.md) — that data model (one row = one product = one
# company, single mt/dv/sub) is retired. See specs/product-db-site-integration-
# 2026-09-19.md for the full plan and the decisions this script implements.
#
# Re-runnable: always regenerates both outputs from scratch. When a newer
# merged database arrives, drop it in and re-run — do not hand-edit the
# outputs.
#
# Run: powershell -ExecutionPolicy Bypass -File build\import-vendors.ps1
# ─────────────────────────────────────────────────────────────────────────────
param(
  [string]$VendorDbXlsx  = "$env:USERPROFILE\Desktop\Claude\CTD-product-db\out\CTD_Complete_Vendor_Product_Database_1_1381.xlsx",
  [string]$BiographyXlsx = "$env:USERPROFILE\Desktop\Claude\CTD-product-db\inputs\09.20.26_CTD_Vendor_Biographies_RECONCILED_1381.xlsx",
  [string]$ContactXlsx   = "$env:USERPROFILE\Desktop\Claude\CTD-product-db\inputs\09.25.26_CTD_Vendor_Contact_Directory_FINAL.xlsx",
  [string]$Root          = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path $VendorDbXlsx)) { throw "Missing workbook: $VendorDbXlsx" }

# ── xlsx reading (unchanged from the prior importer — generic zip/XML reader,
#    no client-specific logic lives here) ────────────────────────────────────
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
    if ($target.StartsWith('/')) { return (Join-Path $dir $target.TrimStart('/').Replace('/', '\')) }
    return (Join-Path $dir ('xl\' + $target.Replace('/', '\')))
  }
  throw "Could not resolve relationship $rid"
}

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

# ── Deryck's final 12-category mapping (CTD_12_Categories_Subcategories_
#    Tooltips.docx, 2026-09-19) — every one of the 77 subcategories, keyed by
#    Subcategory_ID, mapped to the category slug that survives. Specialty
#    Solutions (the former 13th category) is retired; its six subcategories
#    are folded into the categories below (see product-db-site-integration-
#    2026-09-19.md §3a). This table is the single source of truth for the
#    remap — it replaces PRODUCT_CATEGORY, which still encodes the old
#    13-category assignment. ─────────────────────────────────────────────────
$SUBCAT_TO_CAT_SLUG = @{
  10 = 'project-management'; 11 = 'project-management'; 16 = 'project-management'
  24 = 'project-management'; 48 = 'project-management'; 77 = 'project-management'

  3 = 'ai-automation'; 4 = 'ai-automation'; 6 = 'ai-automation'; 29 = 'ai-automation'
  46 = 'ai-automation'; 71 = 'ai-automation'; 76 = 'ai-automation'

  9 = 'safety-compliance'; 12 = 'safety-compliance'; 32 = 'safety-compliance'
  33 = 'safety-compliance'; 56 = 'safety-compliance'; 66 = 'safety-compliance'

  13 = 'estimating-takeoff'; 23 = 'estimating-takeoff'; 52 = 'estimating-takeoff'
  61 = 'estimating-takeoff'; 65 = 'estimating-takeoff'

  5 = 'fleet-equipment'; 20 = 'fleet-equipment'; 26 = 'fleet-equipment'
  31 = 'fleet-equipment'; 40 = 'fleet-equipment'; 63 = 'fleet-equipment'

  1 = 'accounting-payroll'; 21 = 'accounting-payroll'; 35 = 'accounting-payroll'
  36 = 'accounting-payroll'; 44 = 'accounting-payroll'; 64 = 'accounting-payroll'

  34 = 'procurement-purchasing'; 43 = 'procurement-purchasing'; 47 = 'procurement-purchasing'
  51 = 'procurement-purchasing'; 60 = 'procurement-purchasing'; 67 = 'procurement-purchasing'

  18 = 'document-management'; 19 = 'document-management'; 22 = 'document-management'
  25 = 'document-management'; 28 = 'document-management'; 68 = 'document-management'
  73 = 'document-management'; 74 = 'document-management'; 75 = 'document-management'

  17 = 'field-service-dispatch'; 55 = 'field-service-dispatch'; 58 = 'field-service-dispatch'
  59 = 'field-service-dispatch'; 62 = 'field-service-dispatch'; 70 = 'field-service-dispatch'
  72 = 'field-service-dispatch'

  14 = 'crm-sales'; 15 = 'crm-sales'; 27 = 'crm-sales'; 38 = 'crm-sales'
  50 = 'crm-sales'; 57 = 'crm-sales'

  7 = 'construction-leads'; 8 = 'construction-leads'; 30 = 'construction-leads'
  37 = 'construction-leads'; 41 = 'construction-leads'; 45 = 'construction-leads'
  49 = 'construction-leads'

  2 = 'marketing-reputation'; 39 = 'marketing-reputation'; 42 = 'marketing-reputation'
  53 = 'marketing-reputation'; 54 = 'marketing-reputation'; 69 = 'marketing-reputation'
}

# On-screen category names. Slugs are the site's existing URL/filter keys and
# stay unchanged even where Deryck renamed the category (confirmed via his own
# ChatGPT check, screenshotted 2026-09-19: keep old links, change only the
# displayed name).
$CAT_NAME = [ordered]@{
  'project-management'      = 'Project Management'
  'ai-automation'            = 'AI & Automation'
  'safety-compliance'        = 'Safety & Compliance'
  'estimating-takeoff'       = 'Estimating & Takeoff'
  'fleet-equipment'          = 'Fleet & Equipment'
  'accounting-payroll'       = 'Finance & Payroll'
  'procurement-purchasing'   = 'Procurement'
  'document-management'      = 'BIM & Documents'
  'field-service-dispatch'   = 'Field Operations'
  'crm-sales'                = 'CRM & Sales'
  'construction-leads'       = 'Leads & Bids'
  'marketing-reputation'     = 'Marketing & Reputation'
}

function Normalize-Name($s) {
  if (-not $s) { return '' }
  return ([string]$s).ToLower() -replace '[^a-z0-9]', ''
}

function Get-Domain($url) {
  if ([string]::IsNullOrWhiteSpace($url)) { return '' }
  $u = $url.Trim() -replace '^https?://', '' -replace '^www\.', ''
  return ($u -replace '/.*$', '').Trim().ToLower()
}

function Get-Slug($name) {
  $n = $name.ToLower() -replace '[^a-z0-9]+', '-'
  return $n.Trim('-')
}

# ── 1. Read the merged database ──────────────────────────────────────────────
Write-Host 'Reading merged vendor/product database...' -ForegroundColor Cyan
$dbDir = Open-Xlsx $VendorDbXlsx

$subRows   = Read-Sheet $dbDir 'SUBCATEGORIES_NORM'   1
$vendRows  = Read-Sheet $dbDir 'VENDORS_NORM'         1
$prodRows  = Read-Sheet $dbDir 'PRODUCTS_NORM'        1
$pSubRows  = Read-Sheet $dbDir 'PRODUCT_SUBCATEGORY'  1
$mgRows    = Read-Sheet $dbDir 'MASTER_GROUPS_NORM'   1
$pMgRows   = Read-Sheet $dbDir 'PRODUCT_MASTER_GROUP' 1
$divRows   = Read-Sheet $dbDir 'DIVISIONS_NORM'       1
$pDivRows  = Read-Sheet $dbDir 'PRODUCT_DIVISION'     1
$trdRows   = Read-Sheet $dbDir 'TRADES_NORM'          1
$pTrdRows  = Read-Sheet $dbDir 'PRODUCT_TRADE'        1
$msRows    = Read-Sheet $dbDir 'MARKET_SECTORS_NORM'  1
$vMsRows   = Read-Sheet $dbDir 'VENDOR_MARKET_SECTOR' 1

Write-Host ("  vendors {0} | products {1}" -f $vendRows.Count, $prodRows.Count)

# ── 1b. Read the vendor biographies (2026-09-20 client round) — one ~100-word
#      company bio per original Vendor_ID, keyed the same way the merged
#      database is (V0001..V1381). Only COMPLETE ones carry text; 62 of 1381
#      are BLANK (unverifiable source) and are skipped, same as a missing field
#      anywhere else on this site. ─────────────────────────────────────────────
$bioByVendorId = @{}
if (Test-Path $BiographyXlsx) {
  Write-Host 'Reading vendor biographies...' -ForegroundColor Cyan
  $bioDir = Open-Xlsx $BiographyXlsx
  $bioRows = Read-Sheet $bioDir 'VENDOR_BIOGRAPHIES' 1
  foreach ($r in $bioRows) {
    $vid = Val $r 'Vendor_ID'
    $bio = Val $r 'Biography_100_Words'
    if ($vid -and $bio) { $bioByVendorId[$vid] = $bio }
  }
  Write-Host ("  biographies available: {0}" -f $bioByVendorId.Count)
} else {
  Write-Host "  no biography workbook found at $BiographyXlsx - skipping (t.x falls back to prior carry-forward)" -ForegroundColor Yellow
}

# ── 1c. Read the vendor contact directory (2026-09-25 client file) — published
#      business contact details per Vendor_ID (office city/state, phone, email,
#      the official page they came from). Only what the client verified is
#      present; blanks stay blank. ───────────────────────────────────────────
$contactByVendorId = @{}
if (Test-Path $ContactXlsx) {
  Write-Host 'Reading vendor contact directory...' -ForegroundColor Cyan
  $ctDir = Open-Xlsx $ContactXlsx
  foreach ($r in (Read-Sheet $ctDir 'VENDOR_CONTACT_DIRECTORY' 1)) {
    $vid = Val $r 'Vendor_ID'
    if (-not $vid) { continue }
    $c = [ordered]@{
      city = (Val $r 'Office_City'); st = (Val $r 'State_Province')
      ph   = (Val $r 'Business_Phone'); em = (Val $r 'Business_Email')
      src  = (Val $r 'Contact_Source_URL')
    }
    if ($c.city -or $c.st -or $c.ph -or $c.em) { $contactByVendorId[$vid] = $c }
  }
  Write-Host ("  vendors with contact details: {0}" -f $contactByVendorId.Count)
} else {
  Write-Host "  no contact workbook found at $ContactXlsx - skipping" -ForegroundColor Yellow
}

# ── 2. Lookups ────────────────────────────────────────────────────────────────
$SUB_NAME = @{}
foreach ($r in $subRows) { $SUB_NAME[[int](Val $r 'Subcategory_ID')] = (Val $r 'Subcategory_Name') }

$MG_NAME = @{}
foreach ($r in $mgRows) { $MG_NAME[[int](Val $r 'master_group_id')] = (Val $r 'master_group_name') }

# En dash built from its code point, not typed literally — a literal
# non-ASCII character in this .ps1 source file gets misread through the
# system codepage (Windows PowerShell 5.1 has no way to know this file is
# UTF-8 without a BOM) and silently corrupts into mojibake in the output.
$ENDASH = [char]0x2013

$DIV_LABEL = @{}
foreach ($r in $divRows) {
  $id = [int](Val $r 'division_id')
  $DIV_LABEL[$id] = (Val $r 'CSI_Division_Number') + ' ' + $ENDASH + ' ' + (Val $r 'division_name')
}

$TRD_LABEL = @{}
foreach ($r in $trdRows) {
  $id = [int](Val $r 'trade_id')
  $TRD_LABEL[$id] = (Val $r 'CSI_Trade_Number') + ' ' + $ENDASH + ' ' + (Val $r 'trade_name')
}

$MS_NAME = @{}
foreach ($r in $msRows) { $MS_NAME[[int](Val $r 'market_sector_id')] = (Val $r 'market_sector_name') }

# Missing-mapping check — fail loudly rather than silently drop a subcategory.
$missingSubcatMap = @($subRows | Where-Object { -not $SUBCAT_TO_CAT_SLUG.ContainsKey([int](Val $_ 'Subcategory_ID')) })
if ($missingSubcatMap.Count) {
  throw ("Subcategories with no category mapping: " + (($missingSubcatMap | ForEach-Object { Val $_ 'Subcategory_Name' }) -join ', '))
}

# Product-level junctions -> arrays of IDs, keyed by Vendor_Product_ID.
function Build-Junction($rows, $vpKey, $idKey) {
  $out = @{}
  foreach ($r in $rows) {
    $vp = Val $r $vpKey
    if (-not $vp) { continue }
    $id = [int](Val $r $idKey)
    if (-not $out.ContainsKey($vp)) { $out[$vp] = New-Object System.Collections.Generic.List[int] }
    $out[$vp].Add($id)
  }
  return $out
}
$vpSubIds = Build-Junction $pSubRows 'Vendor_Product_ID' 'Subcategory_ID'
$vpMgIds  = Build-Junction $pMgRows  'Vendor_Product_ID' 'Master_Group_ID'
$vpDivIds = Build-Junction $pDivRows 'Vendor_Product_ID' 'Division_ID'
$vpTrdIds = Build-Junction $pTrdRows 'Vendor_Product_ID' 'Trade_ID'

# Vendor-level Market Sector junction, keyed by Vendor_ID (not Vendor_Product_ID
# — this is a company-level fact, not a per-product one).
$vidMsIds = @{}
foreach ($r in $vMsRows) {
  $vid = Val $r 'Vendor_ID'
  if (-not $vid) { continue }
  $id = [int](Val $r 'Market_Sector_ID')
  if (-not $vidMsIds.ContainsKey($vid)) { $vidMsIds[$vid] = New-Object System.Collections.Generic.List[int] }
  $vidMsIds[$vid].Add($id)
}

# ── 3. Carry forward the four fields the new database does not have
#      (Company Size, Pricing Model, Free Trial, Description), plus the old
#      contractor-type array and rank, by domain match against the *current*
#      tools-data.js — see product-db-site-integration-2026-09-19.md §6. ─────
$oldByDomain = @{}
$oldToolsPath = Join-Path $Root 'assets\tools-data.js'
if (Test-Path $oldToolsPath) {
  $oldText = [System.IO.File]::ReadAllText($oldToolsPath)
  $oldJson = $oldText -replace '^\s*window\.TOOLS\s*=\s*', '' -replace ';\s*$', ''
  if ($oldJson.Trim()) {
    $oldTools = $oldJson | ConvertFrom-Json
    foreach ($o in $oldTools) {
      $d = ([string]$o.d).ToLower()
      if ($d -and -not $oldByDomain.ContainsKey($d)) { $oldByDomain[$d] = $o }
    }
  }
}
Write-Host ("  prior site data available for carry-forward: {0} domains" -f $oldByDomain.Count)

# ── 4. Vendor identity + Vendor_ID -> row lookup ─────────────────────────────
$vendorById = @{}
foreach ($v in $vendRows) { $vendorById[(Val $v 'Vendor_ID')] = $v }

function VendorNum($vid) {
  $n = 0
  [void][int]::TryParse(($vid -replace '\D', ''), [ref]$n)
  return $n
}

# ── 5. Group products by normalized Parent_Vendor (a company may span several
#      Vendor_IDs — e.g. Autodesk's 13 acquired products each got their own
#      Vendor_ID in the original audit). See §4 of the spec for why. ─────────
$groups = [ordered]@{}
foreach ($p in $prodRows) {
  $parent = Val $p 'Parent_Vendor'
  if (-not $parent) { $parent = Val $p 'Vendor_Name' }
  $key = Normalize-Name $parent
  if (-not $groups.Contains($key)) { $groups[$key] = New-Object System.Collections.Generic.List[hashtable] }
  $groups[$key].Add($p)
}

$tools = New-Object System.Collections.Generic.List[object]
$slugSeen = @{}
$withProducts = 0
$withNewBio = 0
$withContact = 0

foreach ($key in $groups.Keys) {
  $rows = $groups[$key]

  # Canonical identity = the row belonging to the lowest Vendor_ID in the
  # group (CTD's own "first-seen" convention from the audit) — but for the
  # domain, use whichever domain is *most common* across the group. A
  # company acquired piecemeal (Autodesk: 15 Vendor_IDs) often has its own
  # domain on most rows but a legacy/acquired-product domain (e.g.
  # proest.com) on the single lowest-numbered one; picking by frequency
  # instead of "first" avoids surfacing the wrong company website.
  $canon = $rows | Sort-Object { VendorNum (Val $_ 'Vendor_ID') } | Select-Object -First 1
  $name = Val $canon 'Parent_Vendor'
  if (-not $name) { $name = Val $canon 'Vendor_Name' }

  $vendorIdsInGroup = @($rows | ForEach-Object { Val $_ 'Vendor_ID' } | Select-Object -Unique)
  $domainCounts = @{}
  foreach ($vid in $vendorIdsInGroup) {
    $vv = $vendorById[$vid]
    if (-not $vv) { continue }
    $d = Get-Domain (Val $vv 'Normalized_Domain')
    if ($d) { $domainCounts[$d] = ($domainCounts[$d] + 1) }
  }
  $domain = ''
  if ($domainCounts.Count -gt 0) {
    $domain = ($domainCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key
  }

  # Biography — same "which Vendor_ID actually represents this company"
  # question as the domain above, so the same answer: prefer whichever
  # Vendor_ID's own domain matches the canonical domain (that's the one
  # actually describing the live site), then fall back to the canon row's
  # own Vendor_ID, then to any bio present in the group at all.
  $bio = ''
  foreach ($vid in $vendorIdsInGroup) {
    $vv = $vendorById[$vid]
    if ($vv -and $domain -and (Get-Domain (Val $vv 'Normalized_Domain')) -eq $domain -and $bioByVendorId.ContainsKey($vid)) {
      $bio = $bioByVendorId[$vid]; break
    }
  }
  if (-not $bio) {
    $canonVid = Val $canon 'Vendor_ID'
    if ($bioByVendorId.ContainsKey($canonVid)) { $bio = $bioByVendorId[$canonVid] }
  }
  if (-not $bio) {
    foreach ($vid in ($vendorIdsInGroup | Sort-Object { VendorNum $_ })) {
      if ($bioByVendorId.ContainsKey($vid)) { $bio = $bioByVendorId[$vid]; break }
    }
  }

  # Contact — same "which Vendor_ID represents this company" rule: among the
  # group's Vendor_IDs that have contact details, prefer the one whose domain
  # matches the canonical domain, then the one with the most fields filled,
  # then the lowest Vendor_ID.
  $contact = $null
  $cands = @($vendorIdsInGroup | Where-Object { $contactByVendorId.ContainsKey($_) } | ForEach-Object {
    $cv = $contactByVendorId[$_]
    $vv2 = $vendorById[$_]
    $match = if ($vv2 -and $domain -and (Get-Domain (Val $vv2 'Normalized_Domain')) -eq $domain) { 1 } else { 0 }
    $n = @($cv.city, $cv.st, $cv.ph, $cv.em | Where-Object { $_ }).Count
    [pscustomobject]@{ id = $_; match = $match; n = $n; num = (VendorNum $_) }
  })
  if ($cands.Count -gt 0) {
    $best = $cands | Sort-Object @{Expression='match';Descending=$true}, @{Expression='n';Descending=$true}, @{Expression='num';Descending=$false} | Select-Object -First 1
    $contact = $contactByVendorId[$best.id]
    $withContact++
  }

  $catSlugs = New-Object System.Collections.Generic.HashSet[string]
  $subNames = New-Object System.Collections.Generic.HashSet[string]
  $mgNames  = New-Object System.Collections.Generic.HashSet[string]
  $divLbls  = New-Object System.Collections.Generic.HashSet[string]
  $trdLbls  = New-Object System.Collections.Generic.HashSet[string]
  $products = New-Object System.Collections.Generic.List[object]
  $productNamesSeen = New-Object System.Collections.Generic.HashSet[string]

  foreach ($p in $rows) {
    $vp = Val $p 'Vendor_Product_ID'
    $pname = Val $p 'Product_Name'
    # LEGACY_DUPLICATES (see the merge spec) — the original ChatGPT-authored
    # segments repeat the same product under more than one Vendor_ID for the
    # same company (e.g. Autodesk's V0039 and V0049 both list an identical
    # 20-product list). The underlying database rows are left alone (that
    # cleanup is a separate, still-open decision), but the site must not
    # visibly show "ProEst, ProEst" or double a vendor's product count.
    if ($pname -and $productNamesSeen.Add((Normalize-Name $pname))) {
      $products.Add([ordered]@{ n = $pname; u = (Val $p 'Source_URL') })
    }

    if ($vpSubIds.ContainsKey($vp)) {
      foreach ($sid in $vpSubIds[$vp]) {
        if ($SUB_NAME.ContainsKey($sid)) { [void]$subNames.Add($SUB_NAME[$sid]) }
        if ($SUBCAT_TO_CAT_SLUG.ContainsKey($sid)) { [void]$catSlugs.Add($SUBCAT_TO_CAT_SLUG[$sid]) }
      }
    }
    if ($vpMgIds.ContainsKey($vp)) {
      foreach ($id in $vpMgIds[$vp]) { if ($MG_NAME.ContainsKey($id)) { [void]$mgNames.Add($MG_NAME[$id]) } }
    }
    if ($vpDivIds.ContainsKey($vp)) {
      foreach ($id in $vpDivIds[$vp]) { if ($DIV_LABEL.ContainsKey($id)) { [void]$divLbls.Add($DIV_LABEL[$id]) } }
    }
    if ($vpTrdIds.ContainsKey($vp)) {
      foreach ($id in $vpTrdIds[$vp]) { if ($TRD_LABEL.ContainsKey($id)) { [void]$trdLbls.Add($TRD_LABEL[$id]) } }
    }
  }

  $mktNames = New-Object System.Collections.Generic.HashSet[string]
  foreach ($vid in $vendorIdsInGroup) {
    if ($vidMsIds.ContainsKey($vid)) {
      foreach ($id in $vidMsIds[$vid]) { if ($MS_NAME.ContainsKey($id)) { [void]$mktNames.Add($MS_NAME[$id]) } }
    }
  }

  # slug — unique, dedupe collisions the way the prior importer did
  $slug = Get-Slug $name
  if ($slugSeen.ContainsKey($slug)) { $slugSeen[$slug]++; $slug = "$slug-$($slugSeen[$slug])" }
  else { $slugSeen[$slug] = 1 }

  $old = $null
  if ($domain -and $oldByDomain.ContainsKey($domain)) { $old = $oldByDomain[$domain] }

  $oldX  = ''; $oldSz = ''; $oldPm = ''; $oldFt = ''; $oldRk = 999
  $oldTr = New-Object System.Collections.Generic.List[string]
  if ($old) {
    if ($old.x)  { $oldX  = [string]$old.x }
    if ($old.sz) { $oldSz = [string]$old.sz }
    if ($old.pm) { $oldPm = [string]$old.pm }
    if ($old.ft) { $oldFt = [string]$old.ft }
    if ($old.rk) { $oldRk = [int]$old.rk }
    if ($old.tr) { foreach ($v in @($old.tr)) { $oldTr.Add([string]$v) } }
  }

  if ($products.Count -gt 0) { $withProducts++ }

  # 2026-09-20 client round: the new official biography (verified against the
  # vendor's own site) supersedes the old carry-forward-by-domain description,
  # which was a weaker prior-site value covering far fewer vendors.
  $descX = if ($bio) { $bio } else { $oldX }
  if ($bio) { $withNewBio++ }

  $rec = [ordered]@{
    n        = $name
    s        = $slug
    d        = $domain
    x        = $descX
    c        = [string[]]$catSlugs
    subs     = [string[]]$subNames
    tr       = $oldTr.ToArray()
    mt       = [string[]]$mgNames
    dv       = [string[]]$divLbls
    trd      = [string[]]$trdLbls
    mkt      = [string[]]$mktNames
    products = $products.ToArray()
    sz       = $oldSz
    pm       = $oldPm
    ft       = $oldFt
    rk       = $oldRk
  }
  if ($contact) { $rec['ci'] = $contact }
  $tools.Add([pscustomobject]$rec)
}

$json = $tools | ConvertTo-Json -Depth 6 -Compress
$js   = "window.TOOLS = $json;`n"
$outPath = Join-Path $Root 'assets\tools-data.js'
[System.IO.File]::WriteAllText($outPath, $js, $utf8)

# ── 6. Taxonomy — Master Groups, Divisions, Market Sectors. Full canonical
#      lists (including the ALL/wildcard row, a real filterable value in this
#      database) so an unused value still renders disabled at 0 rather than
#      vanishing — same "Fire Protection -> 0" precedent as before. Trades
#      (425 rows) are not injected wholesale; the facet is built from live
#      data only, same as Division/Master Group were before HX-09 arrived —
#      a fixed 425-checkbox list would not be usable UI. ────────────────────
$taxonomy = [ordered]@{
  generatedFrom = [System.IO.Path]::GetFileName($VendorDbXlsx)
  generatedAt   = (Get-Date -Format 'yyyy-MM-dd')
  note          = 'Master Groups / Divisions / Market Sectors, complete. Trades are CSI-coded and real (t.trd) but built from live data only, not injected as a fixed list - see product-db-site-integration-2026-09-19.md.'
  masterGroups  = @($mgRows | ForEach-Object { [ordered]@{ id = [int](Val $_ 'master_group_id'); name = (Val $_ 'master_group_name') } } | Sort-Object id)
  divisions     = @($divRows | ForEach-Object { [ordered]@{ id = [int](Val $_ 'division_id'); number = (Val $_ 'CSI_Division_Number'); name = (Val $_ 'division_name'); masterGroup = (Val $_ 'master_group_name') } } | Sort-Object id)
  marketSectors = @($msRows | ForEach-Object { [ordered]@{ id = [int](Val $_ 'market_sector_id'); name = (Val $_ 'market_sector_name') } } | Sort-Object id)
}
$taxJsPath = Join-Path $Root 'assets\taxonomy-data.js'
[System.IO.File]::WriteAllText($taxJsPath, ("window.CTD_TAXONOMY = " + ($taxonomy | ConvertTo-Json -Depth 5 -Compress) + ";`n"), $utf8)

# ── 7. Cache-bust every local script and stylesheet ──────────────────────────
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

# ── 8. Report ─────────────────────────────────────────────────────────────
$withDomain  = @($tools | Where-Object { $_.d }).Count
$withCat     = @($tools | Where-Object { $_.c.Count -gt 0 }).Count
$withMt      = @($tools | Where-Object { $_.mt.Count -gt 0 }).Count
$withDv      = @($tools | Where-Object { $_.dv.Count -gt 0 }).Count
$withTrd     = @($tools | Where-Object { $_.trd.Count -gt 0 }).Count
$withMkt     = @($tools | Where-Object { $_.mkt.Count -gt 0 }).Count
$withCarried = @($tools | Where-Object { $_.x }).Count
$multiProd   = @($tools | Where-Object { $_.products.Count -gt 1 }).Count

Write-Host ''
Write-Host '=== Done ===' -ForegroundColor Green
Write-Host ("  companies written    : {0}  (grouped from {1} product rows)" -f $tools.Count, $prodRows.Count)
Write-Host ("  with 2+ products     : {0}" -f $multiProd)
Write-Host ("  with a domain        : {0}" -f $withDomain)
Write-Host ("  with a category      : {0}" -f $withCat)
Write-Host ("  with master group    : {0}" -f $withMt)
Write-Host ("  with division        : {0}" -f $withDv)
Write-Host ("  with real trade      : {0}" -f $withTrd)
Write-Host ("  with market sector   : {0}" -f $withMkt)
Write-Host ("  with new biography   : {0}  (2026-09-20 client round, by Vendor_ID)" -f $withNewBio)
Write-Host ("  with contact details : {0}  (2026-09-25 client file, by Vendor_ID)" -f $withContact)
Write-Host ("  with any description : {0}  (new biography, else prior carry-forward)" -f $withCarried)
Write-Host ("  unique slugs         : {0}" -f (@($tools | Select-Object -ExpandProperty s -Unique).Count))
Write-Host ("  cache stamp          : {0}  ({1} pages updated)" -f $stamp, $stamped)
Write-Host ("  -> {0}" -f $outPath)
Write-Host ("  -> {0}" -f $taxJsPath)

Remove-Item $dbDir -Recurse -Force -ErrorAction SilentlyContinue
if ($bioDir) { Remove-Item $bioDir -Recurse -Force -ErrorAction SilentlyContinue }
if ($ctDir) { Remove-Item $ctDir -Recurse -Force -ErrorAction SilentlyContinue }
