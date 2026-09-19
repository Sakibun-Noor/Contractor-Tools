# Product database site integration

**Source:** `CTD_Complete_Vendor_Product_Database_1_1381.xlsx` (merged 2026-09-19 from
Segment 1 + 2A + 2B — see `product-db-continuation-2026-09-18.md`), in
`CTD-product-db/out/` (not in this repo — client data, never committed).
**Supersedes:** `CTD_Combined_Vendor_Master_1463_HIERARCHY_CLASSIFIED.xlsx` and the
`CTD_Construction_Hierarchy_VALIDATED_4_LEVEL.xlsx` correction it received in
`hierarchy-import.md`.
**Status:** All open decisions resolved 2026-09-19 (see §3, §4, §7). Ready to build.

---

## 1. Why this is a bigger job than a data refresh

The current site was built around **one row = one product = one company**. Every entry
in `window.TOOLS` (`assets/tools-data.js`) carries the vendor's name, domain and
description directly on a single product-like record, with one subcategory (`sub`), one
master trade (`mt`), one division (`dv`), and an array of *contractor types* (`tr` — "GC",
"Commercial", etc., not real trades per `hierarchy-import.md` §3.1/§8.2).

The new database is a real relational model:

- **Vendor** (`VENDORS_NORM`) — a company, with 0 or more products.
- **Product** (`PRODUCTS_NORM`) — one row per Vendor × verified product, each with its
  own Categories, Subcategories, Master Groups, Divisions, and CSI-coded Trades
  (many-to-many junction tables, not single strings).
- **Market Sector** (`MARKET_SECTORS_NORM` / `VENDOR_MARKET_SECTOR`) — a new,
  vendor-level facet, separate from the CSI hierarchy (Commercial, Residential,
  Civil & Infrastructure, Industrial, Process, Oil & Gas, Power Generation, plus
  ALL).

Fitting that into "one row per product" either loses the vendor grouping Deryck asked
for, or needs the site to actually change shape. See §4 for the recommendation.

---

## 2. What's already built and ready to receive this

Checked by reading the live files, not assumed:

- **`vendor-profile.html` already has six list cards** — Divisions, Trades, Master
  Groups, Key Products, Subcategories, Categories — each with a tinted header and a
  "more…" control. `hierarchy-import.md`'s build log flagged these as "padded with
  invented filler" and explicitly left that for later, calling it *"a design decision
  about what those cards should show when a vendor has one real value, and that is
  Deryck's call, not a silent rewrite."* That moment is now — the new database gives
  every one of those cards real, multi-value, per-vendor data for the first time.
- **The taxonomy relabeling is already done.** Divisions / Trades / Master Groups are
  the current on-screen names (not "Divisions of Work" / "Construction Trades" /
  "Major Groups" — see `ctd-page-names` memory). No further renaming needed.
- **The 2026-09-18 decision on the old `tr` field stands**: keep the old
  contractor-type data imported and stored, show it nowhere. The new CSI Trades
  replace it as the displayed "Trades" card/column.

## 3. What's genuinely new and has no UI yet

- **Market Sector** — no filter, no column, no card for this anywhere on the site
  today. **Decided (Sakib, 2026-09-19):** add it as a sidebar filter on Search/Results
  and Advanced Search, **and** as a 5th fact on the vendor page's Facts strip
  (Founded / HQ / Employees / Deployment / Market Sector).
- ~~A 13th category, "Specialty Solutions"~~ — **resolved.** Deryck's own analysis
  (`CTD_12_Categories_Subcategories_Tooltips.docx`, sent 2026-09-19) retires
  Specialty Solutions and redistributes all of its subcategories across the existing
  12 categories, renaming 5 of them in the process. See §3a for the full mapping.
  The homepage stays at 12 tiles — no grid layout change needed, only 5 label swaps.
- **Category naming drift**: `procurement-purchasing` shows as "Back Office
  Operations" on-site today; the new database calls that same category "Procurement
  & Purchasing." `construction-leads` is "Leads, Bids & Estimates" on-site vs.
  "Construction Leads" in the new data. Twelve slugs otherwise line up 1:1 — these
  are label differences on an unchanged slug, not new categories. Superseded by §3a's
  final names in any case.

### 3a. Final 12-category mapping (Deryck, 2026-09-19)

Confirmed via ChatGPT (his own ask, screenshotted back): **URL slugs and database
Category_IDs stay exactly as they are** — only the on-screen name changes, same
convention as the Divisions/Trades/Master Groups rename. No redirects needed.

