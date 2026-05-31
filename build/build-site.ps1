# Builds the full Deryck static site from data/tools.json into dist/.
# Run: powershell -ExecutionPolicy Bypass -File build-site.ps1

$ErrorActionPreference = 'Stop'

$root      = Split-Path -Parent $PSScriptRoot
$dataFile  = Join-Path $root 'data\enriched.json'
$curatedFile = Join-Path $root 'data\curated.json'
$assetsDir = Join-Path $root 'assets'
# The repo root IS the deployable site (works with Vercel, Netlify, GH Pages,
# Cloudflare Pages, S3, etc. with no configuration).
$distDir   = $root
$siteHost  = 'https://deryck.example.com'  # adjust for production sitemap

if (-not (Test-Path $dataFile)) {
    # Fall back to tools.json if enriched.json hasn't been generated yet
    $dataFile = Join-Path $root 'data\tools.json'
    if (-not (Test-Path $dataFile)) { throw "Missing data\enriched.json and data\tools.json. Run parse-tools.ps1 + enrich-data.ps1 first." }
}
$curated = $null
if (Test-Path $curatedFile) {
    $curated = Get-Content -Path $curatedFile -Raw -Encoding UTF8 | ConvertFrom-Json
}

# Ensure the output subfolders exist at the repo root.
if (-not (Test-Path (Join-Path $distDir 'category'))) { New-Item -ItemType Directory -Path (Join-Path $distDir 'category') | Out-Null }
if (-not (Test-Path (Join-Path $distDir 'tool')))     { New-Item -ItemType Directory -Path (Join-Path $distDir 'tool')     | Out-Null }

# Build a hashset of locally cached domains for fast lookup
$srcIcons = Join-Path $assetsDir 'icons'
$cachedDomains = @{}
if (Test-Path $srcIcons) {
    foreach ($f in Get-ChildItem -Path $srcIcons -Filter '*.ico') {
        $cachedDomains[$f.BaseName] = $true
    }
}

$data = Get-Content -Path $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json

# ---------- helpers ----------

function HtmlEncode {
    param([string]$s)
    if ($null -eq $s) { return '' }
    return ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&#39;')
}

function AttrEncode { param([string]$s) HtmlEncode $s }

function RelPath {
    param([int]$depth)
    if ($depth -le 0) { return '' }
    return ('../' * $depth)
}

function FirstLetter {
    param([string]$s)
    if ([string]::IsNullOrWhiteSpace($s)) { return '?' }
    return ($s.Substring(0,1).ToUpper())
}

function ToolIcon {
    param($tool, [int]$depth = 0, [string]$sizeClass = '')
    $domain = $tool.domain
    $letter = FirstLetter $tool.name
    $alt    = AttrEncode "$($tool.name) logo"
    $cls    = "tool-icon $sizeClass".Trim()
    $r      = RelPath $depth

    # Letter fallback when no domain OR no cached icon
    if ([string]::IsNullOrWhiteSpace($domain) -or -not $cachedDomains.ContainsKey($domain)) {
        return '<div class="' + $cls + '"><div class="icon-fallback ' + $sizeClass + '">' + $letter + '</div></div>'
    }

    $localSrc  = "${r}assets/icons/$domain.ico"
    $remoteSrc = "https://icons.duckduckgo.com/ip3/$domain.ico"
    # Try local first; if missing for any reason at runtime, fall back to remote, then to letter
    return '<div class="' + $cls + '"><img src="' + $localSrc + '" alt="' + $alt + '" loading="lazy" onerror="if(!this.dataset.r){this.dataset.r=1;this.src=' + "'$remoteSrc'" + '}else{this.outerHTML=' + "'<div class=\\'icon-fallback $sizeClass\\'>$letter</div>'" + '}"></div>'
}

