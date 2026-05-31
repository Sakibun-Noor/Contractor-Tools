# Renders the new high-intent SEO pages on top of the existing tool pages:
#   /pricing/<slug>/         - 300 pricing pages
#   /alternatives/<slug>/    - 300 alternatives pages
#   /compare/<a>-vs-<b>/     - ~55 head-to-head comparisons
#   /best/<slug>/            - 28 "best of" hubs
#   /trade/<slug>/           - 7 trade hubs
#   /software-category/<slug>/ - 18 software category hubs
#   /workflow/<slug>/        - 8 long-form workflow guides
#   /directory/              - filterable directory of all 300 tools
#   /compare/                - comparison index
#   /pricing/                - pricing index
#   /alternatives/           - alternatives index
#   /best/                   - best-of index
#   /workflow/               - workflow index
#   /trade/                  - trade index
#   /software-category/      - software-category index
#   /quiz/                   - recommendation quiz
#   /thanks/                 - email-capture success page
#
# Re-uses HtmlShell + helpers from build-site.ps1 via dot-source.

$ErrorActionPreference = 'Stop'

# Dot-source the main build script for shared helpers (HtmlShell, Header, Footer,
# Breadcrumb, ToolIcon, HtmlEncode, $data, $curated, $distDir, $siteHost, $cachedDomains).
. (Join-Path $PSScriptRoot 'build-site.ps1')

if (-not $curated) { throw 'curated.json missing. Run curated-data.ps1 first.' }

# Flat tool index (slug -> tool object)
$ToolIndex = @{}
foreach ($c in $data.categories) {
    foreach ($t in $c.tools) { $ToolIndex[$t.slug] = $t }
}

# ------------------------------------------------------------------
# Helpers specific to ecosystem pages
# ------------------------------------------------------------------

function Ensure-Dir { param([string]$p) if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null } }

function Get-Tool { param([string]$slug) return $ToolIndex[$slug] }

function Get-ShortCatName { param([string]$slug)
    foreach ($c in $data.categories) {
        if ($c.slug -eq $slug) { return ($c.name -replace '^Top 50\s+', '') }
    }
    return $slug
}

function Format-PriceBadge {
    param([string]$band)
    $cls = switch ($band) {
        'Free'             { 'chip chip-good' }
        'Under $100/mo'    { 'chip chip-good' }
        '$100-$500/mo'     { 'chip chip-price' }
        'Enterprise'       { 'chip chip-warn' }
        default            { 'chip' }
    }
    return '<span class="' + $cls + '">' + (HtmlEncode $band) + '</span>'
}

function ToolCard-Compact {
    param($tool, [int]$depth)
    $icon = ToolIcon -tool $tool -depth $depth
    $r = RelPath $depth
    return @"
<a href="${r}tool/$($tool.categorySlug)/$($tool.slug).html" class="tool-card bg-white border border-slate-200 rounded-xl p-5 flex flex-col gap-4 h-full">
  <div class="flex items-start gap-4">
    $icon
    <div class="flex-grow min-w-0">
      <h3 class="font-semibold text-slate-900 leading-tight truncate">$(HtmlEncode $tool.name)</h3>
      <div class="text-xs text-slate-500 mt-1 truncate">$(HtmlEncode $tool.domain)</div>
    </div>
  </div>
  <p class="text-sm text-slate-600 leading-relaxed line-clamp-3 flex-grow">$(HtmlEncode $tool.description)</p>
  <div class="flex items-center justify-between pt-2 border-t border-slate-100">
    $(Format-PriceBadge $tool.priceBand)
    <span class="text-xs font-semibold text-blue-600">Details →</span>
  </div>
</a>
"@
}

# Filter tool list by hub filter spec
function Filter-Tools {
    param($filter)
    $matches = @()
    foreach ($c in $data.categories) {
        foreach ($t in $c.tools) {
            $ok = $true
            if ($filter.useCase  -and $t.useCases     -notcontains $filter.useCase) { $ok = $false }
            if ($filter.trade    -and $t.trades       -notcontains $filter.trade)   { $ok = $false }
            if ($filter.size     -and $t.companySizes -notcontains $filter.size)    { $ok = $false }
            if ($filter.band     -and $t.priceBand    -ne          $filter.band)    { $ok = $false }
            if ($ok) { $matches += $t }
        }
    }
    return $matches
}

# Email-capture inline component (single source of truth)
function Email-Capture-Html {
    param([string]$context = 'general')
    return @"
<section class="bg-slate-900 text-white">
  <div class="max-w-4xl mx-auto px-6 py-14 text-center">
    <span class="chip" style="background:rgba(255,255,255,0.10); color:#DBEAFE; border-color:rgba(255,255,255,0.18);">Newsletter</span>
    <h2 class="mt-4 text-2xl md:text-3xl font-bold tracking-tight">Get a contractor-stack briefing in your inbox</h2>
    <p class="mt-3 text-slate-300 text-sm md:text-base max-w-2xl mx-auto">Once a month: new tools, fresh comparisons, pricing changes, and the workflows behind the contractors actually scaling.</p>
    <form class="email-form mx-auto mt-6" data-context="$(AttrEncode $context)" action="https://formspree.io/f/REPLACE_ME" method="POST">
      <input type="email" name="email" placeholder="you@yourcontractingbiz.com" required aria-label="Email">
      <button type="submit">Subscribe</button>
    </form>
    <p class="mt-3 text-xs text-slate-400">One email a month. Unsubscribe anytime.</p>
  </div>
</section>
"@
}

