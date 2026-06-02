# Reads the JS pricing data and rewrites each /pricing/{slug}/index.html's
# tier table with real numbers. Idempotent.
$root = (Resolve-Path "$PSScriptRoot\..").Path
$utf8 = New-Object System.Text.UTF8Encoding($false)

# ── Parse PRICING_DETAIL out of assets/pricing-data.js by evaluating it via JScript-like ──
# Easiest: inline the data as a PowerShell hashtable here, matching pricing-data.js.
# (Keeping it small + explicit avoids a JS engine dependency.)

$data = @{
  'procore' = @{ quote=$true; intro='Quote-based. Procore does not publish public pricing.' }
  'servicetitan' = @{ quote=$true; intro='Quote-based. ServiceTitan does not publish public pricing.' }
  'autodesk-construction-cloud' = @{ quote=$true; intro='Quote-based. Sold as Autodesk Build, BIM Collaborate, Takeoff, Cost, and Docs.' }
  'heavybid' = @{ quote=$true; intro='Quote-based. HCSS HeavyBid is enterprise-priced by user count and add-on modules.' }
  'heavybid-hcss' = @{ quote=$true; intro='Quote-based. HCSS HeavyBid is enterprise-priced by user count and add-on modules.' }
  'proest' = @{ quote=$true; intro='Quote-based since the Autodesk acquisition; sold under Autodesk Construction Cloud bundles.' }

  'buildertrend' = @{ startsAt='$499/mo (monthly) · ~$339/mo annual'; freeTrial='30-day demo'; tiers=@(
    @{n='Essential'; p='$499/mo monthly · ~$339/mo annual'; sub='Unlimited users · PM, daily logs, CRM. No estimating.'},
    @{n='Advanced';  p='$799/mo monthly · ~$499/mo annual'; sub='Adds full estimating: proposals, change orders, takeoff.'},
    @{n='Complete';  p='$1,099/mo monthly · ~$829/mo annual'; sub='Adds client selections portal and warranty management.'}
  ); note='Flat monthly fee, unlimited users on every plan. Annual billing saves $1,920-$3,240/yr.' }

  'jobber' = @{ startsAt='$39/mo (Core, 1 user, annual)'; freeTrial='14 days'; tiers=@(
    @{n='Core'; p='$39/mo'; sub='1 user · quoting, scheduling, invoicing.'},
    @{n='Connect'; p='$169/mo'; sub='5 users · automations, online booking, 2-way sync.'},
    @{n='Grow'; p='$349/mo'; sub='10 users · quote markups, optional line items, batch invoicing.'},
    @{n='Plus'; p='$599/mo'; sub='15 users · dedicated success manager, custom roles.'}
  ); note='Annual billing saves up to 35%. Extra users $29/mo. AI Receptionist $99/mo add-on.' }

  'housecall-pro' = @{ startsAt='$59/mo (Basic, annual)'; freeTrial='14 days'; tiers=@(
    @{n='Basic'; p='$59/mo annual · $79/mo monthly'; sub='1 user · scheduling, dispatch, invoicing.'},
    @{n='Essentials'; p='$149/mo annual · $189/mo monthly'; sub='Up to 5 users · online booking, postcards, QuickBooks sync.'},
    @{n='MAX'; p='$299/mo annual · $329/mo monthly'; sub='1 user + $35/mo per extra · advanced reporting, custom roles.'}
  ); note='Add-ons commonly cost $40-$149/mo on top of the base plan.' }

  'stack' = @{ startsAt='Free (limited Takeoff & Estimate)'; freeTrial='Free plan + 2-week trial on Build & Operate'; tiers=@(
    @{n='Takeoff & Estimate - Free'; p='$0'; sub='Free tier for individuals.'},
    @{n='Takeoff & Estimate - Pro'; p='$2,599/yr'; sub='1 user · cloud takeoff + estimating, unlimited projects.'},
    @{n='Build & Operate'; p='$599/yr'; sub='Field operations module.'},
    @{n='Enterprise'; p='Contact sales'; sub='Volume + premium support.'}
  ); note='Monthly entry option ~$49/user/mo.' }

  'planswift' = @{ startsAt='$1,595 (perpetual license)'; freeTrial='14 days'; tiers=@(
    @{n='Perpetual license'; p='$1,595 one-time'; sub='1 seat · includes year-1 unlimited support. Renewal ~$200-$250/seat/yr.'},
    @{n='Annual subscription'; p='$2,000/yr'; sub='1 seat · includes updates and 2 hrs of training.'}
  ); note='Owned by ConstructConnect.' }

  'bluebeam-revu' = @{ startsAt='$260/user/year (Basics, annual)'; freeTrial='30 days'; tiers=@(
    @{n='Basics'; p='$260/user/yr'; sub='Markup, measure, basic Studio access (no project creation).'},
    @{n='Core'; p='$330/user/yr'; sub='Studio Projects + Sessions for collaboration.'},
    @{n='Complete'; p='$440/user/yr'; sub='Full toolset for managing AECO documents at scale.'},
    @{n='Max'; p='$590/user/yr'; sub='AI-driven drawing review (introductory pricing).'}
  ); note='All plans billed annually per user. Includes desktop + web/mobile.' }

  'companycam' = @{ startsAt='$79/user/mo (Pro, 3-user minimum)'; freeTrial='14 days (no credit card)'; tiers=@(
    @{n='Pro'; p='$79/user/mo'; sub='3 users min · +$29/mo per extra. Unlimited photos, projects.'},
    @{n='Premium'; p='$129/user/mo'; sub='3 users min · adds branded reports, integrations, AI tagging.'},
    @{n='Elite'; p='$199/user/mo'; sub='3 users min · project timelines, advanced workflows.'}
  ); note='Every plan has a 3-user minimum. Only Pro pricing is publicly listed.' }

  'fieldwire' = @{ startsAt='Free (up to 5 users)'; freeTrial='Free forever on Basic'; tiers=@(
    @{n='Basic'; p='$0'; sub='Up to 5 users · 3 projects, 100 sheets, core punch list.'},
    @{n='Pro'; p='$39/user/mo annual · $54/mo monthly'; sub='Sheet compare, exports, reports, unlimited projects.'},
    @{n='Business'; p='$59/user/mo annual · $74/mo monthly'; sub='Custom forms, 360° photos, BIM viewer, storage integrations.'},
    @{n='Business Plus'; p='$89/user/mo annual · $104/mo monthly'; sub='RFIs, submittals, change orders, budget tools.'}
  ); note='Fieldwire by Hilti. Enterprise adds API/SSO/training.' }

  'fieldpulse' = @{ startsAt='$65/user/mo (Essentials)'; freeTrial='14 days'; tiers=@(
    @{n='Essentials'; p='$65/user/mo'; sub='Scheduling, dispatch, CRM, estimates, invoicing, mobile app.'},
    @{n='Professional'; p='$90/user/mo'; sub='Adds payment processing, QuickBooks sync, custom forms.'},
    @{n='Enterprise'; p='Contact sales'; sub='Volume pricing, advanced controls.'}
  ); note='Seat-based - commit to a number of full-access or field-only seats up front.' }

  'contractor-foreman' = @{ startsAt='$49/mo (Basic)'; freeTrial='30 days · 100-day money-back on annual'; tiers=@(
    @{n='Basic'; p='$49/mo'; sub='Small team · core estimating and invoicing.'},
    @{n='Standard'; p='$105/mo'; sub='Adds work orders, permits, online payments, POs.'},
    @{n='Plus'; p='$166/mo'; sub='QuickBooks Online integration, broader feature set. Most popular.'},
    @{n='Pro'; p='$221/mo'; sub='Custom reports, vehicle/equipment logs, permit management.'},
    @{n='Unlimited'; p='$332/mo'; sub='All features unlocked.'}
  ); note='Most affordable all-in-one for SMB contractors.' }

  'houzz-pro' = @{ startsAt='$99/mo (Essential, annual)'; freeTrial='30 days'; tiers=@(
    @{n='Essential'; p='$99/mo annual · $149/mo monthly'; sub='1 dedicated user · +$60/mo per extra. For designers.'},
    @{n='Pro'; p='$159/mo annual · $249/mo monthly'; sub='1 dedicated user · +$60/mo per extra. For contractors.'},
    @{n='Custom'; p='Contact sales'; sub='Tailored package for larger teams.'}
  ); note='12-month contractual commitment on monthly plans.' }

  'sketchup' = @{ startsAt='$129/yr (SketchUp Go)'; freeTrial='Free version available (web only)'; tiers=@(
    @{n='Go'; p='$129/yr · $19.99/mo'; sub='Per user · web-based modeling.'},
    @{n='Pro'; p='$399/yr'; sub='Per user · desktop modeling, LayOut 2D docs, support.'},
    @{n='Studio'; p='$819/yr'; sub='Per user · Pro + V-Ray rendering and Scan Essentials. Annual only.'}
  ); note='Owned by Trimble.' }

  'sketchup-pro' = @{ startsAt='$399/yr (SketchUp Pro)'; freeTrial='30 days'; tiers=@(
    @{n='Pro'; p='$399/yr'; sub='Per user · desktop modeling, LayOut 2D documentation.'},
    @{n='Studio'; p='$819/yr'; sub='Per user · adds V-Ray rendering and Scan Essentials.'}
  ); note='Owned by Trimble.' }

  'asana' = @{ startsAt='Free (up to 2 users)'; freeTrial='30 days on paid plans'; tiers=@(
    @{n='Personal'; p='$0'; sub='1-2 users · basic lists, boards, calendar.'},
    @{n='Starter'; p='$10.99/user/mo annual · $13.49 monthly'; sub='Min 2 users · timeline, dashboards, automations.'},
    @{n='Advanced'; p='$24.99/user/mo annual · $30.49 monthly'; sub='Min 2 users · goals, portfolio workload, Salesforce integration.'},
    @{n='Enterprise'; p='Contact sales'; sub='SSO/SCIM, data residency, HIPAA, audit logs.'}
  ); note='' }

  'monday-com' = @{ startsAt='$9/seat/mo (Basic, annual, 3-seat min)'; freeTrial='14 days'; tiers=@(
    @{n='Free'; p='$0'; sub='Up to 2 seats · limited boards and views.'},
    @{n='Basic'; p='$9/seat/mo annual · $12 monthly'; sub='3 seats min · unlimited free viewers, 5GB storage.'},
    @{n='Standard'; p='$12/seat/mo annual · $14 monthly'; sub='3 seats min · timeline, calendar, automations.'},
    @{n='Pro'; p='$19/seat/mo annual · $24 monthly'; sub='3 seats min · private boards, chart view, time tracking.'},
    @{n='Enterprise'; p='Contact sales'; sub='Advanced security, governance, dedicated support.'}
  ); note='All paid plans require a 3-seat minimum.' }

  'clickup' = @{ startsAt='Free (unlimited users)'; freeTrial='Free forever'; tiers=@(
    @{n='Free Forever'; p='$0'; sub='Unlimited users · 100MB storage, unlimited tasks.'},
    @{n='Unlimited'; p='$7/user/mo annual · $10 monthly'; sub='Unlimited storage, integrations, dashboards.'},
    @{n='Business'; p='$12/user/mo annual · $19 monthly'; sub='Time tracking, custom exports, advanced automations.'},
    @{n='Business Plus'; p='$19/user/mo annual'; sub='Custom permissions, increased automations, priority support.'},
    @{n='Enterprise'; p='Contact sales'; sub='SSO, white-labeling, dedicated CSM.'}
  ); note='ClickUp Brain AI add-on is +$7/user/mo on any paid plan.' }

  'salesforce' = @{ startsAt='$25/user/mo (Starter Suite)'; freeTrial='30 days'; tiers=@(
    @{n='Starter Suite'; p='$25/user/mo'; sub='Sales, service, email marketing - small business bundle.'},
    @{n='Pro Suite'; p='$100/user/mo'; sub='More automation, customization, forecasting.'},
    @{n='Enterprise'; p='$175/user/mo'; sub='Full Sales Cloud, advanced workflow and territory mgmt.'},
    @{n='Unlimited'; p='$350/user/mo'; sub='Premier support, sandboxes, AI features.'}
  ); note='Enterprise and above require annual contracts.' }

  'hubspot-crm' = @{ startsAt='Free (unlimited users)'; freeTrial='Free forever + 14-day Pro trial'; tiers=@(
    @{n='Free CRM'; p='$0'; sub='Unlimited users · contact mgmt, deals, basic email tracking.'},
    @{n='Starter'; p='$15/seat/mo annual · $20 monthly'; sub='Sales/Service Hub · pipelines, automation, meetings.'},
    @{n='Professional'; p='Sales/Service $100/seat/mo · Marketing Hub $890/mo'; sub='Onboarding fee typically required.'},
    @{n='Enterprise'; p='$1,500+/mo per hub · Customer Platform $4,300/mo'; sub='Custom objects, advanced reporting, hierarchical teams.'}
  ); note='Pricing varies by which Hubs you bundle (Sales/Service/Marketing/Content).' }

  'pipedrive' = @{ startsAt='$14/user/mo (Essential, annual)'; freeTrial='14 days'; tiers=@(
    @{n='Essential'; p='$14/user/mo annual'; sub='Basic pipeline, deals, contacts, email integration.'},
    @{n='Advanced'; p='$29/user/mo annual'; sub='Email sync, workflow automation, reporting.'},
    @{n='Professional'; p='$59/user/mo annual'; sub='Revenue forecasting, team mgmt, custom fields.'},
    @{n='Power'; p='$69/user/mo annual'; sub='Advanced permissions, projects, phone support.'},
    @{n='Enterprise'; p='$99/user/mo annual'; sub='Unlimited customization, premium support.'}
  ); note='Monthly billing is ~21% higher. Add-ons available for LeadBooster, Campaigns, Smart Docs.' }

  'quickbooks-online' = @{ startsAt='$38/mo (Simple Start)'; freeTrial='30 days · often 50% off first 3 months'; tiers=@(
    @{n='Simple Start'; p='$38/mo'; sub='1 user · invoicing, expense tracking - solo.'},
    @{n='Essentials'; p='$75/mo'; sub='Up to 3 users · bill management, time tracking.'},
    @{n='Plus'; p='$115/mo'; sub='Up to 5 users · inventory, project profitability.'},
    @{n='Advanced'; p='$275/mo'; sub='Up to 25 users · enhanced reporting, dedicated manager.'}
  ); note='Intuit typically raises prices annually in the summer.' }

  'xero' = @{ startsAt='$25/mo (Early)'; freeTrial='30 days'; tiers=@(
    @{n='Early'; p='$25/mo'; sub='Unlimited users · send up to 20 invoices, enter 5 bills/mo.'},
    @{n='Growing'; p='$55/mo'; sub='Unlimited users · unlimited transactions, dashboards.'},
    @{n='Established'; p='$90/mo'; sub='Unlimited users · multi-currency, projects, KPI analysis.'}
  ); note='Priced per organization, not per user. US edition is monthly only.' }

  'docusign' = @{ startsAt='$10/mo (Personal, annual)'; freeTrial='30 days'; tiers=@(
    @{n='Personal'; p='$10/mo annual · $15 monthly'; sub='1 user · 3 documents per month.'},
    @{n='Standard'; p='$25/user/mo annual · $45 monthly'; sub='100 envelopes/user/yr, reminders, branding.'},
    @{n='Business Pro'; p='$40/user/mo annual · $65 monthly'; sub='Bulk send, payment collection, advanced fields.'},
    @{n='Enterprise'; p='Contact sales'; sub='Volume contracts, SSO, advanced API.'}
  ); note='Most paid plans include envelope caps; high-volume usage requires Enterprise.' }
}

