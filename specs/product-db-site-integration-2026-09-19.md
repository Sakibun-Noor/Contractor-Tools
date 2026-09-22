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

## 10. Build log — 2026-09-20 (client round-2 fixes)

Deryck's 2026-09-19 review notes (`Notes_260919_165719.docx`) contained 20 items.
Per the client's own "we'll discuss later" split, 13 straightforward items (no
open design question) were implemented; 3 explicit "let's discuss" items were
left alone (BIM & Documents center-search click-through, Advanced Results Quick
Facts realignment, and predictive search — scoped as a separate future feature).

### Done this round

1. **Hide CSI codes everywhere a Division/Trade displays.** Added
   `CTD_FILTERS.stripCode()` (strips the `"NN NN NN – "` prefix) — applied to
   `results.html`, `advanced-results.html` table cells and `vendor-profile.html`'s
   Divisions/Trades cards. The raw coded value is kept as the underlying data,
   CSV export, and (on `results.html`/`advanced-results.html`) the `title` tooltip
   / filter value — only the visible label changes.
2. **Replace "ALL…" wildcard display with the real individual values, each
   clickable.** Added `CTD_FILTERS.isAllValue()` / `expandAll()` — when a
   vendor's only Division/Master Group/Trade value is the ALL wildcard, the full
   real list for that dimension is shown instead. Applied to `results.html` and
   `advanced-results.html`. **Vendor Page is the deliberate exception** (client,
   same round): it keeps the plain "ALL DIVISIONS" / "ALL TRADES" text and does
   not expand — `stripCode` still runs there so it reads "ALL DIVISIONS" not
   "ALL – ALL DIVISIONS".
3. **Advanced Filters (5 sections): centered, rollup count badges, small Clear
   buttons.** Evaluation Options, Purchase Options, Available On, Markets
   Served, Company Size on `advanced-search.html` — each `<h4>` now shows an
   "N selected" badge that updates live with `refresh()`, and each section has
   its own Clear button that only unchecks that section's boxes.
4. **Search bar placeholder → "Start your search here"** on `advanced-search.html`.
5. **Advanced Results: fixed the Categories/Subcategories/Key Products
   misalignment.** Root cause: the table's one-line-ellipsis CSS rule
   (`table.res td div, table.res td > a.bl, table.res td.desc-cell`) only matched
   `a.bl` when it was a *direct child* of `<td>` — true for no column. Master
   Groups/Divisions/Trades use plain `<div>`s (matched via the plain descendant
   selector) and always truncated to one line; Categories/Subcategories/Key
   Products wrap their links in a `.cell-scroll` div, so their `<a class="bl">`
   never matched and could wrap onto multiple lines, throwing off row height
   versus the other columns. Added `table.res td .cell-scroll a.bl` to the rule.
6. **Advanced Results: applied `stripCode`/`expandAll`** to the Master
   Groups/Divisions/Trades cells (same treatment as item 1/2).
7. **Vendor Page: removed the "> Vendor Profile" breadcrumb segment** (the
   arrow + text after "Back to Advanced Results") — client confirmed the page
   doesn't need to repeat its own name in the breadcrumb.
8. **Vendor Page: unbolded the "Back to Advanced Results" breadcrumb link** —
   `.crumbs` was `font-weight:500` while every other page's back-link uses `600`
   (semi-bold) but reads lighter next to the vendor page's bold section
   headers; client wanted it to match the site's other plain-text links, set to
   `400`.

### One data-level thing surfaced, not fixed (out of scope for this round)

While testing `expandAll`, found a handful of vendors (e.g. Salesforce) whose
`mt`/`dv`/`trd` arrays hold the "ALL …" wildcard **and** specific real values in
the same array (e.g. `["ALL MASTER GROUPS","Plumbing","HVAC & Mechanical",
"Electrical"]`) — a data inconsistency from the merged database, not something
introduced by this round's code. `expandAll()` only replaces the wildcard when
it's the *sole* entry, so these vendors still show the literal "ALL MASTER
GROUPS" text alongside their real values. This existed already on `results.html`
(same `expandAll` call, same underlying data) before this round touched
anything — confirmed by testing that page's live data directly. Left alone
pending Deryck's own promised list on the "ALL…" issue generally — see
[[ctd-csi-and-all-values-feedback]].

### Verification

Manual server (`build/serve.ps1 8777`) checked in-browser for all 4 pages:
console clean, `advanced-search.html` rollup badges/Clear buttons/centering/
placeholder confirmed live via DOM inspection, `advanced-results.html`
alignment fix and `expandAll` (both the pure-wildcard and mixed-array cases)
confirmed, `vendor-profile.html` breadcrumb removal/unbold and `stripCode`
confirmed on a CSI-coded vendor (Salesforce).

## 11. Build log — 2026-09-22 (vendor biographies)

