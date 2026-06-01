# -----------------------------------------------------------------------------
# HTML templates for the generator. Dot-sourced by generate.ps1.
# All pages share the existing design system in assets/style.css
# -----------------------------------------------------------------------------

$HeroImages = @('contractor-tools','plumbing','commercial','estimating','crm','mechanical')
$HeroMap = @{
  'estimating-takeoff'='estimating'; 'crm-sales'='crm'; 'field-service-dispatch'='contractor-tools';
  'project-management'='commercial'; 'construction-leads'='commercial'; 'accounting-payroll'='estimating';
  'safety-compliance'='mechanical'; 'fleet-equipment'='mechanical'; 'marketing-reputation'='crm';
  'ai-automation'='contractor-tools'; 'document-management'='contractor-tools'; 'procurement-purchasing'='commercial';
  'plumbing'='plumbing'; 'mechanical'='mechanical'; 'hvac'='mechanical'; 'electrical'='contractor-tools';
  'commercial-gc'='commercial'; 'residential-builder'='commercial'; 'general-contractor'='commercial'; 'roofing'='commercial'
}
function Get-HeroImage($key) {
  if ($HeroMap.ContainsKey($key)) { return $HeroMap[$key] }
  $sum = 0; foreach ($ch in $key.ToCharArray()) { $sum += [int]$ch }
  return $HeroImages[$sum % $HeroImages.Count]
}

function Build-Head($title, $desc, $prefix) {
@"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$title</title>
  <meta name="description" content="$desc">
  <meta property="og:title" content="$title">
  <meta property="og:description" content="$desc">
  <meta property="og:type" content="website">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="${prefix}assets/style.css">
</head>
<body class="bg-white">
"@
}

function Build-Header($prefix) {
@"
<header class="sticky top-0 z-50 bg-white/85 backdrop-blur border-b border-slate-200">
  <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between gap-4">
    <a href="${prefix}index.html" class="flex items-center gap-2 font-bold text-lg tracking-tight flex-shrink-0">
      <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-slate-900 text-white text-sm font-bold">C</span>
      <span class="hidden sm:inline">The Contractor Technology Directory</span>
      <span class="sm:hidden">TCTD</span>
    </a>
    <div class="search-wrapper flex-1 max-w-md mx-4 relative" id="search-wrapper">
      <div class="search-input-container">
        <svg class="search-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
        <input type="text" id="tool-search" class="search-input" placeholder="Search HVAC estimating software..." autocomplete="off" />
        <kbd class="search-kbd hidden sm:inline-flex">/</kbd>
      </div>
      <div class="search-dropdown" id="search-dropdown"></div>
    </div>
    <nav class="hidden lg:flex items-center gap-7 text-sm font-medium text-slate-600 flex-shrink-0">
      <a href="${prefix}directory/" class="hover:text-blue-600 transition">Directory</a>
      <a href="${prefix}trades/" class="hover:text-blue-600 transition">Trades</a>
      <a href="${prefix}categories/" class="hover:text-blue-600 transition">Categories</a>
      <a href="${prefix}compare/" class="hover:text-blue-600 transition">Compare</a>
      <a href="${prefix}pricing/" class="hover:text-blue-600 transition">Pricing</a>
    </nav>
    <a href="${prefix}directory/" class="lg:hidden text-sm font-medium text-blue-600 flex-shrink-0">Browse</a>
  </div>
</header>
"@
}

function Build-HeroImage($chipText, $title, $desc, $breadcrumbHtml, $metaHtml, $imgKey, $prefix) {
  $img = Get-HeroImage $imgKey
@"
  <section class="section-hero-image">
    <div class="hero-bg" style="background-image:url('${prefix}assets/hero/$img.webp')"></div>
    <div class="max-w-4xl mx-auto px-6">
      $breadcrumbHtml
      <span class="chip" style="margin-top:1.25rem">$chipText</span>
      <h1>$title</h1>
      <p>$desc</p>
      $metaHtml
    </div>
  </section>
"@
}