function Build-TierTable($entry) {
  $rows = New-Object System.Text.StringBuilder
  if ($entry.quote) {
    [void]$rows.Append('<div class="cmp-row"><div class="cmp-label">Pricing model</div><div class="cmp-val">Quote-based</div><div class="cmp-val text-slate-500">Vendor does not publish pricing</div></div>')
    [void]$rows.Append('<div class="cmp-row"><div class="cmp-label">Starting at</div><div class="cmp-val">Contact sales</div><div class="cmp-val text-slate-500">Custom contract</div></div>')
  } else {
    if ($entry.startsAt) {
      [void]$rows.Append('<div class="cmp-row"><div class="cmp-label">Starts at</div><div class="cmp-val font-semibold text-slate-900">' + $entry.startsAt + '</div><div class="cmp-val text-slate-500">' + ($(if ($entry.freeTrial) { 'Free trial: ' + $entry.freeTrial } else { '' })) + '</div></div>')
    }
    foreach ($t in $entry.tiers) {
      [void]$rows.Append('<div class="cmp-row"><div class="cmp-label">' + $t.n + '</div><div class="cmp-val font-semibold text-slate-900">' + $t.p + '</div><div class="cmp-val text-slate-500">' + $t.sub + '</div></div>')
    }
  }
  return $rows.ToString()
}

