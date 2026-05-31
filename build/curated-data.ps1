# Emits data/curated.json:
#   - bestForHubs     : ~30 "Best X for Y" pages
#   - vsPairs         : curated tool-vs-tool comparisons
#   - workflows       : long-form workflow guides
#   - tradeHubs       : per-trade hub pages
#   - softwareHubs    : per-software-category hub pages
#
# This file is human-authored. Edit values here, then run the build.

$ErrorActionPreference = 'Stop'
$root    = Split-Path -Parent $PSScriptRoot
$outJson = Join-Path $root 'data\curated.json'

# ------------------------------------------------------------------
# Best-For hubs
# Each hub renders as /best/<slug>/  and lists tools matching the filter.
# ------------------------------------------------------------------
$bestForHubs = @(
    @{ slug='contractor-crm';                 title='Best Contractor CRM Tools';                            h1='Best Contractor CRM Software'; intro='The CRMs contractors actually use to manage leads, jobs, and customer history — not generic SaaS dashboards.'; filter=@{ useCase='CRM' } }
    @{ slug='plumbing-crm';                   title='Best Plumbing CRM Software';                            h1='Best CRM Software for Plumbing Contractors'; intro='CRMs that handle the daily reality of a plumbing business: dispatching, on-the-truck quoting, and customer history.'; filter=@{ useCase='CRM'; trade='Plumbing' } }
    @{ slug='hvac-crm';                       title='Best HVAC CRM Software';                                h1='Best CRM Software for HVAC Contractors'; intro='HVAC-fit CRMs that integrate dispatching, maintenance agreements, and accounting.'; filter=@{ useCase='CRM'; trade='HVAC' } }
    @{ slug='mechanical-contractor-software'; title='Best Mechanical Contractor Software';                   h1='Best Software for Mechanical Contractors'; intro='Field service, estimating, and project management platforms used by mechanical contractors.'; filter=@{ trade='Mechanical' } }
    @{ slug='construction-estimating-software';title='Best Construction Estimating Software';                h1='Best Construction Estimating Software'; intro='Estimating platforms used to win profitable bids — from digital takeoff to live cost databases.'; filter=@{ useCase='Estimating' } }
    @{ slug='plumbing-estimating-software';   title='Best Plumbing Estimating Software';                     h1='Best Estimating Software for Plumbing Contractors'; intro='Pipe takeoff, fitting catalogues, and labor-rate databases built for plumbing.'; filter=@{ useCase='Estimating'; trade='Plumbing' } }
    @{ slug='commercial-estimating-tools';    title='Best Commercial Estimating Tools';                      h1='Best Commercial Estimating Tools'; intro='Enterprise-grade estimating platforms for commercial contractors.'; filter=@{ useCase='Estimating'; trade='Commercial' } }
    @{ slug='contractor-project-management-tools';title='Best Contractor Project Management Tools';          h1='Best Project Management Tools for Contractors'; intro='Project management built around the way construction projects actually run — schedules, RFIs, submittals, and field updates.'; filter=@{ useCase='ProjectManagement' } }
    @{ slug='commercial-construction-management-software';title='Best Commercial Construction Management Software';h1='Best Commercial Construction Management Software'; intro='End-to-end platforms for commercial GCs running multiple jobs simultaneously.'; filter=@{ useCase='ProjectManagement'; trade='Commercial' } }
    @{ slug='field-service-management-software';title='Best Field Service Management Software';              h1='Best Field Service Management Software'; intro='Dispatch, mobile work orders, and customer history — the FSM stack for trade contractors.'; filter=@{ useCase='FieldManagement' } }
    @{ slug='dispatch-software-for-contractors';title='Best Dispatch Software for Contractors';              h1='Best Dispatch Software for Contractors'; intro='Drag-and-drop dispatch boards, route optimization, and real-time tech updates.'; filter=@{ useCase='Dispatching' } }
    @{ slug='accounting-software-for-contractors';title='Best Accounting Software for Contractors';          h1='Best Accounting Software for Contractors'; intro='Job costing, AIA billing, certified payroll — contractor accounting that goes beyond generic bookkeeping.'; filter=@{ useCase='Accounting' } }
    @{ slug='construction-safety-tools';      title='Best Construction Safety Tools';                        h1='Best Construction Safety Tools'; intro='Toolbox talks, near-miss reporting, and OSHA-ready documentation built for the jobsite.'; filter=@{ useCase='Safety' } }
    @{ slug='time-tracking-software-for-contractors';title='Best Time Tracking Software for Contractors';   h1='Best Time Tracking Software for Contractors'; intro='Geofencing, photo-verified clock-ins, and clean exports into job-costing and payroll.'; filter=@{ useCase='TimeTracking' } }
    @{ slug='communication-tools-for-contractors';title='Best Communication Tools for Contractors';          h1='Best Communication Tools for Contractors'; intro='Internal communication and client touchpoints — chat, video, calling, and shared inboxes for field-heavy teams.'; filter=@{ useCase='Communication' } }
    @{ slug='document-management-software-for-contractors';title='Best Document Management Software for Contractors';h1='Best Document Management Software for Contractors'; intro='Drawing version control, RFI workflows, and field-ready document storage.'; filter=@{ useCase='DocumentManagement' } }
    @{ slug='fleet-management-software-for-contractors';title='Best Fleet Management Software for Contractors';h1='Best Fleet Management for Contractors'; intro='GPS tracking, dashcams, and maintenance scheduling — built for vans and pickup-truck fleets.'; filter=@{ useCase='FleetManagement' } }
    @{ slug='tool-tracking-software';         title='Best Tool & Equipment Tracking Software';               h1='Best Tool & Equipment Tracking Software'; intro='Cut tool loss across crews and jobsites with check-in/check-out workflows and Bluetooth-tagged inventories.'; filter=@{ useCase='ToolTracking' } }
    @{ slug='bim-software-for-contractors';   title='Best BIM Software for Contractors';                     h1='Best BIM Software for Contractors'; intro='From conceptual modeling to clash detection — the BIM stack contractors actually deploy.'; filter=@{ useCase='BIM' } }
    @{ slug='payments-software-for-contractors';title='Best Payments Software for Contractors';              h1='Best Payments Software for Contractors'; intro='Mobile card processing, financing offers, and ACH for service calls and project billings.'; filter=@{ useCase='Payments' } }
    @{ slug='review-management-for-contractors';title='Best Review Management Software for Contractors';    h1='Best Review Management for Contractors'; intro='Get more 5-star Google reviews after every service call — automated.'; filter=@{ useCase='Reviews' } }
    @{ slug='marketing-software-for-contractors';title='Best Marketing Software for Contractors';            h1='Best Marketing Software for Contractors'; intro='Email automation, lead generation, and brand management for trade businesses.'; filter=@{ useCase='Marketing' } }

    # Size-based hubs
    @{ slug='best-for-solo-contractors';      title='Best Software for Solo Contractors';                    h1='Best Software for Solo Contractors'; intro='Built for one-truck operators and owner-operators — low overhead, fast to deploy, no enterprise bloat.'; filter=@{ size='Solo' } }
    @{ slug='best-for-small-contractors';     title='Best Software for Small Contractors (2-10 employees)'; h1='Best Software for Small Contractors'; intro='Tools that scale from 2 to 10 employees without locking you into per-user pricing that punishes growth.'; filter=@{ size='Small' } }
    @{ slug='best-for-medium-contractors';    title='Best Software for Mid-Size Contractors';                h1='Best Software for Mid-Size Contractor Businesses'; intro='Built for the 10-100 employee range — the size where ad hoc systems start to break.'; filter=@{ size='Medium' } }
    @{ slug='best-for-enterprise-contractors';title='Best Software for Enterprise Construction Firms';       h1='Best Software for Enterprise Construction Firms'; intro='Multi-office, multi-trade, hundreds of users — enterprise-grade platforms that actually deliver.'; filter=@{ size='Enterprise' } }

    # Budget-based hubs
    @{ slug='free-contractor-software';       title='Free Contractor Software';                              h1='Best Free Software for Contractors'; intro='Free tools (or free tiers) worth using in 2026 — no credit-card-required gimmicks.'; filter=@{ band='Free' } }
    @{ slug='affordable-contractor-software'; title='Best Contractor Software Under $100/mo';                h1='Best Contractor Software Under $100/month'; intro='Genuinely useful tools that fit a small-business budget.'; filter=@{ band='Under $100/mo' } }
)

