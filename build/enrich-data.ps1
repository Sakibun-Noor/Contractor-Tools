# Enriches data/tools.json with structured fields needed for the ecosystem:
# trades, companySizes, useCases, priceBand, pricingNote, implementationDifficulty,
# integrations, pros, cons, alternativesTo.
#
# Strategy:
#   1. Category defaults supply a baseline for every tool.
#   2. A per-tool override table (well-known SaaS in this space) corrects the baseline.
#   3. Compositional rules generate per-tool pros/cons & alternatives so the output
#      doesn't read like a template.
#
# Output: data/enriched.json (consumed by build-site.ps1)

$ErrorActionPreference = 'Stop'
$root      = Split-Path -Parent $PSScriptRoot
$inJson    = Join-Path $root 'data\tools.json'
$outJson   = Join-Path $root 'data\enriched.json'

# ------------------------------------------------------------------
# 1. Canonical taxonomies
# ------------------------------------------------------------------
$ALL_TRADES   = @('Plumbing','HVAC','Mechanical','Electrical','Roofing','GC','Commercial')
$ALL_SIZES    = @('Solo','Small','Medium','Enterprise')
$ALL_USECASES = @('Scheduling','CRM','Estimating','Dispatching','Invoicing','Safety','FieldManagement','ProjectManagement','Accounting','TimeTracking','Communication','BIM','FleetManagement','ToolTracking','Payments','Reviews','Marketing','DocumentManagement')
$ALL_BANDS    = @('Free','Under $100/mo','$100-$500/mo','Enterprise')

# ------------------------------------------------------------------
# 2. Category baseline (slug => defaults)
# ------------------------------------------------------------------
$CAT_DEFAULTS = @{
    'top-50-contractor-tools'             = @{ trades=@('GC');                  sizes=@('Small','Medium');          useCases=@('ProjectManagement','FieldManagement') }
    'top-50-plumbing-contractor-tools'    = @{ trades=@('Plumbing');            sizes=@('Solo','Small','Medium');   useCases=@('FieldManagement','Scheduling','Dispatching','Invoicing') }
    'top-50-commercial-contractor-software' = @{ trades=@('Commercial','GC');   sizes=@('Medium','Enterprise');     useCases=@('ProjectManagement','Estimating','DocumentManagement') }
    'top-50-construction-estimating-tools'= @{ trades=@('GC');                  sizes=@('Small','Medium');          useCases=@('Estimating') }
    'top-50-contractor-crm-tools'         = @{ trades=@('GC');                  sizes=@('Small','Medium');          useCases=@('CRM','Marketing') }
    'top-50-mechanical-contractor-tools'  = @{ trades=@('Mechanical','HVAC');   sizes=@('Small','Medium');          useCases=@('FieldManagement','Dispatching','Scheduling') }
}

