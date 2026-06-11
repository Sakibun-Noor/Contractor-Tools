# Build assets/tools-data.js (window.TOOLS) from data/companies.json
# Used by the homepage (search, category counts, most-widely-used).
param([string]$Root = (Resolve-Path "$PSScriptRoot\..").Path)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$data = [System.IO.File]::ReadAllText((Join-Path $Root 'data\companies.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$tools = @()
foreach ($c in $data.companies) {
  $tr = @(); if ($c.trades) { $tr = @($c.trades) }
  $tools += [ordered]@{
    n  = $c.name
    s  = $c.slug
    d  = $c.domain
    x  = $c.description
    c  = @($c.category)
    sub= $c.subcategory
    tr = $tr
    sz = $c.companySize
    rk = $c.rank
  }
}
# Stable order: by category then rank (rank is internal-sort only; never displayed)
$tools = $tools | Sort-Object { $_.c[0] }, { [int]$_.rk }

$json = ($tools | ConvertTo-Json -Depth 6 -Compress)

# "Most Widely Used" rotation = the 50 largest companies (slug list precomputed
# in data\most-widely-used.json; revenue used as size sort key, never published).
$widelyJson = '[]'
$mwuPath = Join-Path $Root 'data\most-widely-used.json'
if (Test-Path $mwuPath) {
  $mwu = [System.IO.File]::ReadAllText($mwuPath, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
  $widelyJson = (@($mwu.slugs) | ConvertTo-Json -Compress)
  if ($mwu.slugs.Count -eq 1) { $widelyJson = "[$widelyJson]" }  # single-item guard
}

# slug -> tool page path; home.js toolHref() uses this so every card/search hit
# lands on the tool detail page instead of falling back to the category page.
$paths = [ordered]@{}
foreach ($c in $data.companies) { $paths[$c.slug] = "tool/$($c.category)/$($c.slug).html" }
$pathsJson = ($paths | ConvertTo-Json -Compress)

$body = "window.TOOLS = $json;`r`n" +
        "window.TOOLS_COUNT = $($tools.Count);`r`n" +
        "window.WIDELY_USED = $widelyJson;`r`n" +
        "window.TOOLPATHS = $pathsJson;`r`n"
[System.IO.File]::WriteAllText((Join-Path $Root 'assets\tools-data.js'), $body, $utf8)
Write-Output ("Wrote assets\tools-data.js  (" + $tools.Count + " tools, widely-used: " + (@($mwu.slugs).Count) + ")")