Deryck sent `09.20.26_CTD_Vendor_Biographies_RECONCILED_1381.xlsx` — one
~100-word company biography per original `Vendor_ID` (V0001–V1381), verified
against each vendor's own website, generated from the same
`CTD_Complete_Vendor_Product_Database_1_1381.xlsx` we delivered him
2026-09-19 ("Controlling master" per the file's own README tab — confirmed by
matching `Vendor_ID`/`Vendor_Name`/domain against our `VENDORS_NORM` sheet
before trusting the join). 1,319 of 1,381 IDs have a complete bio; the other
62 are marked `BLANK - OFFICIAL SOURCE UNVERIFIED` (mostly excluded/
consolidated vendors) and are simply skipped, same as any other missing field.
All 1,088 ACTIVE `Vendor_ID`s have one.

**Where it lives now:** `CTD-product-db/inputs/09.20.26_CTD_Vendor_Biographies_
RECONCILED_1381.xlsx` (sibling data folder, same convention as the other
client workbooks — not committed to this repo).

**Build:** `build/import-vendors.ps1` gained a `$BiographyXlsx` param and a new
step 1b that reads `VENDOR_BIOGRAPHIES` into a `Vendor_ID -> bio` map. Per
company group, the bio is picked with the same precedence already used for
the canonical domain (§4): prefer the `Vendor_ID` whose own domain matches the
group's chosen domain, else the canon row's own `Vendor_ID`, else the first
bio found in the group. The result becomes `t.x` (`$descX`), replacing the old
carry-forward-by-domain value as the primary source — carry-forward is now
only a fallback for the handful of vendors with no bio. Result: all 938
grouped companies now carry a real description (`938/938`, up from `405/556`
carried-forward domains before this round).

**Site wiring:** `vendor-profile.html`'s Company Biography card previously
read `FACTS[t.s].bio` — a hardcoded object with exactly 2 example entries
(`procore`, `autodesk`), neither of which even had a `bio` key, so the card
showed "No company biography on file yet." for literally every vendor. Fixed
to read `t.x` instead. `t.x` already fed the banner's short description and
the Results/Advanced Results "Description" table column, and the CSV
export's "Description" field, so all of those got richer for free — no
separate change needed anywhere else.

**Verification:** ran the import, checked STACK's and Salesforce's bios read
correctly end to end (including a curly-apostrophe character in the source
text — confirmed U+2019 survives the PowerShell xlsx-read/UTF-8-write pipeline
intact; the odd glyph seen mid-investigation was only a terminal font
rendering issue, not real data corruption). Confirmed `0` vendors are missing
a description (`938/938`). Spot-checked `results.html` and
`advanced-results.html` Description columns render the new text single-line,
no layout break. No console errors on any page.