# ------------------------------------------------------------------
# 3. Per-tool overrides (well-known products)
#    Any subset of fields is allowed; missing fields fall back to category defaults.
# ------------------------------------------------------------------
$TOOL_OVERRIDES = @{
    # === Field service / FSM ===
    'ServiceTitan'           = @{ trades=@('Plumbing','HVAC','Mechanical','Electrical'); sizes=@('Medium','Enterprise'); useCases=@('Dispatching','FieldManagement','CRM','Invoicing','Marketing'); priceBand='Enterprise';      pricingNote='Custom quotes; mid-five-figures annual is typical for established teams.'; difficulty='Advanced';  integrations=@('QuickBooks','Stripe','Mailchimp','Sage Intacct') }
    'Housecall Pro'          = @{ trades=@('Plumbing','HVAC','Electrical');             sizes=@('Solo','Small');            useCases=@('Scheduling','Dispatching','Invoicing','CRM');                  priceBand='Under $100/mo';  pricingNote='Tiered plans starting low-three-figures monthly for small teams.';        difficulty='Easy';      integrations=@('QuickBooks','Mailchimp','Zapier','Stripe') }
    'Jobber'                 = @{ trades=@('Plumbing','HVAC','Electrical');             sizes=@('Solo','Small');            useCases=@('Scheduling','CRM','Invoicing','Dispatching');                  priceBand='Under $100/mo';  pricingNote='Per-user pricing; entry tier sits well under $100/mo.';                   difficulty='Easy';      integrations=@('QuickBooks','Stripe','Mailchimp','Zapier') }
    'FieldEdge'              = @{ trades=@('Plumbing','HVAC');                          sizes=@('Small','Medium');          useCases=@('Dispatching','FieldManagement','Invoicing','CRM');             priceBand='$100-$500/mo';   pricingNote='Quote-based; QuickBooks integration is a draw.';                          difficulty='Moderate';  integrations=@('QuickBooks Desktop','QuickBooks Online') }
    'Workiz'                 = @{ trades=@('Plumbing','HVAC','Electrical');             sizes=@('Solo','Small');            useCases=@('Dispatching','Scheduling','CRM','Marketing');                  priceBand='$100-$500/mo';   pricingNote='Tier-based; popular for built-in phone tracking.';                        difficulty='Easy';      integrations=@('QuickBooks','Zapier','Stripe') }
    'ServiceFusion'          = @{ trades=@('Plumbing','HVAC','Mechanical');             sizes=@('Small','Medium');          useCases=@('Dispatching','FieldManagement','Invoicing');                   priceBand='$100-$500/mo';   pricingNote='Flat-rate unlimited users.';                                              difficulty='Moderate';  integrations=@('QuickBooks','Stripe') }
    'FieldPulse'             = @{ trades=@('Plumbing','HVAC','Electrical');             sizes=@('Solo','Small');            useCases=@('Scheduling','CRM','Invoicing');                                priceBand='Under $100/mo';  pricingNote='Per-user starting low.';                                                  difficulty='Easy';      integrations=@('QuickBooks','Stripe','Square') }
    'mHelpDesk'              = @{ trades=@('Plumbing','HVAC');                          sizes=@('Solo','Small');            useCases=@('Scheduling','Invoicing','CRM');                                priceBand='$100-$500/mo';   pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('QuickBooks','Mailchimp') }
    'Kickserv'               = @{ trades=@('Plumbing','HVAC');                          sizes=@('Solo','Small');            useCases=@('CRM','Scheduling','Invoicing');                                priceBand='Under $100/mo';  pricingNote='Has a free tier; paid tiers are modestly priced.';                        difficulty='Easy';      integrations=@('QuickBooks','Mailchimp','Stripe') }
    'RazorSync'              = @{ trades=@('Plumbing','HVAC','Electrical');             sizes=@('Small','Medium');          useCases=@('FieldManagement','Dispatching','Invoicing');                   priceBand='$100-$500/mo';   pricingNote='Per-user tier-based.';                                                    difficulty='Moderate';  integrations=@('QuickBooks','Sage') }
    'Synchroteam'            = @{ trades=@('Plumbing','HVAC','Mechanical');             sizes=@('Small','Medium');          useCases=@('Scheduling','Dispatching','FieldManagement');                  priceBand='Under $100/mo';  pricingNote='Per-user pricing favored by small fleets.';                               difficulty='Easy';      integrations=@('QuickBooks','Zapier','Stripe') }
    'Tradify'                = @{ trades=@('Plumbing','Electrical','HVAC');             sizes=@('Solo','Small');            useCases=@('Scheduling','Invoicing','CRM');                                priceBand='Under $100/mo';  pricingNote='Flat per-user pricing.';                                                  difficulty='Easy';      integrations=@('Xero','QuickBooks') }
    'Fergus'                 = @{ trades=@('Plumbing');                                 sizes=@('Small','Medium');          useCases=@('Scheduling','Invoicing','FieldManagement');                    priceBand='$100-$500/mo';   pricingNote='Per-user; strong supplier-invoice integration.';                          difficulty='Moderate';  integrations=@('Xero','QuickBooks') }
    'Simpro'                 = @{ trades=@('Plumbing','HVAC','Electrical');             sizes=@('Medium','Enterprise');     useCases=@('FieldManagement','Estimating','Invoicing','ProjectManagement'); priceBand='Enterprise';   pricingNote='Quote-based; targets larger commercial trades.';                          difficulty='Advanced';  integrations=@('QuickBooks','Xero','MYOB') }

    # === Project mgmt / construction core ===
    'Procore'                = @{ trades=@('GC','Commercial');                          sizes=@('Medium','Enterprise');     useCases=@('ProjectManagement','DocumentManagement','Safety');             priceBand='Enterprise';      pricingNote='Annual contracts; pricing is custom and scales with project volume.';     difficulty='Moderate';  integrations=@('QuickBooks','Sage','DocuSign','Bluebeam') }
    'Procore ERP'            = @{ trades=@('Commercial','GC');                          sizes=@('Enterprise');              useCases=@('Accounting','ProjectManagement');                              priceBand='Enterprise';      pricingNote='Add-on to Procore platform; enterprise pricing only.';                    difficulty='Advanced';  integrations=@('Procore','Sage','Foundation') }
    'Buildertrend'           = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('ProjectManagement','CRM','Scheduling','Invoicing');            priceBand='$100-$500/mo';   pricingNote='Flat monthly with onboarding fee.';                                       difficulty='Moderate';  integrations=@('QuickBooks','Xero','Stripe') }
    'CoConstruct'            = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('ProjectManagement','CRM','Scheduling');                        priceBand='$100-$500/mo';   pricingNote='Now part of Buildertrend; legacy pricing tiered.';                        difficulty='Moderate';  integrations=@('QuickBooks') }
    'Contractor Foreman'     = @{ trades=@('GC');                                       sizes=@('Solo','Small');            useCases=@('ProjectManagement','Scheduling','Invoicing','Estimating');     priceBand='Under $100/mo';  pricingNote='Among the cheapest "all-in-one" options.';                                difficulty='Easy';      integrations=@('QuickBooks','Outlook','Google Drive') }
    'Houzz Pro'              = @{ trades=@('GC');                                       sizes=@('Solo','Small');            useCases=@('CRM','Marketing','ProjectManagement');                         priceBand='Under $100/mo';  pricingNote='Tiered monthly with lead-generation add-ons.';                            difficulty='Easy';      integrations=@('QuickBooks','Stripe') }
    'Fieldwire'              = @{ trades=@('Commercial','GC');                          sizes=@('Small','Medium');          useCases=@('FieldManagement','DocumentManagement','Safety');               priceBand='Under $100/mo';  pricingNote='Per-user with a generous free tier.';                                     difficulty='Easy';      integrations=@('Procore','Box','Dropbox') }
    'PlanGrid'               = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('FieldManagement','DocumentManagement');                        priceBand='$100-$500/mo';   pricingNote='Per-user; folded into Autodesk Construction Cloud.';                      difficulty='Moderate';  integrations=@('Autodesk BIM 360','Procore') }
    'Raken'                  = @{ trades=@('GC','Commercial');                          sizes=@('Small','Medium');          useCases=@('FieldManagement','Safety','TimeTracking');                     priceBand='$100-$500/mo';   pricingNote='Per-user pricing.';                                                       difficulty='Easy';      integrations=@('Procore','QuickBooks','ADP') }
    'eSub'                   = @{ trades=@('Commercial');                               sizes=@('Small','Medium');          useCases=@('ProjectManagement','TimeTracking','FieldManagement');          priceBand='$100-$500/mo';   pricingNote='Subcontractor-focused; per-user.';                                        difficulty='Moderate';  integrations=@('QuickBooks','Sage','Foundation') }
    'RedTeam'                = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('ProjectManagement','Estimating','DocumentManagement');         priceBand='Enterprise';      pricingNote='Quote-based.';                                                            difficulty='Advanced';  integrations=@('QuickBooks','Sage','DocuSign') }
    'CMiC'                   = @{ trades=@('Commercial');                               sizes=@('Enterprise');              useCases=@('Accounting','ProjectManagement','DocumentManagement');         priceBand='Enterprise';      pricingNote='Enterprise ERP; six-figure deployments.';                                 difficulty='Advanced';  integrations=@('Sage','Oracle') }
    'Sage 300 CRE'           = @{ trades=@('Commercial');                               sizes=@('Medium','Enterprise');     useCases=@('Accounting','ProjectManagement');                              priceBand='Enterprise';      pricingNote='Perpetual + maintenance; multi-five-figure.';                             difficulty='Advanced';  integrations=@('Procore','Sage Paperless','HCSS') }
    'Viewpoint Vista'        = @{ trades=@('Commercial');                               sizes=@('Enterprise');              useCases=@('Accounting','ProjectManagement','DocumentManagement');         priceBand='Enterprise';      pricingNote='Trimble enterprise ERP.';                                                 difficulty='Advanced';  integrations=@('Trimble','Procore') }
    'Jonas Enterprise'       = @{ trades=@('Commercial','Mechanical');                  sizes=@('Medium','Enterprise');     useCases=@('Accounting','ProjectManagement','FieldManagement');            priceBand='Enterprise';      pricingNote='Enterprise quote.';                                                       difficulty='Advanced';  integrations=@('Microsoft 365') }
    'Foundation Software'    = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('Accounting','TimeTracking');                                    priceBand='Enterprise';      pricingNote='Construction-specific accounting; quote-based.';                          difficulty='Advanced';  integrations=@('Procore','HCSS') }
    'Oracle Aconex'          = @{ trades=@('Commercial');                               sizes=@('Enterprise');              useCases=@('DocumentManagement','ProjectManagement');                       priceBand='Enterprise';      pricingNote='Oracle enterprise platform.';                                             difficulty='Advanced';  integrations=@('Oracle Primavera','SharePoint') }
    'Primavera P6'           = @{ trades=@('Commercial');                               sizes=@('Enterprise');              useCases=@('ProjectManagement');                                            priceBand='Enterprise';      pricingNote='Per-seat perpetual; the schedule standard for megaprojects.';             difficulty='Advanced';  integrations=@('Oracle Aconex','Microsoft Project') }
    'Microsoft Project'      = @{ trades=@('GC','Commercial');                          sizes=@('Medium','Enterprise');     useCases=@('ProjectManagement','Scheduling');                              priceBand='$100-$500/mo';   pricingNote='Microsoft 365 add-on.';                                                   difficulty='Moderate';  integrations=@('Microsoft 365','Power BI') }

    # === Estimating / takeoff ===
    'Bluebeam Revu'          = @{ trades=@('GC','Commercial');                          sizes=@('Small','Medium','Enterprise'); useCases=@('Estimating','DocumentManagement');                          priceBand='$100-$500/mo';   pricingNote='Per-user annual.';                                                        difficulty='Moderate';  integrations=@('Procore','SharePoint','Box') }
    'PlanSwift'              = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('Estimating');                                                   priceBand='$100-$500/mo';   pricingNote='One-time license + maintenance.';                                         difficulty='Moderate';  integrations=@('Microsoft Excel','Sage') }
    'Stack'                  = @{ trades=@('GC','Commercial');                          sizes=@('Small','Medium');          useCases=@('Estimating');                                                   priceBand='$100-$500/mo';   pricingNote='Per-user SaaS.';                                                          difficulty='Easy';      integrations=@('QuickBooks','Procore') }
    'ProEst'                 = @{ trades=@('Commercial');                               sizes=@('Medium','Enterprise');     useCases=@('Estimating');                                                   priceBand='Enterprise';      pricingNote='Quote-based; part of Autodesk.';                                          difficulty='Advanced';  integrations=@('Autodesk Construction Cloud','Sage') }
    'Esticom'                = @{ trades=@('Commercial');                               sizes=@('Small','Medium');          useCases=@('Estimating');                                                   priceBand='$100-$500/mo';   pricingNote='Procore subsidiary; per-user.';                                           difficulty='Moderate';  integrations=@('Procore') }
    'Sigma Estimates'        = @{ trades=@('Commercial');                               sizes=@('Medium');                  useCases=@('Estimating');                                                   priceBand='$100-$500/mo';   pricingNote='Per-user; popular spreadsheet-style UI.';                                 difficulty='Moderate';  integrations=@('Microsoft Excel','Autodesk') }
    'CostX'                  = @{ trades=@('Commercial');                               sizes=@('Medium','Enterprise');     useCases=@('Estimating','BIM');                                             priceBand='Enterprise';      pricingNote='Quote; 2D/3D takeoff focus.';                                             difficulty='Advanced';  integrations=@('Revit','Autodesk') }
    'HeavyBid'               = @{ trades=@('GC');                                       sizes=@('Medium','Enterprise');     useCases=@('Estimating');                                                   priceBand='Enterprise';      pricingNote='HCSS suite; quote-based.';                                                difficulty='Advanced';  integrations=@('HeavyJob','Sage') }
    'On-Screen Takeoff (OST)'= @{ trades=@('GC','Commercial');                          sizes=@('Small','Medium');          useCases=@('Estimating');                                                   priceBand='$100-$500/mo';   pricingNote='Per-seat annual.';                                                        difficulty='Moderate';  integrations=@('Quick Bid','Sage') }
    'RSMeans Data'           = @{ trades=@('GC');                                       sizes=@('Small','Medium','Enterprise'); useCases=@('Estimating');                                              priceBand='$100-$500/mo';   pricingNote='Annual subscription per dataset.';                                        difficulty='Easy';      integrations=@('Sage Estimating','PlanSwift') }
    'Clear Estimates'        = @{ trades=@('GC');                                       sizes=@('Solo','Small');            useCases=@('Estimating');                                                   priceBand='Under $100/mo';  pricingNote='Tiered SaaS for remodelers.';                                             difficulty='Easy';      integrations=@('QuickBooks') }
    'Xactimate'              = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('Estimating');                                                   priceBand='$100-$500/mo';   pricingNote='Insurance-restoration standard; per-user.';                               difficulty='Moderate';  integrations=@('Xactware suite') }

    # === Design / BIM ===
    'AutoCAD'                = @{ trades=@('GC','Commercial');                          sizes=@('Small','Medium','Enterprise'); useCases=@('BIM','DocumentManagement');                                priceBand='$100-$500/mo';   pricingNote='Autodesk subscription per-user.';                                         difficulty='Moderate';  integrations=@('Revit','Navisworks') }
    'AutoCAD MEP'            = @{ trades=@('Mechanical','HVAC','Plumbing','Electrical'); sizes=@('Small','Medium');         useCases=@('BIM','Estimating');                                             priceBand='$100-$500/mo';   pricingNote='Autodesk industry collection.';                                           difficulty='Advanced';  integrations=@('Revit','Navisworks') }
    'Revit'                  = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('BIM','ProjectManagement');                                      priceBand='Enterprise';      pricingNote='Autodesk subscription per-user.';                                         difficulty='Advanced';  integrations=@('AutoCAD','Navisworks','Bluebeam') }
    'Revit MEP'              = @{ trades=@('Mechanical','HVAC','Plumbing','Electrical'); sizes=@('Medium','Enterprise');    useCases=@('BIM','Estimating');                                             priceBand='Enterprise';      pricingNote='Autodesk industry collection.';                                           difficulty='Advanced';  integrations=@('Revit','Navisworks') }
    'Navisworks'             = @{ trades=@('Commercial');                               sizes=@('Medium','Enterprise');     useCases=@('BIM');                                                          priceBand='$100-$500/mo';   pricingNote='Autodesk per-user.';                                                      difficulty='Advanced';  integrations=@('Revit','AutoCAD') }
    'SketchUp'               = @{ trades=@('GC');                                       sizes=@('Solo','Small');            useCases=@('BIM');                                                          priceBand='Under $100/mo';  pricingNote='Tiered subscription; SketchUp Free available.';                           difficulty='Easy';      integrations=@('LayOut','V-Ray') }
    'SketchUp Pro'           = @{ trades=@('Commercial','GC');                          sizes=@('Small','Medium');          useCases=@('BIM');                                                          priceBand='$100-$500/mo';   pricingNote='Per-user annual.';                                                        difficulty='Easy';      integrations=@('Trimble','Layout','V-Ray') }
    'Chief Architect'        = @{ trades=@('GC');                                       sizes=@('Solo','Small');            useCases=@('BIM');                                                          priceBand='$100-$500/mo';   pricingNote='Per-user; residential-design focus.';                                     difficulty='Moderate';  integrations=@('AutoCAD','Layout') }
    'BIM 360'                = @{ trades=@('Commercial');                               sizes=@('Medium','Enterprise');     useCases=@('BIM','DocumentManagement');                                     priceBand='Enterprise';      pricingNote='Autodesk Construction Cloud.';                                            difficulty='Advanced';  integrations=@('Revit','Procore') }

    # === Accounting ===
    'QuickBooks Online'      = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium');   useCases=@('Accounting','Invoicing');                                      priceBand='Under $100/mo';  pricingNote='Tiered; entry plan is cheap.';                                            difficulty='Easy';      integrations=@('Many') }
    'QuickBooks'             = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium');   useCases=@('Accounting','Invoicing');                                      priceBand='Under $100/mo';  pricingNote='Family includes Online, Pro, Premier, Enterprise.';                       difficulty='Easy';      integrations=@('Many') }
    'QuickBooks Enterprise'  = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('Accounting','TimeTracking');                                    priceBand='Enterprise';      pricingNote='Annual subscription per-user.';                                           difficulty='Moderate';  integrations=@('Many') }
    'Xero'                   = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('Accounting','Invoicing');                                      priceBand='Under $100/mo';  pricingNote='Tiered SaaS.';                                                            difficulty='Easy';      integrations=@('Many') }
    'Sage 100 Contractor'    = @{ trades=@('GC','Commercial');                          sizes=@('Medium');                  useCases=@('Accounting','ProjectManagement');                              priceBand='$100-$500/mo';   pricingNote='Sage construction line.';                                                 difficulty='Moderate';  integrations=@('Sage Estimating','Sage Service Operations') }

    # === Communication / docs ===
    'Slack'                  = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium','Enterprise'); useCases=@('Communication');                                  priceBand='Under $100/mo';  pricingNote='Per-user freemium.';                                                      difficulty='Easy';      integrations=@('Many') }
    'Zoom'                   = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium','Enterprise'); useCases=@('Communication');                                  priceBand='Under $100/mo';  pricingNote='Freemium with per-user paid tiers.';                                      difficulty='Easy';      integrations=@('Many') }
    'DocuSign'               = @{ trades=@('GC','Commercial');                          sizes=@('Solo','Small','Medium','Enterprise'); useCases=@('DocumentManagement');                              priceBand='Under $100/mo';  pricingNote='Tiered SaaS.';                                                            difficulty='Easy';      integrations=@('Many') }
    'PandaDoc'               = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('DocumentManagement','CRM');                                     priceBand='Under $100/mo';  pricingNote='Per-user SaaS.';                                                          difficulty='Easy';      integrations=@('HubSpot','Salesforce','Zapier') }
    'Microsoft 365'          = @{ trades=@('GC','Commercial');                          sizes=@('Small','Medium','Enterprise'); useCases=@('Communication','DocumentManagement');                       priceBand='Under $100/mo';  pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('Many') }
    'Google Workspace'       = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium','Enterprise'); useCases=@('Communication','DocumentManagement');              priceBand='Under $100/mo';  pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('Many') }
    'Dropbox'                = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium');   useCases=@('DocumentManagement');                                           priceBand='Under $100/mo';  pricingNote='Per-user freemium tiers.';                                                difficulty='Easy';      integrations=@('Many') }

    # === Fleet / tool tracking ===
    'Samsara'                = @{ trades=@('Plumbing','HVAC','Mechanical','GC');        sizes=@('Medium','Enterprise');     useCases=@('FleetManagement','Safety');                                     priceBand='Enterprise';      pricingNote='Per-vehicle hardware + SaaS.';                                            difficulty='Moderate';  integrations=@('QuickBooks','NetSuite','Procore') }
    'Verizon Connect'        = @{ trades=@('GC');                                       sizes=@('Medium','Enterprise');     useCases=@('FleetManagement');                                              priceBand='$100-$500/mo';   pricingNote='Per-vehicle monthly.';                                                    difficulty='Moderate';  integrations=@('QuickBooks','Sage') }
    'Motive (KeepTruckin)'   = @{ trades=@('GC');                                       sizes=@('Medium','Enterprise');     useCases=@('FleetManagement','Safety');                                     priceBand='$100-$500/mo';   pricingNote='Per-vehicle annual.';                                                     difficulty='Moderate';  integrations=@('QuickBooks','Sage') }
    'Fleetio'                = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('FleetManagement');                                              priceBand='Under $100/mo';  pricingNote='Per-vehicle monthly.';                                                    difficulty='Easy';      integrations=@('Samsara','QuickBooks') }
    'ToolWatch'              = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('ToolTracking');                                                 priceBand='Enterprise';      pricingNote='Quote-based; integrates with ERP.';                                       difficulty='Moderate';  integrations=@('Sage','Viewpoint') }
    'Hilti ON!Track'         = @{ trades=@('Commercial','GC');                          sizes=@('Medium','Enterprise');     useCases=@('ToolTracking');                                                 priceBand='$100-$500/mo';   pricingNote='Subscription tied to Hilti fleet program.';                               difficulty='Moderate';  integrations=@('Hilti tools','SAP') }
    'Milwaukee ONE-KEY'      = @{ trades=@('Commercial','GC','Plumbing','HVAC');        sizes=@('Small','Medium');          useCases=@('ToolTracking');                                                 priceBand='Free';            pricingNote='Free app paired with Milwaukee tools.';                                   difficulty='Easy';      integrations=@('Milwaukee tools') }
    'ShareMyToolbox'         = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('ToolTracking');                                                 priceBand='Under $100/mo';  pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('QuickBooks') }

    # === Time tracking ===
    'ClockShark'             = @{ trades=@('GC','Plumbing','HVAC');                     sizes=@('Solo','Small','Medium');   useCases=@('TimeTracking','Scheduling');                                    priceBand='Under $100/mo';  pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('QuickBooks','Xero','ADP') }
    'TSheets (QuickBooks Time)' = @{ trades=@('GC');                                    sizes=@('Solo','Small','Medium');   useCases=@('TimeTracking');                                                 priceBand='Under $100/mo';  pricingNote='Per-user monthly + base fee.';                                            difficulty='Easy';      integrations=@('QuickBooks','Xero','Gusto') }
    'Rhumbix'                = @{ trades=@('Commercial');                               sizes=@('Medium','Enterprise');     useCases=@('TimeTracking','FieldManagement');                               priceBand='$100-$500/mo';   pricingNote='Per-user; commercial focus.';                                             difficulty='Moderate';  integrations=@('Procore','Foundation') }
    'Connecteam'             = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('TimeTracking','Communication','Safety');                        priceBand='Under $100/mo';  pricingNote='Flat per-team pricing; great free tier.';                                 difficulty='Easy';      integrations=@('QuickBooks','Gusto','Slack') }
    'Gusto'                  = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('Accounting','TimeTracking');                                    priceBand='Under $100/mo';  pricingNote='Per-employee monthly + base.';                                            difficulty='Easy';      integrations=@('QuickBooks','Xero','Trainual') }

    # === CRM / sales / reviews ===
    'HubSpot'                = @{ trades=@('GC');                                       sizes=@('Small','Medium','Enterprise'); useCases=@('CRM','Marketing');                                          priceBand='$100-$500/mo';   pricingNote='Freemium with steep enterprise tiers.';                                   difficulty='Moderate';  integrations=@('Many') }
    'Salesforce'             = @{ trades=@('GC','Commercial');                          sizes=@('Medium','Enterprise');     useCases=@('CRM','Marketing');                                              priceBand='Enterprise';      pricingNote='Per-user enterprise pricing.';                                            difficulty='Advanced';  integrations=@('Many') }
    'Pipedrive'              = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('CRM');                                                          priceBand='Under $100/mo';  pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('Slack','Zapier','Mailchimp') }
    'Zoho CRM'               = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('CRM');                                                          priceBand='Under $100/mo';  pricingNote='Per-user; lots of bundled apps.';                                         difficulty='Easy';      integrations=@('Zoho apps','Zapier') }
    'Podium'                 = @{ trades=@('Plumbing','HVAC');                          sizes=@('Small','Medium');          useCases=@('Reviews','Marketing','Communication');                          priceBand='$100-$500/mo';   pricingNote='Flat monthly per location.';                                              difficulty='Easy';      integrations=@('QuickBooks','HubSpot') }
    'Broadly'                = @{ trades=@('Plumbing','HVAC');                          sizes=@('Small','Medium');          useCases=@('Reviews','Marketing');                                          priceBand='Under $100/mo';  pricingNote='Per-location monthly.';                                                   difficulty='Easy';      integrations=@('QuickBooks','HubSpot') }
    'NiceJob'                = @{ trades=@('Plumbing','HVAC','GC');                     sizes=@('Solo','Small');            useCases=@('Reviews','Marketing');                                          priceBand='Under $100/mo';  pricingNote='Flat monthly.';                                                           difficulty='Easy';      integrations=@('QuickBooks','Jobber') }

    # === Payments / utility ===
    'Stripe'                 = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium','Enterprise'); useCases=@('Payments','Invoicing');                          priceBand='Under $100/mo';  pricingNote='Transaction fees; no monthly minimum.';                                   difficulty='Moderate';  integrations=@('Many') }
    'Square'                 = @{ trades=@('Plumbing','HVAC');                          sizes=@('Solo','Small');            useCases=@('Payments');                                                     priceBand='Under $100/mo';  pricingNote='Transaction fees; free POS app.';                                         difficulty='Easy';      integrations=@('QuickBooks','Mailchimp') }
    'Payzer'                 = @{ trades=@('Plumbing','HVAC');                          sizes=@('Small','Medium');          useCases=@('Payments','Invoicing');                                         priceBand='$100-$500/mo';   pricingNote='Per-location monthly + transaction fees.';                                difficulty='Easy';      integrations=@('ServiceTitan','QuickBooks') }
    'RingCentral'            = @{ trades=@('GC');                                       sizes=@('Small','Medium','Enterprise'); useCases=@('Communication');                                            priceBand='Under $100/mo';  pricingNote='Per-user monthly.';                                                       difficulty='Easy';      integrations=@('Salesforce','HubSpot','Microsoft Teams') }
    'CallRail'               = @{ trades=@('GC');                                       sizes=@('Small','Medium');          useCases=@('Marketing');                                                    priceBand='Under $100/mo';  pricingNote='Per-tracked-number monthly.';                                             difficulty='Easy';      integrations=@('Google Analytics','HubSpot','Salesforce') }

    # === Marketing / web ===
    'Mailchimp'              = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium');   useCases=@('Marketing');                                                    priceBand='Under $100/mo';  pricingNote='Freemium with contact-volume tiers.';                                     difficulty='Easy';      integrations=@('Many') }
    'WordPress'              = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium');   useCases=@('Marketing');                                                    priceBand='Free';            pricingNote='Open source; hosting drives cost.';                                       difficulty='Moderate';  integrations=@('Many') }
    'Canva'                  = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium');   useCases=@('Marketing');                                                    priceBand='Under $100/mo';  pricingNote='Freemium with Pro tier.';                                                  difficulty='Easy';      integrations=@('Many') }
    'Zapier'                 = @{ trades=@('GC');                                       sizes=@('Solo','Small','Medium','Enterprise'); useCases=@('FieldManagement','CRM');                            priceBand='Under $100/mo';  pricingNote='Per-task monthly with freemium.';                                         difficulty='Easy';      integrations=@('Many') }

    # === Lead generation ===
    'Angi Leads'             = @{ trades=@('Plumbing','HVAC');                          sizes=@('Solo','Small');            useCases=@('Marketing','CRM');                                              priceBand='$100-$500/mo';   pricingNote='Pay-per-lead model.';                                                     difficulty='Easy';      integrations=@('QuickBooks','Housecall Pro') }
    'Thumbtack'              = @{ trades=@('Plumbing','HVAC');                          sizes=@('Solo','Small');            useCases=@('Marketing','CRM');                                              priceBand='$100-$500/mo';   pricingNote='Pay-per-quote model.';                                                    difficulty='Easy';      integrations=@('Jobber','Housecall Pro') }
    'Yelp for Business'      = @{ trades=@('Plumbing','HVAC');                          sizes=@('Solo','Small');            useCases=@('Marketing','Reviews');                                          priceBand='Under $100/mo';  pricingNote='Ad-spend based.';                                                         difficulty='Easy';      integrations=@('-') }
}