function Header-Html {
    param([int]$depth)
    $r = RelPath $depth
    return @"
<header class="sticky top-0 z-50 bg-white/85 backdrop-blur border-b border-slate-200">
  <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between gap-6">
    <a href="${r}index.html" class="flex items-center gap-2 font-bold text-xl tracking-tight">
      <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-slate-900 text-white text-sm font-bold">D</span>
      <span>Deryck</span>
    </a>
    <nav class="hidden lg:flex items-center gap-7 text-sm font-medium text-slate-600">
      <a href="${r}directory/" class="hover:text-blue-600 transition">Directory</a>
      <a href="${r}best/" class="hover:text-blue-600 transition">Best Of</a>
      <a href="${r}compare/" class="hover:text-blue-600 transition">Compare</a>
      <a href="${r}pricing/" class="hover:text-blue-600 transition">Pricing</a>
      <a href="${r}workflow/" class="hover:text-blue-600 transition">Workflows</a>
      <a href="${r}quiz/" class="hover:text-blue-600 transition">Find My Stack</a>
    </nav>
    <a href="${r}directory/" class="lg:hidden text-sm font-medium text-blue-600">Browse</a>
  </div>
</header>
"@
}

function Footer-Html {
    param([int]$depth)
    $r = RelPath $depth
    $year = (Get-Date).Year
    return @"
<footer class="mt-24 border-t border-slate-200 bg-slate-50">
  <div class="max-w-7xl mx-auto px-6 py-12 grid md:grid-cols-3 gap-10">
    <div>
      <div class="flex items-center gap-2 font-bold text-xl">
        <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-slate-900 text-white text-sm font-bold">D</span>
        <span>Deryck</span>
      </div>
      <p class="mt-3 text-sm text-slate-600 max-w-sm">A curated reference of 300 essential contractor tools across six trades. Discover what each tool does and link directly to the official source.</p>
    </div>
    <div>
      <h4 class="text-sm font-semibold text-slate-900 mb-3">Categories</h4>
      <ul class="space-y-2 text-sm text-slate-600">
$(($data.categories | ForEach-Object { "        <li><a class=`"hover:text-blue-600`" href=`"${r}category/$($_.slug).html`">$(HtmlEncode (($_.name -replace '^Top 50\s+', '')))</a></li>" }) -join "`n")
      </ul>
    </div>
    <div>
      <h4 class="text-sm font-semibold text-slate-900 mb-3">About</h4>
      <p class="text-sm text-slate-600">Deryck is an informational directory. We do not rank or endorse any product; each entry describes what a tool is used for, so you can decide what fits your workflow.</p>
    </div>
  </div>
  <div class="border-t border-slate-200">
    <div class="max-w-7xl mx-auto px-6 py-5 text-xs text-slate-500 flex flex-col md:flex-row items-center justify-between gap-2">
      <span>&copy; $year Deryck. All trademarks are property of their respective owners.</span>
      <span>$($data.categories.Count) categories &middot; 300 tools indexed</span>
    </div>
  </div>
</footer>
"@
}

function HtmlShell {
    param(
        [string]$title,
        [string]$description,
        [string]$canonicalRelative,
        [int]$depth,
        [string]$bodyClass = 'bg-white',
        [string]$body,
        [string]$jsonLd = ''
    )
    $r = RelPath $depth
    $titleH    = HtmlEncode $title
    $descH     = AttrEncode $description
    $canonical = "$siteHost/$canonicalRelative"
    $ldBlock = ''
    if (-not [string]::IsNullOrWhiteSpace($jsonLd)) {
        $ldBlock = "  <script type=`"application/ld+json`">$jsonLd</script>"
    }
    return @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$titleH</title>
  <meta name="description" content="$descH">
  <link rel="canonical" href="$canonical">
  <meta property="og:title" content="$titleH">
  <meta property="og:description" content="$descH">
  <meta property="og:type" content="website">
  <meta property="og:url" content="$canonical">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="${r}assets/style.css">
$ldBlock
</head>
<body class="$bodyClass">
$(Header-Html -depth $depth)
$body
$(Footer-Html -depth $depth)
</body>
</html>
"@
}

function Breadcrumb-Html {
    param([array]$items)
    # items: array of @{ label=; href= } ; last item is current page (no link)
    $r = ''
    for ($i = 0; $i -lt $items.Count; $i++) {
        $it = $items[$i]
        if ($i -gt 0) { $r += '<span class="mx-2 text-slate-300">/</span>' }
        if ($i -eq $items.Count - 1) {
            $r += "<span class=`"text-slate-900 font-medium`">$(HtmlEncode $it.label)</span>"
        } else {
            $r += "<a class=`"hover:text-blue-600`" href=`"$($it.href)`">$(HtmlEncode $it.label)</a>"
        }
    }
    return @"
<nav aria-label="Breadcrumb" class="text-sm text-slate-500">
  $r
</nav>
"@
}

function Json-Escape {
    param([string]$s)
    if ($null -eq $s) { return '' }
    $s = $s -replace '\\', '\\\\'
    $s = $s -replace '"', '\"'
    $s = $s -replace "`r", ''
    $s = $s -replace "`n", '\n'
    $s = $s -replace "`t", '\t'
    return $s
}

# ---------- Page builders ----------

function Build-Index {
    $hero = @"
<section class="hero">
  <div class="max-w-7xl mx-auto px-6 w-full text-white">
    <span class="chip" style="background:rgba(255,255,255,0.10); color:#DBEAFE; border-color:rgba(255,255,255,0.18);">300 tools &middot; 6 trades &middot; built for serious operators</span>
    <h1 class="mt-4 text-4xl sm:text-5xl md:text-6xl font-extrabold tracking-tight max-w-3xl leading-[1.05]">
      The contractor operations search engine.
    </h1>
    <p class="mt-5 text-lg md:text-xl text-slate-200 max-w-2xl">
      Compare 300 contractor platforms head-to-head, look up pricing, find alternatives, and learn how high-performing teams run their estimating, dispatching, and project workflows.
    </p>
    <div class="mt-8 flex flex-wrap gap-3">
      <a href="quiz/" class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-lg shadow-lg shadow-blue-900/30 transition">
        Find my contractor stack
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
      </a>
      <a href="directory/" class="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white font-semibold px-6 py-3 rounded-lg backdrop-blur transition border border-white/20">
        Filter all 300 tools
      </a>
    </div>
  </div>
</section>
"@

    $stats = @"
<section class="border-y border-slate-200 bg-slate-50">
  <div class="max-w-7xl mx-auto px-6 py-8 grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
    <div><div class="text-3xl font-extrabold text-slate-900">300</div><div class="text-xs uppercase tracking-wider text-slate-500 mt-1">Tools indexed</div></div>
    <div><div class="text-3xl font-extrabold text-slate-900">6</div><div class="text-xs uppercase tracking-wider text-slate-500 mt-1">Trade categories</div></div>
    <div><div class="text-3xl font-extrabold text-slate-900">100%</div><div class="text-xs uppercase tracking-wider text-slate-500 mt-1">Direct links</div></div>
    <div><div class="text-3xl font-extrabold text-blue-600">$0</div><div class="text-xs uppercase tracking-wider text-slate-500 mt-1">Cost to browse</div></div>
  </div>
</section>
"@

    $ecoIntros = @(
        @{ icon='🔎'; title='Filterable directory';    href='directory/'; sub='All 300 tools, filter by trade, size, budget, and use case.' },
        @{ icon='⚖️'; title='Side-by-side comparisons'; href='compare/';  sub='ServiceTitan vs Jobber, Procore vs Buildertrend &mdash; 50+ matchups.' },
        @{ icon='💰'; title='Pricing breakdowns';      href='pricing/';   sub='Tier ranges and what teams actually pay, per tool.' },
        @{ icon='↔';  title='Alternatives to every tool'; href='alternatives/'; sub='Curated swap lists when a tool isn''t the right fit.' },
        @{ icon='🏆'; title='Best-of guides';          href='best/';      sub='28 hubs: best plumbing CRM, best estimating software, more.' },
        @{ icon='🛠️'; title='Workflow playbooks';      href='workflow/';  sub='How commercial GCs estimate. How HVAC dispatchers run their boards.' }
    )
    $ecoCards = ''
    foreach ($e in $ecoIntros) {
        $ecoCards += @"
<a href="$($e.href)" class="cat-tile p-6 flex items-start gap-4">
  <span class="text-3xl">$($e.icon)</span>
  <div>
    <div class="text-base font-bold text-slate-900">$($e.title)</div>
    <div class="text-sm text-slate-600 mt-1">$($e.sub)</div>
  </div>
</a>
"@
    }

    $about = @"
<section id="about" class="bg-white border-y border-slate-200">
  <div class="max-w-7xl mx-auto px-6 py-20">
    <div class="text-center max-w-2xl mx-auto mb-12">
      <span class="chip">The ecosystem</span>
      <h2 class="mt-4 text-3xl md:text-4xl font-bold tracking-tight text-slate-900">More than a list. A way to actually choose.</h2>
      <p class="mt-3 text-slate-600">Every contractor stack is different. Deryck turns the 300-tool universe into a workflow you can navigate &mdash; compare, price, alternative, decide.</p>
    </div>
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
      $ecoCards
    </div>
  </div>
</section>
"@

    $catCards = ''
    foreach ($c in $data.categories) {
        $shortName = ($c.name -replace '^Top 50\s+', '')
        $catCards += @"
<a href="category/$($c.slug).html" class="cat-tile p-7 flex flex-col gap-4">
  <div class="flex items-center justify-between">
    <span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Category</span>
    <span class="text-xs font-semibold text-slate-500">$($c.tools.Count) tools</span>
  </div>
  <h3 class="text-xl font-bold tracking-tight text-slate-900">$(HtmlEncode $shortName)</h3>
  <p class="text-sm text-slate-600 leading-relaxed flex-grow">
    Tools and platforms used across $(HtmlEncode ($shortName.ToLower())) workflows.
  </p>
  <div class="flex items-center gap-1 text-sm font-semibold text-blue-600">
    Explore <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
  </div>
</a>
"@
    }

    $categoriesSection = @"
<section id="categories" class="bg-blueprint">
  <div class="max-w-7xl mx-auto px-6 py-20">
    <div class="text-center max-w-2xl mx-auto mb-12">
      <span class="chip">Explore</span>
      <h2 class="mt-4 text-3xl md:text-4xl font-bold tracking-tight text-slate-900">Six trades. Three hundred tools.</h2>
      <p class="mt-3 text-slate-600">Pick a category to see every tool indexed for that trade, with a short explainer of what it does.</p>
    </div>
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
      $catCards
    </div>
  </div>
</section>
"@

    $body = $hero + $stats + $about + $categoriesSection

    $jsonLd = @"
{"@context":"https://schema.org","@type":"WebSite","name":"Deryck","url":"$siteHost","description":"$(Json-Escape $data.tagline)"}
"@

    $html = HtmlShell -title 'Deryck — A reference of 300 essential contractor tools' `
        -description 'Browse 300 essential tools used across six contracting trades. Clear explanations and direct links — no rankings, just what each tool actually does.' `
        -canonicalRelative 'index.html' `
        -depth 0 `
        -body $body `
        -jsonLd $jsonLd

    $outPath = Join-Path $distDir 'index.html'
    Set-Content -Path $outPath -Value $html -Encoding UTF8
    Write-Host "  wrote index.html"
}

function Build-CategoryPage {
    param($category)

    $shortName = ($category.name -replace '^Top 50\s+', '')

    $crumb = Breadcrumb-Html @(
        @{ label='Home';     href='../index.html' },
        @{ label=$shortName; href='' }
    )

    $cards = ''
    foreach ($t in $category.tools) {
        $icon = ToolIcon -tool $t -depth 1
        $cards += @"
<a href="../tool/$($category.slug)/$($t.slug).html" class="tool-card bg-white border border-slate-200 rounded-xl p-5 flex flex-col gap-4 h-full">
  <div class="flex items-start gap-4">
    $icon
    <div class="flex-grow min-w-0">
      <h3 class="font-semibold text-slate-900 leading-tight truncate">$(HtmlEncode $t.name)</h3>
      <div class="text-xs text-slate-500 mt-1 truncate">$(HtmlEncode $t.domain)</div>
    </div>
  </div>
  <p class="text-sm text-slate-600 leading-relaxed line-clamp-3 flex-grow">$(HtmlEncode $t.description)</p>
  <div class="flex items-center justify-between pt-2 border-t border-slate-100">
    <span class="text-xs font-semibold text-blue-600">View details</span>
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
  </div>
</a>
"@
    }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-7xl mx-auto px-6 pt-10 pb-6">
    $crumb
    <header class="mt-6 max-w-3xl">
      <span class="chip">Category</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $shortName)</h1>
      <p class="mt-4 text-lg text-slate-600 leading-relaxed">
        $($category.tools.Count) tools commonly used across $(HtmlEncode ($shortName.ToLower())) workflows. Click any tool to see what it&rsquo;s used for and visit the official site.
      </p>
    </header>
  </div>

  <div class="max-w-7xl mx-auto px-6 pb-20">
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
      $cards
    </div>
  </div>
</main>
"@

    $itemList = '['
    for ($i = 0; $i -lt $category.tools.Count; $i++) {
        $t = $category.tools[$i]
        $sep = ','
        if ($i -eq $category.tools.Count - 1) { $sep = '' }
        $itemList += "{`"@type`":`"ListItem`",`"position`":$($i+1),`"name`":`"$(Json-Escape $t.name)`",`"url`":`"$siteHost/tool/$($category.slug)/$($t.slug).html`"}$sep"
    }
    $itemList += ']'
    $jsonLd = "{`"@context`":`"https://schema.org`",`"@type`":`"ItemList`",`"name`":`"$(Json-Escape $shortName)`",`"numberOfItems`":$($category.tools.Count),`"itemListElement`":$itemList}"

    $html = HtmlShell `
        -title "$shortName — Deryck" `
        -description "Explore $($category.tools.Count) tools used across $($shortName.ToLower()) workflows. Brief explainer of each tool and direct links to the official site." `
        -canonicalRelative "category/$($category.slug).html" `
        -depth 1 `
        -body $body `
        -jsonLd $jsonLd

    $outPath = Join-Path $distDir "category\$($category.slug).html"
    Set-Content -Path $outPath -Value $html -Encoding UTF8
}