| # | Slug (unchanged) | Old on-screen name | New on-screen name | Subcategories now included (beyond the slug's original set) |
|---|---|---|---|---|
| 1 | `project-management` | Project Management | Project Management | + Site Planning & Feasibility |
| 2 | `ai-automation` | AI & Automation | AI & Automation | + Robotics & Automation Hardware |
| 3 | `safety-compliance` | Safety & Compliance | Safety & Compliance | unchanged |
| 4 | `estimating-takeoff` | Estimating & Takeoff | Estimating & Takeoff | unchanged |
| 5 | `fleet-equipment` | Fleet & Equipment | Fleet & Equipment | unchanged |
| 6 | `accounting-payroll` | Accounting & Payroll | **Finance & Payroll** | unchanged subcategories, name only |
| 7 | `procurement-purchasing` | Back Office Operations | **Procurement** | unchanged subcategories, name only |
| 8 | `document-management` | Document Management | **BIM & Documents** | + BIM & Design, Digital Twins, Reality Capture & 3D Scanning |
| 9 | `field-service-dispatch` | Field Service & Dispatch | **Field Operations** | + Workforce & Recruiting |
| 10 | `crm-sales` | CRM & Sales | CRM & Sales | unchanged |
| 11 | `construction-leads` | Leads, Bids & Estimates | **Leads & Bids** | unchanged subcategories, name only |
| 12 | `marketing-reputation` | Marketing & Reputation | Marketing & Reputation | unchanged |

**Flagged to Deryck, not yet answered:** category 8 ("BIM & Documents") absorbs three
of Specialty Solutions' largest subcategories (BIM & Design — 107 vendors, Reality
Capture & 3D Scanning — 111 vendors) on top of the existing Document Management
vendors (98). Estimated 250+ vendors once built, likely the single largest category
on the site — the same "too big to be useful" problem he raised about Specialty
Solutions, just moved one level down. Proceeding with his mapping as given; revisit
if the built count looks as large as estimated.

## 4. The real open question: how does a multi-product vendor render?

`PRODUCTS_NORM` groups by `Vendor_ID`, but **`Vendor_ID` is not always "the company"**
— it's checked, not assumed:

- **STACK (`V0001`)** — 2 products under one `Vendor_ID`. Clean case.
- **Autodesk** — spread across **13 different `Vendor_ID` rows**
  (`V0008, V0039, V0049, V0202, V0203, V0217, V0281, V0434, V0435, V0457, V0458,
  V0499, V0563`), each one product, all sharing the free-text `Parent_Vendor` =
  "Autodesk". Same pattern for Trimble, Sage, Deltek, Hexagon, and others acquired
  piecemeal across the original ChatGPT audit batches.

So "group products by vendor" has two candidate keys, and they disagree for exactly
the companies Deryck is most likely to click on first:

| Grouping key | STACK | Autodesk |
|---|---|---|
| `Vendor_ID` | 1 vendor, 2 products | 13 separate vendor listings, 1 product each |
| `Parent_Vendor` (free text) | 1 vendor, 2 products | 1 vendor, 13 products |

**Decided (Sakib, 2026-09-19):** group by `Parent_Vendor` for display (normalizing
case/whitespace the same way `build_batch.py` did during the audit), keep `Vendor_ID`
as the row's canonical URL/slug source (pick the lowest `Vendor_ID` in the group,
matching CTD's own "first-seen" convention from the audit). This makes the vendor
page and results table show "Autodesk — 13 products" the way Deryck's original ask
implied, without re-running any research. This changes vendor *counts* (1,088
`VENDORS_NORM` rows collapse to fewer real companies) — worth a screenshot once
built, before it ships, so the new count isn't a surprise.

Once grouped, `results.html` / `advanced-results.html` need each row to show a
product count (and the existing `moreCell(...)` pattern already used for the
Divisions/Trades cells extends naturally to a product list per row).

---

## 5. Field mapping — old → new