function Build-ToolCard($c, $prefix) {
  $letter = $c.name.Substring(0,1).ToUpper()
  $domain = $c.domain
  $href = $prefix + $c.toolPath
  $nameH = HtmlEnc $c.name
  $descH = HtmlEnc $c.description
@"
<a href="$href" class="tool-card bg-white border border-slate-200 rounded-xl p-5 flex flex-col gap-4 h-full">
  <div class="flex items-start gap-4">
    <div class="tool-icon"><img src="${prefix}assets/icons/$domain.ico" alt="$nameH logo" loading="lazy" onerror="if(!this.dataset.r){this.dataset.r=1;this.src='https://icons.duckduckgo.com/ip3/$domain.ico'}else{this.outerHTML='<div class=\'icon-fallback \'>$letter</div>'}"></div>
    <div class="flex-grow min-w-0">
      <h3 class="font-semibold text-slate-900 leading-tight truncate">$nameH</h3>
      <div class="text-xs text-slate-500 mt-1 truncate">$domain</div>
    </div>
  </div>
  <p class="text-sm text-slate-600 leading-relaxed line-clamp-3 flex-grow">$descH</p>
  <div class="flex items-center justify-between pt-2 border-t border-slate-100">
    <span class="text-xs font-semibold text-blue-600">View details</span>
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
  </div>
</a>
"@
}

function Build-ToolGrid($list, $prefix) {
  if (-not $list -or $list.Count -eq 0) {
    return '<div class="col-span-full text-center py-16 text-slate-500">Vendor listings for this section are being added. <a href="' + $prefix + 'directory/" class="text-blue-600 font-medium">Browse the full directory</a>.</div>'
  }
  $sb = New-Object System.Text.StringBuilder
  foreach ($c in $list) { [void]$sb.Append((Build-ToolCard $c $prefix)) }
  return $sb.ToString()
}

function Build-Footer($prefix) {
  $catLinks = New-Object System.Text.StringBuilder
  foreach ($cat in $Global:tax.categories) {
    $nm = HtmlEnc $cat.name
    [void]$catLinks.Append('<li><a class="hover:text-blue-400 transition" href="' + $prefix + $cat.slug + '/">' + $nm + '</a></li>')
  }
  $searchScript = Build-SearchScript $prefix
  $cl = $catLinks.ToString()
@"
<footer class="footer-premium">
  <div class="max-w-7xl mx-auto px-6 py-16 grid md:grid-cols-3 gap-10 relative z-10">
    <div>
      <div class="flex items-center gap-2 font-bold text-xl text-white">
        <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-blue-600 text-white text-sm font-bold">C</span>
        <span>The Contractor Technology Directory</span>
      </div>
      <p class="mt-4 text-sm text-slate-400 max-w-sm leading-relaxed">Search contractor software, apps, vendors, and resources by trade, category, or company.</p>
    </div>
    <div>
      <h4 class="text-sm font-semibold text-slate-200 mb-4">Categories</h4>
      <ul class="space-y-2.5 text-sm text-slate-400">$cl</ul>
    </div>
    <div>
      <h4 class="text-sm font-semibold text-slate-200 mb-4">Browse</h4>
      <ul class="space-y-2.5 text-sm text-slate-400">
        <li><a class="hover:text-blue-400 transition" href="${prefix}trades/">All Trades</a></li>
        <li><a class="hover:text-blue-400 transition" href="${prefix}categories/">All Categories</a></li>
        <li><a class="hover:text-blue-400 transition" href="${prefix}compare/">Compare Software</a></li>
        <li><a class="hover:text-blue-400 transition" href="${prefix}pricing/">Pricing</a></li>
        <li><a class="hover:text-blue-400 transition" href="${prefix}directory/">Full Directory</a></li>
      </ul>
    </div>
  </div>
  <div class="border-t border-slate-800">
    <div class="max-w-7xl mx-auto px-6 py-5 text-xs text-slate-500 flex flex-col md:flex-row items-center justify-between gap-2 relative z-10">
      <span>&copy; 2026 The Contractor Technology Directory. All trademarks are property of their respective owners.</span>
      <span>12 categories &middot; 34 trades &middot; contractor software directory</span>
    </div>
  </div>
</footer>
$searchScript
</body>
</html>
"@
}

