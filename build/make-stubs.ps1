# Build simple on-brand stub pages for Resources / Blog / Contact (nav targets).
param([string]$Root = (Resolve-Path "$PSScriptRoot\..").Path)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

# globals needed by templates (footer iterates $Global:tax.categories)
$Global:tax = [System.IO.File]::ReadAllText((Join-Path $Root 'data\taxonomy.json'), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
function HtmlEnc($s) { if ($null -eq $s) { return '' } return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;') }
. (Join-Path $PSScriptRoot 'templates.ps1')

$stubs = @(
  @{ slug='resources'; title='Resources'; eyebrow='Guides &amp; tools';
     blurb='Buying guides, checklists, and how-tos for choosing construction software are on the way. In the meantime, browse the directory by category or trade.' },
  @{ slug='blog'; title='Blog'; eyebrow='News &amp; insights';
     blurb='Articles and product breakdowns for construction teams are coming soon. Check back shortly, or start exploring the directory.' },
  @{ slug='contact'; title='Contact'; eyebrow='Get in touch';
     blurb='A contact form is being set up. For now, reach out through the directory and we will route your message to the right place.' }
)

foreach ($s in $stubs) {
  $prefix = '../'
  $title = "$($s.title) | The Construction Technology Directory"
  $desc  = "$($s.title) - The Construction Technology Directory."
  $head = Build-Head $title $desc $prefix
  $header = Build-Header $prefix
  $footer = Build-Footer $prefix
  $body = @"
<main class="max-w-4xl mx-auto px-6 py-20 md:py-28 text-center">
  <span class="inline-flex items-center gap-2 text-xs font-semibold uppercase tracking-widest text-orange-600">$($s.eyebrow)</span>
  <h1 class="mt-4 text-4xl md:text-5xl font-extrabold tracking-tight text-slate-900">$($s.title)</h1>
  <p class="mt-5 text-lg text-slate-600 leading-relaxed max-w-2xl mx-auto">$($s.blurb)</p>
  <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
    <a href="${prefix}categories/" class="inline-flex items-center gap-2 px-5 py-3 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 transition">Browse categories</a>
    <a href="${prefix}trades/" class="inline-flex items-center gap-2 px-5 py-3 rounded-lg bg-white border border-slate-200 text-slate-800 font-semibold hover:border-blue-500 transition">Browse trades</a>
  </div>
  <p class="mt-10 inline-flex items-center gap-2 text-sm font-semibold text-slate-400">Coming soon</p>
</main>
"@
  $html = $head + $header + $body + $footer
  $outDir = Join-Path $Root $s.slug
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
  [System.IO.File]::WriteAllText((Join-Path $outDir 'index.html'), $html, $utf8)
  Write-Output ("Wrote $($s.slug)/index.html")
}