function Build-ToolPage {
    param($category, $tool)

    $shortName = ($category.name -replace '^Top 50\s+', '')

    $crumb = Breadcrumb-Html @(
        @{ label='Home';      href='../../index.html' },
        @{ label=$shortName;  href="../../category/$($category.slug).html" },
        @{ label=$tool.name;  href='' }
    )

    $icon = ToolIcon -tool $tool -depth 2 -sizeClass 'lg'

    # Pick 4 related tools (deterministic: next 4 by position, wrap around)
    $tools = $category.tools
    $idx   = $tools.IndexOf($tool)
    $related = @()
    for ($i = 1; $i -le 4; $i++) {
        $j = ($idx + $i) % $tools.Count
        if ($j -ne $idx) { $related += $tools[$j] }
    }

    $relatedCards = ''
    foreach ($r in $related) {
        $rIcon = ToolIcon -tool $r -depth 2
        $relatedCards += @"
<a href="$($r.slug).html" class="tool-card bg-white border border-slate-200 rounded-xl p-4 flex items-start gap-3">
  $rIcon
  <div class="min-w-0">
    <div class="font-semibold text-slate-900 truncate">$(HtmlEncode $r.name)</div>
    <div class="text-xs text-slate-500 mt-1 line-clamp-2">$(HtmlEncode $r.description)</div>
  </div>
</a>
"@
    }

    $domainBlock = ''
    if ($tool.domain) {
        $domainDisplay = HtmlEncode $tool.domain
        $domainBlock = '<div class="text-sm text-slate-500 mt-1">' + $domainDisplay + '</div>'
    }

    # ----- chips (trade / use case / price band / difficulty) -----
    $chips = ''
    if ($tool.trades) {
        foreach ($tr in $tool.trades) { $chips += '<span class="chip">' + (HtmlEncode $tr) + '</span>' }
    }
    if ($tool.useCases) {
        foreach ($u in ($tool.useCases | Select-Object -First 3)) { $chips += '<span class="chip chip-soft">' + (HtmlEncode $u) + '</span>' }
    }
    if ($tool.priceBand)  { $chips += '<span class="chip chip-price">' + (HtmlEncode $tool.priceBand) + '</span>' }
    if ($tool.implementationDifficulty) { $chips += '<span class="chip chip-soft">' + (HtmlEncode "$($tool.implementationDifficulty) to deploy") + '</span>' }

    # ----- ecosystem CTAs (pricing / alternatives) -----
    $ecoCtas = @"
        <a href="../../pricing/$($tool.slug)/" class="eco-cta">
          <span class="eco-cta-icon">$</span>
          <div>
            <div class="eco-cta-title">$(HtmlEncode $tool.name) pricing</div>
            <div class="eco-cta-sub">Tiers, models, and what teams actually pay</div>
          </div>
        </a>
        <a href="../../alternatives/$($tool.slug)/" class="eco-cta">
          <span class="eco-cta-icon">↔</span>
          <div>
            <div class="eco-cta-title">$(HtmlEncode $tool.name) alternatives</div>
            <div class="eco-cta-sub">Six platforms commonly considered against $(HtmlEncode $tool.name)</div>
          </div>
        </a>
"@

    # ----- pros / cons -----
    $prosHtml = ''
    if ($tool.pros) {
        foreach ($p in $tool.pros) {
            $prosHtml += '<li class="flex gap-2 items-start"><span class="text-green-600 font-bold mt-0.5">+</span><span>' + (HtmlEncode $p) + '</span></li>'
        }
    }
    $consHtml = ''
    if ($tool.cons) {
        foreach ($c in $tool.cons) {
            $consHtml += '<li class="flex gap-2 items-start"><span class="text-rose-500 font-bold mt-0.5">−</span><span>' + (HtmlEncode $c) + '</span></li>'
        }
    }

    # ----- integrations -----
    $intsHtml = ''
    if ($tool.integrations) {
        foreach ($ig in $tool.integrations) {
            $intsHtml += '<span class="chip chip-soft">' + (HtmlEncode $ig) + '</span>'
        }
    }

    # ----- best-for block: which hubs include this tool -----
    $bestForHtml = ''
    if ($curated -and $curated.bestForHubs) {
        $matchingHubs = @()
        foreach ($hub in $curated.bestForHubs) {
            $ok = $true
            if ($hub.filter.useCase  -and $tool.useCases     -notcontains $hub.filter.useCase) { $ok = $false }
            if ($hub.filter.trade    -and $tool.trades       -notcontains $hub.filter.trade)   { $ok = $false }
            if ($hub.filter.size     -and $tool.companySizes -notcontains $hub.filter.size)    { $ok = $false }
            if ($hub.filter.band     -and $tool.priceBand    -ne          $hub.filter.band)    { $ok = $false }
            if ($ok) { $matchingHubs += $hub }
        }
        $matchingHubs = $matchingHubs | Select-Object -First 5
        if ($matchingHubs.Count -gt 0) {
            $hubLinks = ''
            foreach ($h in $matchingHubs) {
                $hubLinks += '<a href="../../best/' + $h.slug + '/" class="hub-pill">' + (HtmlEncode $h.title) + ' →</a>'
            }
            $bestForHtml = @"
<section class="max-w-5xl mx-auto px-6 pb-10">
  <div class="bg-slate-50 border border-slate-200 rounded-2xl p-6 md:p-8">
    <h2 class="text-sm font-bold uppercase tracking-widest text-slate-500">$(HtmlEncode $tool.name) appears in these guides</h2>
    <div class="mt-4 flex flex-wrap gap-2">$hubLinks</div>
  </div>
</section>
"@
        }
    }

    # ----- related VS comparisons -----
    $vsHtml = ''
    if ($curated -and $curated.vsPairs) {
        $relatedVs = @($curated.vsPairs | Where-Object { $_.left -eq $tool.slug -or $_.right -eq $tool.slug } | Select-Object -First 4)
        if ($relatedVs.Count -gt 0) {
            $vsLinks = ''
            foreach ($v in $relatedVs) {
                $otherSlug = if ($v.left -eq $tool.slug) { $v.right } else { $v.left }
                $vsLinks += @"
<a href="../../compare/$($v.left)-vs-$($v.right)/" class="vs-card">
  <span class="text-xs uppercase tracking-wider text-slate-500 font-semibold">Comparison</span>
  <div class="mt-1 font-bold text-slate-900">$(HtmlEncode $tool.name) vs $(HtmlEncode ($otherSlug -replace '-', ' '))</div>
  <div class="text-xs text-blue-600 font-semibold mt-2">View side-by-side →</div>
</a>
"@
            }
            $vsHtml = @"
<section class="max-w-5xl mx-auto px-6 pb-10">
  <h2 class="text-lg font-bold text-slate-900 mb-4">Compare $(HtmlEncode $tool.name) head-to-head</h2>
  <div class="grid sm:grid-cols-2 gap-3">$vsLinks</div>
</section>
"@
        }
    }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-5xl mx-auto px-6 pt-10 pb-6">
    $crumb
  </div>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-8 md:p-10 shadow-sm">
      <div class="flex flex-col md:flex-row md:items-start gap-6">
        $icon
        <div class="flex-grow min-w-0">
          <span class="chip">$(HtmlEncode $shortName)</span>
          <h1 class="mt-3 text-3xl md:text-4xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $tool.name)</h1>
          $domainBlock
          <div class="mt-4 flex flex-wrap gap-2">$chips</div>
        </div>
        <a href="$(AttrEncode $tool.url)" rel="noopener noreferrer" target="_blank" class="inline-flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-lg shadow-lg shadow-blue-900/20 transition whitespace-nowrap">
          Visit official site
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17L17 7"/><path d="M8 7h9v9"/></svg>
        </a>
      </div>

      <div class="divider"></div>

      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">What this tool is used for</h2>
      <p class="mt-3 text-lg md:text-xl text-slate-800 leading-relaxed">$(HtmlEncode $tool.description)</p>

      <div class="mt-8 grid sm:grid-cols-2 gap-3">
        $ecoCtas
      </div>
    </div>
  </section>

  $bestForHtml

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="grid md:grid-cols-2 gap-6">
      <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
        <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Strengths</h2>
        <ul class="mt-3 space-y-2 text-sm text-slate-700">$prosHtml</ul>
      </div>
      <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
        <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Trade-offs to know</h2>
        <ul class="mt-3 space-y-2 text-sm text-slate-700">$consHtml</ul>
      </div>
    </div>
  </section>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Integrations</h2>
      <div class="mt-3 flex flex-wrap gap-2">$intsHtml</div>
      <p class="mt-4 text-xs text-slate-500">Integration coverage is summarised from public materials. Verify on the vendor site before relying on a specific connector.</p>
    </div>
  </section>

  $vsHtml

  <section class="max-w-5xl mx-auto px-6 pb-20">
    <h2 class="text-lg font-bold text-slate-900 mb-4">Related tools in this category</h2>
    <div class="grid sm:grid-cols-2 gap-4">
      $relatedCards
    </div>
  </section>
</main>
"@

    $jsonLd = @"
{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[
{"@type":"ListItem","position":1,"name":"Home","item":"$siteHost/index.html"},
{"@type":"ListItem","position":2,"name":"$(Json-Escape $shortName)","item":"$siteHost/category/$($category.slug).html"},
{"@type":"ListItem","position":3,"name":"$(Json-Escape $tool.name)","item":"$siteHost/tool/$($category.slug)/$($tool.slug).html"}
]}
"@

    $html = HtmlShell `
        -title "$($tool.name) — what it&rsquo;s used for | Deryck" `
        -description $tool.description `
        -canonicalRelative "tool/$($category.slug)/$($tool.slug).html" `
        -depth 2 `
        -body $body `
        -jsonLd $jsonLd

    $outDir = Join-Path $distDir "tool\$($category.slug)"
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
    $outPath = Join-Path $outDir "$($tool.slug).html"
    Set-Content -Path $outPath -Value $html -Encoding UTF8
}