function Build-SearchScript($prefix) {
@"
<script>
(function() {
  let tools = [], loaded = false;
  fetch('${prefix}data/tools.json').then(r => r.json()).then(data => {
    const seen = new Set();
    data.categories.forEach(cat => cat.tools.forEach(t => {
      if (!seen.has(t.slug)) { seen.add(t.slug);
        tools.push({ name:t.name, slug:t.slug, category:cat.slug, description:t.description, domain:t.domain }); }
    }));
    tools.sort((a,b)=>a.name.localeCompare(b.name)); loaded = true;
  });
  const input=document.getElementById('tool-search'), dropdown=document.getElementById('search-dropdown'), wrapper=document.getElementById('search-wrapper');
  let activeIdx=-1;
  function hl(text,q){const i=text.toLowerCase().indexOf(q.toLowerCase());return i<0?text:text.slice(0,i)+'<mark>'+text.slice(i,i+q.length)+'</mark>'+text.slice(i+q.length);}
  function render(m,q){
    if(!m.length){dropdown.innerHTML='<div class="search-empty">No tools found</div>';dropdown.classList.add('open');return;}
    dropdown.innerHTML=m.slice(0,12).map(function(t,i){return '<a href="${prefix}tool/'+t.category+'/'+t.slug+'.html" class="search-item'+(i===activeIdx?' active':'')+'" data-idx="'+i+'"><div class="search-item-icon">'+t.name.charAt(0).toUpperCase()+'</div><div class="search-item-info"><div class="search-item-name">'+hl(t.name,q)+'</div><div class="search-item-desc">'+t.description.slice(0,70)+(t.description.length>70?'...':'')+'</div></div></a>';}).join('');
    if(m.length>12)dropdown.innerHTML+='<div class="search-more">+ '+(m.length-12)+' more results</div>';
    dropdown.classList.add('open');
  }
  function search(q){
    if(!loaded||!q){dropdown.classList.remove('open');dropdown.innerHTML='';activeIdx=-1;return;}
    const ql=q.toLowerCase();
    const m=tools.filter(function(t){return t.name.toLowerCase().includes(ql)||t.description.toLowerCase().includes(ql);});
    m.sort(function(a,b){const A=a.name.toLowerCase().startsWith(ql)?0:1,B=b.name.toLowerCase().startsWith(ql)?0:1;return A-B||a.name.localeCompare(b.name);});
    activeIdx=-1;render(m,q);
  }
  if(input){
    input.addEventListener('input',function(){search(input.value.trim());});
    input.addEventListener('focus',function(){if(input.value.trim())search(input.value.trim());});
    input.addEventListener('keydown',function(e){const items=dropdown.querySelectorAll('.search-item');if(!items.length)return;
      if(e.key==='ArrowDown'){e.preventDefault();activeIdx=Math.min(activeIdx+1,items.length-1);upd(items);}
      else if(e.key==='ArrowUp'){e.preventDefault();activeIdx=Math.max(activeIdx-1,-1);upd(items);}
      else if(e.key==='Enter'&&activeIdx>=0){e.preventDefault();items[activeIdx].click();}
      else if(e.key==='Escape'){dropdown.classList.remove('open');input.blur();}});
    function upd(items){items.forEach(function(el,i){el.classList.toggle('active',i===activeIdx);});if(activeIdx>=0&&items[activeIdx])items[activeIdx].scrollIntoView({block:'nearest'});}
    document.addEventListener('click',function(e){if(!wrapper.contains(e.target))dropdown.classList.remove('open');});
    document.addEventListener('keydown',function(e){if(e.key==='/'&&document.activeElement!==input&&!['INPUT','TEXTAREA','SELECT'].includes(document.activeElement.tagName)){e.preventDefault();input.focus();}});
  }
})();
</script>
"@
}

function Build-Breadcrumb($crumbs) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<nav aria-label="Breadcrumb" class="breadcrumb-light">')
  for ($i=0; $i -lt $crumbs.Count; $i++) {
    $cr = $crumbs[$i]
    $lbl = HtmlEnc $cr.label
    if ($i -gt 0) { [void]$sb.Append('<span class="mx-2" style="color:#475569">/</span>') }
    if ($cr.href) { [void]$sb.Append('<a href="' + $cr.href + '">' + $lbl + '</a>') }
    else { [void]$sb.Append('<span class="font-medium" style="color:#F1F5F9">' + $lbl + '</span>') }
  }
  [void]$sb.Append('</nav>')
  return $sb.ToString()
}

# -- PAGE BUILDERS ------------------------------------------------------------

