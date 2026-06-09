# Build data/tools.json (generator input) from data/companies.json
# Groups the 600 companies into their 12 real categories (explicit, no guessing).
param([string]$Root = (Resolve-Path "$PSScriptRoot\..").Path)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$data = [System.IO.File]::ReadAllText((Join-Path $Root 'data\companies.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json

# Preserve category order from taxonomy
$tax = [System.IO.File]::ReadAllText((Join-Path $Root 'data\taxonomy.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$catOrder = @($tax.categories | ForEach-Object { $_.slug })
$catName  = @{}; foreach ($c in $tax.categories) { $catName[$c.slug] = $c.name }

# Group companies by category slug
$byCat = @{}
foreach ($c in $data.companies) {
  $cs = $c.category
  if (-not $byCat.ContainsKey($cs)) { $byCat[$cs] = @() }
  $byCat[$cs] += $c
}

$cats = @()
foreach ($slug in $catOrder) {
  if (-not $byCat.ContainsKey($slug)) { continue }
  $list = $byCat[$slug] | Sort-Object { [int]$_.rank }
  $tools = @()
  $pos = 1
  foreach ($c in $list) {
    $tools += [ordered]@{
      position    = $pos
      name        = $c.name
      slug        = $c.slug
      url         = $c.website
      domain      = $c.domain
      description = $c.description
      sub         = $c.subcategory
      trades      = @($c.trades)
      divisions   = $c.divisions
    }
    $pos++
  }
  $cats += [ordered]@{ name = $catName[$slug]; slug = $slug; tools = $tools }
}

$out = [ordered]@{
  siteName  = 'The Construction Technology Directory'
  tagline   = 'Search 600+ construction software platforms across 12 categories.'
  categories = $cats
}
$json = $out | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $Root 'data\tools.json'), $json, $utf8)
$total = ($cats | ForEach-Object { $_.tools.Count } | Measure-Object -Sum).Sum
Write-Output ("Wrote data\tools.json  ($($cats.Count) categories, $total tools)")