# ------------------------------------------------------------------
# VS pairs — curated, high-search-volume comparisons.
# Each pair: leftSlug, rightSlug. Build script looks them up in enriched.json.
# ------------------------------------------------------------------
$vsPairs = @(
    # FSM / dispatch — most-searched in the space
    @{ left='servicetitan';      right='jobber' }
    @{ left='servicetitan';      right='housecall-pro' }
    @{ left='servicetitan';      right='fieldedge' }
    @{ left='servicetitan';      right='servicefusion' }
    @{ left='servicetitan';      right='workiz' }
    @{ left='jobber';            right='housecall-pro' }
    @{ left='jobber';            right='workiz' }
    @{ left='jobber';            right='fieldpulse' }
    @{ left='jobber';            right='tradify' }
    @{ left='housecall-pro';     right='workiz' }
    @{ left='housecall-pro';     right='fieldpulse' }
    @{ left='housecall-pro';     right='mhelpdesk' }
    @{ left='fieldedge';         right='servicefusion' }
    @{ left='razorsync';         right='servicefusion' }
    @{ left='synchroteam';       right='razorsync' }
    @{ left='simpro';            right='servicetitan' }
    @{ left='simpro';            right='fergus' }
    @{ left='kickserv';          right='jobber' }

    # Project management
    @{ left='procore';           right='buildertrend' }
    @{ left='procore';           right='coconstruct' }
    @{ left='procore';           right='fieldwire' }
    @{ left='procore';           right='plangrid' }
    @{ left='procore';           right='redteam' }
    @{ left='buildertrend';      right='coconstruct' }
    @{ left='buildertrend';      right='houzz-pro' }
    @{ left='buildertrend';      right='contractor-foreman' }
    @{ left='contractor-foreman';right='houzz-pro' }
    @{ left='fieldwire';         right='plangrid' }
    @{ left='raken';             right='fieldwire' }
    @{ left='smartsheet';        right='monday-com' }
    @{ left='asana';             right='monday-com' }
    @{ left='asana';             right='clickup' }
    @{ left='wrike';             right='asana' }

    # Estimating / takeoff
    @{ left='planswift';         right='stack' }
    @{ left='planswift';         right='bluebeam-revu' }
    @{ left='stack';             right='on-screen-takeoff-ost' }
    @{ left='proest';            right='sigma-estimates' }
    @{ left='sigma-estimates';   right='costx' }
    @{ left='clear-estimates';   right='xactimate' }
    @{ left='heavybid';          right='proest' }

    # Accounting
    @{ left='quickbooks-online'; right='xero' }
    @{ left='quickbooks-online'; right='sage-100-contractor' }
    @{ left='quickbooks-enterprise';right='foundation-software' }

    # BIM / design
    @{ left='autocad';           right='sketchup' }
    @{ left='autocad';           right='revit' }
    @{ left='revit';             right='sketchup-pro' }

    # Scheduling / time tracking
    @{ left='microsoft-project'; right='primavera-p6' }
    @{ left='clockshark';        right='tsheets-quickbooks-time' }
    @{ left='clockshark';        right='connecteam' }

    # Fleet
    @{ left='samsara';           right='verizon-connect' }
    @{ left='samsara';           right='motive-keeptruckin' }
    @{ left='fleetio';           right='samsara' }

    # CRM / reviews
    @{ left='podium';            right='broadly' }
    @{ left='broadly';           right='nicejob' }

    # Documents
    @{ left='docusign';          right='pandadoc' }
)