function Build-CategoryPage($cat, $list) {
  $prefix = '../'
  $count = if ($list) { $list.Count } else { 0 }
  $nameH = HtmlEnc $cat.name
  $nameLower = $cat.name.ToLower()
  $subCount = $cat.subcategories.Count
  $title = "$nameH Software for Contractors | The Contractor Technology Directory"
  $desc  = "Browse $nameLower software, apps, and vendors used by contractors. $subCount subcategories, filtered by trade and company."
  $bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label='Categories';href=($prefix+'categories/')}, @{label=$cat.name})
  $meta = '<div class="hero-meta"><span>' + $count + ' Vendors</span><span>' + $subCount + ' Subcategories</span><span>Direct Links</span></div>'
  $heroDesc = "Software and vendors for $nameLower &mdash; explore by subcategory or jump straight to a tool."
  $hero = Build-HeroImage 'Category' $nameH $heroDesc $bc $meta $cat.slug $prefix

  $subPills = New-Object System.Text.StringBuilder
  foreach ($sub in $cat.subcategories) {
    $sn = HtmlEnc $sub.name
    [void]$subPills.Append('<a href="' + $prefix + $cat.slug + '/' + $sub.slug + '/" class="hub-pill">' + $sn + '</a>')
  }
  $grid = Build-ToolGrid $list $prefix
  $pills = $subPills.ToString()
  $body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">Subcategories</span></div>
      <div class="flex flex-wrap gap-2.5 mb-12">$pills</div>
      <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">$count Vendors in $nameH</span></div>
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$grid</div>
    </div>
  </div>
</main>
"@
  return (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
}

function Build-SubcategoryPage($cat, $sub, $catList) {
  $prefix = '../../'
  $catNameH = HtmlEnc $cat.name
  $subNameH = HtmlEnc $sub.name
  $title = "$subNameH Software for Contractors | $catNameH"
  $desc  = "$subNameH tools and vendors for contractors, part of the $catNameH category."
  $bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label=$cat.name;href=($prefix+$cat.slug+'/')}, @{label=$sub.name})
  $meta = '<div class="hero-meta"><span>' + $catNameH + '</span><span>Subcategory</span></div>'
  $heroDesc = "$subNameH software for contractors &mdash; a focused slice of $catNameH."
  $hero = Build-HeroImage 'Subcategory' $subNameH $heroDesc $bc $meta $cat.slug $prefix
  $grid = Build-ToolGrid $catList $prefix
  $catHref = $prefix + $cat.slug + '/'
  $body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <p class="text-slate-600 max-w-3xl mb-8">Vendors below are drawn from the <a href="$catHref" class="text-blue-600 font-medium">$catNameH</a> category. Subcategory-specific filtering refines as more vendor data is tagged.</p>
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$grid</div>
    </div>
  </div>
</main>
"@
  return (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
}

function Build-TradePage($trade, $list) {
  $prefix = '../../'
  $count = if ($list) { $list.Count } else { 0 }
  $nameH = HtmlEnc $trade.name
  $title = "$nameH Software and Apps for Contractors | The Contractor Technology Directory"
  $desc  = "Software, apps, and vendors used by $nameH contractors &mdash; estimating, dispatch, CRM, project management, and more."
  $bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label='Trades';href=($prefix+'trades/')}, @{label=$trade.name})
  $meta = '<div class="hero-meta"><span>' + $count + ' Vendors</span><span>' + (HtmlEnc $trade.group) + '</span><span>CSI Div ' + $trade.csi + '</span></div>'
  $heroDesc = "Everything $nameH contractors use to estimate, sell, dispatch, and run the business."
  $hero = Build-HeroImage 'Trade' ($nameH + ' Software &amp; Apps') $heroDesc $bc $meta $trade.slug $prefix

  $catPills = New-Object System.Text.StringBuilder
  foreach ($m in ($Global:tax.tradeCategoryMap | Where-Object { $_.tradeId -eq $trade.id })) {
    $cn = HtmlEnc $m.categoryName
    [void]$catPills.Append('<a href="' + $prefix + $m.url.Trim('/') + '/" class="hub-pill">' + $cn + '</a>')
  }
  $grid = Build-ToolGrid $list $prefix
  $pills = $catPills.ToString()
  $body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">$nameH by Category</span></div>
      <div class="flex flex-wrap gap-2.5 mb-12">$pills</div>
      <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">Popular with $nameH Contractors</span></div>
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$grid</div>
    </div>
  </div>
</main>
"@
  return (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
}