| Old (`tools-data.js`) | New source | Notes |
|---|---|---|
| `n` (name), `d` (domain), `x` (description) | `VENDORS_NORM.Vendor_Name` / `Normalized_Domain` / *(no description column — see §6)* | |
| `c` (category slugs) | `PRODUCT_CATEGORY` → `CATEGORIES_NORM` | now per-**product**, aggregate to vendor level as the union across all its products |
| `sub` (single subcategory) | `PRODUCT_SUBCATEGORY` → `SUBCATEGORIES_NORM` | now multi-valued per product; vendor-level card lists the union |
| `tr` (contractor types) | *(unchanged, imported but not displayed per the 2026-09-18 decision)* | |
| `mt` (single master trade) | `PRODUCT_MASTER_GROUP` → `MASTER_GROUPS_NORM` | now multi-valued, derived from Trades, `0 = ALL MASTER GROUPS` wildcard |
| `dv` (single division) | `PRODUCT_DIVISION` → `DIVISIONS_NORM` | now multi-valued |
| *(none)* | `PRODUCT_TRADE` → `TRADES_NORM` | brand new — real CSI-coded trades (`26 05 00 Electrical Contractors`, etc.), this is what `hierarchy-import.md` §8.3 said still needed a licensed dataset; it has now arrived via Deryck's own audit |
| *(none)* | `VENDOR_MARKET_SECTOR` → `MARKET_SECTORS_NORM` | brand new facet, see §3 |
| *(none, single product per row)* | `PRODUCTS_NORM` (multiple rows per `Parent_Vendor`) | see §4 |
| `sz`, `pm`, `ft` (size, pricing model, free trial) | *(not present in the new database)* | see §6 |

## 6. What the new database does *not* carry