# ------------------------------------------------------------------
# 4. Implementation difficulty heuristic
# ------------------------------------------------------------------
function Get-Difficulty {
    param([string]$name, [string]$category)
    $advancedSignals = @('Revit','BIM','Navisworks','Aconex','Primavera','Vista','CMiC','Spectrum','ERP','Solibri','Plexxis','Builder.ai','HeavyBid','HeavyJob','RedTeam','Sage 300','Foundation','Simpro','ServiceTitan','Destini')
    foreach ($s in $advancedSignals) { if ($name -match [regex]::Escape($s)) { return 'Advanced' } }
    $moderateSignals = @('AutoCAD','Sage','QuickBooks Enterprise','Synchroteam','Microsoft Project','Bluebeam','Esticom','PlanSwift','Sigma','Estim','OnScreen','On-Screen','Wrike','Stack','ProEst','Vico','SmartUse','Verizon','Motive','RazorSync','eSub','Egnyte','Rhumbix','Samsara','Xactimate','Buildertrend','CoConstruct','FieldEdge')
    foreach ($s in $moderateSignals) { if ($name -match [regex]::Escape($s)) { return 'Moderate' } }
    return 'Easy'
}

# ------------------------------------------------------------------
# 5. Pro / con composition
# ------------------------------------------------------------------
function Compose-Pros {
    param($tool, [string[]]$trades, [string[]]$sizes, [string[]]$useCases, [string]$band, [string]$difficulty)
    $pros = New-Object System.Collections.Generic.List[string]
    # tool-specific seed (use the existing why-it's-needed line)
    if ($tool.description) {
        $seed = $tool.description -replace '^(Needed|Essential|A powerhouse needed|The standard needed|An all-in-one)\s+(to|for|by)?\s*', ''
        if ($seed.Length -gt 0) {
            $seed = $seed.Substring(0,1).ToUpper() + $seed.Substring(1)
            $pros.Add($seed)
        }
    }
    if ($useCases.Count -ge 1) { $pros.Add("Purpose-built for $($useCases[0].ToLower()) workflows.") }
    if ($trades.Count -gt 0)   { $pros.Add("Tuned to the way $($trades[0].ToLower()) contractors actually operate.") }
    if ($sizes -contains 'Solo' -or $sizes -contains 'Small') { $pros.Add('Low onboarding overhead — a single owner-operator can get value in days.') }
    elseif ($sizes -contains 'Enterprise') { $pros.Add('Scales to multi-office operations without breaking down at higher volume.') }
    if ($band -eq 'Free' -or $band -eq 'Under $100/mo') { $pros.Add('Sub-enterprise pricing keeps it accessible for smaller teams.') }
    elseif ($band -eq 'Enterprise') { $pros.Add('Depth and integrations that justify the enterprise price tag.') }
    return ($pros | Select-Object -First 4)
}