function Build-ComboPage($trade, $cat, $m, $list) {
  $prefix = '../../'
  $count = if ($list) { $list.Count } else { 0 }
  $tradeNameH = HtmlEnc $trade.name
  $catNameH = HtmlEnc $cat.name
  $titleH = HtmlEnc $m.title
  $title = "$titleH | The Contractor Technology Directory"
  $desc  = "$tradeNameH $catNameH software and vendors. Compare the tools $($trade.name.ToLower()) contractors use for $($cat.name.ToLower())."
  $bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label=$trade.name;href=($prefix+'trades/'+$trade.slug+'/')}, @{label=$cat.name})
  $meta = '<div class="hero-meta"><span>' + $count + ' Vendors</span><span>' + $tradeNameH + '</span><span>' + $catNameH + '</span></div>'
  $heroDesc = "The $($cat.name.ToLower()) software and vendors most relevant to $tradeNameH contractors."
  $hero = Build-HeroImage ($tradeNameH + ' &middot; ' + $catNameH) $titleH $heroDesc $bc $meta $trade.slug $prefix
  $grid = Build-ToolGrid $list $prefix

  $related = New-Object System.Text.StringBuilder
  foreach ($mm in ($Global:tax.tradeCategoryMap | Where-Object { $_.tradeId -eq $trade.id -and $_.categoryId -ne $cat.id } | Select-Object -First 8)) {
    $rl = HtmlEnc ($trade.name + ' ' + $mm.categoryName)
    [void]$related.Append('<a href="' + $prefix + $mm.url.Trim('/') + '/" class="hub-pill">' + $rl + '</a>')
  }
  $rel = $related.ToString()
  $body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$grid</div>
      <div class="section-title-row mt-16"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">Related $tradeNameH Software</span></div>
      <div class="flex flex-wrap gap-2.5">$rel</div>
    </div>
  </div>
</main>
"@
  return (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
}

# -- HUB INDEXES + HOMEPAGE ---------------------------------------------------

function Build-TradesIndex() {
  $prefix = '../'
  $title = "All Contractor Trades | The Contractor Technology Directory"
  $desc  = "Browse software and vendors by contractor trade: HVAC, plumbing, electrical, mechanical, roofing, concrete, and more."
  $bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label='Trades'})
  $meta = '<div class="hero-meta"><span>' + $Global:tax.trades.Count + ' Trades</span><span>Filterable</span><span>SEO Hubs</span></div>'
  $hero = Build-HeroImage 'Browse' 'Contractor Trades' 'Find the software, apps, and vendors used by every construction trade.' $bc $meta 'commercial' $prefix

  $groups = [ordered]@{}
  foreach ($t in $Global:tax.trades) {
    if (-not $groups.Contains($t.group)) { $groups[$t.group] = New-Object System.Collections.Generic.List[object] }
    $groups[$t.group].Add($t)
  }
  $sb = New-Object System.Text.StringBuilder
  foreach ($g in $groups.Keys) {
    $gH = HtmlEnc $g
    [void]$sb.Append('<div class="section-title-row mt-12 first:mt-0"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">' + $gH + '</span></div>')
    [void]$sb.Append('<div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5 mb-4">')
    foreach ($t in $groups[$g]) {
      $tn = HtmlEnc $t.name
      [void]$sb.Append('<a href="' + $prefix + 'trades/' + $t.slug + '/" class="cat-tile p-6 flex flex-col gap-3"><div class="flex items-center justify-between"><span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Trade</span><span class="text-xs font-semibold text-slate-500">CSI ' + $t.csi + '</span></div><h3 class="text-lg font-bold tracking-tight text-slate-900">' + $tn + '</h3><div class="flex items-center gap-1 text-sm font-semibold text-blue-600 mt-auto">Explore <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg></div></a>')
    }
    [void]$sb.Append('</div>')
  }
  $tiles = $sb.ToString()
  $body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">$tiles</div>
  </div>
</main>
"@
  return (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
}

