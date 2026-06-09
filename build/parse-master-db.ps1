# ─────────────────────────────────────────────────────────────────────────────
# Parse the master company DB (with Divisions) + real descriptions
#   IN : CT Files\1Final2 Contractor Technology Directory with Divisions (2).xlsx (Master DB sheet)
#        CT Files\CategoryX_Company_Descriptions_Draft.xlsx (real descriptions)
#   OUT: data\companies.json  (flat, NO revenue fields ever)
#
# PRIVACY: Revenue columns are INTERNAL ONLY. They are never written to output.
# ─────────────────────────────────────────────────────────────────────────────
param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path,
  [string]$CtFiles = (Resolve-Path "$PSScriptRoot\..\..\CT Files").Path
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Unzip-Xlsx($xlsx) {
  $tmp = Join-Path $env:TEMP ("xl_" + [Guid]::NewGuid().ToString("N").Substring(0,8))
  New-Item -ItemType Directory $tmp | Out-Null
  Copy-Item $xlsx "$tmp\f.zip"
  Expand-Archive "$tmp\f.zip" "$tmp\x" -Force
  return "$tmp\x"
}
function Get-SharedStrings($xlDir) {
  $p = "$xlDir\xl\sharedStrings.xml"
  $arr = @()
  if (Test-Path $p) {
    $raw = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
    foreach ($si in [regex]::Matches($raw, '(?s)<si>(.*?)</si>')) {
      $txt = -join ([regex]::Matches($si.Groups[1].Value, '(?s)<t[^>]*>(.*?)</t>') | ForEach-Object { $_.Groups[1].Value })
      $arr += $txt
    }
  }
  return ,$arr
}
function Get-Rows($sheetPath, $shared) {
  $raw = [System.IO.File]::ReadAllText($sheetPath, [System.Text.Encoding]::UTF8)
  $rows = @()
  foreach ($rm in [regex]::Matches($raw, '(?s)<row[^>]*>(.*?)</row>')) {
    $cells = @{}; $maxCol = 0
    foreach ($cm in [regex]::Matches($rm.Groups[1].Value, '(?s)<c r="([A-Z]+)\d+"([^>]*)>(.*?)</c>')) {
      $col = $cm.Groups[1].Value; $attr = $cm.Groups[2].Value; $inner = $cm.Groups[3].Value
      $val = ''
      if ($attr -match 't="s"') {
        $v = [regex]::Match($inner, '(?s)<v>(.*?)</v>')
        if ($v.Success) { $i=[int]$v.Groups[1].Value; if ($i -lt $shared.Count) { $val = $shared[$i] } }
      } else {
        $t = [regex]::Match($inner, '(?s)<t[^>]*>(.*?)</t>')
        if ($t.Success) { $val = $t.Groups[1].Value }
        else { $v = [regex]::Match($inner, '(?s)<v>(.*?)</v>'); if ($v.Success) { $val = $v.Groups[1].Value } }
      }
      $val = $val -replace '&amp;','&' -replace '&lt;','<' -replace '&gt;','>' -replace '&#39;',"'" -replace '&quot;','"'
      $idx = 0; foreach ($ch in $col.ToCharArray()) { $idx = $idx*26 + ([int]$ch - 64) }
      $cells[$idx] = $val; if ($idx -gt $maxCol) { $maxCol = $idx }
    }
    $arr = @(); for ($i=1; $i -le $maxCol; $i++) { if ($cells.ContainsKey($i)) { $arr += $cells[$i] } else { $arr += '' } }
    $rows += ,$arr
  }
  return ,$rows
}
function Slugify($s) {
  if ($null -eq $s) { return '' }
  $x = $s.ToLower().Trim()
  $x = $x -replace '&','and'
  $x = $x -replace '[^a-z0-9]+','-'
  $x = $x -replace '^-+','' -replace '-+$',''
  return $x
}
# Swap "contractor"->"construction" everywhere (client request), then fix dup artifacts.
function Swap-Word($s) {
  if ($null -eq $s) { return '' }
  $x = $s
  # Exception: keep the industry-standard trade name "General Contractor(s)"
  $x = $x -replace '(?i)general contractor(s?)', "GENCONTRACTORTOKEN`$1"
  $x = $x -creplace 'Contractors','Construction'
  $x = $x -creplace 'Contractor','Construction'
  $x = $x -creplace 'contractors','construction'
  $x = $x -creplace 'contractor','construction'
  # collapse artifacts like "construction and construction", "construction construction"
  $x = $x -replace '(?i)construction and construction','construction'
  $x = $x -replace '(?i)construction construction','construction'
  # restore preserved trade name
  $x = $x -replace 'GENCONTRACTORTOKEN','General Contractor'
  return $x
}

