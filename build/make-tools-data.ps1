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
$body = "window.TOOLS = $json;`r`n" +
        "window.TOOLS_COUNT = $($tools.Count);`r`n"
[System.IO.File]::WriteAllText((Join-Path $Root 'assets\tools-data.js'), $body, $utf8)
Write-Output ("Wrote assets\tools-data.js  (" + $tools.Count + " tools)")