function Build-CategoriesIndex() {
  $prefix = '../'
  $title = "All Software Categories | The Contractor Technology Directory"
  $desc  = "Browse contractor software by category: estimating, CRM, dispatch, project management, accounting, safety, and more."
  $bc = Build-Breadcrumb @(@{label='Home';href=($prefix+'index.html')}, @{label='Categories'})
  $meta = '<div class="hero-meta"><span>' + $Global:tax.categories.Count + ' Categories</span><span>72 Subcategories</span><span>SEO Hubs</span></div>'
  $hero = Build-HeroImage 'Browse' 'Software Categories' 'Everything contractors use to estimate, sell, dispatch, manage projects, and run the business.' $bc $meta 'estimating' $prefix

  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">')
  foreach ($cat in $Global:tax.categories) {
    $cn = HtmlEnc $cat.name
    $subNamesH = (($cat.subcategories | ForEach-Object { HtmlEnc $_.name }) -join ' &middot; ')
    [void]$sb.Append('<a href="' + $prefix + $cat.slug + '/" class="cat-tile p-7 flex flex-col gap-4"><div class="flex items-center justify-between"><span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Category</span><span class="text-xs font-semibold text-slate-500">' + $cat.subcategories.Count + ' subcats</span></div><h3 class="text-xl font-bold tracking-tight text-slate-900">' + $cn + '</h3><p class="text-sm text-slate-600 leading-relaxed flex-grow">' + $subNamesH + '</p><div class="flex items-center gap-1 text-sm font-semibold text-blue-600">Explore <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg></div></a>')
  }
  [void]$sb.Append('</div>')
  $tiles = $sb.ToString()
  $body = @"
<main>
$hero
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">$tiles</div>
  </div>
</main>
"@
  return (Build-Head $title $desc $prefix) + (Build-Header $prefix) + $body + (Build-Footer $prefix)
}

function Resolve-CompanyHref($slug, $prefix) {
  if ($Global:companies.ContainsKey($slug)) { return $prefix + $Global:companies[$slug].toolPath }
  return $prefix + 'directory/'
}