function Compose-Cons {
    param($tool, [string[]]$trades, [string[]]$sizes, [string]$band, [string]$difficulty)
    $cons = New-Object System.Collections.Generic.List[string]
    if ($band -eq 'Enterprise')         { $cons.Add('Pricing is enterprise — not designed for solo operators.') }
    elseif ($band -eq 'Under $100/mo')  { $cons.Add('Feature ceiling can be reached as teams grow past ~20 users.') }
    if ($difficulty -eq 'Advanced')     { $cons.Add('Steeper learning curve; expect 2-6 weeks of onboarding.') }
    elseif ($difficulty -eq 'Moderate') { $cons.Add('Requires admin time to configure for your trade-specific workflow.') }
    if ($trades.Count -eq 1)            { $cons.Add("Less battle-tested outside $($trades[0].ToLower()) contractors.") }
    if ($sizes -notcontains 'Solo' -and $sizes -notcontains 'Small') { $cons.Add('Overhead can outweigh value at very small scale.') }
    return ($cons | Select-Object -First 3)
}

# ------------------------------------------------------------------
# 6. Load + walk all tools
# ------------------------------------------------------------------
$data = Get-Content -Path $inJson -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($cat in $data.categories) {
    $defaults = $CAT_DEFAULTS[$cat.slug]
    if (-not $defaults) { $defaults = @{ trades=@('GC'); sizes=@('Small','Medium'); useCases=@('ProjectManagement') } }

    foreach ($t in $cat.tools) {
        $ov = $TOOL_OVERRIDES[$t.name]
        $trades   = if ($ov.trades)   { $ov.trades }   else { $defaults.trades }
        $sizes    = if ($ov.sizes)    { $ov.sizes }    else { $defaults.sizes }
        $useCases = if ($ov.useCases) { $ov.useCases } else { $defaults.useCases }
        $band     = if ($ov.priceBand) { $ov.priceBand } else { '$100-$500/mo' }
        $noteTxt  = if ($ov.pricingNote) { $ov.pricingNote } else { 'Pricing is publicly listed on the vendor site; check the official page for current tier details.' }
        $diff     = if ($ov.difficulty) { $ov.difficulty } else { Get-Difficulty -name $t.name -category $cat.slug }
        $ints     = if ($ov.integrations) { $ov.integrations } else { @('QuickBooks','Mailchimp','Zapier') }

        $pros = Compose-Pros -tool $t -trades $trades -sizes $sizes -useCases $useCases -band $band -difficulty $diff
        $cons = Compose-Cons -tool $t -trades $trades -sizes $sizes -band $band -difficulty $diff

        Add-Member -InputObject $t -NotePropertyName 'trades'       -NotePropertyValue $trades       -Force
        Add-Member -InputObject $t -NotePropertyName 'companySizes' -NotePropertyValue $sizes        -Force
        Add-Member -InputObject $t -NotePropertyName 'useCases'     -NotePropertyValue $useCases     -Force
        Add-Member -InputObject $t -NotePropertyName 'priceBand'    -NotePropertyValue $band         -Force
        Add-Member -InputObject $t -NotePropertyName 'pricingNote'  -NotePropertyValue $noteTxt      -Force
        Add-Member -InputObject $t -NotePropertyName 'implementationDifficulty' -NotePropertyValue $diff -Force
        Add-Member -InputObject $t -NotePropertyName 'integrations' -NotePropertyValue $ints         -Force
        Add-Member -InputObject $t -NotePropertyName 'pros'         -NotePropertyValue ([array]$pros) -Force
        Add-Member -InputObject $t -NotePropertyName 'cons'         -NotePropertyValue ([array]$cons) -Force
        Add-Member -InputObject $t -NotePropertyName 'categorySlug' -NotePropertyValue $cat.slug     -Force
    }
}