function Build-NotFound {
    $catCards = ''
    foreach ($c in $data.categories) {
        $shortName = ($c.name -replace '^Top 50\s+', '')
        $catCards += @"
<a href="category/$($c.slug).html" class="cat-tile p-5 flex flex-col gap-2">
  <span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Category</span>
  <h3 class="text-base font-bold text-slate-900">$(HtmlEncode $shortName)</h3>
  <span class="text-xs text-slate-500">$($c.tools.Count) tools</span>
</a>
"@
    }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-4xl mx-auto px-6 py-24 text-center">
    <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-blue-50 text-blue-600 text-2xl font-extrabold mb-6">404</div>
    <h1 class="text-4xl md:text-5xl font-extrabold tracking-tight text-slate-900">Page not found</h1>
    <p class="mt-4 text-lg text-slate-600 max-w-xl mx-auto">
      The page you were looking for doesn&rsquo;t exist or has moved. Jump to a category below or head back to the homepage.
    </p>
    <div class="mt-8 flex flex-wrap justify-center gap-3">
      <a href="index.html" class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold px-5 py-2.5 rounded-lg transition">Back to home</a>
    </div>
  </div>
  <div class="max-w-5xl mx-auto px-6 pb-20">
    <h2 class="text-sm font-bold uppercase tracking-widest text-slate-500 mb-4 text-center">Or browse a category</h2>
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
      $catCards
    </div>
  </div>
</main>
"@

    $html = HtmlShell `
        -title 'Page not found — Deryck' `
        -description 'The page you were looking for could not be found.' `
        -canonicalRelative '404.html' `
        -depth 0 `
        -body $body

    Set-Content -Path (Join-Path $distDir '404.html') -Value $html -Encoding UTF8
    Write-Host "  wrote 404.html"
}

function Build-Sitemap {
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $urls = @()
    $urls += "<url><loc>$siteHost/index.html</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>1.0</priority></url>"
    foreach ($c in $data.categories) {
        $urls += "<url><loc>$siteHost/category/$($c.slug).html</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>"
        foreach ($t in $c.tools) {
            $urls += "<url><loc>$siteHost/tool/$($c.slug)/$($t.slug).html</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.6</priority></url>"
        }
    }
    $xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n$(($urls | ForEach-Object { "  $_" }) -join "`n")`n</urlset>"
    Set-Content -Path (Join-Path $distDir 'sitemap.xml') -Value $xml -Encoding UTF8

    $robots = "User-agent: *`nAllow: /`nSitemap: $siteHost/sitemap.xml`n"
    Set-Content -Path (Join-Path $distDir 'robots.txt') -Value $robots -Encoding UTF8
}