function Build-Homepage() {
  $prefix = ''
  $title = "The Contractor Technology Directory - Search 600+ contractor software, apps & vendors"
  $desc  = "Search contractor software, apps, vendors, and resources by trade, category, or company."

  $tradeTiles = New-Object System.Text.StringBuilder
  foreach ($t in ($Global:tax.trades | Select-Object -First 12)) {
    $tn = HtmlEnc $t.name
    [void]$tradeTiles.Append('<a href="trades/' + $t.slug + '/" class="hub-pill text-base px-5 py-2.5">' + $tn + '</a>')
  }
  $catTiles = New-Object System.Text.StringBuilder
  foreach ($cat in $Global:tax.categories) {
    $cn = HtmlEnc $cat.name
    $subNames = (($cat.subcategories | Select-Object -First 3 | ForEach-Object { HtmlEnc $_.name }) -join ' &middot; ')
    [void]$catTiles.Append('<a href="' + $cat.slug + '/" class="cat-tile p-7 flex flex-col gap-4"><div class="flex items-center justify-between"><span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Category</span><span class="text-xs font-semibold text-slate-500">' + $cat.subcategories.Count + ' subcats</span></div><h3 class="text-xl font-bold tracking-tight text-slate-900">' + $cn + '</h3><p class="text-sm text-slate-600 leading-relaxed flex-grow">' + $subNames + '</p><div class="flex items-center gap-1 text-sm font-semibold text-blue-600">Explore <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg></div></a>')
  }
  $popularSlugs = @('procore','servicetitan','buildertrend','jobber','stack','autodesk-construction-cloud','quickbooks-online','companycam')
  $popular = New-Object System.Text.StringBuilder
  foreach ($s in $popularSlugs) {
    if (-not $Global:companies.ContainsKey($s)) { continue }
    $c = $Global:companies[$s]
    [void]$popular.Append((Build-ToolCard $c $prefix))
  }
  $compares = @(
    @{label='Procore vs Buildertrend'; href='compare/procore-vs-buildertrend/'},
    @{label='Jobber vs Housecall Pro'; href='compare/jobber-vs-housecall-pro/'},
    @{label='PlanSwift vs STACK'; href='compare/planswift-vs-stack/'},
    @{label='HeavyBid vs ProEst'; href='compare/heavybid-vs-proest/'}
  )
  $cmpSb = New-Object System.Text.StringBuilder
  foreach ($cm in $compares) {
    $lb = HtmlEnc $cm.label
    [void]$cmpSb.Append('<a href="' + $cm.href + '" class="vs-card flex items-center justify-between"><span class="font-semibold text-slate-900">' + $lb + '</span><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3B82F6" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg></a>')
  }

  $tt = $tradeTiles.ToString()
  $ct = $catTiles.ToString()
  $pop = $popular.ToString()
  $cmp = $cmpSb.ToString()
  $nTrades = $Global:tax.trades.Count
  $nCats = $Global:tax.categories.Count

  $head = Build-Head $title $desc $prefix
  $header = Build-Header $prefix
  $footer = Build-Footer $prefix
  $body = @"
<section class="hero">
  <div class="max-w-7xl mx-auto px-6 w-full text-white">
    <span class="chip" style="background:rgba(255,255,255,0.08); color:#93C5FD; border-color:rgba(255,255,255,0.15);">600+ software platforms &middot; vendors &middot; resources</span>
    <h1 class="mt-5 text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-extrabold tracking-tight max-w-4xl leading-[1.05]">
      The Contractor Technology Directory
    </h1>
    <p class="mt-6 text-lg md:text-xl text-slate-300 max-w-2xl leading-relaxed">
      Search contractor software, apps, vendors, and resources by trade, category, or company.
    </p>
    <div class="mt-10 flex flex-wrap gap-4">
      <a href="trades/" class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-500 text-white font-semibold px-7 py-3.5 rounded-xl shadow-lg shadow-blue-900/40 transition-all duration-200 hover:-translate-y-0.5">
        Browse Trades
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
      </a>
      <a href="categories/" class="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white font-semibold px-7 py-3.5 rounded-xl backdrop-blur transition-all duration-200 border border-white/20 hover:-translate-y-0.5">
        Browse Categories
      </a>
    </div>
  </div>
</section>

<section class="stats-bar">
  <div class="max-w-7xl mx-auto px-6 py-10 grid grid-cols-2 md:grid-cols-4 gap-8 text-center relative z-10">
    <div><div class="text-3xl md:text-4xl font-extrabold text-white">600+</div><div class="text-xs uppercase tracking-wider text-slate-400 mt-1.5">Software &amp; vendors</div></div>
    <div><div class="text-3xl md:text-4xl font-extrabold text-white">$nTrades</div><div class="text-xs uppercase tracking-wider text-slate-400 mt-1.5">Contractor trades</div></div>
    <div><div class="text-3xl md:text-4xl font-extrabold text-white">$nCats</div><div class="text-xs uppercase tracking-wider text-slate-400 mt-1.5">Software categories</div></div>
    <div><div class="text-3xl md:text-4xl font-extrabold text-blue-400">Free</div><div class="text-xs uppercase tracking-wider text-slate-400 mt-1.5">Cost to browse</div></div>
  </div>
</section>

<section id="trades">
  <div class="section-hero">
    <div class="max-w-2xl mx-auto px-6">
      <span class="chip">Browse by trade</span>
      <h2>Find tools built for your trade.</h2>
      <p>Every system a contractor uses, organized by the trade that runs it.</p>
    </div>
  </div>
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <div class="flex flex-wrap justify-center gap-3 mb-6">$tt</div>
      <div class="text-center"><a href="trades/" class="text-sm font-semibold text-blue-600">View all $nTrades trades &rarr;</a></div>
    </div>
  </div>
</section>

<section id="categories">
  <div class="section-hero">
    <div class="max-w-2xl mx-auto px-6">
      <span class="chip">Browse by category</span>
      <h2>Twelve categories. Every workflow.</h2>
      <p>From estimating and takeoff to AI and automation, the full contractor software stack.</p>
    </div>
  </div>
  <div class="bg-premium-light">
    <div class="max-w-7xl mx-auto px-6 py-16">
      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">$ct</div>
    </div>
  </div>
</section>

<section id="popular" class="bg-premium-light">
  <div class="max-w-7xl mx-auto px-6 py-16">
    <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">Popular Contractor Software</span></div>
    <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">$pop</div>
  </div>
</section>

<section id="compare" class="bg-premium-light">
  <div class="max-w-7xl mx-auto px-6 pb-16">
    <div class="section-title-row"><span class="text-sm font-semibold uppercase tracking-wider text-slate-500">Compare Software</span></div>
    <div class="grid sm:grid-cols-2 gap-4">$cmp</div>
    <div class="mt-6"><a href="compare/" class="text-sm font-semibold text-blue-600">See all comparisons &rarr;</a></div>
  </div>
</section>
"@
  return $head + $header + $body + $footer
}