# ------------------------------------------------------------------
# Trade hubs — landing pages for each trade
# ------------------------------------------------------------------
$tradeHubs = @(
    @{ slug='plumbing';   trade='Plumbing';   title='Plumbing Contractor Software & Tools';
        intro='Every system a plumbing business needs to win jobs, dispatch techs, and protect margin — from one-truck operators to multi-location franchises.';
        sections=@(
            'CRM & Dispatch',
            'Estimating',
            'Field Management',
            'Accounting & Payments'
        ) }
    @{ slug='hvac';       trade='HVAC';       title='HVAC Contractor Software & Tools';
        intro='Maintenance agreements, summer-rush dispatching, and equipment lifecycle tracking — the platforms HVAC contractors actually deploy.';
        sections=@( 'CRM & Dispatch', 'Maintenance Agreements', 'Estimating', 'Fleet & Tools' ) }
    @{ slug='mechanical'; trade='Mechanical'; title='Mechanical Contractor Software & Tools';
        intro='Project-grade mechanical contracting demands fabrication estimating, BIM coordination, and field-to-office data flow. These tools deliver.';
        sections=@( 'Estimating & Takeoff', 'BIM & Coordination', 'Field Management', 'Accounting' ) }
    @{ slug='electrical'; trade='Electrical'; title='Electrical Contractor Software & Tools';
        intro='Service calls, panel work, and commercial wire pulls — the electrical contractor tech stack covered.';
        sections=@( 'CRM & Dispatch', 'Estimating & Takeoff', 'Field Management', 'Accounting' ) }
    @{ slug='roofing';    trade='Roofing';    title='Roofing Contractor Software & Tools';
        intro='Aerial measurements, supplement workflows, and insurance estimating — the roofing-specific tools that win deals.';
        sections=@( 'Lead Generation', 'Estimating', 'Project Management', 'Reviews & Marketing' ) }
    @{ slug='general-contractor';trade='GC';   title='General Contractor Software & Tools';
        intro='GCs juggle subs, schedules, RFIs, and AIA billing. The platforms below run the operation.';
        sections=@( 'Project Management', 'Estimating', 'Field Management', 'Accounting' ) }
    @{ slug='commercial';  trade='Commercial';title='Commercial Contractor Software & Tools';
        intro='Multi-million-dollar commercial builds need enterprise-grade PM, BIM, and accounting. The proven stack:';
        sections=@( 'Project Management & ERP', 'BIM & Coordination', 'Estimating', 'Field Management' ) }
)