function Build-PricingBlock($entry) {
  $rows = Build-TierTable $entry
  $note = if ($entry.note) { '<p class="mt-3 text-xs text-slate-500">' + $entry.note + ' Pricing researched June 2026 - confirm against the vendor site before signing.</p>' } else { '<p class="mt-3 text-xs text-slate-500">Pricing researched June 2026 - confirm against the vendor site before signing.</p>' }
  return @"
    <h2 class="text-lg font-bold text-slate-900 mb-3">Pricing tiers</h2>
    <div class="bg-white border border-slate-200 rounded-xl">
$rows
    </div>
$note
"@
}

$updated = 0; $skipped = 0
foreach ($slug in $data.Keys) {
  $path = Join-Path $root "pricing/$slug/index.html"
  if (-not (Test-Path $path)) { Write-Output ("MISS: " + $path); $skipped++; continue }
  $c = [System.IO.File]::ReadAllText($path, $utf8)
  $newBlock = Build-PricingBlock $data[$slug]

  # Find and replace the entire pricing-tier section.
  $pat = '(?s)<h2[^>]*>Pricing tiers \(estimated\)</h2>\s*<div class="bg-white border border-slate-200 rounded-xl">.*?</div>\s*<p class="mt-3 text-xs text-slate-500">[^<]*</p>'
  $new = [regex]::Replace($c, $pat, [System.Text.RegularExpressions.Regex]::Escape($newBlock).Replace('\','\\'), 1)
  # The Escape above was for safety; but [regex]::Replace with literal-friendly call is simpler:
  $new = [regex]::Replace($c, $pat, { param($m) $newBlock }, 1)
  if ($new -eq $c) { Write-Output ("NO-MATCH: " + $slug); $skipped++; continue }
  [System.IO.File]::WriteAllText($path, $new, $utf8)
  $updated++
}
Write-Output ("Pricing pages updated: " + $updated + ", skipped: " + $skipped)