# ---------- Run ----------

# Dot-source guard: skip main execution when this script is dot-sourced
# (build-ecosystem.ps1 reuses these template functions).
if ($MyInvocation.InvocationName -eq '.') { return }

Write-Host "Building Deryck..."
Write-Host ""
Write-Host "Homepage:"
Build-Index

Write-Host ""
Write-Host "Category pages:"
foreach ($c in $data.categories) {
    Build-CategoryPage $c
    Write-Host ("  wrote category/{0}.html ({1} tools)" -f $c.slug, $c.tools.Count)
}

Write-Host ""
Write-Host "Tool detail pages:"
$toolCount = 0
foreach ($c in $data.categories) {
    foreach ($t in $c.tools) {
        Build-ToolPage $c $t
        $toolCount++
    }
    Write-Host ("  wrote {0} pages under tool/{1}/" -f $c.tools.Count, $c.slug)
}

Write-Host ""
Write-Host "Auxiliary pages:"
Build-NotFound

Write-Host ""
Write-Host "SEO files:"
Build-Sitemap
Write-Host "  wrote sitemap.xml + robots.txt"

Write-Host ""
$totalFiles = 1 + $data.categories.Count + $toolCount + 1  # +1 for 404.html
Write-Host "Build complete: $totalFiles HTML files + sitemap.xml + robots.txt."
Write-Host "Output: $distDir"
Write-Host ""
Write-Host "Open this in your browser:"
Write-Host "  $distDir\index.html"