# ------------------------------------------------------------------
# Software category hubs — by use case
# ------------------------------------------------------------------
$softwareHubs = @(
    @{ slug='crm';                useCase='CRM';                title='Contractor CRM Software';                intro='Lead capture, customer history, and follow-up automation built for contracting businesses.' }
    @{ slug='estimating';         useCase='Estimating';         title='Construction Estimating Software';      intro='Digital takeoff, assembly libraries, and unit-cost databases that win profitable bids.' }
    @{ slug='project-management'; useCase='ProjectManagement';  title='Construction Project Management Software';intro='Schedules, RFIs, submittals, and field updates — the operating system for construction projects.' }
    @{ slug='field-service';      useCase='FieldManagement';    title='Field Service Management Software';     intro='Mobile work orders, dispatching, and customer signatures captured at the curb.' }
    @{ slug='dispatching';        useCase='Dispatching';        title='Contractor Dispatching Software';        intro='Visual dispatch boards and route optimization for trade-service businesses.' }
    @{ slug='scheduling';         useCase='Scheduling';         title='Contractor Scheduling Software';         intro='Calendar-based scheduling, geofenced clock-ins, and crew assignments.' }
    @{ slug='invoicing';          useCase='Invoicing';          title='Contractor Invoicing Software';          intro='Send branded invoices from the field, accept ACH, and chase past-due balances automatically.' }
    @{ slug='accounting';         useCase='Accounting';         title='Construction Accounting Software';       intro='Job costing, AIA billing, retainage, and certified payroll done right.' }
    @{ slug='time-tracking';      useCase='TimeTracking';       title='Contractor Time-Tracking Software';      intro='Geofenced punch-ins, photo verification, and clean payroll exports.' }
    @{ slug='safety';             useCase='Safety';             title='Construction Safety Software';           intro='Toolbox talks, JSAs, near-miss reporting, and OSHA-ready archives.' }
    @{ slug='bim';                useCase='BIM';                title='BIM Software for Contractors';           intro='From quick conceptual models to enterprise BIM 360 clash detection.' }
    @{ slug='fleet-management';   useCase='FleetManagement';    title='Contractor Fleet Management Software';   intro='Telematics, dashcams, and maintenance scheduling for vans and pickups.' }
    @{ slug='tool-tracking';      useCase='ToolTracking';       title='Tool & Equipment Tracking Software';     intro='Stop bleeding budget on lost tools with check-out workflows and Bluetooth tagging.' }
    @{ slug='communication';      useCase='Communication';      title='Contractor Communication Software';      intro='Office-to-field chat, video, and shared inboxes.' }
    @{ slug='document-management';useCase='DocumentManagement'; title='Contractor Document Management Software';intro='Drawing versions, RFI workflows, and field-ready document storage.' }
    @{ slug='payments';           useCase='Payments';           title='Contractor Payment Software';            intro='Mobile card processing, ACH for project billings, and consumer financing offers.' }
    @{ slug='reviews';            useCase='Reviews';            title='Contractor Review Management';           intro='Automate the post-service 5-star ask. The reputation moat.' }
    @{ slug='marketing';          useCase='Marketing';          title='Contractor Marketing Software';          intro='Email, lead-gen, call tracking, and brand design.' }
)

