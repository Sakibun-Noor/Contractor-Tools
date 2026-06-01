# Parses the DAF Master Taxonomy worksheets into data/taxonomy.json
# Run from repo root: powershell -File build/parse-taxonomy.ps1 -XlsxDir <unzipped xlsx dir>
param(
  [string]$XlsxDir = "$env:TEMP\taxonomy_unzip",
  [string]$OutFile = "$PSScriptRoot\..\data\taxonomy.json"
)

function Get-SheetRows {
  param([string]$Path)
  $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
  $rows = @()
  $rowMatches = [regex]::Matches($raw, '(?s)<row[^>]*>(.*?)</row>')
  foreach ($rm in $rowMatches) {
    $cells = @{}
    $cellMatches = [regex]::Matches($rm.Groups[1].Value, '(?s)<c r="([A-Z]+)\d+"[^>]*>(.*?)</c>')
    foreach ($cm in $cellMatches) {
      $col = $cm.Groups[1].Value
      $inner = $cm.Groups[2].Value
      $t = [regex]::Match($inner, '(?s)<t[^>]*>(.*?)</t>')
      $val = ''
      if ($t.Success) { $val = $t.Groups[1].Value }
      $bullet = [char]0x2022
      $val = $val -replace '&amp;', '&' -replace '&#8226;', $bullet -replace '&lt;', '<' -replace '&gt;', '>' -replace '&#39;', "'" -replace '&quot;', '"'
      $cells[$col] = $val.Trim()
    }
    $rows += ,$cells
  }
  return $rows
}

$ws = Join-Path $XlsxDir 'xl\worksheets'

# ---- Trades (sheet5) ----
# Cols: A Trade_ID, B Parent_Trade_Group, C Primary_CSI_Division, D Trade_Name, E SEO_Keyword_Seeds, F Trade_URL, G Notes
$tradeRows = Get-SheetRows (Join-Path $ws 'sheet5.xml')
$trades = @()
for ($i = 1; $i -lt $tradeRows.Count; $i++) {
  $r = $tradeRows[$i]
  if (-not $r['A']) { continue }
  $url = $r['F']
  $slug = ($url -replace '/trades/', '' -replace '/', '')
  $trades += [ordered]@{
    id      = $r['A']
    group   = $r['B']
    csi     = $r['C']
    name    = $r['D']
    keywords= $r['E']
    slug    = $slug
    url     = $url
  }
}

# ---- Categories + Subcategories (sheet6) ----
# Cols: A Category_ID, B Category_Name, C Subcategory, D Subcategory_ID, E Primary_URL, F Subcategory_URL, G Purpose, H Homepage_Display
$catRows = Get-SheetRows (Join-Path $ws 'sheet6.xml')
$catMap = [ordered]@{}
for ($i = 1; $i -lt $catRows.Count; $i++) {
  $r = $catRows[$i]
  if (-not $r['A']) { continue }
  $cid = $r['A']
  if (-not $catMap.Contains($cid)) {
    $primary = $r['E']
    $slug = ($primary.Trim('/'))
    $catMap[$cid] = [ordered]@{
      id            = $cid
      name          = $r['B']
      slug          = $slug
      url           = $primary
      homepageDisplay = $r['H']
      subcategories = @()
    }
  }
  $subUrl = $r['F']
  $subSlug = ''
  if ($subUrl) { $subSlug = ($subUrl.Trim('/') -split '/')[-1] }
  $catMap[$cid].subcategories += [ordered]@{
    name    = $r['C']
    id      = $r['D']
    slug    = $subSlug
    url     = $subUrl
    purpose = $r['G']
  }
}
$categories = @($catMap.Values)

# ---- Trade x Category Mapping (sheet7) ----
# Cols: A Mapping_ID, B Trade_ID, C Trade_Name, D Category_ID, E Category_Name, F Priority, G SEO_Page_Title, H URL_Slug, I Search_Intent, J Notes
$mapRows = Get-SheetRows (Join-Path $ws 'sheet7.xml')
$mappings = @()
for ($i = 1; $i -lt $mapRows.Count; $i++) {
  $r = $mapRows[$i]
  if (-not $r['A']) { continue }
  $mappings += [ordered]@{
    tradeId    = $r['B']
    tradeName  = $r['C']
    categoryId = $r['D']
    categoryName = $r['E']
    priority   = $r['F']
    title      = $r['G']
    url        = $r['H']
    intent     = $r['I']
  }
}

$out = [ordered]@{
  generatedFrom = 'DAF_Master_Taxonomy_V2'
  categories    = $categories
  trades        = $trades
  tradeCategoryMap = $mappings
}

$json = $out | ConvertTo-Json -Depth 8
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, $json, $utf8NoBom)
Write-Output ("Wrote: " + $OutFile)
Write-Output ("Categories: " + $categories.Count + "  Trades: " + $trades.Count + "  Mappings: " + $mappings.Count)