Checked against `VENDORS_NORM` and `PRODUCTS_NORM` columns — neither sheet has a
company-size, pricing-model, free-trial, or long-form description field. Those four
fields power real UI today (Company Size filter, vendor-page pricing line, the
Free Trial badge, and every card's description text). This import cannot fill them —
they need to either **carry over from the old file** (matched by domain, since
`Normalized_Domain` is common to both) for the ~1,381 vendors that overlap, or show
"—" the way `hierarchy-import.md`'s HX-07 already does for unverified fields, for
anything new. Recommend carry-over-by-domain rather than blanking data the site
already has correctly.

---

## 7. Decisions (all resolved 2026-09-19)

1. ~~§4 — group by `Parent_Vendor`, not `Vendor_ID`~~ — **decided**, see §4.
2. ~~§3 — where does Market Sector live~~ — **decided**: filter facet + vendor-page
   fact, see §3.
3. ~~§3 — the 13th category~~ — **decided**: dissolved into the existing 12 per
   Deryck's mapping, see §3a. Slugs and Category_IDs unchanged; only 5 on-screen
   names change.
4. **§6 — carry Company Size / Pricing Model / Free Trial / description forward**
   from the current `tools-data.js` by domain match, rather than losing them. No
   objection raised; proceeding on this basis.
5. **The 230 legacy duplicate products** flagged in `LEGACY_DUPLICATES` — **decided**:
   left for a separate later pass, unrelated to this import.

## 8. Build order

1. Rewrite `build/import-vendors.ps1` (and whichever `parse-*.ps1` it calls) to read
   the merged workbook: group `PRODUCTS_NORM` by normalized `Parent_Vendor`, carry
   forward size/pricing/trial/description by domain from the current data, remap
   subcategories into the 12 final categories per §3a, emit the new per-product
   Category/Subcategory/Master Group/Division/Trade arrays and the new Market
   Sector array.
2. Regenerate `assets/tools-data.js` and `assets/taxonomy-data.js`.
3. Update `assets/filters.js` to build facets from the new multi-valued fields plus
   the new Market Sector facet.
4. Update `results.html`, `advanced-search.html`, `advanced-results.html` (product
   count / list per row, Market Sector column and filter) and `vendor-profile.html`
   (feed the six existing cards real data, add Market Sector to the Facts strip).
5. Relabel the 5 renamed category tiles on `index.html` (slugs/hrefs unchanged, text
   and any logo swaps only) — no grid layout change.
6. Verify in-browser: no console errors, no horizontal scroll, fold intact, filters
   actually narrow results, per the standard acceptance checklist this project has
   used every round (see `hierarchy-import.md` §5 for the template). Also check the
   "BIM & Documents" vendor count flagged in §3a.
7. Write the build log into this spec.

---

## 9. Build log — 2026-09-19

All 7 steps done. `build/import-vendors.ps1` was fully rewritten (the HX-01..HX-09
hierarchy-classified-workbook importer is retired) rather than patched — the input
file, join logic and output shape all changed.

### Result

| Metric | Value |
|---|---|
| Vendor rows in the merged database | 1,088 (`VENDORS_NORM`) |
| Product rows | 2,625 |
| Companies written to `tools-data.js` (grouped by `Parent_Vendor`) | **938** |
| Companies with 2+ products | 322 |
| Companies with a domain / category / master group / division / real trade / market sector | 938 / 938 / 938 / 938 / 938 / 938 (100%) |
| Descriptions carried forward from the prior site by domain match | 405 of 556 available |

### Two real bugs found and fixed during the build, not just the plan

1. **PowerShell hashtable construction threw `ArgumentException: Argument types do
   not match`** on every vendor. Root cause: `@($genericList)` where the list held
   `[ordered]@{}` (OrderedDictionary) entries fails in Windows PowerShell 5.1, even
   though the same collection enumerates fine in a `foreach` or via `.ToArray()`.
   Fixed by switching every generic-collection field to `.ToArray()`
   (`List[object]`) or an explicit `[string[]]` cast (`HashSet[string]`) instead of
   `@(...)`.
2. **Division/Trade labels rendered as mojibake** (`ALL â€" ALL DIVISIONS`) and, as
   a direct consequence, every Division/Trade facet counted 0 vendors even though
   the data was present — the canonical taxonomy list (correctly built once) no
   longer string-matched the per-vendor corrupted value. Root cause: the script's
   own literal `' – '` (en dash) character, typed directly in the `.ps1` source.
   Windows PowerShell 5.1 reads a BOM-less script file through the system
   codepage, not UTF-8, so the literal character silently corrupted on load. Fixed
   by building the dash from its code point (`[char]0x2013`) instead of typing it —
   immune to source-file encoding entirely. Worth remembering for any future
   PowerShell script in this repo that needs a non-ASCII literal.

### §3a's flagged risk — did it happen?

"BIM & Documents" is **284** vendors, the largest category (next is Project
Management at 219). Sizeable, as predicted, but not as extreme as Specialty
Solutions' share of the old 13-category split — left as Deryck specified rather
than adjusted unilaterally; worth another look if he flags it.

### Verified in-browser (localhost, `build/serve.ps1`)

| # | Check | Result |
|---|---|---|
| 1 | `results.html` loads, sidebar facets populate | Categories/Subcategories/Products/Master Groups/Divisions/Trades all show real counts |
| 2 | Category names match Deryck's renames | Finance & Payroll, Procurement, BIM & Documents, Field Operations, Leads & Bids all render |
| 3 | Market Sector facet (was a 0-count invented stub) | Real data on `results.html`, `advanced-search.html`: Commercial 165, ALL MARKET SECTORS 706, Civil & Infrastructure 51, etc. |
| 4 | Multi-product vendor grouping | Autodesk: 1 vendor row, `autodesk.com` (not `proest.com`), 42 deduplicated real products, no repeats |
| 5 | STACK (clean 1-`Vendor_ID` case) | 2 real products (`STACK | Build & Operate`, `STACK | Takeoff & Estimate`), not the old "Estimating Software" placeholder |
| 6 | Vendor page's 6 cards + new Market Sector fact | All real per-vendor data on both STACK and Autodesk; Facts strip now 5 columns |
| 7 | Live filtering end-to-end | Checking "AI & Automation" on `results.html`: 938 → 217, URL becomes `?cat=ai-automation` (slug unchanged); same 217 confirmed on `advanced-results.html?cat=ai-automation` |
| 8 | Console errors | None, any of the 5 pages (`index.html`, `results.html`, `advanced-search.html`, `advanced-results.html`, `vendor-profile.html`) |
| 9 | Homepage tiles | All 12 render; 5 renamed labels (Finance, Leads & Bids, Field Ops, BIM & Docs, Procurement) show, hrefs/slugs unchanged, no layout change |

### Left alone, deliberately

- The 230 `LEGACY_DUPLICATES` products (pre-existing in the 1–560 ChatGPT-authored
  range) are still in the source database untouched, per the standing decision.
  The *site* no longer double-displays them for a grouped vendor (products are
  deduplicated by normalized name at import time — see the Autodesk example above,
  which had raw duplicate product rows across two of its Vendor_IDs), but the
  underlying `PRODUCTS_NORM` rows and the affected vendors' `Verified_Construction_
  Tech_Product_Count` are unchanged.
- Company Size / Pricing Model / Free Trial / description for the ~533 companies
  with no domain match in the prior site (mostly the 561–1381 continuation
  vendors) show "—" / blank, same as any other unverified field on this site
  (HX-07 precedent). Not fabricated.