$catNameToSlug = @{
  'Estimating & Takeoff'='estimating-takeoff'; 'Construction Leads'='construction-leads';
  'CRM & Sales'='crm-sales'; 'Field Service & Dispatch'='field-service-dispatch';
  'Project Management'='project-management'; 'Accounting & Payroll'='accounting-payroll';
  'Safety & Compliance'='safety-compliance'; 'Fleet & Equipment'='fleet-equipment';
  'Marketing & Reputation'='marketing-reputation'; 'AI & Automation'='ai-automation';
  'Document Management'='document-management'; 'Procurement & Purchasing'='procurement-purchasing'
}

# ── Load real descriptions (Company/App -> description) ───────────────────────
$descMap = @{}
$descXlsx = Join-Path $CtFiles 'CategoryX_Company_Descriptions_Draft.xlsx'
$dx = Unzip-Xlsx $descXlsx
$dshared = Get-SharedStrings $dx
$drows = Get-Rows "$dx\xl\worksheets\sheet1.xml" $dshared
# header: Record #, Company/App, Website, Directory Category, Company Description Summary, ...
for ($r=1; $r -lt $drows.Count; $r++) {
  $row = $drows[$r]
  if ($row.Count -lt 5) { continue }
  $nm = $row[1]; $desc = $row[4]
  if ($nm -and $desc -and -not $descMap.ContainsKey($nm)) { $descMap[$nm] = $desc }
}
Write-Output ("Descriptions loaded: " + $descMap.Count)

# ── Load Master DB ───────────────────────────────────────────────────────────
$dbXlsx = Join-Path $CtFiles '1Final2 Contractor Technology Directory with Divisions (2).xlsx'
$mx = Unzip-Xlsx $dbXlsx
$mshared = Get-SharedStrings $mx   # likely empty (inline strings)
$mrows = Get-Rows "$mx\xl\worksheets\sheet2.xml" $mshared
Write-Output ("Master DB rows (incl header): " + $mrows.Count)

# Column indices (0-based) from header inspection.
# NOTE: revenue columns (O-Y) are deliberately NOT read — internal only.
$C = @{ rank=1; name=2; website=3; primaryCat=4; sub=5; trades=6; whatItDoes=7;
        pricing=8; size=9; pubpriv=10; slug=26; notes=32; divisions=33 }

