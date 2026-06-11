# Build one detail page per company: tool/{category}/{slug}.html
# Source of truth: data/companies.json (600 records).
# These are the link targets used by category pages, homepage cards, and search.
param([string]$Root = (Resolve-Path "$PSScriptRoot\..").Path)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$Global:tax = [System.IO.File]::ReadAllText((Join-Path $Root 'data\taxonomy.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
function HtmlEnc($s) { if ($null -eq $s) { return '' } return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;') }
. (Join-Path $PSScriptRoot 'templates.ps1')

$data = [System.IO.File]::ReadAllText((Join-Path $Root 'data\companies.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json

# index by category for the "More in {category}" block
$byCat = @{}
foreach ($c in $data.companies) {
  if (-not $byCat.ContainsKey($c.category)) { $byCat[$c.category] = New-Object System.Collections.Generic.List[object] }
  $byCat[$c.category].Add($c)
}
foreach ($k in @($byCat.Keys)) { $byCat[$k] = @($byCat[$k] | Sort-Object { [int]$_.rank }) }

$n = 0
foreach ($c in $data.companies) {
  $related = @($byCat[$c.category] | Where-Object { $_.slug -ne $c.slug } | Select-Object -First 6)
  $html = Build-ToolPage $c $related
  $dir = Join-Path $Root ("tool\" + $c.category)
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText((Join-Path $dir ($c.slug + '.html')), $html, $utf8)
  $n++
}
Write-Output ("Tool pages written: " + $n)