# ------------------------------------------------------------------
# 7. Flat tool index (used by comparison / alternatives logic)
# ------------------------------------------------------------------
$allTools = @()
foreach ($cat in $data.categories) {
    foreach ($t in $cat.tools) { $allTools += $t }
}

# Compute alternativesTo per tool — overlap by useCase + trade, within same category preferred
foreach ($cat in $data.categories) {
    foreach ($t in $cat.tools) {
        $candidates = @()
        foreach ($other in $cat.tools) {
            if ($other.name -eq $t.name) { continue }
            $usOverlap = ($other.useCases | Where-Object { $t.useCases -contains $_ }).Count
            $trOverlap = ($other.trades   | Where-Object { $t.trades   -contains $_ }).Count
            $score = ($usOverlap * 3) + $trOverlap
            if ($score -gt 0) {
                $candidates += [PSCustomObject]@{ tool = $other; score = $score }
            }
        }
        $top = $candidates | Sort-Object -Property score -Descending | Select-Object -First 6
        $altSlugs = @($top | ForEach-Object {
            [PSCustomObject]@{
                slug         = $_.tool.slug
                name         = $_.tool.name
                categorySlug = $cat.slug
                priceBand    = $_.tool.priceBand
                description  = $_.tool.description
                domain       = $_.tool.domain
            }
        })
        Add-Member -InputObject $t -NotePropertyName 'alternativesTo' -NotePropertyValue $altSlugs -Force
    }
}

# Add to data root: total tool count + a flat index for quick filtering on the client
$data | Add-Member -NotePropertyName 'enrichedAt' -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd') -Force
$data | Add-Member -NotePropertyName 'taxonomies' -NotePropertyValue ([PSCustomObject]@{
    trades   = $ALL_TRADES
    sizes    = $ALL_SIZES
    useCases = $ALL_USECASES
    bands    = $ALL_BANDS
}) -Force

$json = $data | ConvertTo-Json -Depth 8
Set-Content -Path $outJson -Value $json -Encoding UTF8

Write-Host "Wrote $outJson"
Write-Host "Enriched $($allTools.Count) tools."
Write-Host ("  with overrides: {0}" -f (($allTools | Where-Object { $TOOL_OVERRIDES.ContainsKey($_.name) }).Count))
Write-Host ("  default-only:   {0}" -f (($allTools | Where-Object { -not $TOOL_OVERRIDES.ContainsKey($_.name) }).Count))