**Second file received alongside this, not yet actioned:**
`09.20.26_CTD_191_Excluded_Vendor_Placement_Review.xlsx` — Deryck's re-review
of the 191 vendors currently in `EXCLUDED_VENDORS`, recommending where each
could be placed if it now qualifies. Breakdown: 76 `KEEP EXCLUDED` (no
qualifying product), 35 `ADD TO CTD` + 3 `ADD / CONSOLIDATE` (ready to place —
38 vendors total), 20 `CONDITIONAL / SCOPE REVIEW` + 56 `IDENTITY NOT
VERIFIED` (needs more research before any placement — these two together are
the `RESEARCH_QUEUE` sheet's 76 rows), 1 `LEGACY / DISCONTINUED`. The client
said "not modify the master database" in the file's own SUMMARY tab, so this
is a recommendation to review, not something to import automatically. Sitting
until the user decides how to proceed — see [[ctd-round2-fixes-2026-09-20]].

## 12. Build log — 2026-09-22 (final corrections doc)

Deryck's `102026 CTD Corrections_260920_200619.docx` — 20 items across 5
pages, read in full (text + all 17 screenshots) before building anything.
Three needed a decision first; the user resolved all three: (1) add the
missing Markets Served items and expect to source real vendor data for them
later, (2) treat "click a result → vendor's site, or profile if none" as
resolved, (3) start the main-search autosuggest now rather than deferring it
again.

**Markets Served taxonomy expansion.** Added 8 new rows to
`MARKET_SECTORS_NORM` in the master xlsx (`CTD-product-db/out/CTD_Complete_
Vendor_Product_Database_1_1381.xlsx`): Col/Varsity Sports, Education, Energy
/ Utilities, Government / Public Sector, Healthcare, Manufacturing,
Nonprofit, Retail / Hospitality (ids 8-15). Re-ran `import-vendors.ps1` to
regenerate `taxonomy-data.js` — same "complete canonical list, unused entries
render disabled at 0" precedent already used for Divisions/Master Groups
(Fire Protection). All 8 show on both Search/Results' and Advanced Search's
Markets Served panel automatically (both build from the same generated
taxonomy) at 0/disabled until real vendor-level tagging data arrives from
Deryck — no vendor data was invented to make this land.

**Autosuggest (`assets/autosuggest.js`, new file).** A single shared module,
`CTD_AUTOSUGGEST.init('hdr-q')`, wired into all 5 pages' header search bar
(index.html didn't load any data/filter scripts before this — added
tools-data.js/taxonomy-data.js/filters.js there too, since autosuggest needs
`window.TOOLS`). Suggests matching Vendors, Products and Categories as the
user types (prefix matches ranked above substring matches, capped at 8),
arrow-key navigable, Enter selects the highlighted suggestion or falls
through to the page's own existing search submit when nothing is
highlighted — no page's search behavior needed to change.

**Search/Results (`results.html`).**
- Links keep their underline always (was hover-only).
- Row hover: background highlight already existed: added `.vn` (vendor name)
  turning blue on row hover, and the whole row is click-to-website (opens
  the vendor's site in a new tab, or `vendor-profile.html` in the same tab
  if no domain) — except clicks on an actual link/button in the row, which
  keep their own behavior.
- Master Groups/Divisions/Trades cell values are now clickable links
  (`?mt=`/`?div=`/`?trd=`), matching how Categories/Subcategories/Products
  already worked. Every truncated cell value got a `title` tooltip.
- Advanced Filters panel (the right-sidebar one, `sr-af-*` — distinct from
  Advanced Search's own panel) had no Clear control at all; added one red
  button at its base that clears only that panel's checkboxes.
- Chips row "Clear All" → "Clear". Left-nav search placeholder → "Search
  Keyword".

**Advanced Search (`advanced-search.html`).**
- The 6 big selector cards (Product/Subcategory/Category/Trades/Divisions/
  Master Groups) and the Markets Served mini-list now show a persistent
  scrollbar (`overflow-y:auto` → `scroll`) even when content currently fits,
  per the client's "might shrink on smaller displays" reasoning. Scoped to
  those — the other 4 mini Advanced-Filter sections (Eval/Purchase/Avail/
  Size) are short, unscrolled lists by design and weren't given a scroll
  wrapper.
- The 5 mini Advanced Filters' Clear buttons were landing at different
  heights depending on each section's list length (client's screenshot showed
  this directly). `.af-grp` now fills its grid-stretched column height and
  `.af-clear` uses `margin-top:auto` to sit on one shared baseline regardless
  of content height — confirmed all 5 at the same pixel offset.
- "Clear All" chip → "Clear".

**Advanced Results (`advanced-results.html`).**
- Description column now wraps (3-line clamp) instead of a single truncated
  line; the cell's `title` carries the full untruncated biography for a
  native tooltip when it's still cut off.
- Master Groups/Divisions/Trades converted from plain text to clickable
  links, same as Search/Results, with tooltips on every truncated value.
- Row hover highlight scoped to just Categories/Subcategories/Key Products/
  Master Groups/Divisions/Trades (columns 3-8) — client's explicit exception:
  "does not apply to Vendor, Description, Quick Facts and Actions."
- Quick Facts (Available On) bullet-circle icons removed; each value gets a
  `title` tooltip instead.
- Same row-click-to-website behavior added as Search/Results, for
  consistency between the two result tables (not explicitly requested for
  this page in the doc, but the two tables are otherwise built the same way
  and an asymmetry here would be confusing).
- Links keep their underline always, same as Search/Results.

**Vendor Page (`vendor-profile.html`).**
- Quick Facts strip (Founded/HQ/Employees/Deployment/Market Sector)
  `justify-content:center` added so each fact's icon+label+value group
  centers in its column.
- Market Sector value gets a `title` tooltip with the full list when it
  truncates.

**Not built — data-dependent, not code:** "Need Contact Info" — same as the
prior round, no verified contact data exists yet; nothing to build until
Deryck's contact-info file lands.

**Verification:** manual server, all 5 pages, console clean throughout.
Autosuggest tested end-to-end (typed "stack", saw Vendor/Product suggestions,
clicked one, landed on the right vendor page). Confirmed via DOM inspection:
row `data-go`/`data-go-external` attributes, Master Groups/Divisions/Trades
`href`+`title`, red Clear button clears only its own panel, all 5 mini
Advanced Filters Clear buttons at an identical pixel offset, `.sel-list`/
`.af-scroll` computed `overflow-y: scroll`, Advanced Results' hover rule
scoped to `nth-child(n+3):nth-child(-n+8)`, Description `title` carries the
full ~760-character bio, Quick Facts icons gone, row-click opens the site in
a new tab but a real link inside the row does not trigger it, all 15 real
Market Sectors (7 original + 8 new) present in both pages' filter lists.