# ------------------------------------------------------------------
# Workflow long-form guides
# Each workflow renders as /workflow/<slug>/  with multi-section content.
# ------------------------------------------------------------------
$workflows = @(
    @{ slug='how-commercial-contractors-estimate-projects'
        title='How Commercial Contractors Estimate Projects'
        intent='Informational + funnel'
        intro='Commercial estimating is fundamentally different from residential — it''s a process problem, not a calculation problem. Here''s how high-performing commercial contractors actually run the estimating workflow, and which tools they reach for at each stage.'
        sections=@(
            @{ heading='1. Bid solicitation & qualification'; body='The estimating workflow starts before any takeoff. Commercial estimators receive 2-10x more invitations than they can realistically bid, so step one is qualification: project size, owner type, schedule realism, and competitor field. Bid management tools like BuildingConnected, iSqFt, and SmartBid aggregate invitations and let estimators flag promising ones early.'; tools=@('buildingconnected','isqft','smartbid','pipelinesuite') }
            @{ heading='2. Drawing intake & versioning'; body='Once a job is in, drawings get organized by trade, sheet, and revision. Bluebeam Revu is the long-standing market choice for marking up and comparing drawing sets; cloud tools like Procore and Autodesk Construction Cloud now compete here too. Version discipline matters — a single estimate built on superseded drawings can blow a margin.'; tools=@('bluebeam-revu','procore','autodesk-construction-cloud') }
            @{ heading='3. Quantity takeoff'; body='Digital takeoff is now standard. PlanSwift, Stack, On-Screen Takeoff, and Esticom all offer point-and-click measurement against PDFs and DWGs. For BIM-driven jobs, Sigma Estimates and CostX pull quantities directly from the model — eliminating an entire round of human counting.'; tools=@('planswift','stack','on-screen-takeoff-ost','esticom','sigma-estimates','costx') }
            @{ heading='4. Pricing & assembly'; body='Quantities become dollars via assembly databases. RSMeans provides localized, regularly updated unit cost data. Estimating platforms like ProEst, HCSS HeavyBid, and Sage Estimating layer assemblies, labor productivity rates, and equipment cost on top.'; tools=@('rsmeans-data','proest','heavybid','sigma-estimates') }
            @{ heading='5. Subcontractor solicitation'; body='Self-perform line items get priced internally; everything else goes out to subs. SmartBid, BuildingConnected, and Pantera Tools handle ITB distribution, qualification, and quote collection — keeping a paper trail you''ll need post-award.'; tools=@('smartbid','buildingconnected','pantera-tools') }
            @{ heading='6. Bid day & final scrub'; body='In the final hours, sub quotes get pasted into the schedule of values. Markup gets adjusted by gut and by GC strategy. Spreadsheets still dominate this final step; teams using Destini Estimator, ProEst, or Sigma get a more controlled workflow with audit history.'; tools=@('destini-estimator','proest','sigma-estimates') }
            @{ heading='7. Handoff to operations'; body='Won the job? The estimate becomes the project budget. Tools like Procore and Sage 300 CRE pull the structured estimate into the production system so PMs can track real spend vs estimate — closing the feedback loop on which assumptions were right.'; tools=@('procore','sage-300-cre','foundation-software') }
        )
        outro='The estimating workflow is roughly the same shape at every commercial contractor — what differs is how much of it lives in disciplined software vs scattered spreadsheets. Most teams improve fastest by tightening steps 3 (takeoff) and 5 (sub solicitation) first.'
    }

    @{ slug='how-hvac-contractors-dispatch-techs'
        title='How HVAC Contractors Dispatch Technicians'
        intent='Informational + funnel'
        intro='HVAC dispatching is a real-time optimization problem: skill match, ETA, travel time, capacity, and customer urgency all matter. Here''s the modern workflow.'
        sections=@(
            @{ heading='1. Call intake & priority'; body='Calls arrive via phone, web booking, and recurring maintenance triggers. Modern HVAC software (ServiceTitan, FieldEdge, Housecall Pro) captures all three into one queue with priority tagging.'; tools=@('servicetitan','fieldedge','housecall-pro') }
            @{ heading='2. Schedule preview'; body='Dispatchers see today''s board — assigned techs, current job, ETA, and skill tags. Drag-and-drop interfaces let them snap a new call onto the right tech in seconds. Synchroteam, Workiz, and ServiceFusion all support visual scheduling.'; tools=@('servicetitan','synchroteam','workiz','servicefusion') }
            @{ heading='3. Tech assignment by skill'; body='Not every HVAC tech is licensed for boilers. Not every tech installs mini-splits. Smart dispatch tools tag techs by certification and only show qualified options for each call.'; tools=@('servicetitan','fieldedge','simpro') }
            @{ heading='4. Customer ETA notifications'; body='The biggest customer-experience lever is "tech is 12 minutes out" SMS. Podium, Housecall Pro, and ServiceTitan all automate this — and the conversion lift on the next service call is measurable.'; tools=@('servicetitan','housecall-pro','podium') }
            @{ heading='5. Live tech tracking'; body='GPS plus dashcams (Samsara, Verizon Connect, Motive) protect against insurance claims and let dispatchers re-route the right tech if a call slips.'; tools=@('samsara','verizon-connect','motive-keeptruckin') }
            @{ heading='6. Job completion → invoice'; body='Tech wraps the call, gets a signature on the phone, and the invoice fires automatically. Same platforms close the loop with QuickBooks or accounting integrations.'; tools=@('servicetitan','housecall-pro','quickbooks-online') }
        )
        outro='HVAC dispatch maturity follows a predictable arc: paper → spreadsheets → FSM software → integrated suite with telematics. The biggest jump in throughput typically happens at step 3.'
    }

    @{ slug='how-plumbing-companies-set-up-a-crm'
        title='How Plumbing Companies Set Up a CRM Workflow'
        intent='Informational + funnel'
        intro='A plumbing CRM isn''t just a contact list — it''s a lead-to-cash workflow with dispatching, on-truck quoting, and recurring service triggers built in.'
        sections=@(
            @{ heading='1. Define the lead lifecycle'; body='Before tooling, map your stages: web lead → qualified → scheduled → on-site → quoted → won → invoiced → reviewed. Each stage needs an owner and a service-level expectation.'; tools=@('jobber','housecall-pro','servicetitan') }
            @{ heading='2. Pick the right platform'; body='For 1-5 truck operations, Jobber and Housecall Pro are the natural fits. For 5-30 trucks, Workiz and FieldEdge add power. Beyond that, ServiceTitan dominates.'; tools=@('jobber','housecall-pro','workiz','fieldedge','servicetitan') }
            @{ heading='3. Wire up your lead sources'; body='Web form → CRM. Phone → call tracking (CallRail) → CRM. Recurring maintenance → automated trigger → dispatch.'; tools=@('callrail','servicetitan','jobber') }
            @{ heading='4. Build flat-rate pricebook'; body='The single biggest revenue lever is a flat-rate pricebook on every truck. ServiceTitan and Profit Rhino are common; Housecall Pro and Jobber have lighter-weight equivalents.'; tools=@('servicetitan','housecall-pro','jobber') }
            @{ heading='5. Automate post-job touchpoints'; body='Review request, thank-you note, and warranty reminder. NiceJob, Podium, and Broadly handle this with one-click integrations.'; tools=@('nicejob','podium','broadly') }
            @{ heading='6. Track and refine'; body='Look at win rate by lead source, average ticket, and customer lifetime value. CRMs with built-in dashboards (ServiceTitan, Housecall Pro) make this trivial.'; tools=@('servicetitan','housecall-pro') }
        )
        outro='The plumbers winning right now aren''t the ones with the best techs — they''re the ones whose CRM workflow turns every call into a tracked, optimized event.'
    }

    @{ slug='how-gcs-manage-subcontractor-payments'
        title='How General Contractors Manage Subcontractor Payments'
        intent='Informational + funnel'
        intro='Sub-payment workflows are where projects bleed cash quietly. Here''s the disciplined process modern GCs follow.'
        sections=@(
            @{ heading='1. Subcontract setup'; body='Every sub gets a defined contract value, schedule of values (SOV), and retainage terms. Procore, RedTeam, and Sage 300 CRE all model this natively.'; tools=@('procore','redteam','sage-300-cre') }
            @{ heading='2. Monthly billing intake'; body='Subs submit pay apps against the SOV. Procore Invoicing, GCPay, and Textura (now Oracle) are common platforms. DocuSign streamlines signatures.'; tools=@('procore','docusign') }
            @{ heading='3. Lien waiver collection'; body='Conditional + unconditional lien waivers tracked per billing cycle. Missing waivers stall payment — and create real legal exposure.'; tools=@('procore','docusign') }
            @{ heading='4. PM approval workflow'; body='PM verifies work-in-place vs billed-to-date. Procore and RedTeam route through approvers automatically.'; tools=@('procore','redteam') }
            @{ heading='5. Accounting cut & release'; body='Accounting integrates with Sage 300 CRE, Foundation Software, QuickBooks Enterprise, or CMiC to issue checks/ACH.'; tools=@('sage-300-cre','foundation-software','quickbooks-enterprise','cmic') }
            @{ heading='6. Audit trail & 1099s'; body='Year-end reporting needs clean records. The platforms above all generate the necessary reports.'; tools=@('foundation-software','sage-300-cre') }
        )
        outro='A clean sub-payment workflow protects margin, protects the schedule (subs that get paid on time show up), and protects against liens. The platforms above pay for themselves on a single mid-size project.'
    }

    @{ slug='small-contractor-tech-stack-from-scratch'
        title='Building a Small-Contractor Tech Stack from Scratch'
        intent='Informational + funnel'
        intro='You''re a 1-5 employee contractor. Here''s the minimum viable software stack — what to buy, what to skip, and the order to deploy.'
        sections=@(
            @{ heading='1. Field service / CRM (week 1)'; body='Start with one platform that handles scheduling, dispatching, quoting, and invoicing. Jobber or Housecall Pro for most trades. Skip enterprise FSM until you''re past 10 employees.'; tools=@('jobber','housecall-pro') }
            @{ heading='2. Accounting (week 1)'; body='QuickBooks Online. Connect it to your FSM the same week. Don''t wait — backfilling accounting is brutal.'; tools=@('quickbooks-online') }
            @{ heading='3. Payments (week 2)'; body='Mobile card processing built into your FSM. Stripe or Square as backup. Offer financing via Payzer if your average ticket is over $1k.'; tools=@('stripe','square','payzer') }
            @{ heading='4. Reviews (week 2)'; body='NiceJob is the easiest entry. Podium if you want SMS-first. Don''t skip this — your Google rating is your CAC.'; tools=@('nicejob','podium') }
            @{ heading='5. Communication (week 3)'; body='Slack for the team, Google Workspace for email + docs. Skip Microsoft 365 unless you already use it.'; tools=@('slack','google-workspace') }
            @{ heading='6. Time tracking (month 2)'; body='ClockShark or Connecteam — both have geofencing and clean QuickBooks integration.'; tools=@('clockshark','connecteam') }
            @{ heading='7. Marketing (month 3)'; body='Mailchimp for email lists, Canva for graphics, WordPress for the website. Total stack cost: ~$50/mo combined.'; tools=@('mailchimp','canva','wordpress') }
        )
        outro='Total monthly cost for this entire stack runs roughly $200-400/mo at the small-business scale. Add tools as the business grows — don''t front-load.'
    }

    @{ slug='how-field-service-teams-reduce-no-shows'
        title='How Field Service Teams Reduce No-Shows and Reschedules'
        intent='Informational + funnel'
        intro='Every no-show is roughly $200-500 in lost revenue and crew time. Here''s the operational workflow top performers use to cut no-show rate by 50-70%.'
        sections=@(
            @{ heading='1. Confirm at booking'; body='Two-way SMS confirmation at the moment of booking. ServiceTitan and Housecall Pro send this automatically; smaller-stack teams can use Podium.'; tools=@('servicetitan','housecall-pro','podium') }
            @{ heading='2. 24-hour reminder'; body='Automated SMS + email day-before. Re-confirm appointment window. Offer easy reschedule link.'; tools=@('servicetitan','housecall-pro','jobber') }
            @{ heading='3. Day-of dispatch SMS'; body='"Tech is on the way" SMS with tech name and photo. This single touch reduces no-shows by 30%+ in practice.'; tools=@('servicetitan','housecall-pro','podium') }
            @{ heading='4. Live GPS tracking'; body='Customer sees the truck approaching, just like an Uber. ServiceTitan, FieldEdge, and Housecall Pro all support this.'; tools=@('servicetitan','fieldedge','housecall-pro') }
            @{ heading='5. Follow-up on no-shows'; body='Automated SMS within 30 minutes asking what happened. About 1 in 3 reschedules vs being lost to a competitor.'; tools=@('podium','servicetitan') }
        )
        outro='Steps 3 and 4 are the highest-leverage. Most teams implement step 2 first because it''s easy — but step 3 moves the needle hardest.'
    }

    @{ slug='how-to-track-project-profitability'
        title='How Commercial Contractors Track Project Profitability'
        intent='Informational + funnel'
        intro='Project-level profitability is the single number that separates contractors who scale from contractors who go bust. Here''s the workflow to track it in real time.'
        sections=@(
            @{ heading='1. Set the budget at award'; body='Convert the winning estimate into the project budget at award. Procore, Sage 300 CRE, and Foundation Software all import structured estimates from ProEst, Sage Estimating, or HeavyBid.'; tools=@('procore','sage-300-cre','foundation-software','proest','heavybid') }
            @{ heading='2. Code time to cost codes'; body='Every field hour must hit a cost code. ClockShark, Rhumbix, or the time-tracking module in Procore handle this on the phone.'; tools=@('clockshark','rhumbix','procore') }
            @{ heading='3. AP coding'; body='Every invoice from a supplier or sub also hits a cost code. Sage 300 CRE, Foundation Software, and Procore Financials make this routine.'; tools=@('sage-300-cre','foundation-software','procore') }
            @{ heading='4. Live cost-to-complete forecasting'; body='Weekly, PM reviews current spend, work-in-place, and forecasts remaining. The variance between estimate and forecast is your true margin signal.'; tools=@('procore','sage-300-cre','redteam') }
            @{ heading='5. Margin review at milestone'; body='At 25%, 50%, 75% completion: full margin review. Adjust forecasts. Lock in change orders. Catch budget bleed before it''s irreversible.'; tools=@('procore','sage-300-cre','foundation-software') }
        )
        outro='The single most overlooked step is #4 — many teams only review profitability at project close, which is far too late to act.'
    }

    @{ slug='best-crm-workflow-for-contractors'
        title='The Best CRM Workflow for Contractor Businesses'
        intent='Informational + funnel'
        intro='Generic CRM advice doesn''t apply to contractors. Your sales process happens in the truck. Here''s the workflow tailored to how trade businesses actually operate.'
        sections=@(
            @{ heading='1. Capture every lead, every channel'; body='Web form, phone, walk-in referrals, Google Maps, Yelp, Angi, Thumbtack — all into one queue. CallRail for call tracking, your CRM for everything else.'; tools=@('callrail','housecall-pro','jobber','servicetitan','angi-leads','thumbtack') }
            @{ heading='2. Tag lead source on every record'; body='Without source tagging, you can''t calculate channel ROI. Most contractor CRMs have a one-click source field. Use it ruthlessly.'; tools=@('servicetitan','jobber','housecall-pro') }
            @{ heading='3. Auto-route to dispatcher'; body='Inbound web lead → SMS to dispatcher within 60 seconds. Speed-to-lead is the #1 conversion lever in trade services.'; tools=@('servicetitan','housecall-pro','workiz') }
            @{ heading='4. Standardize the in-home quote'; body='Tablet-based flat-rate pricebook. Same options shown to every customer. Conversion rate goes up; price erosion goes down.'; tools=@('servicetitan','jobber','housecall-pro') }
            @{ heading='5. Follow-up sequence on unwon quotes'; body='Day 1, day 3, day 7, day 30 — automated SMS + email. About 15% of "lost" quotes will book within 30 days from this sequence alone.'; tools=@('servicetitan','jobber','podium') }
            @{ heading='6. Recurring service triggers'; body='Annual maintenance reminders, water heater anniversaries, HVAC seasonal tune-ups. Set once, runs forever.'; tools=@('servicetitan','fieldedge','housecall-pro') }
        )
        outro='Most contractors get to step 2 and stall. The compounding returns happen at steps 5 and 6 — and they''re the cheapest to implement.'
    }
)

# Wrap and emit
$out = [PSCustomObject]@{
    bestForHubs   = $bestForHubs
    vsPairs       = $vsPairs
    tradeHubs     = $tradeHubs
    softwareHubs  = $softwareHubs
    workflows     = $workflows
}

$json = $out | ConvertTo-Json -Depth 10
Set-Content -Path $outJson -Value $json -Encoding UTF8
Write-Host "Wrote $outJson"
Write-Host "  Best-For hubs:       $($bestForHubs.Count)"
Write-Host "  VS pairs:            $($vsPairs.Count)"
Write-Host "  Trade hubs:          $($tradeHubs.Count)"
Write-Host "  Software hubs:       $($softwareHubs.Count)"
Write-Host "  Workflow guides:     $($workflows.Count)"
