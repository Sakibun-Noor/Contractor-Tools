/* ============================================================
   Real pricing data — researched June 2026.
   Verify on vendor sites before quoting clients; SaaS pricing
   changes frequently.

   model: "tier" | "quote" | "freemium" | "oneTime"
   quoteOnly: true       => vendor publishes no public pricing
   freePlan: true        => has a no-cost tier
   ============================================================ */
window.PRICING_DETAIL = {

  /* ---------- Construction / Field Service ---------- */

  "procore": {
    model: "quote", quoteOnly: true,
    startsAt: "Contact sales",
    note: "Quote-based. Procore does not publish pricing — annual contracts negotiated by ARR/users/modules.",
    asOf: "2026-06"
  },

  "servicetitan": {
    model: "quote", quoteOnly: true,
    startsAt: "Contact sales",
    note: "Quote-based. ServiceTitan does not publish pricing — quotes scale with technicians, modules, and trade.",
    asOf: "2026-06"
  },

  "autodesk-construction-cloud": {
    model: "quote", quoteOnly: true,
    startsAt: "Contact sales",
    note: "Quote-based, sold as Autodesk Build, BIM Collaborate, Takeoff, Cost, and Docs — bundled by project or enterprise.",
    asOf: "2026-06"
  },

  "heavybid": {
    model: "quote", quoteOnly: true,
    startsAt: "Contact sales",
    note: "Quote-based. HCSS HeavyBid prices by user count and add-on modules; expect enterprise-level annual contracts.",
    asOf: "2026-06"
  },
  "heavybid-hcss": {
    model: "quote", quoteOnly: true,
    startsAt: "Contact sales",
    note: "Quote-based. HCSS HeavyBid prices by user count and add-on modules; expect enterprise-level annual contracts.",
    asOf: "2026-06"
  },

  "proest": {
    model: "quote", quoteOnly: true,
    startsAt: "Contact sales",
    note: "Quote-based since the Autodesk acquisition; usually sold under Autodesk Construction Cloud bundles.",
    asOf: "2026-06"
  },

  "buildertrend": {
    model: "tier",
    startsAt: "$499/mo",
    startsAtNote: "Essential, monthly billing — annual brings it to ~$339/mo",
    freeTrial: "30-day demo / sandbox",
    tiers: [
      { name: "Essential", price: "$499/mo (monthly) · ~$339/mo annual", per: "unlimited users", notes: "Project management, daily logs, CRM. No estimating module." },
      { name: "Advanced",  price: "$799/mo (monthly) · ~$499/mo annual", per: "unlimited users", notes: "Adds full estimating: proposals, change orders, takeoff, bid requests, POs." },
      { name: "Complete",  price: "$1,099/mo (monthly) · ~$829/mo annual", per: "unlimited users", notes: "Adds client selections portal and warranty management." }
    ],
    note: "Flat monthly fee, unlimited users on every plan. Annual billing saves $1,920–$3,240/yr.",
    asOf: "2026-06"
  },

  "jobber": {
    model: "tier",
    startsAt: "$39/mo",
    startsAtNote: "Core plan, 1 user, billed annually",
    freeTrial: "14 days",
    tiers: [
      { name: "Core",    price: "$39/mo",  per: "1 user",   notes: "Quoting, scheduling, invoicing." },
      { name: "Connect", price: "$169/mo", per: "5 users",  notes: "Automations, online booking, 2-way sync." },
      { name: "Grow",    price: "$349/mo", per: "10 users", notes: "Quote markups, optional line items, batch invoicing." },
      { name: "Plus",    price: "$599/mo", per: "15 users", notes: "Dedicated success manager, custom roles." }
    ],
    note: "Annual billing saves up to 35%. Extra users $29/mo. Add-ons: AI Receptionist $99/mo, Marketing Suite $79/mo.",
    asOf: "2026-06"
  },

  "housecall-pro": {
    model: "tier",
    startsAt: "$59/mo",
    startsAtNote: "Basic plan, annual billing",
    freeTrial: "14 days",
    tiers: [
      { name: "Basic",      price: "$59/mo annual · $79/mo monthly", per: "1 user",      notes: "Scheduling, dispatch, invoicing." },
      { name: "Essentials", price: "$149/mo annual · $189/mo monthly", per: "up to 5 users", notes: "Online booking, postcards, QuickBooks sync." },
      { name: "MAX",        price: "$299/mo annual · $329/mo monthly", per: "1 user + $35/mo per extra", notes: "Advanced reporting, custom roles, recurring services." }
    ],
    note: "Add-ons commonly cost $40–$149/mo on top of the base plan.",
    asOf: "2026-06"
  },

  "stack": {
    model: "freemium", freePlan: true,
    startsAt: "Free",
    startsAtNote: "Free Takeoff & Estimate tier available",
    freeTrial: "Free plan + 2-week trial on Build & Operate",
    tiers: [
      { name: "Takeoff & Estimate — Free", price: "$0", per: "limited", notes: "Free tier for individuals." },
      { name: "Takeoff & Estimate — Pro",  price: "$2,599/yr", per: "1 user", notes: "Cloud takeoff + estimating, unlimited projects." },
      { name: "Build & Operate",           price: "$599/yr",  per: "flat",   notes: "Field operations module." },
      { name: "Enterprise",                price: "Contact sales", per: "custom", notes: "Volume + premium support." }
    ],
    note: "Monthly entry option ~$49/user/mo.",
    asOf: "2026-06"
  },

  "planswift": {
    model: "oneTime",
    startsAt: "$1,595 (perpetual)",
    startsAtNote: "One-time license, includes 1st year support",
    freeTrial: "14 days",
    tiers: [
      { name: "Perpetual license", price: "$1,595 one-time", per: "1 seat", notes: "Includes year-1 unlimited support. Optional annual renewal ~$200–$250/seat for updates." },
      { name: "Annual subscription", price: "$2,000/yr", per: "1 seat", notes: "Includes updates and 2 hours of training." }
    ],
    note: "Owned by ConstructConnect.",
    asOf: "2026-06"
  },

  "bluebeam-revu": {
    model: "tier",
    startsAt: "$260/user/year",
    startsAtNote: "Basics plan, billed annually",
    freeTrial: "30 days",
    tiers: [
      { name: "Basics",   price: "$260/user/yr", per: "1 user", notes: "Markup, measure, basic Studio access (no project creation)." },
      { name: "Core",     price: "$330/user/yr", per: "1 user", notes: "Studio Projects + Sessions for collaboration." },
      { name: "Complete", price: "$440/user/yr", per: "1 user", notes: "Full toolset for managing AECO documents at scale." },
      { name: "Max",      price: "$590/user/yr", per: "1 user", notes: "AI-driven drawing review (intro pricing)." }
    ],
    note: "All plans billed annually per user; includes desktop + web/mobile.",
    asOf: "2026-06"
  },

  "companycam": {
    model: "tier",
    startsAt: "$79/user/mo",
    startsAtNote: "Pro plan, 3-user minimum",
    freeTrial: "14 days (no credit card)",
    tiers: [
      { name: "Pro",     price: "$79/user/mo",  per: "3 users min, +$29/mo per extra", notes: "Unlimited photos, projects, basic reports." },
      { name: "Premium", price: "$129/user/mo", per: "3 users min, +$29/mo per extra", notes: "Adds branded reports, integrations, AI tagging." },
      { name: "Elite",   price: "$199/user/mo", per: "3 users min, +$29/mo per extra", notes: "Project timelines, advanced workflows, support." }
    ],
    note: "Every plan has a 3-user minimum — no single-user option. Only Pro pricing is publicly listed.",
    asOf: "2026-06"
  },

  "fieldwire": {
    model: "freemium", freePlan: true,
    startsAt: "Free",
    startsAtNote: "Basic plan: up to 5 users, 3 projects, 100 sheets",
    freeTrial: "Free forever on Basic",
    tiers: [
      { name: "Basic",         price: "$0", per: "up to 5 users", notes: "3 projects, 100 sheets, core punch list." },
      { name: "Pro",           price: "$39/user/mo annual · $54/mo monthly", per: "per user", notes: "Sheet compare, exports, reports, unlimited projects." },
      { name: "Business",      price: "$59/user/mo annual · $74/mo monthly", per: "per user", notes: "Custom forms, 360° photos, BIM viewer, storage integrations." },
      { name: "Business Plus", price: "$89/user/mo annual · $104/mo monthly", per: "per user", notes: "RFIs, submittals, change orders, budget tools." }
    ],
    note: "Now Fieldwire by Hilti. Enterprise adds API/SSO/training.",
    asOf: "2026-06"
  },

  "fieldpulse": {
    model: "tier",
    startsAt: "$65/user/mo",
    startsAtNote: "Essentials plan, contract-based seats",
    freeTrial: "14 days",
    tiers: [
      { name: "Essentials",   price: "$65/user/mo",  per: "per user", notes: "Scheduling, dispatch, CRM, estimates, invoicing, mobile app." },
      { name: "Professional", price: "$90/user/mo",  per: "per user", notes: "Adds payment processing, QuickBooks sync, custom forms." },
      { name: "Enterprise",   price: "Contact sales", per: "custom",   notes: "Volume pricing, advanced controls." }
    ],
    note: "Seat-based — you commit to a number of full-access or field-only seats up front.",
    asOf: "2026-06"
  },

  "contractor-foreman": {
    model: "tier",
    startsAt: "$49/mo",
    startsAtNote: "Basic plan",
    freeTrial: "30 days (100-day money-back on annual)",
    tiers: [
      { name: "Basic",     price: "$49/mo",  per: "small team",  notes: "Core estimating and invoicing." },
      { name: "Standard",  price: "$105/mo", per: "team",        notes: "Work orders, permits, online payments, POs." },
      { name: "Plus",      price: "$166/mo", per: "team",        notes: "QuickBooks Online integration, broader feature set. Most popular." },
      { name: "Pro",       price: "$221/mo", per: "team",        notes: "Custom reports, vehicle/equipment logs, permit management." },
      { name: "Unlimited", price: "$332/mo", per: "team",        notes: "All features unlocked." }
    ],
    note: "Most affordable all-in-one option for SMB contractors.",
    asOf: "2026-06"
  },

  "houzz-pro": {
    model: "tier",
    startsAt: "$99/mo",
    startsAtNote: "Essential plan, billed annually",
    freeTrial: "30 days",
    tiers: [
      { name: "Essential", price: "$99/mo annual · $149/mo monthly",  per: "1 dedicated user, +$60/mo per extra", notes: "For designers. Leads, project management, mood boards." },
      { name: "Pro",       price: "$159/mo annual · $249/mo monthly", per: "1 dedicated user, +$60/mo per extra", notes: "For contractors. Estimating, takeoffs, payments, client portal." },
      { name: "Custom",    price: "Contact sales", per: "team", notes: "Tailored package — designers or contractors." }
    ],
    note: "12-month contractual commitment on monthly plans.",
    asOf: "2026-06"
  },

  /* ---------- Design / Drafting ---------- */

  "sketchup": {
    model: "tier",
    startsAt: "$129/yr",
    startsAtNote: "SketchUp Go, billed annually",
    freeTrial: "Free version available (web only)",
    tiers: [
      { name: "Go",     price: "$129/yr · $19.99/mo", per: "per user", notes: "Web-based modeling." },
      { name: "Pro",    price: "$399/yr", per: "per user", notes: "Desktop modeling, LayOut 2D docs, support." },
      { name: "Studio", price: "$819/yr", per: "per user", notes: "Pro + V-Ray rendering and Scan Essentials. Annual only." }
    ],
    asOf: "2026-06"
  },
  "sketchup-pro": {
    model: "tier",
    startsAt: "$399/yr",
    startsAtNote: "SketchUp Pro, annual subscription",
    freeTrial: "30 days",
    tiers: [
      { name: "Pro",    price: "$399/yr", per: "per user", notes: "Desktop modeling, LayOut 2D documentation, professional interoperability." },
      { name: "Studio", price: "$819/yr", per: "per user", notes: "Adds V-Ray rendering and Scan Essentials." }
    ],
    asOf: "2026-06"
  },

  /* ---------- Project Management ---------- */

  "asana": {
    model: "freemium", freePlan: true,
    startsAt: "Free",
    startsAtNote: "Personal plan free for up to 2 users",
    freeTrial: "30 days on paid plans",
    tiers: [
      { name: "Personal",   price: "$0",            per: "1–2 users", notes: "Basic lists, boards, calendar." },
      { name: "Starter",    price: "$10.99/user/mo annual · $13.49 monthly", per: "min 2 users", notes: "Timeline, dashboards, custom fields, unlimited automations." },
      { name: "Advanced",   price: "$24.99/user/mo annual · $30.49 monthly", per: "min 2 users", notes: "Goals, Portfolio Workload, Salesforce/Tableau integration." },
      { name: "Enterprise", price: "Contact sales", per: "custom", notes: "SSO/SCIM, data residency, HIPAA, audit logs." }
    ],
    asOf: "2026-06"
  },

  "monday-com": {
    model: "freemium", freePlan: true,
    startsAt: "$9/seat/mo",
    startsAtNote: "Basic plan, annual billing, 3-seat minimum",
    freeTrial: "14 days",
    tiers: [
      { name: "Free",       price: "$0",            per: "up to 2 seats", notes: "Limited boards and views." },
      { name: "Basic",      price: "$9/seat/mo annual · $12 monthly",  per: "3 seats min", notes: "Unlimited free viewers, 5GB storage." },
      { name: "Standard",   price: "$12/seat/mo annual · $14 monthly", per: "3 seats min", notes: "Timeline, calendar, automations, integrations." },
      { name: "Pro",        price: "$19/seat/mo annual · $24 monthly", per: "3 seats min", notes: "Private boards, chart view, time tracking." },
      { name: "Enterprise", price: "Contact sales", per: "custom", notes: "Advanced security, governance, dedicated support." }
    ],
    note: "All paid plans require a 3-seat minimum — even for 1–2 users.",
    asOf: "2026-06"
  },

  "clickup": {
    model: "freemium", freePlan: true,
    startsAt: "Free",
    startsAtNote: "Free Forever plan for unlimited users",
    freeTrial: "Free forever",
    tiers: [
      { name: "Free Forever", price: "$0",              per: "unlimited users", notes: "100MB storage, unlimited tasks." },
      { name: "Unlimited",    price: "$7/user/mo annual · $10 monthly",  per: "per user", notes: "Unlimited storage, integrations, dashboards." },
      { name: "Business",     price: "$12/user/mo annual · $19 monthly", per: "per user", notes: "Time tracking, custom exports, advanced automations." },
      { name: "Business Plus",price: "$19/user/mo annual", per: "per user", notes: "Custom permissions, increased automations, priority support." },
      { name: "Enterprise",   price: "Contact sales", per: "custom", notes: "SSO, white-labeling, dedicated CSM." }
    ],
    note: "ClickUp Brain (AI add-on) is +$7/user/mo on any paid plan.",
    asOf: "2026-06"
  },

  /* ---------- CRM ---------- */

  "salesforce": {
    model: "tier",
    startsAt: "$25/user/mo",
    startsAtNote: "Starter Suite",
    freeTrial: "30 days",
    tiers: [
      { name: "Starter Suite", price: "$25/user/mo",  per: "per user", notes: "Sales, service, email marketing — small business bundle." },
      { name: "Pro Suite",     price: "$100/user/mo", per: "per user", notes: "More automation, customization, forecasting." },
      { name: "Enterprise",    price: "$175/user/mo", per: "per user", notes: "Full Sales Cloud — advanced workflow and territory mgmt." },
      { name: "Unlimited",     price: "$350/user/mo", per: "per user", notes: "Premier support, sandboxes, AI features." }
    ],
    note: "Enterprise and above require annual contracts.",
    asOf: "2026-06"
  },

  "hubspot-crm": {
    model: "freemium", freePlan: true,
    startsAt: "Free",
    startsAtNote: "HubSpot CRM is free for unlimited users",
    freeTrial: "Free forever + 14-day Pro trial",
    tiers: [
      { name: "Free CRM",     price: "$0",                per: "unlimited users", notes: "Contact mgmt, deals, basic email tracking." },
      { name: "Starter",      price: "$15/seat/mo annual · $20 monthly", per: "per seat", notes: "Sales/Service Hub — pipelines, automation, meetings." },
      { name: "Professional", price: "$100/seat/mo (Sales/Service) · Marketing Hub $890/mo", per: "varies", notes: "Onboarding fee typically required." },
      { name: "Enterprise",   price: "$1,500+/mo per hub · Customer Platform $4,300/mo", per: "varies", notes: "Custom objects, advanced reporting, hierarchical teams." }
    ],
    note: "Pricing varies by which Hubs (Sales/Service/Marketing/Content) you bundle and seat count.",
    asOf: "2026-06"
  },

  "pipedrive": {
    model: "tier",
    startsAt: "$14/user/mo",
    startsAtNote: "Essential, annual billing",
    freeTrial: "14 days",
    tiers: [
      { name: "Essential",    price: "$14/user/mo annual", per: "per user", notes: "Basic pipeline, deals, contacts, email integration." },
      { name: "Advanced",     price: "$29/user/mo annual", per: "per user", notes: "Email sync, workflow automation, reporting." },
      { name: "Professional", price: "$59/user/mo annual", per: "per user", notes: "Revenue forecasting, team mgmt, custom fields." },
      { name: "Power",        price: "$69/user/mo annual", per: "per user", notes: "Advanced permissions, projects, phone support." },
      { name: "Enterprise",   price: "$99/user/mo annual", per: "per user", notes: "Unlimited customization, premium support." }
    ],
    note: "Monthly billing is ~21% higher. Add-ons: LeadBooster, Campaigns, Web Visitors, Smart Docs.",
    asOf: "2026-06"
  },

  /* ---------- Accounting / e-Sign ---------- */

  "quickbooks-online": {
    model: "tier",
    startsAt: "$38/mo",
    startsAtNote: "Simple Start (often discounted 50% for 3 months)",
    freeTrial: "30 days",
    tiers: [
      { name: "Simple Start", price: "$38/mo",  per: "1 user",       notes: "Invoicing, expense tracking — solo." },
      { name: "Essentials",   price: "$75/mo",  per: "up to 3 users", notes: "Bill management, time tracking." },
      { name: "Plus",         price: "$115/mo", per: "up to 5 users", notes: "Inventory, project profitability." },
      { name: "Advanced",     price: "$275/mo", per: "up to 25 users", notes: "Enhanced reporting, dedicated manager, batch invoicing." }
    ],
    note: "Intuit typically raises prices annually in the summer.",
    asOf: "2026-06"
  },

  "xero": {
    model: "tier",
    startsAt: "$25/mo",
    startsAtNote: "Early plan",
    freeTrial: "30 days",
    tiers: [
      { name: "Early",       price: "$25/mo", per: "unlimited users", notes: "Send up to 20 invoices, enter 5 bills/mo." },
      { name: "Growing",     price: "$55/mo", per: "unlimited users", notes: "Unlimited transactions, dashboards." },
      { name: "Established", price: "$90/mo", per: "unlimited users", notes: "Multi-currency, project tracking, expense claims, KPI analysis." }
    ],
    note: "Priced per organization, not per user. US edition is monthly only (no annual prepay).",
    asOf: "2026-06"
  },

  "docusign": {
    model: "tier",
    startsAt: "$10/mo",
    startsAtNote: "Personal plan, billed annually",
    freeTrial: "30 days",
    tiers: [
      { name: "Personal",     price: "$10/mo annual · $15 monthly", per: "1 user",  notes: "3 documents/month." },
      { name: "Standard",     price: "$25/user/mo annual · $45 monthly", per: "per user", notes: "100 envelopes/user/yr, reminders, branding." },
      { name: "Business Pro", price: "$40/user/mo annual · $65 monthly", per: "per user", notes: "Bulk send, payment collection, advanced fields." },
      { name: "Enterprise",   price: "Contact sales", per: "custom", notes: "Volume contracts, SSO, advanced API." }
    ],
    note: "Most paid plans include envelope caps; high-volume use generally requires Enterprise.",
    asOf: "2026-06"
  }
};

window.PRICING_AS_OF = "June 2026";