$companies = @()
$slugSeen = @{}
for ($r=1; $r -lt $mrows.Count; $r++) {
  $row = $mrows[$r]
  if ($row.Count -lt 8) { continue }
  $name = $row[$C.name]
  if (-not $name) { continue }
  $primaryCat = $row[$C.primaryCat]
  $catSlug = $catNameToSlug[$primaryCat]
  if (-not $catSlug) { $catSlug = Slugify $primaryCat }

  # slug: prefer SEO Slug last segment, else slugify name
  $slug = ''
  if ($row.Count -gt $C.slug -and $row[$C.slug]) {
    $segs = ($row[$C.slug].Trim('/') -split '/'); $slug = $segs[$segs.Count-1]
  }
  if (-not $slug) { $slug = Slugify $name }
  $baseSlug = $slug; $n=2
  while ($slugSeen.ContainsKey($slug)) { $slug = "$baseSlug-$n"; $n++ }
  $slugSeen[$slug] = $true

  # description: prefer real desc file, else What It Does
  $desc = $descMap[$name]
  if (-not $desc) { $desc = $row[$C.whatItDoes] }
  # Protect the company's own brand name (e.g. "Contractor Foreman") from the word swap
  if ($name -match 'ontractor') { $desc = $desc -replace [regex]::Escape($name), 'BRANDNAMETOKEN' }
  $desc = Swap-Word $desc
  $desc = $desc -replace 'BRANDNAMETOKEN', $name

  # trades + divisions -> arrays
  $tradesRaw = if ($row.Count -gt $C.trades) { $row[$C.trades] } else { '' }
  $trades = @(); if ($tradesRaw) { $trades = @($tradesRaw -split '[,;]' | ForEach-Object { Swap-Word ($_.Trim()) } | Where-Object { $_ }) }
  $divRaw = if ($row.Count -gt $C.divisions) { $row[$C.divisions] } else { '' }

  $website = $row[$C.website]
  $domain = ''
  if ($website -match '^https?://([^/]+)') { $domain = $matches[1] -replace '^www\.','' }

  $rank = 9999
  if ($row[$C.rank] -match '^\d+$') { $rank = [int]$row[$C.rank] }

  $companies += [ordered]@{
    rank        = $rank
    name        = $name   # brand name kept as-is (not word-swapped)
    slug        = $slug
    website     = $website
    domain      = $domain
    category    = $catSlug
    categoryName= Swap-Word $primaryCat
    subcategory = Swap-Word $row[$C.sub]
    trades      = $trades
    divisions   = $divRaw
    description = $desc
    pricingModel= if ($row.Count -gt $C.pricing) { $row[$C.pricing] } else { '' }
    companySize = if ($row.Count -gt $C.size) { $row[$C.size] } else { '' }
    publicPrivate = if ($row.Count -gt $C.pubpriv) { $row[$C.pubpriv] } else { '' }
    # NOTE: revenue fields intentionally omitted (internal only, never published)
  }
}

Write-Output ("Companies parsed: " + $companies.Count)
# Per-category counts
$companies | Group-Object category | Sort-Object Name | ForEach-Object { Write-Output ("  {0,-26} {1}" -f $_.Name, $_.Count) }

$out = @{ generatedFrom = '1Final2 Contractor Technology Directory with Divisions (2).xlsx + CategoryX descriptions'
          note = 'Revenue fields excluded by policy (internal only).'
          count = $companies.Count
          companies = $companies }
$json = $out | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $Root 'data\companies.json'), $json, $utf8)
Write-Output ("Wrote data\companies.json")

# ── Most Widely Used: the top 50 companies by Deryck's Category Rank ───────────
# Deryck: "until we get a robust traffic report, put the largest 50 companies on
# the rotation." We use his own Category Rank (rank 1 = top company in a category)
# and round-robin across all 12 categories, so the list spans categories the way
# his mockup did (Stack, Procore, ServiceTitan, Buildertrend, Bluebeam...).
$catOrder = @($companies | ForEach-Object { $_.category } | Select-Object -Unique)
$byCat = @{}
foreach ($s in $catOrder) {
  $byCat[$s] = @($companies | Where-Object { $_.category -eq $s } | Sort-Object { [int]$_.rank })
}
$picked = @(); $depth = 0
while ($picked.Count -lt 50 -and $depth -lt 60) {
  foreach ($s in $catOrder) {
    if ($byCat[$s].Count -gt $depth) { $picked += $byCat[$s][$depth]; if ($picked.Count -ge 50) { break } }
  }
  $depth++
}
$top50 = @($picked | Select-Object -First 50)
$mwu = [ordered]@{
  note  = 'Top 50 by Category Rank, round-robin across categories. No revenue used.'
  basis = 'category-rank'
  count = $top50.Count
  slugs = @($top50 | ForEach-Object { $_.slug })
}
$mwuJson = $mwu | ConvertTo-Json -Depth 4
[System.IO.File]::WriteAllText((Join-Path $Root 'data\most-widely-used.json'), $mwuJson, $utf8)
Write-Output ("Wrote data\most-widely-used.json  (top " + $top50.Count + " by category rank)")
Write-Output ("  first 8: " + (($top50 | Select-Object -First 8 | ForEach-Object { $_.name }) -join ', '))