# ==================================================================
# 1) PRICING PAGES /pricing/<slug>/
# ==================================================================
function Build-PricingPage {
    param($tool)

    $shortCat = Get-ShortCatName $tool.categorySlug
    $crumb = Breadcrumb-Html @(
        @{ label='Home';                       href='../../index.html' },
        @{ label='Pricing';                    href='../index.html' },
        @{ label="$($tool.name) pricing";      href='' }
    )
    $icon = ToolIcon -tool $tool -depth 2 -sizeClass 'lg'

    # Alternatives strip (low-cost / comparable / higher tier)
    $altCards = ''
    if ($tool.alternativesTo) {
        foreach ($alt in ($tool.alternativesTo | Select-Object -First 4)) {
            $altT = Get-Tool $alt.slug
            if (-not $altT) { continue }
            $altIcon = ToolIcon -tool $altT -depth 2
            $altCards += @"
<a href="../$($altT.slug)/" class="tool-card bg-white border border-slate-200 rounded-xl p-4 flex items-start gap-3">
  $altIcon
  <div class="min-w-0">
    <div class="font-semibold text-slate-900 truncate">$(HtmlEncode $altT.name)</div>
    <div class="text-xs text-slate-500 mt-1">$(HtmlEncode $altT.priceBand)</div>
  </div>
</a>
"@
        }
    }

    $tiersHtml = ''
    switch ($tool.priceBand) {
        'Free'          { $tiersHtml = '<div class="cmp-row"><div class="cmp-label">Free tier</div><div class="cmp-val">Yes</div><div class="cmp-val text-slate-500">Some advanced features may require paid add-ons</div></div>' }
        'Under $100/mo' { $tiersHtml = @"
<div class="cmp-row"><div class="cmp-label">Entry tier</div><div class="cmp-val">Under $100/mo</div><div class="cmp-val text-slate-500">Per user or flat depending on plan</div></div>
<div class="cmp-row"><div class="cmp-label">Mid tier</div><div class="cmp-val">~$100-$300/mo</div><div class="cmp-val text-slate-500">More features and seats</div></div>
"@ }
        '$100-$500/mo'  { $tiersHtml = @"
<div class="cmp-row"><div class="cmp-label">Starter</div><div class="cmp-val">~$100-$200/mo</div><div class="cmp-val text-slate-500">Solo / very small teams</div></div>
<div class="cmp-row"><div class="cmp-label">Growth</div><div class="cmp-val">~$200-$400/mo</div><div class="cmp-val text-slate-500">Typical small-business sweet spot</div></div>
<div class="cmp-row"><div class="cmp-label">Pro</div><div class="cmp-val">~$400-$500/mo</div><div class="cmp-val text-slate-500">Multi-user with advanced features</div></div>
"@ }
        'Enterprise'    { $tiersHtml = @"
<div class="cmp-row"><div class="cmp-label">Pricing model</div><div class="cmp-val">Quote-based</div><div class="cmp-val text-slate-500">Custom contract</div></div>
<div class="cmp-row"><div class="cmp-label">Typical range</div><div class="cmp-val">Five to six figures annually</div><div class="cmp-val text-slate-500">Scales with users, modules, project volume</div></div>
<div class="cmp-row"><div class="cmp-label">Implementation</div><div class="cmp-val">$(HtmlEncode $tool.implementationDifficulty)</div><div class="cmp-val text-slate-500">Plan for several weeks of onboarding</div></div>
"@ }
    }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-5xl mx-auto px-6 pt-10 pb-6">$crumb</div>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-8 md:p-10 shadow-sm">
      <div class="flex flex-col md:flex-row md:items-center gap-6">
        $icon
        <div class="flex-grow min-w-0">
          <span class="chip">Pricing</span>
          <h1 class="mt-3 text-3xl md:text-4xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $tool.name) Pricing</h1>
          <div class="mt-2 text-sm text-slate-500">$(HtmlEncode $tool.domain) &middot; $(HtmlEncode $shortCat)</div>
          <div class="mt-3 flex flex-wrap gap-2">$(Format-PriceBadge $tool.priceBand)<span class="chip chip-soft">$(HtmlEncode $tool.implementationDifficulty) to deploy</span></div>
        </div>
        <a href="$(AttrEncode $tool.url)" target="_blank" rel="noopener noreferrer" class="inline-flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-lg whitespace-nowrap">
          See official pricing →
        </a>
      </div>

      <div class="divider"></div>

      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">What you'll pay for $(HtmlEncode $tool.name)</h2>
      <p class="mt-3 text-base md:text-lg text-slate-800 leading-relaxed">$(HtmlEncode $tool.pricingNote)</p>
    </div>
  </section>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <h2 class="text-lg font-bold text-slate-900 mb-3">Pricing tiers (estimated)</h2>
    <div class="bg-white border border-slate-200 rounded-xl">
      $tiersHtml
    </div>
    <p class="mt-3 text-xs text-slate-500">Numbers above are reference ranges based on public materials. Always confirm against the vendor's current pricing page before signing a contract.</p>
  </section>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <h2 class="text-lg font-bold text-slate-900 mb-3">Lower-cost & higher-tier alternatives</h2>
    <div class="grid sm:grid-cols-2 gap-3">$altCards</div>
    <a href="../../alternatives/$($tool.slug)/" class="mt-4 inline-flex text-sm font-semibold text-blue-600 hover:text-blue-700">See the full $(HtmlEncode $tool.name) alternatives list →</a>
  </section>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Beyond pricing</h2>
      <div class="mt-4 grid sm:grid-cols-3 gap-3">
        <a href="../../tool/$($tool.categorySlug)/$($tool.slug).html" class="eco-cta"><span class="eco-cta-icon">i</span><div><div class="eco-cta-title">Tool overview</div><div class="eco-cta-sub">What it does, pros and cons</div></div></a>
        <a href="../../alternatives/$($tool.slug)/" class="eco-cta"><span class="eco-cta-icon">↔</span><div><div class="eco-cta-title">Alternatives</div><div class="eco-cta-sub">$(($tool.alternativesTo).Count) commonly compared options</div></div></a>
        <a href="$(AttrEncode $tool.url)" target="_blank" rel="noopener noreferrer" class="eco-cta"><span class="eco-cta-icon">→</span><div><div class="eco-cta-title">Official site</div><div class="eco-cta-sub">Current pricing &amp; demo</div></div></a>
      </div>
    </div>
  </section>

  $(Email-Capture-Html -context "pricing-$($tool.slug)")
</main>
"@

    $html = HtmlShell `
        -title "$($tool.name) Pricing &mdash; Plans, Tiers & What Teams Actually Pay | Deryck" `
        -description "How much does $($tool.name) cost? Tier breakdown, pricing model, and how it compares to alternatives. Updated reference for contractor teams." `
        -canonicalRelative "pricing/$($tool.slug)/" `
        -depth 2 `
        -body $body

    $dir = Join-Path $distDir "pricing\$($tool.slug)"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 2) ALTERNATIVES PAGES /alternatives/<slug>/
# ==================================================================
function Build-AlternativesPage {
    param($tool)
    $shortCat = Get-ShortCatName $tool.categorySlug

    $crumb = Breadcrumb-Html @(
        @{ label='Home';                                 href='../../index.html' },
        @{ label='Alternatives';                         href='../index.html' },
        @{ label="$($tool.name) alternatives";           href='' }
    )
    $icon = ToolIcon -tool $tool -depth 2 -sizeClass 'lg'

    $altCards = ''
    foreach ($alt in ($tool.alternativesTo)) {
        $altT = Get-Tool $alt.slug
        if (-not $altT) { continue }
        $altIcon = ToolIcon -tool $altT -depth 2
        $whyText = if ($altT.useCases -and $tool.useCases) {
            $shared = @($altT.useCases | Where-Object { $tool.useCases -contains $_ } | Select-Object -First 2)
            if ($shared.Count -gt 0) { 'Overlaps on ' + ($shared -join ', ') + '.' } else { 'Similar trade focus.' }
        } else { 'Similar workflow coverage.' }

        $vsLink = ''
        $existsLeftRight = $curated.vsPairs | Where-Object { ($_.left -eq $tool.slug -and $_.right -eq $altT.slug) -or ($_.left -eq $altT.slug -and $_.right -eq $tool.slug) } | Select-Object -First 1
        if ($existsLeftRight) {
            $vsLink = '<a href="../../compare/' + $existsLeftRight.left + '-vs-' + $existsLeftRight.right + '/" class="text-xs font-semibold text-blue-600 hover:text-blue-700">View head-to-head →</a>'
        }

        $altCards += @"
<div class="bg-white border border-slate-200 rounded-2xl p-5 flex flex-col gap-4 h-full">
  <div class="flex items-start gap-4">
    $altIcon
    <div class="flex-grow min-w-0">
      <a href="../../tool/$($altT.categorySlug)/$($altT.slug).html" class="font-bold text-slate-900 hover:text-blue-600">$(HtmlEncode $altT.name)</a>
      <div class="text-xs text-slate-500 mt-0.5">$(HtmlEncode $altT.domain)</div>
    </div>
    $(Format-PriceBadge $altT.priceBand)
  </div>
  <p class="text-sm text-slate-700 leading-relaxed">$(HtmlEncode $altT.description)</p>
  <p class="text-xs text-slate-500">$whyText</p>
  <div class="flex items-center justify-between pt-2 border-t border-slate-100">
    <a href="../../pricing/$($altT.slug)/" class="text-xs font-semibold text-blue-600 hover:text-blue-700">Pricing →</a>
    $vsLink
  </div>
</div>
"@
    }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-5xl mx-auto px-6 pt-10 pb-6">$crumb</div>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-8 md:p-10 shadow-sm">
      <div class="flex flex-col md:flex-row md:items-center gap-6">
        $icon
        <div class="flex-grow min-w-0">
          <span class="chip">Alternatives</span>
          <h1 class="mt-3 text-3xl md:text-4xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $tool.name) Alternatives</h1>
          <div class="mt-2 text-sm text-slate-500">$(HtmlEncode $shortCat) &middot; $(($tool.alternativesTo).Count) commonly compared options</div>
        </div>
      </div>
      <div class="divider"></div>
      <p class="text-base md:text-lg text-slate-700 leading-relaxed">If $(HtmlEncode $tool.name) isn't the right fit &mdash; too expensive, missing a feature, or not built for your trade &mdash; these are the tools contractor teams typically evaluate next. Each handles a similar slice of the workflow but with different trade-offs.</p>
    </div>
  </section>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="grid sm:grid-cols-2 gap-4">$altCards</div>
  </section>

  <section class="max-w-5xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Still on $(HtmlEncode $tool.name)?</h2>
      <p class="mt-3 text-slate-700">Sometimes the right move is to stay with the platform you have and tune it. Compare $(HtmlEncode $tool.name) head-to-head with the leading alternative below, or read the pricing breakdown to confirm you're on the right tier.</p>
      <div class="mt-4 grid sm:grid-cols-2 gap-3">
        <a href="../../tool/$($tool.categorySlug)/$($tool.slug).html" class="eco-cta"><span class="eco-cta-icon">i</span><div><div class="eco-cta-title">$(HtmlEncode $tool.name) overview</div><div class="eco-cta-sub">What it does, strengths &amp; trade-offs</div></div></a>
        <a href="../../pricing/$($tool.slug)/" class="eco-cta"><span class="eco-cta-icon">$</span><div><div class="eco-cta-title">$(HtmlEncode $tool.name) pricing</div><div class="eco-cta-sub">Tiers and typical totals</div></div></a>
      </div>
    </div>
  </section>

  $(Email-Capture-Html -context "alternatives-$($tool.slug)")
</main>
"@

    $html = HtmlShell `
        -title "$($tool.name) Alternatives &mdash; 6 Options Contractors Switch To | Deryck" `
        -description "If $($tool.name) isn't the right fit, here are six platforms commonly evaluated alongside it. Pricing, trade focus, and head-to-head comparisons." `
        -canonicalRelative "alternatives/$($tool.slug)/" `
        -depth 2 `
        -body $body

    $dir = Join-Path $distDir "alternatives\$($tool.slug)"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 3) VS COMPARISON PAGES /compare/<a>-vs-<b>/
# ==================================================================
function Build-VsPage {
    param($leftSlug, $rightSlug)
    $a = Get-Tool $leftSlug
    $b = Get-Tool $rightSlug
    if (-not $a -or -not $b) { return }

    $crumb = Breadcrumb-Html @(
        @{ label='Home';     href='../../index.html' },
        @{ label='Compare';  href='../index.html' },
        @{ label="$($a.name) vs $($b.name)"; href='' }
    )
    $iconA = ToolIcon -tool $a -depth 2 -sizeClass 'lg'
    $iconB = ToolIcon -tool $b -depth 2 -sizeClass 'lg'

    # Build comparison rows
    function Row {
        param([string]$label, [string]$valA, [string]$valB)
        return @"
<div class="cmp-row">
  <div class="cmp-label">$(HtmlEncode $label)</div>
  <div class="cmp-val">$valA</div>
  <div class="cmp-val">$valB</div>
</div>
"@
    }
    function ListVal { param([string[]]$arr) if ($arr) { return ($arr | ForEach-Object { HtmlEncode $_ }) -join ', ' } else { return '<span class="text-slate-400">—</span>' } }

    $rows  = Row 'Best for trades'      (ListVal $a.trades)        (ListVal $b.trades)
    $rows += Row 'Best for team size'   (ListVal $a.companySizes)  (ListVal $b.companySizes)
    $rows += Row 'Primary use cases'    (ListVal $a.useCases)      (ListVal $b.useCases)
    $rows += Row 'Pricing band'         (HtmlEncode $a.priceBand)  (HtmlEncode $b.priceBand)
    $rows += Row 'Implementation'       (HtmlEncode $a.implementationDifficulty) (HtmlEncode $b.implementationDifficulty)
    $rows += Row 'Integrations (sample)' (ListVal ($a.integrations | Select-Object -First 4)) (ListVal ($b.integrations | Select-Object -First 4))

    # Pros/cons side-by-side
    function ProsCons { param($tool)
        $proHtml = '';   foreach ($p in $tool.pros) { $proHtml += '<li class="flex gap-2 items-start"><span class="text-green-600 font-bold mt-0.5">+</span><span>' + (HtmlEncode $p) + '</span></li>' }
        $conHtml = '';   foreach ($c in $tool.cons) { $conHtml += '<li class="flex gap-2 items-start"><span class="text-rose-500 font-bold mt-0.5">−</span><span>' + (HtmlEncode $c) + '</span></li>' }
        return @"
<div>
  <h3 class="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Strengths</h3>
  <ul class="space-y-2 text-sm text-slate-700">$proHtml</ul>
  <h3 class="text-xs font-bold uppercase tracking-widest text-slate-500 mt-5 mb-2">Trade-offs</h3>
  <ul class="space-y-2 text-sm text-slate-700">$conHtml</ul>
</div>
"@
    }

    # Verdict (deterministic from data)
    $verdictLines = @()
    if ($a.priceBand -ne $b.priceBand) {
        $cheaper = if (@('Free','Under $100/mo','$100-$500/mo','Enterprise').IndexOf($a.priceBand) -lt @('Free','Under $100/mo','$100-$500/mo','Enterprise').IndexOf($b.priceBand)) { $a.name } else { $b.name }
        $verdictLines += "If price is the deciding factor, $cheaper sits in the more affordable band."
    }
    $aSizes = if ($a.companySizes) { $a.companySizes } else { @() }
    $bSizes = if ($b.companySizes) { $b.companySizes } else { @() }
    if ($aSizes -contains 'Enterprise' -and -not ($bSizes -contains 'Enterprise')) { $verdictLines += "$($a.name) scales further into enterprise; $($b.name) is the simpler pick for smaller teams." }
    elseif ($bSizes -contains 'Enterprise' -and -not ($aSizes -contains 'Enterprise')) { $verdictLines += "$($b.name) scales further into enterprise; $($a.name) is the simpler pick for smaller teams." }
    $aTrades = if ($a.trades) { $a.trades } else { @() }
    $bTrades = if ($b.trades) { $b.trades } else { @() }
    $sharedTrades = @($aTrades | Where-Object { $bTrades -contains $_ })
    if ($sharedTrades.Count -gt 0) { $verdictLines += "Both serve $(($sharedTrades -join ', ').ToLower()) contractors well; the choice usually comes down to feature depth and team size." }
    $verdictText = $verdictLines -join ' '

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-6xl mx-auto px-6 pt-10 pb-6">$crumb</div>

  <section class="max-w-6xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-8 md:p-10 shadow-sm text-center">
      <span class="chip">Head-to-head</span>
      <h1 class="mt-3 text-3xl md:text-4xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $a.name) vs $(HtmlEncode $b.name)</h1>
      <p class="mt-3 text-base text-slate-600 max-w-2xl mx-auto">A side-by-side comparison of two tools contractor teams frequently evaluate against each other &mdash; with the differences that actually matter.</p>

      <div class="mt-8 grid sm:grid-cols-2 gap-4 max-w-4xl mx-auto">
        <a href="../../tool/$($a.categorySlug)/$($a.slug).html" class="bg-slate-50 border border-slate-200 rounded-xl p-5 flex items-center gap-4 hover:border-blue-300 transition">
          $iconA
          <div class="text-left">
            <div class="font-bold text-slate-900">$(HtmlEncode $a.name)</div>
            <div class="text-xs text-slate-500">$(HtmlEncode $a.domain)</div>
            <div class="mt-2">$(Format-PriceBadge $a.priceBand)</div>
          </div>
        </a>
        <a href="../../tool/$($b.categorySlug)/$($b.slug).html" class="bg-slate-50 border border-slate-200 rounded-xl p-5 flex items-center gap-4 hover:border-blue-300 transition">
          $iconB
          <div class="text-left">
            <div class="font-bold text-slate-900">$(HtmlEncode $b.name)</div>
            <div class="text-xs text-slate-500">$(HtmlEncode $b.domain)</div>
            <div class="mt-2">$(Format-PriceBadge $b.priceBand)</div>
          </div>
        </a>
      </div>
    </div>
  </section>

  <section class="max-w-6xl mx-auto px-6 pb-10">
    <h2 class="text-lg font-bold text-slate-900 mb-3">Side-by-side</h2>
    <div class="bg-white border border-slate-200 rounded-xl">
      <div class="cmp-row" style="background:#F8FAFC;">
        <div class="cmp-label">&nbsp;</div>
        <div class="font-bold text-slate-900">$(HtmlEncode $a.name)</div>
        <div class="font-bold text-slate-900">$(HtmlEncode $b.name)</div>
      </div>
      $rows
    </div>
  </section>

  <section class="max-w-6xl mx-auto px-6 pb-10">
    <h2 class="text-lg font-bold text-slate-900 mb-4">Strengths &amp; trade-offs</h2>
    <div class="grid md:grid-cols-2 gap-6">
      <div class="bg-white border border-slate-200 rounded-2xl p-6">
        <h3 class="text-base font-bold text-slate-900">$(HtmlEncode $a.name)</h3>
        $(ProsCons $a)
      </div>
      <div class="bg-white border border-slate-200 rounded-2xl p-6">
        <h3 class="text-base font-bold text-slate-900">$(HtmlEncode $b.name)</h3>
        $(ProsCons $b)
      </div>
    </div>
  </section>

  <section class="max-w-6xl mx-auto px-6 pb-10">
    <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Bottom line</h2>
      <p class="mt-3 text-base md:text-lg text-slate-800 leading-relaxed">$(HtmlEncode $verdictText)</p>
      <div class="mt-5 grid sm:grid-cols-2 gap-3">
        <a href="../../pricing/$($a.slug)/" class="eco-cta"><span class="eco-cta-icon">$</span><div><div class="eco-cta-title">$(HtmlEncode $a.name) pricing</div><div class="eco-cta-sub">See tier breakdown</div></div></a>
        <a href="../../pricing/$($b.slug)/" class="eco-cta"><span class="eco-cta-icon">$</span><div><div class="eco-cta-title">$(HtmlEncode $b.name) pricing</div><div class="eco-cta-sub">See tier breakdown</div></div></a>
        <a href="../../alternatives/$($a.slug)/" class="eco-cta"><span class="eco-cta-icon">↔</span><div><div class="eco-cta-title">$(HtmlEncode $a.name) alternatives</div><div class="eco-cta-sub">More options like $(HtmlEncode $a.name)</div></div></a>
        <a href="../../alternatives/$($b.slug)/" class="eco-cta"><span class="eco-cta-icon">↔</span><div><div class="eco-cta-title">$(HtmlEncode $b.name) alternatives</div><div class="eco-cta-sub">More options like $(HtmlEncode $b.name)</div></div></a>
      </div>
    </div>
  </section>

  $(Email-Capture-Html -context "compare-$($a.slug)-vs-$($b.slug)")
</main>
"@

    $html = HtmlShell `
        -title "$($a.name) vs $($b.name) &mdash; Side-by-Side Comparison | Deryck" `
        -description "$($a.name) vs $($b.name) for contractors: pricing, trade focus, integrations, and the differences that actually matter when you're choosing." `
        -canonicalRelative "compare/$leftSlug-vs-$rightSlug/" `
        -depth 2 `
        -body $body

    $dir = Join-Path $distDir "compare\$leftSlug-vs-$rightSlug"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 4) BEST-FOR HUB PAGES /best/<slug>/
# ==================================================================
function Build-BestForHub {
    param($hub)
    $matches = Filter-Tools -filter $hub.filter | Select-Object -First 24

    $crumb = Breadcrumb-Html @(
        @{ label='Home';      href='../../index.html' },
        @{ label='Best Of';   href='../index.html' },
        @{ label=$hub.title;  href='' }
    )

    $cards = ''
    foreach ($t in $matches) {
        $cards += ToolCard-Compact -tool $t -depth 2
    }
    if (-not $cards) { $cards = '<div class="bg-white border border-slate-200 rounded-xl p-8 text-center text-slate-500">No matching tools yet. <a class="text-blue-600 font-semibold" href="../">Browse other guides →</a></div>' }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-6xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-6xl mx-auto px-6 pb-10">
    <div class="max-w-3xl">
      <span class="chip">Best Of</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $hub.h1)</h1>
      <p class="mt-4 text-lg text-slate-600 leading-relaxed">$(HtmlEncode $hub.intro)</p>
      <p class="mt-2 text-sm text-slate-500">$($matches.Count) tools matching this filter.</p>
    </div>
  </section>
  <section class="max-w-6xl mx-auto px-6 pb-20">
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$cards</div>
  </section>
  $(Email-Capture-Html -context "best-$($hub.slug)")
</main>
"@
    $html = HtmlShell `
        -title "$($hub.title) | Deryck" `
        -description $hub.intro `
        -canonicalRelative "best/$($hub.slug)/" `
        -depth 2 `
        -body $body
    $dir = Join-Path $distDir "best\$($hub.slug)"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 5) TRADE HUB /trade/<slug>/
# ==================================================================
function Build-TradeHub {
    param($hub)
    $matches = Filter-Tools -filter @{ trade=$hub.trade } | Select-Object -First 36

    $crumb = Breadcrumb-Html @(
        @{ label='Home';      href='../../index.html' },
        @{ label='Trades';    href='../index.html' },
        @{ label=$hub.title;  href='' }
    )

    $cards = ''
    foreach ($t in $matches) { $cards += ToolCard-Compact -tool $t -depth 2 }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-6xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-6xl mx-auto px-6 pb-10">
    <div class="max-w-3xl">
      <span class="chip">$(HtmlEncode $hub.trade)</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $hub.title)</h1>
      <p class="mt-4 text-lg text-slate-600 leading-relaxed">$(HtmlEncode $hub.intro)</p>
      <p class="mt-2 text-sm text-slate-500">$($matches.Count) tools tuned for $(HtmlEncode $hub.trade.ToLower()) contractors.</p>
    </div>
  </section>
  <section class="max-w-6xl mx-auto px-6 pb-20">
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$cards</div>
  </section>
  $(Email-Capture-Html -context "trade-$($hub.slug)")
</main>
"@
    $html = HtmlShell `
        -title "$($hub.title) | Deryck" `
        -description $hub.intro `
        -canonicalRelative "trade/$($hub.slug)/" `
        -depth 2 `
        -body $body
    $dir = Join-Path $distDir "trade\$($hub.slug)"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 6) SOFTWARE CATEGORY HUB /software-category/<slug>/
# ==================================================================
function Build-SoftwareHub {
    param($hub)
    $matches = Filter-Tools -filter @{ useCase=$hub.useCase } | Select-Object -First 36

    $crumb = Breadcrumb-Html @(
        @{ label='Home';     href='../../index.html' },
        @{ label='Software'; href='../index.html' },
        @{ label=$hub.title; href='' }
    )

    $cards = ''
    foreach ($t in $matches) { $cards += ToolCard-Compact -tool $t -depth 2 }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-6xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-6xl mx-auto px-6 pb-10">
    <div class="max-w-3xl">
      <span class="chip">$(HtmlEncode $hub.useCase)</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $hub.title)</h1>
      <p class="mt-4 text-lg text-slate-600 leading-relaxed">$(HtmlEncode $hub.intro)</p>
      <p class="mt-2 text-sm text-slate-500">$($matches.Count) platforms in this category.</p>
    </div>
  </section>
  <section class="max-w-6xl mx-auto px-6 pb-20">
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$cards</div>
  </section>
  $(Email-Capture-Html -context "soft-$($hub.slug)")
</main>
"@
    $html = HtmlShell `
        -title "$($hub.title) | Deryck" `
        -description $hub.intro `
        -canonicalRelative "software-category/$($hub.slug)/" `
        -depth 2 `
        -body $body
    $dir = Join-Path $distDir "software-category\$($hub.slug)"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 7) WORKFLOW GUIDES /workflow/<slug>/
# ==================================================================
function Build-WorkflowPage {
    param($wf)

    $crumb = Breadcrumb-Html @(
        @{ label='Home';      href='../../index.html' },
        @{ label='Workflows'; href='../index.html' },
        @{ label=$wf.title;   href='' }
    )

    $sectionsHtml = ''
    foreach ($s in $wf.sections) {
        $toolChips = ''
        foreach ($slug in $s.tools) {
            $tt = Get-Tool $slug
            if ($tt) {
                $toolChips += '<a href="../../tool/' + $tt.categorySlug + '/' + $tt.slug + '.html" class="hub-pill">' + (HtmlEncode $tt.name) + ' →</a>'
            }
        }
        $sectionsHtml += @"
<section class="max-w-3xl mx-auto px-6 pb-10">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">$(HtmlEncode $s.heading)</h2>
  <p class="mt-3 text-base text-slate-700 leading-relaxed">$(HtmlEncode $s.body)</p>
  <div class="mt-4 flex flex-wrap gap-2">$toolChips</div>
</section>
"@
    }

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-3xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-3xl mx-auto px-6 pb-10">
    <span class="chip">Workflow guide</span>
    <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $wf.title)</h1>
    <p class="mt-5 text-lg text-slate-700 leading-relaxed">$(HtmlEncode $wf.intro)</p>
  </section>
  $sectionsHtml
  <section class="max-w-3xl mx-auto px-6 pb-12">
    <div class="bg-white border border-slate-200 rounded-2xl p-6 md:p-7">
      <h2 class="text-xs font-bold uppercase tracking-widest text-slate-500">Takeaway</h2>
      <p class="mt-3 text-base md:text-lg text-slate-800 leading-relaxed">$(HtmlEncode $wf.outro)</p>
    </div>
  </section>
  $(Email-Capture-Html -context "workflow-$($wf.slug)")
</main>
"@
    $html = HtmlShell `
        -title "$($wf.title) | Deryck" `
        -description $wf.intro `
        -canonicalRelative "workflow/$($wf.slug)/" `
        -depth 2 `
        -body $body
    $dir = Join-Path $distDir "workflow\$($wf.slug)"
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 8) INDEX PAGES (one per ecosystem section: /pricing/, /best/, etc.)
# ==================================================================

function Build-EcosystemIndex {
    param([string]$folder, [string]$title, [string]$intro, [array]$entries, [string]$context)
    # entries: array of @{ href; title; sub }
    $crumb = Breadcrumb-Html @(
        @{ label='Home';  href='../index.html' },
        @{ label=$title;  href='' }
    )
    $cards = ''
    foreach ($e in $entries) {
        $cards += @"
<a href="$($e.href)" class="cat-tile p-5 flex flex-col gap-2">
  <div class="text-xs font-semibold uppercase tracking-wider text-blue-600">$($e.tag)</div>
  <h3 class="text-base font-bold text-slate-900">$(HtmlEncode $e.title)</h3>
  <p class="text-sm text-slate-600 leading-relaxed flex-grow">$(HtmlEncode $e.sub)</p>
</a>
"@
    }
    $body = @"
<main class="bg-blueprint">
  <div class="max-w-7xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-7xl mx-auto px-6 pb-10">
    <div class="max-w-3xl">
      <span class="chip">$(HtmlEncode $title)</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">$(HtmlEncode $title)</h1>
      <p class="mt-4 text-lg text-slate-600 leading-relaxed">$(HtmlEncode $intro)</p>
      <p class="mt-2 text-sm text-slate-500">$($entries.Count) entries</p>
    </div>
  </section>
  <section class="max-w-7xl mx-auto px-6 pb-20">
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">$cards</div>
  </section>
  $(Email-Capture-Html -context $context)
</main>
"@
    $html = HtmlShell `
        -title "$title | Deryck" `
        -description $intro `
        -canonicalRelative "$folder/" `
        -depth 1 `
        -body $body
    $dir = Join-Path $distDir $folder
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 9) INTERACTIVE DIRECTORY /directory/
#    Client-side JS-driven filter UI over all 300 tools.
# ==================================================================
function Build-Directory {
    # Emit a JS data blob with the flat tool list for client-side filtering.
    # Dedupe by slug — same tool can live in multiple categories.
    $seen = @{}
    $flat = @()
    foreach ($c in $data.categories) {
        foreach ($t in $c.tools) {
            if ($seen.ContainsKey($t.slug)) { continue }
            $seen[$t.slug] = $true
            $flat += [PSCustomObject]@{
                slug         = $t.slug
                name         = $t.name
                description  = $t.description
                url          = $t.url
                domain       = $t.domain
                categorySlug = $c.slug
                trades       = @($t.trades)
                companySizes = @($t.companySizes)
                useCases     = @($t.useCases)
                priceBand    = $t.priceBand
            }
        }
    }
    $blob = $flat | ConvertTo-Json -Depth 5 -Compress

    $tradesPills   = ($data.taxonomies.trades   | ForEach-Object { '<span class="filter-pill" data-filter="trade" data-value="'   + $_ + '">' + (HtmlEncode $_) + '</span>' }) -join ''
    $sizesPills    = ($data.taxonomies.sizes    | ForEach-Object { '<span class="filter-pill" data-filter="size" data-value="'    + $_ + '">' + (HtmlEncode $_) + '</span>' }) -join ''
    $useCasesPills = ($data.taxonomies.useCases | ForEach-Object { '<span class="filter-pill" data-filter="useCase" data-value="' + $_ + '">' + (HtmlEncode $_) + '</span>' }) -join ''
    $bandsPills    = ($data.taxonomies.bands    | ForEach-Object { '<span class="filter-pill" data-filter="band" data-value="'    + ($_ -replace '"','') + '">' + (HtmlEncode $_) + '</span>' }) -join ''

    $crumb = Breadcrumb-Html @(
        @{ label='Home';      href='../index.html' },
        @{ label='Directory'; href='' }
    )

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-7xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-7xl mx-auto px-6 pb-10">
    <div class="max-w-3xl">
      <span class="chip">All 300 tools</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">The Contractor Software Directory</h1>
      <p class="mt-4 text-lg text-slate-600 leading-relaxed">Filter every tool we track by trade, team size, use case, and budget. No rankings &mdash; just the matches that fit your criteria.</p>
    </div>
  </section>

  <section class="max-w-7xl mx-auto px-6 pb-6">
    <div class="bg-white border border-slate-200 rounded-2xl p-6">
      <div class="flex items-center gap-3 mb-4">
        <input type="search" id="dir-search" placeholder="Search by tool name (e.g. Procore, ServiceTitan)" class="flex-grow px-4 py-2.5 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500">
        <button id="dir-clear" class="text-sm font-semibold text-slate-600 hover:text-blue-600 px-3 py-2">Clear all</button>
      </div>
      <div class="space-y-3">
        <div>
          <div class="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Trade</div>
          <div class="flex flex-wrap gap-2" id="dir-trade-pills">$tradesPills</div>
        </div>
        <div>
          <div class="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Team size</div>
          <div class="flex flex-wrap gap-2" id="dir-size-pills">$sizesPills</div>
        </div>
        <div>
          <div class="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Use case</div>
          <div class="flex flex-wrap gap-2" id="dir-usecase-pills">$useCasesPills</div>
        </div>
        <div>
          <div class="text-xs font-bold uppercase tracking-widest text-slate-500 mb-2">Budget</div>
          <div class="flex flex-wrap gap-2" id="dir-band-pills">$bandsPills</div>
        </div>
      </div>
    </div>
  </section>

  <section class="max-w-7xl mx-auto px-6 pb-20">
    <div class="flex items-center justify-between mb-4">
      <div class="text-sm text-slate-600"><span id="dir-count" class="font-semibold text-slate-900">300</span> tools shown</div>
    </div>
    <div id="dir-results" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4"></div>
    <div id="dir-empty" class="hidden bg-white border border-slate-200 rounded-xl p-10 text-center text-slate-500">
      No tools match those filters. <button id="dir-reset" class="text-blue-600 font-semibold hover:text-blue-700">Reset filters</button>
    </div>
  </section>

  $(Email-Capture-Html -context "directory")
</main>

<script>
const TOOLS = $blob;
const FILTERS = { trade: new Set(), size: new Set(), useCase: new Set(), band: new Set(), q: '' };

function render() {
  const q = FILTERS.q.toLowerCase().trim();
  const filtered = TOOLS.filter(t => {
    if (FILTERS.trade.size   && !t.trades.some(x => FILTERS.trade.has(x)))     return false;
    if (FILTERS.size.size    && !t.companySizes.some(x => FILTERS.size.has(x))) return false;
    if (FILTERS.useCase.size && !t.useCases.some(x => FILTERS.useCase.has(x))) return false;
    if (FILTERS.band.size    && !FILTERS.band.has(t.priceBand))                 return false;
    if (q                    && !t.name.toLowerCase().includes(q) && !t.description.toLowerCase().includes(q)) return false;
    return true;
  });
  document.getElementById('dir-count').textContent = filtered.length;
  const results = document.getElementById('dir-results');
  const empty   = document.getElementById('dir-empty');
  if (filtered.length === 0) {
    results.classList.add('hidden'); empty.classList.remove('hidden'); return;
  }
  results.classList.remove('hidden'); empty.classList.add('hidden');
  results.innerHTML = filtered.slice(0, 200).map(t => {
    const iconUrl = t.domain ? '../assets/icons/' + t.domain + '.ico' : '';
    const iconHtml = iconUrl
      ? '<div class="tool-icon"><img src="' + iconUrl + '" alt="" loading="lazy" onerror="this.outerHTML=\'<div class=icon-fallback>' + t.name[0] + '</div>\'"></div>'
      : '<div class="tool-icon"><div class="icon-fallback">' + t.name[0] + '</div></div>';
    return ''
      + '<a href="../tool/' + t.categorySlug + '/' + t.slug + '.html" class="tool-card bg-white border border-slate-200 rounded-xl p-5 flex flex-col gap-4 h-full">'
      + '<div class="flex items-start gap-4">' + iconHtml
      + '<div class="flex-grow min-w-0"><h3 class="font-semibold text-slate-900 leading-tight truncate">' + t.name + '</h3>'
      + '<div class="text-xs text-slate-500 mt-1 truncate">' + (t.domain||'') + '</div></div></div>'
      + '<p class="text-sm text-slate-600 leading-relaxed line-clamp-3 flex-grow">' + t.description + '</p>'
      + '<div class="flex items-center justify-between pt-2 border-t border-slate-100">'
      + '<span class="chip chip-soft">' + (t.priceBand||'') + '</span>'
      + '<span class="text-xs font-semibold text-blue-600">Details →</span></div></a>';
  }).join('');
}

document.querySelectorAll('.filter-pill').forEach(pill => {
  pill.addEventListener('click', () => {
    const kind = pill.dataset.filter; const value = pill.dataset.value;
    const set = FILTERS[kind];
    if (set.has(value)) { set.delete(value); pill.classList.remove('active'); }
    else { set.add(value); pill.classList.add('active'); }
    render();
  });
});
document.getElementById('dir-search').addEventListener('input', e => { FILTERS.q = e.target.value; render(); });
function resetAll() {
  ['trade','size','useCase','band'].forEach(k => FILTERS[k].clear());
  FILTERS.q = '';
  document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
  document.getElementById('dir-search').value = '';
  render();
}
document.getElementById('dir-clear').addEventListener('click', resetAll);
document.getElementById('dir-reset').addEventListener('click', resetAll);
render();
</script>
"@

    $html = HtmlShell `
        -title 'Directory — Filter 300 Contractor Tools by Trade, Size, Use Case & Budget | Deryck' `
        -description 'Interactive directory of every contractor tool we track. Filter by trade (plumbing, HVAC, GC...), team size, use case, and budget band.' `
        -canonicalRelative 'directory/' `
        -depth 1 `
        -body $body

    $dir = Join-Path $distDir 'directory'
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 10) RECOMMENDATION QUIZ /quiz/
# ==================================================================
function Build-Quiz {
    # Emit data + a small SPA in one HTML file (dedupe by slug)
    $seen = @{}
    $flat = @()
    foreach ($c in $data.categories) {
        foreach ($t in $c.tools) {
            if ($seen.ContainsKey($t.slug)) { continue }
            $seen[$t.slug] = $true
            $flat += [PSCustomObject]@{
                slug=$t.slug; name=$t.name; description=$t.description; categorySlug=$c.slug;
                trades=@($t.trades); companySizes=@($t.companySizes); useCases=@($t.useCases); priceBand=$t.priceBand
            }
        }
    }
    $blob = $flat | ConvertTo-Json -Depth 5 -Compress

    $crumb = Breadcrumb-Html @(
        @{ label='Home'; href='../index.html' },
        @{ label='Find My Stack'; href='' }
    )

    $body = @"
<main class="bg-blueprint">
  <div class="max-w-3xl mx-auto px-6 pt-10 pb-6">$crumb</div>
  <section class="max-w-3xl mx-auto px-6 pb-20">
    <div class="text-center mb-8">
      <span class="chip">Recommendation engine</span>
      <h1 class="mt-3 text-3xl md:text-5xl font-extrabold tracking-tight text-slate-900">Find your contractor stack</h1>
      <p class="mt-3 text-base md:text-lg text-slate-600">Four quick questions. We'll point you at the tools real contracting businesses your size actually use.</p>
    </div>

    <div id="quiz-app" class="quiz-card">
      <!-- Progress -->
      <div class="flex items-center justify-between text-xs text-slate-500 font-semibold uppercase tracking-widest mb-6">
        <span>Step <span id="q-step">1</span> of 4</span>
        <span id="q-progress">25%</span>
      </div>
      <div class="h-1 bg-slate-100 rounded-full mb-7"><div id="q-bar" class="h-1 bg-blue-600 rounded-full" style="width:25%"></div></div>

      <!-- Step 1: Trade -->
      <div data-step="1">
        <h2 class="text-xl font-bold text-slate-900">What trade are you in?</h2>
        <div class="mt-5 grid sm:grid-cols-2 gap-2">
          <div class="quiz-option" data-key="trade" data-val="Plumbing">🚿 Plumbing</div>
          <div class="quiz-option" data-key="trade" data-val="HVAC">❄️ HVAC</div>
          <div class="quiz-option" data-key="trade" data-val="Mechanical">⚙️ Mechanical</div>
          <div class="quiz-option" data-key="trade" data-val="Electrical">⚡ Electrical</div>
          <div class="quiz-option" data-key="trade" data-val="Roofing">🏠 Roofing</div>
          <div class="quiz-option" data-key="trade" data-val="GC">🏗️ General Contractor</div>
          <div class="quiz-option" data-key="trade" data-val="Commercial">🏢 Commercial</div>
        </div>
      </div>

      <!-- Step 2: Size -->
      <div data-step="2" hidden>
        <h2 class="text-xl font-bold text-slate-900">How many people on the team?</h2>
        <div class="mt-5 space-y-2">
          <div class="quiz-option" data-key="size" data-val="Solo">Just me (1 person)</div>
          <div class="quiz-option" data-key="size" data-val="Small">Small (2-10)</div>
          <div class="quiz-option" data-key="size" data-val="Medium">Medium (11-100)</div>
          <div class="quiz-option" data-key="size" data-val="Enterprise">Enterprise (100+)</div>
        </div>
      </div>

      <!-- Step 3: Use Case -->
      <div data-step="3" hidden>
        <h2 class="text-xl font-bold text-slate-900">What's the most important thing the software needs to do?</h2>
        <div class="mt-5 grid sm:grid-cols-2 gap-2">
          <div class="quiz-option" data-key="useCase" data-val="CRM">Manage leads &amp; customers (CRM)</div>
          <div class="quiz-option" data-key="useCase" data-val="Scheduling">Schedule &amp; dispatch jobs</div>
          <div class="quiz-option" data-key="useCase" data-val="Estimating">Estimate &amp; price work</div>
          <div class="quiz-option" data-key="useCase" data-val="ProjectManagement">Manage projects end-to-end</div>
          <div class="quiz-option" data-key="useCase" data-val="Accounting">Run the books / job costing</div>
          <div class="quiz-option" data-key="useCase" data-val="FieldManagement">Coordinate field teams</div>
          <div class="quiz-option" data-key="useCase" data-val="TimeTracking">Track time on the jobsite</div>
          <div class="quiz-option" data-key="useCase" data-val="Safety">Run safety / compliance</div>
        </div>
      </div>

      <!-- Step 4: Budget -->
      <div data-step="4" hidden>
        <h2 class="text-xl font-bold text-slate-900">Budget range?</h2>
        <div class="mt-5 space-y-2">
          <div class="quiz-option" data-key="band" data-val="Free">Free / minimal cost</div>
          <div class="quiz-option" data-key="band" data-val="Under \$100/mo">Under \$100/month</div>
          <div class="quiz-option" data-key="band" data-val="\$100-\$500/mo">\$100-\$500/month</div>
          <div class="quiz-option" data-key="band" data-val="Enterprise">Enterprise (custom quote)</div>
        </div>
      </div>

      <!-- Results -->
      <div data-step="5" hidden>
        <h2 class="text-xl font-bold text-slate-900">Your shortlist</h2>
        <p class="text-sm text-slate-600 mt-1">Based on your answers, these are the tools we'd point you at first.</p>
        <div id="quiz-results" class="mt-5 space-y-3"></div>
        <button id="quiz-restart" class="mt-6 text-sm font-semibold text-blue-600 hover:text-blue-700">← Start over</button>
      </div>
    </div>
  </section>

  $(Email-Capture-Html -context "quiz")
</main>

<script>
const QTOOLS = $blob;
const QSTATE = {};
let qStep = 1;

function show(step){
  qStep = step;
  document.querySelectorAll('[data-step]').forEach(el => el.hidden = (parseInt(el.dataset.step)!==step));
  const pct = step <= 4 ? (step*25) : 100;
  document.getElementById('q-step').textContent = Math.min(step,4);
  document.getElementById('q-progress').textContent = pct + '%';
  document.getElementById('q-bar').style.width = pct + '%';
  if (step === 5) computeResults();
}

document.querySelectorAll('.quiz-option').forEach(opt => {
  opt.addEventListener('click', () => {
    const k = opt.dataset.key; const v = opt.dataset.val;
    QSTATE[k] = v;
    opt.parentElement.querySelectorAll('.quiz-option').forEach(o => o.classList.remove('selected'));
    opt.classList.add('selected');
    setTimeout(() => show(qStep+1), 220);
  });
});

function computeResults(){
  const scored = QTOOLS.map(t => {
    let s = 0;
    if (QSTATE.trade   && t.trades.includes(QSTATE.trade))         s += 3;
    if (QSTATE.size    && t.companySizes.includes(QSTATE.size))    s += 2;
    if (QSTATE.useCase && t.useCases.includes(QSTATE.useCase))     s += 3;
    if (QSTATE.band    && t.priceBand === QSTATE.band)             s += 2;
    return { t, s };
  }).filter(x => x.s > 0).sort((a,b) => b.s - a.s).slice(0, 6);
  const out = document.getElementById('quiz-results');
  out.innerHTML = scored.length === 0
    ? '<div class="text-slate-500">No exact matches — try broadening your criteria. <a href="../directory/" class="text-blue-600 font-semibold">Browse the full directory →</a></div>'
    : scored.map(x => {
        const t = x.t;
        return ''
          + '<a href="../tool/' + t.categorySlug + '/' + t.slug + '.html" class="quiz-option" style="text-decoration:none">'
          + '<div class="flex-grow"><div class="font-semibold text-slate-900">' + t.name + '</div>'
          + '<div class="text-xs text-slate-500">' + (t.priceBand||'') + ' · matches ' + x.s + ' of your criteria</div></div>'
          + '<span class="text-blue-600 font-semibold">→</span></a>';
      }).join('');
}

document.getElementById('quiz-restart').addEventListener('click', () => {
  Object.keys(QSTATE).forEach(k => delete QSTATE[k]);
  document.querySelectorAll('.quiz-option').forEach(o => o.classList.remove('selected'));
  show(1);
});

show(1);
</script>
"@

    $html = HtmlShell `
        -title 'Find My Contractor Stack — Personalized Tool Recommendations | Deryck' `
        -description 'Answer 4 short questions about your trade, team size, use case, and budget. Get a curated shortlist of contractor software that actually fits.' `
        -canonicalRelative 'quiz/' `
        -depth 1 `
        -body $body

    $dir = Join-Path $distDir 'quiz'
    Ensure-Dir $dir
    Set-Content -Path (Join-Path $dir 'index.html') -Value $html -Encoding UTF8
}

# ==================================================================
# 11) SITEMAP — overrides the one from build-site.ps1 so it includes
#     all the new URLs.
# ==================================================================
function Build-Sitemap-Full {
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $urls = New-Object System.Collections.Generic.List[string]
    $urls.Add("<url><loc>$siteHost/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>1.0</priority></url>")
    $urls.Add("<url><loc>$siteHost/directory/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.9</priority></url>")
    $urls.Add("<url><loc>$siteHost/quiz/</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.7</priority></url>")
    foreach ($f in @('best','compare','pricing','alternatives','workflow','trade','software-category')) {
        $urls.Add("<url><loc>$siteHost/$f/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.7</priority></url>")
    }
    # Categories
    foreach ($c in $data.categories) {
        $urls.Add("<url><loc>$siteHost/category/$($c.slug).html</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.7</priority></url>")
        foreach ($t in $c.tools) {
            $urls.Add("<url><loc>$siteHost/tool/$($c.slug)/$($t.slug).html</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.6</priority></url>")
            $urls.Add("<url><loc>$siteHost/pricing/$($t.slug)/</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.65</priority></url>")
            $urls.Add("<url><loc>$siteHost/alternatives/$($t.slug)/</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.65</priority></url>")
        }
    }
    foreach ($h in $curated.bestForHubs)  { $urls.Add("<url><loc>$siteHost/best/$($h.slug)/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.75</priority></url>") }
    foreach ($v in $curated.vsPairs)      { $urls.Add("<url><loc>$siteHost/compare/$($v.left)-vs-$($v.right)/</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.75</priority></url>") }
    foreach ($h in $curated.tradeHubs)    { $urls.Add("<url><loc>$siteHost/trade/$($h.slug)/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.7</priority></url>") }
    foreach ($h in $curated.softwareHubs) { $urls.Add("<url><loc>$siteHost/software-category/$($h.slug)/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.7</priority></url>") }
    foreach ($w in $curated.workflows)    { $urls.Add("<url><loc>$siteHost/workflow/$($w.slug)/</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.7</priority></url>") }
    $xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n$(($urls | ForEach-Object { '  ' + $_ }) -join "`n")`n</urlset>"
    Set-Content -Path (Join-Path $distDir 'sitemap.xml') -Value $xml -Encoding UTF8

    $robots = "User-agent: *`nAllow: /`nSitemap: $siteHost/sitemap.xml`n"
    Set-Content -Path (Join-Path $distDir 'robots.txt') -Value $robots -Encoding UTF8
}

# ==================================================================
# Orchestrate
# ==================================================================

Write-Host ""
Write-Host "=== Ecosystem build ==="
Write-Host ""

# Flat tool count
$total = 0
foreach ($c in $data.categories) { $total += $c.tools.Count }

Write-Host "Pricing pages..." -NoNewline
foreach ($c in $data.categories) { foreach ($t in $c.tools) { Build-PricingPage $t } }
Write-Host " $total written"

Write-Host "Alternatives pages..." -NoNewline
foreach ($c in $data.categories) { foreach ($t in $c.tools) { Build-AlternativesPage $t } }
Write-Host " $total written"

Write-Host "VS comparison pages..." -NoNewline
$vsCount = 0
foreach ($p in $curated.vsPairs) { Build-VsPage $p.left $p.right; $vsCount++ }
Write-Host " $vsCount written"

Write-Host "Best-For hubs..." -NoNewline
foreach ($h in $curated.bestForHubs) { Build-BestForHub $h }
Write-Host " $($curated.bestForHubs.Count) written"

Write-Host "Trade hubs..." -NoNewline
foreach ($h in $curated.tradeHubs)    { Build-TradeHub $h }
Write-Host " $($curated.tradeHubs.Count) written"

Write-Host "Software category hubs..." -NoNewline
foreach ($h in $curated.softwareHubs) { Build-SoftwareHub $h }
Write-Host " $($curated.softwareHubs.Count) written"

Write-Host "Workflow guides..." -NoNewline
foreach ($w in $curated.workflows)    { Build-WorkflowPage $w }
Write-Host " $($curated.workflows.Count) written"

Write-Host "Ecosystem index pages..." -NoNewline
Build-EcosystemIndex -folder 'pricing'      -title 'Pricing'      -intro 'Pricing breakdowns for every contractor tool we track. Tiers, models, and what teams actually pay.' -context 'idx-pricing' -entries (@(
    foreach ($c in $data.categories) { foreach ($t in $c.tools) {
        @{ tag=$t.priceBand; href="$($t.slug)/"; title="$($t.name) pricing"; sub=$t.pricingNote }
    } }
))
Build-EcosystemIndex -folder 'alternatives' -title 'Alternatives' -intro 'Six alternatives for every tool we track. Switch lists when a platform isn''t the right fit.' -context 'idx-alts' -entries (@(
    foreach ($c in $data.categories) { foreach ($t in $c.tools) {
        @{ tag='Switch list'; href="$($t.slug)/"; title="$($t.name) alternatives"; sub=$t.description }
    } }
))
Build-EcosystemIndex -folder 'compare'      -title 'Compare'      -intro 'Head-to-head matchups between the tools contractor teams evaluate against each other.' -context 'idx-compare' -entries (@(
    foreach ($p in $curated.vsPairs) {
        $a = Get-Tool $p.left; $b = Get-Tool $p.right
        if ($a -and $b) {
            @{ tag='Comparison'; href="$($p.left)-vs-$($p.right)/"; title="$($a.name) vs $($b.name)"; sub="Side-by-side: trade fit, pricing, integrations, implementation." }
        }
    }
))
Build-EcosystemIndex -folder 'best'         -title 'Best Of'      -intro 'Curated "best for" guides &mdash; the right tool for a specific trade, team size, use case, or budget.' -context 'idx-best' -entries (@(
    foreach ($h in $curated.bestForHubs) { @{ tag='Best of'; href="$($h.slug)/"; title=$h.title; sub=$h.intro } }
))
Build-EcosystemIndex -folder 'workflow'     -title 'Workflows'    -intro 'How real contractor teams run their operations &mdash; estimating, dispatching, payments, and the tech stack behind each.' -context 'idx-workflow' -entries (@(
    foreach ($w in $curated.workflows) { @{ tag='Workflow'; href="$($w.slug)/"; title=$w.title; sub=$w.intro } }
))
Build-EcosystemIndex -folder 'trade'        -title 'By Trade'     -intro 'Tool stacks tuned to specific trades &mdash; plumbing, HVAC, mechanical, electrical, roofing, GC, commercial.' -context 'idx-trade' -entries (@(
    foreach ($h in $curated.tradeHubs)    { @{ tag='Trade hub';     href="$($h.slug)/"; title=$h.title; sub=$h.intro } }
))
Build-EcosystemIndex -folder 'software-category' -title 'By Software Category' -intro 'Drill down by what the software does: CRM, estimating, project management, accounting, BIM, more.' -context 'idx-software' -entries (@(
    foreach ($h in $curated.softwareHubs) { @{ tag='Category';      href="$($h.slug)/"; title=$h.title; sub=$h.intro } }
))
Write-Host " 7 written"

Write-Host "Directory..." -NoNewline
Build-Directory
Write-Host " ok"

Write-Host "Quiz..." -NoNewline
Build-Quiz
Write-Host " ok"

Write-Host "Sitemap (full)..." -NoNewline
Build-Sitemap-Full
Write-Host " ok"

# Final counts
$pricing   = (Get-ChildItem -Path (Join-Path $distDir 'pricing')      -Filter index.html -Recurse).Count
$alts      = (Get-ChildItem -Path (Join-Path $distDir 'alternatives') -Filter index.html -Recurse).Count
$compare   = (Get-ChildItem -Path (Join-Path $distDir 'compare')      -Filter index.html -Recurse).Count
$best      = (Get-ChildItem -Path (Join-Path $distDir 'best')         -Filter index.html -Recurse).Count
$trade     = (Get-ChildItem -Path (Join-Path $distDir 'trade')        -Filter index.html -Recurse).Count
$soft      = (Get-ChildItem -Path (Join-Path $distDir 'software-category') -Filter index.html -Recurse).Count
$wf        = (Get-ChildItem -Path (Join-Path $distDir 'workflow')     -Filter index.html -Recurse).Count

Write-Host ""
Write-Host "Ecosystem build complete:"
Write-Host ("  /pricing/             {0,4} pages" -f $pricing)
Write-Host ("  /alternatives/        {0,4} pages" -f $alts)
Write-Host ("  /compare/             {0,4} pages" -f $compare)
Write-Host ("  /best/                {0,4} pages" -f $best)
Write-Host ("  /trade/               {0,4} pages" -f $trade)
Write-Host ("  /software-category/   {0,4} pages" -f $soft)
Write-Host ("  /workflow/            {0,4} pages" -f $wf)
Write-Host  '  /directory/, /quiz/   2 pages'
Write-Host  '  sitemap.xml regenerated (all URLs)'
