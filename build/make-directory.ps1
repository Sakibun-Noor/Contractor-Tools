# Build directory/index.html — the full A-Z directory of all 600 tools,
# grouped by category with anchor pills. Linked from the footer + homepage.
param([string]$Root = (Resolve-Path "$PSScriptRoot\..").Path)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$Global:tax = [System.IO.File]::ReadAllText((Join-Path $Root 'data\taxonomy.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
function HtmlEnc($s) { if ($null -eq $s) { return '' } return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;') }
. (Join-Path $PSScriptRoot 'templates.ps1')

$data = [System.IO.File]::ReadAllText((Join-Path $Root 'data\companies.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$prefix = '../'

$byCat = [ordered]@{}
foreach ($cat in $Global:tax.categories) { $byCat[$cat.slug] = @{ name = $cat.name; tools = (New-Object System.Collections.Generic.List[object]) } }
foreach ($c in $data.companies) { if ($byCat.Contains($c.category)) { $byCat[$c.category].tools.Add($c) } }

$title = "Full Directory &mdash; $($data.companies.Count) Construction Software Tools | The Construction Technology Directory"
$desc  = "Browse all $($data.companies.Count) construction software platforms in one place, grouped by category &mdash; estimating, CRM, dispatch, accounting, safety, and more."
$bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label='Full Directory'})
$meta = '<div class="hero-meta"><span>' + $data.companies.Count + ' Tools</span><span>12 Categories</span><span>Direct Links</span></div>'
$hero = Build-HeroImage 'Browse' 'Full Directory' 'Every platform in the directory, grouped by category &mdash; use search or jump with the pills below.' $bc $meta 'directory' $prefix

$pills = New-Object System.Text.StringBuilder
foreach ($slug in $byCat.Keys) {
  [void]$pills.Append('<a href="#' + $slug + '" class="hub-pill">' + (HtmlEnc $byCat[$slug].name) + '</a>')
}

$sections = New-Object System.Text.StringBuilder
foreach ($slug in $byCat.Keys) {
  $grp = $byCat[$slug]
  $nameH = HtmlEnc $grp.name
  [void]$sections.Append('<div class="section-title-row mt-14" id="' + $slug + '"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">' + $nameH + ' &middot; ' + $grp.tools.Count + ' tools</span></div>')
  [void]$sections.Append('<div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">')
  foreach ($c in ($grp.tools | Sort-Object { [int]$_.rank })) {
    $cc = @{ name=$c.name; domain=$c.domain; description=$c.description; toolPath=("tool/" + $c.category + "/" + $c.slug + ".html") }
    [void]$sections.Append((Build-ToolCard $cc $prefix))
  }
  [void]$sections.Append('</div>')
}

$body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">Jump to a category</span></div>
      <div class="flex flex-wrap gap-2.5 mb-2">$($pills.ToString())</div>
      $($sections.ToString())
    </div>
  </div>
</main>
"@
$html = (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
$outDir = Join-Path $Root 'directory'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
[System.IO.File]::WriteAllText((Join-Path $outDir 'index.html'), $html, $utf8)
Write-Output ("Wrote directory/index.html (" + $data.companies.Count + " tools)")
