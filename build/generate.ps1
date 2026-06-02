# ─────────────────────────────────────────────────────────────────────────────
# The Contractor Technology Directory — static page generator
# Reads:  data/taxonomy.json  +  data/tools.json
# Writes: category / subcategory / trade / trade-category combo pages
# Run:    powershell -File build/generate.ps1
# ─────────────────────────────────────────────────────────────────────────────
param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-JsonFile($path) {
  $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  return $raw | ConvertFrom-Json
}
function Save-Html($relPath, $html) {
  $full = Join-Path $Root $relPath
  $dir = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($full, $html, $utf8)
}
function HtmlEnc($s) { if ($null -eq $s) { return '' } return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;') }

$tax   = Read-JsonFile (Join-Path $Root 'data\taxonomy.json')
$tools = Read-JsonFile (Join-Path $Root 'data\tools.json')

# ── Build deduped company list with the path to an existing tool page ─────────
$companies = @{}
foreach ($cat in $tools.categories) {
  foreach ($t in $cat.tools) {
    if (-not $companies.ContainsKey($t.slug)) {
      $companies[$t.slug] = [ordered]@{
        name        = $t.name
        slug        = $t.slug
        domain      = $t.domain
        url         = $t.url
        description = $t.description
        toolPath    = "tool/$($cat.slug)/$($t.slug).html"
        cats        = New-Object System.Collections.Generic.HashSet[string]
        trades      = New-Object System.Collections.Generic.HashSet[string]
        srcCats     = New-Object System.Collections.Generic.List[string]
      }
    }
    [void]$companies[$t.slug].srcCats.Add($cat.slug)
  }
}

# ── Keyword classifiers ──────────────────────────────────────────────────────
$catKeywords = @{
  'estimating-takeoff'      = @('estimat','takeoff','take-off','quantity','bid prep','cost data','costing','measure','blueprint','square foot')
  'construction-leads'      = @('lead','permit','bid network','bidding','prequalif','project tracking','market intelligence','bid leads','opportunit')
  'crm-sales'               = @('crm','customer relationship','sales','pipeline','follow-up','follow up','lead tracking','proposal','quote','customer service')
  'field-service-dispatch'  = @('dispatch','field service','work order','technician','scheduling','route','service call','invoicing','job scheduling','field management')
  'project-management'      = @('project management','construction management','project tracking','gantt','daily log','punch list','rfi','submittal','collaboration','jobsite','field collaboration','plan room','scheduling')
  'accounting-payroll'      = @('account','payroll','invoic','bookkeep','quickbooks','expense','financial','payment','billing','time tracking','timesheet','erp')
  'safety-compliance'       = @('safety','compliance','inspection','incident','osha','certif','training','toolbox talk','jha','audit')
  'fleet-equipment'         = @('fleet','equipment','gps','telematics','vehicle','asset track','tool track','machine','rental','mileage')
  'marketing-reputation'    = @('marketing','review','reputation','seo','website','email campaign','social','advertis','newsletter','lead gen','brand')
  'ai-automation'           = @('ai ','a.i','artificial intelligence','automation','automate','zapier','integrat','workflow','chatbot','machine learning')
  'document-management'     = @('document','file','plan','drawing','pdf','e-signature','esignature','signature','docusign','storage','markup','blueprint','sharing','content')
  'procurement-purchasing'  = @('procure','purchas','material','supplier','inventory','order','catalog','vendor manage','takeoff to order')
}
$tradeKeywords = @{
  'hvac'          = @('hvac','heating','cooling','air conditioning','furnace')
  'plumbing'      = @('plumb')
  'electrical'    = @('electric')
  'mechanical'    = @('mechanical','pipefitting','pipe fitting')
  'refrigeration' = @('refrigerat')
  'roofing'       = @('roof')
  'concrete'      = @('concrete')
  'masonry'       = @('masonry','brick')
  'drywall'       = @('drywall')
  'painting'      = @('paint')
  'flooring'      = @('floor')
  'landscaping'   = @('landscap','irrigation')
  'excavation'    = @('excavat','grading')
  'sitework'      = @('sitework','site work')
  'general-contractor' = @('general contractor','construction management','builder','remodel')
  'commercial-gc' = @('commercial')
  'residential-builder' = @('residential','home builder','homebuilder','custom home')
}

foreach ($slug in $companies.Keys) {
  $c = $companies[$slug]
  $hay = ($c.name + ' ' + $c.description).ToLower()
  foreach ($ck in $catKeywords.Keys) {
    foreach ($kw in $catKeywords[$ck]) { if ($hay.Contains($kw)) { [void]$c.cats.Add($ck); break } }
  }
  foreach ($tk in $tradeKeywords.Keys) {
    foreach ($kw in $tradeKeywords[$tk]) { if ($hay.Contains($kw)) { [void]$c.trades.Add($tk); break } }
  }
  # Seed from source categories so the obvious ones are never empty
  if ($c.srcCats -contains 'top-50-construction-estimating-tools') { [void]$c.cats.Add('estimating-takeoff') }
  if ($c.srcCats -contains 'top-50-contractor-crm-tools') { [void]$c.cats.Add('crm-sales') }
  if ($c.srcCats -contains 'top-50-plumbing-contractor-tools') { [void]$c.trades.Add('plumbing') }
  if ($c.srcCats -contains 'top-50-mechanical-contractor-tools') { [void]$c.trades.Add('mechanical') }
  if ($c.srcCats -contains 'top-50-commercial-contractor-software') { [void]$c.trades.Add('commercial-gc') }
  if ($c.cats.Count -eq 0) { [void]$c.cats.Add('project-management') } # sensible default
}

# Quick lookups: category slug -> companies, trade slug -> companies
function Companies-ForCat($catSlug) {
  $out = @()
  foreach ($slug in $companies.Keys) { if ($companies[$slug].cats.Contains($catSlug)) { $out += $companies[$slug] } }
  return ,($out | Sort-Object { $_.name })
}
function Companies-ForTrade($tradeSlug) {
  $out = @()
  foreach ($slug in $companies.Keys) { if ($companies[$slug].trades.Contains($tradeSlug)) { $out += $companies[$slug] } }
  return ,($out | Sort-Object { $_.name })
}

Write-Output ("Companies deduped: " + $companies.Count)
$Global:companies = $companies
$Global:tax = $tax

# Templates are sourced from build/templates.ps1
. (Join-Path $PSScriptRoot 'templates.ps1')

# ── Generate pages ───────────────────────────────────────────────────────────
$counts = @{ category=0; subcategory=0; trade=0; combo=0 }

# Category + Subcategory pages
foreach ($cat in $tax.categories) {
  $companiesInCat = Companies-ForCat $cat.slug
  $html = Build-CategoryPage $cat $companiesInCat
  Save-Html "$($cat.slug)/index.html" $html
  $counts.category++

  foreach ($sub in $cat.subcategories) {
    $subHtml = Build-SubcategoryPage $cat $sub $companiesInCat
    Save-Html "$($cat.slug)/$($sub.slug)/index.html" $subHtml
    $counts.subcategory++
  }
}

# Trade pages
foreach ($trade in $tax.trades) {
  $companiesInTrade = Companies-ForTrade $trade.slug
  $html = Build-TradePage $trade $companiesInTrade
  Save-Html "trades/$($trade.slug)/index.html" $html
  $counts.trade++
}

# Trade x Category combo pages (the SEO engine)
foreach ($m in $tax.tradeCategoryMap) {
  $catSlug = ($m.categoryId -replace '^CAT-','').ToLower()
  # find category + trade objects
  $catObj = $tax.categories | Where-Object { $_.id -eq $m.categoryId } | Select-Object -First 1
  $tradeObj = $tax.trades | Where-Object { $_.id -eq $m.tradeId } | Select-Object -First 1
  if (-not $catObj -or -not $tradeObj) { continue }
  $list = Companies-ForCat $catObj.slug
  $html = Build-ComboPage $tradeObj $catObj $m $list
  $slug = $m.url.Trim('/')
  Save-Html "$slug/index.html" $html
  $counts.combo++
}

# Hub indexes
Save-Html "trades/index.html" (Build-TradesIndex)
Save-Html "categories/index.html" (Build-CategoriesIndex)
# NOTE: index.html (homepage) is now the Claude-design build using assets/home.css
# + assets/home.js + assets/tools-data.js. It is intentionally NOT regenerated here
# so the generator can't clobber it. Re-enable Build-Homepage only if reverting.
# Save-Html "index.html" (Build-Homepage)

Write-Output ("Generated -> category: {0}  subcategory: {1}  trade: {2}  combo: {3}" -f $counts.category,$counts.subcategory,$counts.trade,$counts.combo)
Write-Output "Also generated: trades/index, categories/index, homepage"
