# CTD Corrections — 08/23/26

**Source:** `082326 CTD Corrections _260823_165731.docx` (rev. 2026-08-31, 28 screenshots)
**Data:** `CTD_Combined_Vendor_Master_1463_COMPLETED.xlsx` + `CTD_Master_Trades_Divisions_Trades_Subtrades (1).xlsx` *(both received 2026-08-31 — always use the latest files sent)*
**Written:** 2026-08-31

---

## 1. How to read this

Every correction has a stable ID (`G-01`, `H-03`, …). Use the ID when discussing or
committing. Each entry states:

- **Doc** — what the correction file literally says, plus its screenshot
- **Files** — what has to change
- **Now** — verified current state (I read the markup; this is not assumed)
- **Want** — the target state
- **Done when** — the check that proves it landed

Status markers:

| Marker | Meaning |
|---|---|
| ✅ | Unblocked — data and design both exist, can be built now |
| ⚠️ | Buildable, but rests on an assumption recorded in §4 |
| ⛔ | Blocked — required data does not exist yet |

---

## 2. Page map

The canonical flow. **Six distinct pages, six distinct files — all now exist.**

```
Home / Hero                          index.html                    ✅
  └─ Search / Results                results.html                  ✅ built 2026-09-01
       └─ Advanced Search / Results  advanced-search-results.html  ✅
            └─ Dedicated Search      dedicated-search.html         ✅
                 └─ Dedicated Results dedicated-results.html       ✅
                      └─ Vendor      vendor-profile.html           ✅
```

> The rest of this section describes the state **before** `results.html` was built. It is
> kept because it explains why the stopgap wiring existed and what had to be undone.
> Current state: homepage → `results.html`; the `?ref=selection` flag is gone (`DR-10`).

**Critical: `results.html` does not exist in this repo.** Every other page in the flow
does. It is fully specified in `specs/search-page-desktop.md` (+ `-mobile.md`) — target
filename, palette, nine-column table, two-question panel — and the reference design
supplied on 2026-08-31 matches that spec exactly. It was specified and never built.

Consequences:

1. The homepage category tiles currently point at **`dedicated-results.html?cat=<slug>`**
   (12 links in `index.html`) — a stopgap standing in for the missing page. Once
   `results.html` exists they must be repointed (`SR-09`).
2. `dedicated-results.html` carries a vestigial dual-mode flag from that stopgap:
   ```js
   if (sp.get('ref') === 'selection') { /* back-link → dedicated-search.html */ }
   ```
   Default gives "Back to Home"; `?ref=selection` gives "Back to Dedicated Selection".
   Under the correct flow Dedicated Results is only ever reached from Dedicated Search,
   so the default branch is dead once `results.html` lands — see `G-02` and `DR-10`.
3. §5.3 and §5.6 are **separate files with separate corrections**. Nothing is shared or
   deduplicated between them.

### Palette conflict

The two page families use different tokens for the same brand colours:

| Token | `index.html` | Search / results / vendor pages |
|---|---|---|
| navy | `#071536` | `#00164B` |
| orange | `#F36F21` | `#F26A1B` |
| blue | `#1B5FD0` | `#1B5FD0` |

Not raised in the correction doc, but it affects `H-01` (match the header navy) and
`H-04` / `V-03` (orange). Corrections below use the palette **local to the file being
edited**. Unifying the two is a separate task — see §4.9.

---

## 3. Decisions already made

| # | Decision |
|---|---|
| D1 | Load **all 1,463** vendors. The 863 unenriched rows render with `—` in empty cells. No field is invented. |
| D2 | ~~Master Trade uses the doc's 11 groups~~ **Superseded 2026-08-31** — use the 11 Master Trades in `CTD_Master_Trades_Divisions_Trades_Subtrades.xlsx`. See §3.1. |
| D3 | ~~Trades vocabulary is the 34 trades in `taxonomy.json`~~ **Superseded 2026-08-31** — Trade is a construction discipline, per the client taxonomy. See §3.1. |
| D4 | Page names follow §2. |
| D5 | Hero glow (`H-02`) is fixed by **regenerating the image externally**, not by code. |

> **D2 and D3 were superseded by the client's 2026-08-31 answers. Read §3.1 and §3.2
> before planning any work.**

### 3.1 Client answers — 2026-08-31

Two files received, plus written answers across the day. **All three questions are now
resolved.** Q3 landed in two parts — the vocabulary first, then the per-vendor
classification agreed that evening.

**Files**
- `CTD_Master_Trades_Divisions_Trades_Subtrades (1).xlsx` — the taxonomy. Authoritative.
- `CTD_Combined_Vendor_Master_1463_COMPLETED.xlsx` — vendor data, 863 rows enriched.

> Client instruction: **"Always use the last file sent."** These two supersede
> `CTD_Combined_Vendor_Master_1463(1).xlsx` for every purpose.

#### The two taxonomies are separate and must not be mixed

| Axis | Levels | Describes |
|---|---|---|
| **Software** | Category → Subcategory → Product | What the software vendor *sells* |
| **Construction** | Master Trade → Division → Trade → Subtrade | Who the vendor *sells to* |

Confirmed by the client verbatim: *"Category - Subcategory - Products are for Technology
Software Vendors. Master Trades - Divisions - Trades - Subtrades are what type of
Construction professionals the Software Vendors sell to."*

#### ✅ Q1 resolved — a Trade is a construction discipline

Each level contains many of the next: Master Trades contain Divisions, Divisions contain
Trades, Trades contain Subtrades. The supplied taxonomy has **11 Master Trades → 50
Divisions → 50 Trades → 1,000 Subtrades**.

| Level | Count | Real examples from the file |
|---|---|---|
| Master Trade | 11 | Structural · Building Envelope · Mechanical · Civil & Sitework |
| Division | 50 | `03 Concrete` · `22 Plumbing` · `26 Electrical` |
| Trade | 50 | Concrete · Masonry · Roofing, Waterproofing & Insulation |
| Subtrade | 1,000 | Cast-in-Place Concrete · Post-Tensioned Concrete · Medical Gas |

**Therefore option B.** Job roles are out — the client: *"These are roles within a specific
construction project."* Contractor types are out — the client: *"This is wrong."*

⚠️ **The reference designs are wrong on this point.** Every mockup shows the TRADES column
as *Project Managers, Superintendents, Estimators, Architects*. Those are job roles. The
column must instead show trades such as *Concrete*, *Masonry*, *Roofing*. Same for the
Advanced Search TRADES facet, which currently lists Project Management (142),
Superintendent (100), Estimating (86).

#### ✅ Q2 resolved — CSI MasterFormat, 50 divisions supplied

The `DIVISIONS` sheet is standard MasterFormat, `00`–`49`, reserved divisions retained and
labelled *Future Scope* so the numbering stays complete.

⚠️ **The Search Results design's division labels are wrong** and the client confirmed it:
`02 = HVAC` and `31 = Drywall` do not exist. Per the supplied file, `02` is Existing
Conditions and `31` is Earthwork; HVAC is `23`, and drywall sits under `09` Finishes.
Those sample links must be relabelled when `results.html` is built (`SR-00`).

#### ✅ Q3 part 1 — the vocabulary (11 Master Trades supplied)

The **11 Master Trades are supplied**, and every Division maps to exactly one of them — so
the *vocabulary* and the *division → master trade* mapping are both settled.

**These are not the 11 groups in the correction notes.** The list changed:

| # | Master Trade | # | Master Trade |
|---|---|---|---|
| 1 | General Construction & Project Delivery | 7 | Mechanical |
| 2 | Structural | 8 | Electrical & Technology |
| 3 | Building Envelope | 9 | Civil & Sitework |
| 4 | Interior Finishes | 10 | Transportation & Infrastructure |
| 5 | Specialty Building Systems | 11 | Industrial & Process / Energy & Power |
| 6 | Fire & Safety | | |

#### ✅ Q3 part 2 — per-vendor classification agreed

The vendor→taxonomy gap is closed by agreement. The client will classify all 1,463
vendors **before** any database change, so the results can be reviewed first.

**Incoming file — `record_id | master_trade | primary_trade | cross_trade`**

| Field | Values | Rule |
|---|---|---|
| `record_id` | existing IDs | Join key. Names are not used for matching. |
| `master_trade` | one of the **11** | Must match `MASTER_TRADES` exactly — no variants or abbreviations |
| `primary_trade` | one of the **50** | Must match `TRADES` exactly |
| `cross_trade` | `Yes` / `No` | `Yes` = broadly useful across several Master Trades |

**Integrity rule (client-specified):** `primary_trade` must always belong under the
selected `master_trade`. `Mechanical` + `Concrete` is invalid. The hierarchy defines
this, so it is machine-checkable on import — see §6 task 2.

**Worked examples supplied by the client**

| Vendor type | Master Trade | Primary Trade | Cross |
|---|---|---|---|
| Concrete estimating | Structural | Concrete | No |
| Roofing software | Building Envelope | Roofing, Waterproofing & Insulation | No |
| Procore-type platform | General Construction & Project Delivery | General Conditions & Project Services | **Yes** |

`confidence` and `reason` stay on the client's QA sheet and are not needed in the
production file.

**Why `cross_trade` ships in the production file, not just QA.** A broadly-applicable
vendor gets one primary home so filters resolve, and the flag records that the product
is not actually limited to that area. Without it, QuickBooks would vanish from every
Master Trade except General Construction. Filter behaviour follows in `SR-06` / `AS-01`:
primary matches first, cross-trade vendors surfaced rather than hidden.

**`trades_served` is untouched this pass.** Confirmed as contractor/audience types, to be
renamed `contractor_types_served` later. Do not build the Trade filter on it.

### 3.2 Data reality check

Measured from `CTD_Combined_Vendor_Master_1463_COMPLETED.xlsx`, all 1,463 rows
(re-measured 2026-08-31). This governs what the facets can actually do.

| Facet | Column | Coverage | Verdict |
|---|---|---|---|
| Category | `primary_category` | ✅ 1,463 / 12 values | Works |
| Subcategory | `subcategory` | ✅ 1,463 / 72 values | Works |
| Product | `product_names` | ✅ 1,463 | Works — 825 use the vendor name as fallback |
| **Division** | `construction_divisions_served` | ⚠️ 1,463 but **85% are `ALL`** | Weak facet |
| **Trade** | `trades_served` | ⛔ 1,463 but **wrong vocabulary** | Unusable |
| **Master Trade** | — | ⛔ **column still does not exist** | Unbuildable |
| **Subtrade** | — | ⛔ **column does not exist** | Unbuildable |
| Website | `website_url` | ⛔ **638 of 1,463** | 825 vendors have no URL |

**Divisions — entire column, all 1,463 rows:**

| Value | Rows |
|---|---|
| `ALL` | **1,237** |
| `31,32,33` | 140 |
| `21,22,23,25,26,27,28,31,32,33` | 62 |
| `03,31,32` | 14 |
| `26,27,28` · `22,33` · `21,26,28` · `05` · `07` | 11 combined |

**Trades — entire column, all 1,463 rows.** Now 14 distinct values, up from 5. But they
are still *contractor types*, which the client has explicitly ruled wrong:

| Value | Rows |
|---|---|
| `GC, Commercial, Residential, Specialty Trades` | 714 |
| `All Contractors` | 400 |
| `Civil, Sitework, Surveying, GC` | 103 |
| `GC, Commercial, Architects, Engineers, Specialty Trades` | 73 |
| `GC, Commercial, Mechanical, Plumbing, Electrical, Specialty Trades` | 50 |
| `Plumbing, HVAC, Electrical, Mechanical, Service Contractors` | 50 |
| *8 further values* | 73 combined |

**What this means.** The software axis is now **fully covered** — Category, Subcategory and
Product work for all 1,463 vendors. That is a real unblock: the right-hand
"WHAT ARE YOU LOOKING FOR?" card and three table columns can be built today.

The construction axis is **still not connected to the vendors**. The taxonomy itself is
complete and excellent (§3.1), but no vendor carries a Master Trade, Trade or Subtrade,
and its one link — Division — is `ALL` for 85% of rows. A Division filter would offer nine
options, one matching 1,237 vendors.

Still blocked: the left-hand "WHAT DO YOU DO?" card, three table columns on every results
page, the Advanced Search Trade/Division/Master-Trade facets, and the Dedicated Search
Master Trade panel — `SR-06`, `AS-01`, `AS-05`, `DS-02`, `DS-03`, `DR-08`, and half of
`SR-00`. See open item 4.15.

---

## 3.3 Build log — Phase 1 shipped 2026-09-01

**17 corrections implemented and verified in-browser.** Verification was done by reading
computed values off the live pages (colours, element counts, offsets, scroll widths), not
by eye. No console errors on any page.

| ID | Change | Verified by |
|---|---|---|
| H-03 | Strip headings aligned via `min-h-[2.75em]` on the four descriptions | All four headings at `top: 582` |
| H-04 | `border-t-2 border-ctd-orange` on `<footer>` | Computed `rgb(243,111,33)` |
| H-05 | Resources column gains Find · Learn · Research · Insights | 7 items in order |
| H-06 | `FAQ · Glossary` on one line | Both anchors share a `top` |
| H-07 | 8 social icons | 8 anchors, 0 zero-width glyphs |
| AS-02 | Facet labels wrap; `overflow-x:hidden` on sidebar; table rounding fixed | 0 horizontally-scrolling elements |
| AS-03 | `.vn` 700 → 500 | `vn=500`, `th=700` |
| AS-04 | 2-person icon → 3-person | 3 `<circle>` in `.pcount` |
| DS-01 | Sort buttons on all 6 facet panels | 6 buttons; A→Z and Z→A both confirmed |
| DS-05 | "Dedicated Selection" → "Dedicated Search": H1, the orange button on Advanced Search, and the back-label | 0 occurrences left repo-wide |
| DR-01 | H1 → `DEDICATED RESULTS PAGE` | Rendered H1 matches |
| DR-03 | Button → `Change Search` | Rendered label matches |
| DR-05 | Actions restructured: globe + bookmark above View Profile | 10 globes, 10 bookmarks; toggle persists |
| DR-06 | Row-checkbox column removed, both tables | 0 table checkboxes; 50 sidebar checkboxes intact |
| DR-07 | `TRADES SERVED` → `TRADES` | 0 occurrences left |
| DR-08 | Column **reorder** only — Trades now precedes Divisions | Header order confirmed |
| DR-09 | `AVAILABLE ON` → `QUICK FACTS` + sort arrows | Header order confirmed |
| V-03 | Save Vendor orange | Computed `rgb(242,106,27)`, text and icon |

### Two bugs found during verification

1. **`DR-01` was silently reverted at runtime.** Editing the static `<h1>` was not enough —
   `applyFiltersAndRender()` rewrites `.phead` on every render and carried a hard-coded
   `'DEDICATED SEARCH RESULTS PAGE'` fallback. Fixed at the JS source. Worth remembering:
   on these pages the visible heading is *JS-owned*, so any future rename must change both.
2. **`AS-02` had a second cause, and my first fix was wrong.** Beyond the sidebar labels,
   the table itself scrolled. I initially assumed percentage-width rounding and let the
   last column absorb the remainder — that made it *worse*. The real cause was that the
   nowrap `View Profile` button is a **fixed pixel size inside a percentage column**, so
   it overflows its cell whenever the viewport shrinks enough. A wider `ACTIONS` column
   only moves the width at which it breaks.
   Fixed properly by making the button fluid — `display:flex; width:100%`, horizontal
   padding `9px → 5px` — and setting `ACTIONS` to `10%`.
   **Verified at 1280 / 1440 / 1600: zero horizontally-scrolling elements.**
   At **1024 the table still scrolls**, and that is correct: `table.res` carries an
   explicit `min-width:900px` so narrow screens scroll rather than crush eight columns.
   The page's mobile layout takes over below 999px, making 1024–1279 the tightest desktop
   case. Say if you want the min-width lowered for that band.

### Deliberate scope calls

- **`DR-08` is half-done.** The column *order* is now Trades → Divisions → Master Trades,
  matching `AS-01`. The Trades column still renders `trades_served` (contractor types),
  which the client has ruled wrong. Content swaps to `primary_trade` when the
  classification file lands — no further layout work needed.
- **`AS-03` applied to Advanced Search only**, as the correction specifies.
  `dedicated-results.html` still has `.vn{font-weight:700}`. Its equivalent correction
  (`SR-02`) targets `results.html`. Say the word and I'll align it for consistency.
- **`AS-04` applied to all three results pages**, not just Advanced Search. The correction
  names only Advanced, but all three shared the same 2-person icon and leaving them
  mismatched would look like an oversight.
- **The globe is omitted, not disabled, for vendors with no domain** (825 of 1,463).
  A link to `https://` is worse than no link — see 4.16.
- **`DR-07` covers the six flow pages only.** The phrase "Trades served" also appears on
  the **600 legacy `tool/<category>/<slug>.html` pages** — output of the old build
  pipeline, outside the correction doc's scope and not part of the §2 flow. Left alone
  deliberately; those pages need a wider decision (see §4.17) rather than a blind
  find-and-replace across 600 files.

### Files touched

`index.html` · `dedicated-results.html` · `advanced-search-results.html` ·
`dedicated-search.html` · `vendor-profile.html`

`.bak` copies of all five sit beside the originals. Delete once you're happy — nothing
else references them.

---

## 3.4 Build log — Phase 2 in progress, 2026-09-01

### Data layer — done

**New: `build/import-vendors.ps1`.** Regenerates everything from the two client
workbooks. Re-runnable: when a newer workbook arrives, drop it in and re-run. Never
hand-edit the outputs.

| Output | Contents |
|---|---|
| `assets/tools-data.js` | `window.TOOLS` — **1,463** vendors (was 600) |
| `data/construction-taxonomy.json` | Full hierarchy: 11 / 50 / 50 / 1,000 |
| `assets/taxonomy-data.js` | Facet vocabularies only, 11.7 KB — subtrades excluded so pages don't carry 400 KB for nothing |

Import results: **1,463 vendors, 1,463 unique slugs, 1,463 with a category, 638 with a
domain.** Slug uniqueness matters — `vendor-profile.html?s=` looks vendors up by it, and
a collision would silently show the wrong vendor.

**`G-01` verified live:** every count now reads 1,463; Advanced Search paginates to 147
pages. Category distribution shifted as expected once the 863 joined —
Document Management 289, Project Management 253, AI & Automation 158.

**`DS-02` done.** The Master Trade panel lists all **11 real groups** from the client
taxonomy. It previously showed three labels — "General Construction & Project Delivery",
"Mechanical Trades", "All Master Trades" — of which two don't exist in the hierarchy at
all. That was the "Items Missing" the correction flagged.
Counts are 0 pending classification, so entries render **disabled and dimmed** rather
than filtering to an empty table. `filters.js` falls back to the old derivation if
`taxonomy-data.js` is absent.

**Deliberately not done: category → Master Trade derivation.** The client ruled it out —
an estimating tool may serve electrical *or* concrete, and the same software category
would give both the same Master Trade. Divisions and Trades facets are untouched this
pass; they still filter, and swap to real values in Phase 3.

### A production bug found on the way

Updating the data alone would not have reached users. Pages referenced
`assets/tools-data.js` with no version, so returning visitors keep the cached copy and
still see 600. Worse, a stale `filters.js` against fresh data — which is exactly what bit
me mid-build: the new taxonomy code was on disk but the browser ran the old file.

`import-vendors.ps1` now stamps **every local `.js`/`.css` reference** across all pages
with the build time (`?v=yyyyMMddHHmm`). One rule covers every asset.

### `DR-04` — vendor logos, done

`build/fetch-icons.ps1` rewritten to read `assets/tools-data.js` instead of the old
600-vendor `data/tools.json`.

**Fetch result: 556 unique domains, 531 cached, 25 fell back, 0 corrupt files.**
`assets/icons/` went 176 → 620 `.ico` files. (556 unique domains across 638 vendors —
some share one, e.g. several Google products.)

Both results tables now render the logo. New `vendorCell()` helper in each:
cached favicon → letter circle when the icon 404s → letter circle when the vendor has no
domain at all.

**It also fixed a live bug.** The vendor cell linked to `href="https://"` for every
vendor without a domain — 825 dead links per full listing. The domain link is now
omitted entirely when there is no domain, matching what `DR-05` already does for the
globe icon.

Verified: logos decode (naturalWidth 32–288), 0 broken images visible, 0 dead `https://`
links, and the final page — which is all unenriched vendors — renders letter circles
correctly.

### `SR-00` — `results.html` built

The missing Search Results page now exists, built to `specs/search-page-desktop.md` +
`-mobile.md` and the reference design. 625 lines, self-contained, reusing the shared
chrome and `filters.js` / `actions.js`.

All six regions per the spec: sticky header · title row + 3 buttons · two-question panel ·
9-column table · pagination · shared footer.

**Live now (software axis — the data is complete for all 1,463):**
Category, Subcategory and Product columns all populate; the right-hand
"WHAT ARE YOU LOOKING FOR?" card filters the table; `Start typing…` narrows each card's
lists; sorting, pagination and 10/25/50 per page all work; logos render with letter-circle
fallback; Actions follow `SR-03`.

**Placeholder (construction axis):** the left-hand "WHAT DO YOU DO?" card lists the real
hierarchy — 11 Master Trades, the 50 CSI Divisions, the 50 Trades — but the entries are
not clickable and the Master Trades column shows `—`. A note on the card says so. They
go live when the classification file is imported.

**Two deviations from the reference design, both deliberate:**

1. **Actions is two rows, not one.** The design puts globe · bookmark · View Profile on a
   single row; corrections P25/P28/P30 ask for the icons above a View Profile bar. The
   correction wins, and it now matches the other two results tables.
2. **Trades sits before Divisions.** The design puts TRADES last
   (`… MASTER TRADES · DIVISIONS · TRADES`); correction P35 puts it between Categories and
   Divisions. Following P35 per open item 4.10, so all three results tables read
   identically. **Flag if you want the reference order restored here.**

**A design error corrected.** The reference's Division samples read `02 – HVAC` and
`31 – Drywall`. Neither exists — the client confirmed it. The page now renders the real
CSI values straight from the taxonomy: `02 – Existing Conditions`, `03 – Concrete`.

**Verified:** 1,463 count · category link → `?cat=` → 62 for CRM & Sales · chip renders and
clears · Advanced Filters carries the selection through as
`advanced-search-results.html?cat=…` · sort · pagination · 25/page · `Start typing…` narrows
to `Payroll (21)` · 10/10 logos decode · no console errors.
**Mobile (spec-mandated):** at 375px and 760px the page body never scrolls sideways —
only `.tscroll` does — all 9 columns are kept, and **0 touch targets under 40px** (7 failed
on the first pass and were fixed).

### `SR-09` / `DR-10` / `G-02` — flow rewired

| Change | Result |
|---|---|
| 14 homepage links + the header search form | now target `results.html` — 0 references to `dedicated-results.html` remain on the homepage |
| Advanced Search "Back to Search Results" | now resolves to `results.html` (was the stopgap) |
| Vendor profile breadcrumb "Search Results" | same |
| `?ref=selection` stopgap | **removed** — script block, dual back-label, and the orphaned `refParam` round-trip in `applyFiltersAndRender` |
| Dedicated Results back-link | now unconditionally "Back to Dedicated Search" |

End-to-end walk verified: Home → Search Results → Advanced → Dedicated Search →
Dedicated Results → Vendor, forward and back, no console errors at any step.

### Phase 2 complete

Remaining work is Phase 3 only, and all of it waits on the client's classification file.

---

## 4. Open items

These need an answer. Each has a working default so nothing is blocked on them.

**4.1 — Advanced Filters has no backing data (⛔ affects AS-06)**
The reference panel needs five filter groups. Three have no column in the workbook:

| Group | Data status |
|---|---|
| Evaluation Options | `free_trial_available`, `free_demo_available` exist. **"Peer Reviewed" does not.** |
| Purchase Options | `pricing_model` exists but holds prose (`"Subscription / license"`). Needs parsing. **"Contract Per Quarter" is absent.** |
| Company Type | `public_private` exists, but values read `"Private / Verify"` — needs normalising. |
| Available On | Vocabulary conflict — see 4.2. |
| Markets Served | **No column exists at all.** 10 values in the reference. |
*Default:* build all five groups; render options with no data as disabled with a
`0` count, so the layout matches the reference without faking membership.

**4.2 — "Available On" vocabulary conflict (⚠️)**
Reference: Web Browser · Mobile App · Desktop Software.
Live site: Cloud-Based · Mobile App · API Available · Web Access.
*Default:* keep the live four (they have data), since the doc asks for *more* options,
not different ones.

**4.3 — "Indutrdura" (⚠️)**
Appears in the reference's Markets Served list, between Infrastructure and Retail /
Hospitality. Almost certainly a typo. *Default:* drop it, use the other nine.

**4.4 — Company Size (⚠️)**
Present on the live page, absent from the reference. *Default:* keep it — the data
exists (`company_size_served`) and the instruction was additive.

**4.5 — Active Filters chip row (⚠️)**
The reference shows a chip row (`United States`, `Project Management`, `SaaS`); the live
page has none. Not mentioned in the text. *Default:* out of scope.

**4.6 — "Make sure worksheep links all of these" (P74) (⚠️)**
Reading "worksheep" as "worksheet". *Default:* all 11 Master Trade entries must be live
links through to filtered results.

**4.7 — Contact Info completeness (P108) (⚠️)**
"Include all items" — the card has three slots (address, phone, email), all rendering
`—` for most vendors. Unclear whether this means *add more field types* or *populate the
existing three*. *Default:* populate the existing three; flag for confirmation.

**4.8 — Social profile URLs (⚠️)**
All social `href`s are `#` placeholders on both home and vendor pages.
*Default:* leave as `#`; spec the icons, order and colours only.

**4.9 — Palette unification**
Out of scope for this pass. Recorded so it isn't lost.

**4.10 — Trades column position differs between the two results tables (⚠️)**
The reference design for `results.html` puts TRADES **last, after DIVISIONS**:
`… MASTER TRADES · DIVISIONS · TRADES · ACTIONS`.
Correction P35 for `advanced-search-results.html` puts it **between CATEGORIES and
DIVISIONS**. `DR-08` follows P35 for `dedicated-results.html`.
*Default:* follow P35 everywhere — `… CATEGORIES · TRADES · DIVISIONS · MASTER TRADES …` —
so all three tables read identically. This overrides the reference design's ordering on
`results.html`. **Flag if you want the reference order kept there instead.**

**4.11 — Is `results.html` genuinely unbuilt, or is this snapshot stale? (⛔)**
The SEARCH/RESULTS corrections read as though written against a *live* page — "Remove
checkboxes", "Missing Trades", "Unbold Results section" describe a page with faults, not
a blank one. But no such file exists in this repo, and the homepage falls through to
`dedicated-results.html`.
*Two readings:*
  - **(a)** It was never built; the corrections were written against the reference design.
    Then `SR-00` is a build, and SR-01…SR-06 are deltas from `specs/search-page-desktop.md`.
  - **(b)** It exists on the deployed site and this GitHub snapshot is behind. Then
    `SR-00` is wrong and SR-01…SR-06 are edits to a file I have not seen.
*Default:* (a). **If (b), send me the live `results.html` and I will rewrite §5.3 against
the real markup** — the current entries would be guesswork otherwise.

**4.15 — Vendors not mapped into the construction taxonomy (✅ RESOLVED 2026-08-31)**
Option (a) agreed. The client classifies all 1,463 vendors and delivers
`record_id | master_trade | primary_trade | cross_trade` **before** any database change,
so the classification can be reviewed first. Full detail in §3.1.
Of the 226 vendors with specific divisions, the client reports 146 already resolve
cleanly to a single Master Trade; only 80 span several. The remaining 1,237 are
classified vendor-by-vendor rather than by category.
**Awaiting delivery — this is now the critical-path dependency for Phase 3.**

**4.17 — What happens to the 600 legacy `tool/` pages? (⚠️)**
`tool/<category>/<slug>.html` — 600 pages generated by the old build pipeline. They are
live, indexed in `sitemap.xml`, and still say "Trades served" with values like
`All Construction`. They sit outside the §2 flow and outside the correction doc.
They will drift further as the new taxonomy lands: 600 pages describing vendors by the
old vocabulary while the six flow pages use the new one.
*Options:* regenerate them from the new data · leave and let them age · retire them and
redirect into the new flow (as `vercel.json` already does for `/category/*`).
*Default:* leave untouched this pass. **Worth a decision before launch.**

**4.16 — 825 vendors have no website (⚠️)**
`website_url` covers 638 of 1,463; the enrichment audit confirms 825 were
*"left blank rather than guessing a domain"* — the right call. But it means no favicon can
be fetched and no "Visit Website" globe can resolve for those rows.
*Default:* letter-circle fallback for the logo, globe hidden (not disabled) where there is
no URL. Affects `DR-04`, `DR-05`, `SR-03`.

---

#### Resolved

**4.12 — "Trade" means three different things (✅ RESOLVED 2026-08-31)**
Answer: **construction discipline**. See §3.1. The designs' job-role values are wrong and
must be replaced.
*Original analysis retained below for context.*
Three incompatible definitions are in play:

| Source | Example values | What it actually is |
|---|---|---|
| Reference designs | Project Managers · Superintendents · Estimators · Architects · Schedulers | **Job roles / personas** |
| `data/taxonomy.json` (D3) | HVAC · Plumbing · Electrical · Concrete · Roofing *(34)* | **Construction disciplines** |
| Workbook `trades_served` | All Contractors · GC, Commercial, Residential… *(5)* | **Contractor-type buckets** |

The Advanced Search reference reinforces the first: its TRADES facet reads Project
Management (142) · Superintendent (100) · Estimating (86) · Labor Management (72) ·
Scheduling (64) — roles, not trades.
**This must be settled before any TRADES column or facet is built.** D3 assumed the
second; the designs you have supplied consistently show the first.
*No default — genuinely ambiguous, and picking wrong means rebuilding three tables.*

**4.13 — Two different Division schemes (✅ RESOLVED 2026-08-31)**
Answer: **CSI MasterFormat**, 50 divisions supplied. The Search Results design's
`02 = HVAC` / `31 = Drywall` labels are wrong and must be corrected in `SR-00`.
*Original analysis retained below.*
| Source | Sample |
|---|---|
| Search Results reference + `search-page-desktop.md` | `00 – General` · `01 – General Work of Practice` · **`02 – HVAC`** · **`31 – Drywall`** |
| Dedicated Search + Advanced Search references | `03 – Concrete` · `04 – Masonry` · `05 – Metals` · `06 – Wood & Plastics` · `09 – Finishes` · `34 – Transportation` |
| Workbook (62 rows) | `21,22,23,25,26,27,28,31,32,33` |

The second and third are **CSI MasterFormat**. The first is not — in MasterFormat, 02 is
Existing Conditions and 31 is Earthwork, not HVAC and Drywall. So the Search Results
design uses a custom CTD numbering that contradicts the other two pages.
*Default:* CSI MasterFormat, since it matches the data and two of three designs.
**Confirm — if the custom scheme is correct, I need the full numbered list.**

**4.14 — Master Trade has no source at all (⚠️ PARTLY RESOLVED 2026-08-31)**
The **vocabulary** is answered: 11 Master Trades supplied, plus a complete
division → master trade mapping (Appendix A). The **per-vendor assignment** is not —
that moved to open item 4.15.
*Original analysis retained below.*
There is no `master_trade` column, and Appendix A's plan to derive it from divisions is
dead on arrival: 538 vendors say `ALL`, 62 share one identical list, 863 are blank. That
mapping would put ~538 in *General*, ~62 in *Mechanical/Electrical*, ~863 in *Other* —
worthless as a filter.
The designs also disagree with the correction doc on the vocabulary itself:

| Source | Groups |
|---|---|
| Correction doc (D2) | 11 — General, Architectural, Concrete & Masonry, … Other |
| Advanced Search reference | 5 — General Construction · Project Delivery · Mechanical · Electrical & Technology · Civil & Utilities |
| Search Results reference | 4 shown — General Contractors & Project Delivery · Industrial Trades · Electrical & Technology Trades · Civil & Sitework |

*Options:*
  - **(a)** You supply a `vendor → master_trade` mapping for all 1,463 (a spreadsheet
    column is enough). Cleanest, unblocks everything immediately.
  - **(b)** Derive from `primary_category` — 12 categories → the 11 groups. Mechanical,
    honest, but it makes Master Trade a near-duplicate of Category, so the two facets
    would move together and one becomes redundant.
  - **(c)** Ship the 11 labels with real counts only where derivable; everything else
    `Other`. Matches the correction doc visually, filters poorly.
*No default — needs your decision.*

---

## 5. Corrections

### 5.1 Global

#### G-01 · Vendor count must read 1,463, not 600 ⚠️
**Doc** GLOBAL — "Over 1200 records, not 600"
**Files** `assets/tools-data.js`, `data/tools.json`, all result pages
**Now** 600 vendors. Every count on every page derives from this.
**Want** All 1,463 from `Combined_Vendors_1463`. Per D1 the 863 unenriched rows show
`—` in empty cells and are excluded from facet counts (they have no facet values).
**Done when** Advanced Search Results reads "1,463 Vendor Matches"; the directory
paginates to 147 pages at 10/page; no row renders `undefined` or `null`.
**Note** The doc says "over 1200", the workbook holds 1,463, the mockup says 1,248.
Building to 1,463 — the actual row count.

#### G-02 · Back-link must name the previous page ⚠️
**Doc** GLOBAL — "< Back to [Previous Page]"
**Files** all pages with a `.back-link`
**Now** Hard-coded per page; `dedicated-results.html` flips between two labels via the
`?ref=selection` flag; `vendor-profile.html` uses a static breadcrumb.
**Want** Label reflects actual origin, following the §2 chain.
**Done when** Each step back up the chain names the page it returns to; arriving at a
page directly (no referrer) falls back to its parent in §2, never a dead link.

---

### 5.2 Home / Hero

#### H-01 · Category tile band → header navy ⛔
**Doc** HOME PAGE (image3, image4) — "Make background for category icons same color as
blue background… match the solid dark blue color used in the top header navigation bar"
**Files** `index.html`, `assets/logos/*.png` (12 files)
**Now** Light blue band (`#E9F5FD` / `#DCEEFB`). Tile labels are `text-ctd-navy`
(`#071536`). Icons are dark-navy line art on transparent PNGs (verified: RGBA,
`accounting-payroll.png` is near-black).
**Want** Band becomes `#071536`, matching the header.
**Blocker** As written this makes the tiles **unreadable** — dark icons and dark labels
on a dark ground. The correction cannot ship alone. Requires either:
  - **(a)** flip labels to white **and** produce light/white versions of all 12 PNGs; or
  - **(b)** keep the dark icons, seat each on a white rounded chip, labels white.
**Done when** Band reads `#071536`; every icon and label meets ≥4.5:1 contrast.
**Needs your call:** (a) or (b).

#### H-02 · Skyline visible under the AI logo ⚠️
**Doc** HOME PAGE (image5) — "Skyline should be clear and visible under AI logo…
reduce the glowing effects, shadows, or gradients"
**Files** `assets/ctd/hero_image.jpg` (2172×452), plus `assets/hero/home-hero-mobile.webp`
if it carries the same graphic
**Now** An additive blue bloom around the AI brain washes out the skyline. Confirmed by
gamma-lift that the building detail **survives underneath** — the bloom is layered over
the skyline, not painted through it.
**Want** Skyline reads clearly behind and beneath the brain; brain and circuit traces
stay bright.
**Route** Per D5, regenerated externally. Prompts issued separately. A code-side
fallback exists (masked dehaze, strength 0.42, radius 55, x-ramp 1300→1560) producing
`hero_image_FIXED.jpg` at 337 KB — held in scratchpad, not committed.
**Done when** New asset is 2172×452, ≤360 KB, drops in at `assets/ctd/hero_image.jpg`;
the logo lockup and all icon labels are pixel-intact (generators mangle small text);
mobile hero receives identical treatment.

#### H-03 · Align LEARN and RESEARCH with FIND and INSIGHTS ✅
**Doc** HOME PAGE (image6) — "Pull Learn and Research up 1 row because its lower
compared to find and insights"
**Files** `index.html`
**Now** In the four-up strip, the FIND and INSIGHTS headings sit ~11px higher than
LEARN and RESEARCH — the two shorter body copies push their headings down.
**Want** All four headings share one baseline.
**Fix** The four cells are independently laid out; give the strip `items-start` and the
heading rows a shared fixed height, or make each cell a 2-row grid with a fixed heading
track.
**Done when** All four headings share a baseline at every breakpoint down to 375px.

#### H-04 · Thin orange rule above the footer ✅
**Doc** HOME PAGE — "Use an orange thin Horizontal Line which will separate between
footer and content above"
**Files** `index.html`
**Now** No divider — the FIND/LEARN/RESEARCH/INSIGHTS strip runs straight into the footer.
**Want** A thin orange rule between them: `1px`, `#F36F21` (home palette — see §2).
**Done when** Rule spans the full width, sits directly above the footer block, and does
not double up with any existing border.

#### H-05 · Footer Resources gains Find / Learn / Research / Insights ⚠️
**Doc** HOME PAGE — "Resources: Find, Research, Insight, Learn in footer"
**Files** `index.html`
**Now** Resources column = Technology Guides · FAQ · Glossary (`index.html:286-288`).
**Want** Technology Guides · Find · Learn · Research · Insights, then FAQ · Glossary
per `H-06`.
**Note** The reference mockup's Resources column omits FAQ entirely; `H-06` requires it.
Keeping FAQ, since a correction that names it outranks a mockup that omits it.
**Done when** All entries present, in order, each linking to a real target or a
documented placeholder.

#### H-06 · FAQ and Glossary share one line ✅
**Doc** HOME PAGE — "Make FAQ/Glossary on one line"
**Files** `index.html`
**Now** Two separate block-level `<a>` elements on consecutive lines.
**Want** One line: `FAQ · Glossary`, two links, separated by a middot.
**Done when** They occupy a single line and stay on one line down to 375px.

#### H-07 · Eight social icons in the footer ✅
**Doc** HOME PAGE (image7) — "ALL 8 ICONS on Home Page Footer. Add Tiktok, Houzz,
pinterest, X."
**Files** `index.html`
**Now** Four: LinkedIn, Facebook, YouTube, Instagram (`index.html:304-315`), all
`href="#"`.
**Want** Eight — add TikTok, Houzz, Pinterest, X.
**Available** Font Awesome 6.5.2 is already loaded and carries all four:
`fa-tiktok`, `fa-houzz`, `fa-pinterest-p`, `fa-x-twitter`. No new dependency.
**Brand colours** TikTok `#000000` · Houzz `#4DBC15` · Pinterest `#BD081C` · X `#000000`
**Done when** Eight icons render in a 4×2 grid matching existing sizing/hover, each with
an `aria-label`. Hrefs remain `#` per 4.8.

---

### 5.3 Search / Results

> **`results.html` — does not exist yet.** Build to `specs/search-page-desktop.md` and
> `specs/search-page-mobile.md`, then apply SR-01…SR-06 as deltas from that spec.

#### SR-00 · Build the Search Results page ⛔
**Doc** Implied by the whole SEARCH/RESULTS section, plus the reference design supplied
2026-08-31
**Files** new `results.html`
**Now** Missing. Homepage tiles fall through to `dedicated-results.html?cat=<slug>`.
**Want** The page as specified. Structure, top → bottom:

| # | Region | Content |
|---|---|---|
| 1 | Header | Sticky navy `#00164B`; logo; centre search `Search Company, Product, Category, Trade or Keyword`; nav About Us · Contact Us · Add / Modify Info · Home |
| 2 | Title row | H1 `SEARCH RESULTS` + live subline `N companies match your search criteria.`; right: ☆ Save Search · ⭳ Export Results · ⚑ Advanced Filters (solid navy) |
| 3 | Two-question panel | Two white cards. **WHAT DO YOU DO?** → Master Trade (blue) · Division (green) · Trade (orange). **WHAT ARE YOU LOOKING FOR?** → Category (blue) · Subcategory (green) · Product (orange). Each column: 4 sample links + `View all … ›`. Each card has a `Start typing…` input. |
| 4 | Results table | `# · VENDORS · CATEGORIES · SUBCATEGORIES · PRODUCTS · MASTER TRADES · DIVISIONS · TRADES · ACTIONS`; `↑↓` on every sortable header; rows alternate white / cream `#FBF6EF`; `more…` links where a field overflows |
| 5 | Pagination | Left live count; centre `‹ 1 2 3 4 5 … ›`; right `Results per page: [10 ▾]` (10/25/50) |
| 6 | Footer | Shared CTD footer — must carry `H-05`/`H-06`/`H-07` |

**Palette** Per the spec: navy `#00164B` · orange `#F26A1B` · blue `#1B5FD0` · vendor link
`#1C57B8` · green `#158526` · cream `#FBF6EF` · line `#E4E9F0` · muted `#6B7793`.
**Blocker** The spec itself flags this: it marks PRODUCTS, MASTER TRADES, DIVISIONS and
TRADES as *"derived/placeholder … swap in real values when the Master-Trade→Division→Trade
taxonomy + product data are provided."* **That taxonomy still has not been provided** —
§3.2 shows the construction-axis columns are still unusable. So today `SR-00`
can be built with regions 1, 2, 5, 6 real; region 3's right-hand card (Category /
Subcategory / Product) real; and region 3's **left-hand card plus three table columns
placeholder**. Building it fully requires §6 tasks 2-4 first.
**Done when** `results.html` renders all six regions at 1280/1440/1600px and at 375px per
the mobile spec; the count reads 1,463 per `G-01`; sorting, category links, pagination and
per-page all drive the table.

#### SR-01 · Search selection above the results ⚠️
**Doc** SEARCH/RESULTS PAGE — "Include Search selection above center content"
**Files** `results.html`
**Want** The active search selection is shown above the results table — i.e. the
two-question panel (region 3) sits above the table, and whatever the user has picked
stays visible there rather than being swallowed once results render.
**Done when** Every active facet is visible above the table, each individually
dismissable, and dismissing one re-runs the query.

#### SR-02 · Unbold the results body ✅
**Doc** SEARCH/RESULTS PAGE — "Unbold Results section of center content"
**Files** `results.html`
**Want** Weight on column headers and the two card question labels only; table body
regular.
**Done when** No `font-weight` above 400 below `<thead>`. Same rule as `AS-03`.

#### SR-03 · Actions: globe + bookmark above View Profile ✅
**Doc** SEARCH/RESULTS PAGE — "Put View Profile Under globe / bookmark" · "Globe and
bookmark top" · "Bottom - View Profile Bar" *(P25, P28, P30)*
**Files** `results.html`
**Now (reference design)** All three sit on **one horizontal row**: globe · bookmark ·
View Profile.
**Want** Two rows — this is a **delta from the supplied mockup**, the correction wins:
```
┌─────────────────┐
│   🌐    🔖      │  ← globe + bookmark, side by side, top
│  [View Profile] │  ← full-width bar, beneath
└─────────────────┘
```
**Done when** Icons sit side by side above a full-width View Profile bar; globe opens the
vendor site in a new tab; bookmark toggles and persists; both have accessible labels.
Matches `DR-05` so the two tables agree.

#### SR-04 · Advanced Filters opens the Advanced page ✅
**Doc** SEARCH/RESULTS PAGE — "Click Advanced Filters, take us to Advanced"
**Files** `results.html`
**Want** The solid-navy ⚑ Advanced Filters button navigates to
`advanced-search-results.html`.
**Done when** It reaches Advanced Search Results with the current filters preserved in
the query string.

#### SR-05 · No row checkboxes ✅
**Doc** SEARCH/RESULTS PAGE — "Remove checkboxes"
**Files** `results.html`
**Want** No row-selection column. The reference design already omits it — build it that
way and it never appears. Table opens on `#`.
**Note** Facet checkboxes are unaffected; this page has none anyway.
**Done when** The table's first column is `#`.

#### SR-06 · Trades column present ⛔
**Doc** SEARCH/RESULTS PAGE — "Missing Trades"
**Files** `results.html`
**Want** A TRADES column, populated from the D3 vocabulary.
**Note** The reference places TRADES **last, after DIVISIONS**; `AS-01` places it
**between CATEGORIES and DIVISIONS** on Advanced Search Results. See open item 4.10 —
the two pages currently disagree.
**Blocker** Same trade-mapping dependency as `AS-01`.
**Done when** The column renders with real trades, `—` for unenriched rows.

#### SR-09 · Repoint homepage tiles to `results.html` ✅
**Doc** Implied by the §2 flow
**Files** `index.html`
**Now** 12 category tiles link to `dedicated-results.html?cat=<slug>`, plus one bare
`dedicated-results.html`.
**Want** All 13 point at `results.html?cat=<slug>`, per the flow.
**Depends on** `SR-00`.
**Done when** No homepage link targets `dedicated-results.html`, and each tile lands on
Search Results pre-filtered to that category.

---

### 5.4 Advanced Search / Results

> `advanced-search-results.html`

#### AS-01 · Add Trades column between Categories and Divisions ⛔
**Doc** ADVANCED SEARCH/RESULTS (image8) — "Trades is missing. Trade will sit between
Categories and division."
**Files** `advanced-search-results.html`
**Now** Columns: `☐ · # · VENDORS · PRODUCTS · SUBCATEGORIES · CATEGORIES · DIVISIONS ·
MASTER TRADES · ACTIONS`. No Trades column.
**Want** `… CATEGORIES · TRADES · DIVISIONS · MASTER TRADES …`
**Blocker** Needs the D3 trade vocabulary mapped per vendor. The 863 unenriched rows
have no trade data and render `—`.
**Done when** Column sits between Categories and Divisions, sortable like its
neighbours, widths re-balanced to 100%.

#### AS-02 · No horizontal scroll ⚠️
**Doc** ADVANCED SEARCH/RESULTS (image9, image10) — "No horizontal scroll. The current
one has a scroll in the Categories section."
**Files** `advanced-search-results.html`
**Now** The sidebar Categories facet scrolls horizontally — long labels
("Leads, Bids & Estimates") overflow their container.
**Want** No horizontal scroll anywhere. Long labels wrap or ellipsise.
**Watch** `AS-01` adds a ninth column; the table must absorb it without introducing the
scroll this correction removes. Reference layout keeps all columns visible at 1600px.
**Done when** `document.scrollingElement.scrollWidth <= clientWidth` at 1280px, 1440px
and 1600px, and no descendant scrolls horizontally.

#### AS-03 · Bold headers only ✅
**Doc** ADVANCED SEARCH/RESULTS (image11) — "No bold for results or selections, just
headers"
**Files** `advanced-search-results.html`
**Now** Vendor names and facet labels render bold.
**Want** Weight on column headers and facet group titles only.
**Done when** No `font-weight` above 400 in table body cells or facet option labels.

#### AS-04 · People icon beside the vendor count ✅
**Doc** ADVANCED SEARCH/RESULTS — "3 people next to vendor matches"
**Files** `advanced-search-results.html`
**Now** A two-person SVG sits left of the count.
**Want** The three-person variant, as in the reference.
**Available** `dedicated-results.html:166` already contains the correct three-person
path (two figures plus `M23 21v-2a4 4 0 00-3-3.87` and `M16 3.13a4 4 0 010 7.75`).
Copy it across.
**Done when** Advanced Search Results shows the three-person glyph at 16px, matching
`dedicated-results.html`.

#### AS-05 · Trades facet in the sidebar ⛔
**Doc** ADVANCED SEARCH/RESULTS — "Trades missing"
**Files** `advanced-search-results.html`
**Now** A `TRADES` facet block exists but is the only one appearing once in the markup
where every other facet appears twice (sidebar + table header) — it is present in the
sidebar and absent from the table.
**Want** Facet populated from the D3 vocabulary with live counts, plus the `AS-01`
column.
**Blocker** Same as `AS-01`.
**Done when** Sidebar Trades facet lists trades with counts, has a working "view more
trades" link, and filters the table.

#### AS-06 · Expand Advanced Filters to match the reference ⛔
**Doc** "Advanced search page:" (image27 = reference, image28 = current) — "there are
more options in the advanced filters option. So make it like the reference"
**Files** `advanced-search-results.html`
**Now** Two groups in two columns, each with an internal vertical scrollbar:
  - COMPANY SIZE — Small/Mid-Market (388), Mid-Market/Enterprise (96), Enterprise (60), Small Business (56)
  - AVAILABLE ON — Cloud-Based (600), Mobile App (544), API Available (156), Web Access (56)
**Want** Five groups in three columns, no internal scroll:

| Column | Groups |
|---|---|
| 1 | **Evaluation Options** — Free Trial / Freemium · Demo on Available · Peer Reviewed<br>**Purchase Options** — Subscription · One-Time Purchase · Contract Per Quarter |
| 2 | **Company Type** — Public Company · Private Company<br>**Available On** — see 4.2 |
| 3 | **Markets Served** — Civil / Heavy Highway · Commercial · Education · Energy / Utilities · Government / Public Works · Healthcare · Industrial · Infrastructure · Retail / Hospitality |

**Blocker** Three of five groups have no backing column — see 4.1. Per that default,
unbacked options render disabled with a `0` count.
**Keep** Company Size per 4.4.
**Done when** Panel matches the reference's three-column layout, no group scrolls
internally, the panel collapses via its chevron, and every enabled option filters
correctly.

---

### 5.5 Dedicated Search

> `dedicated-search.html`

#### DS-01 · Sort arrows on all six facet panels ✅
**Doc** DEDICATED SEARCH PAGE (image12) — "Up/Down arrows for each of the 6 sections"
**Files** `dedicated-search.html`
**Now** Six panels — PRODUCT, SUBCATEGORY, CATEGORY, TRADE, DIVISION, MASTER TRADE —
each with a search box and an ⓘ, but no sort control.
**Want** Up/down arrows in each header, matching the `↑↓` pattern already used on the
results tables.
**Done when** All six carry the control and it re-sorts that panel's options
ascending/descending.

#### DS-02 · Master Trade panel lists all 11 groups ⛔
**Doc** DEDICATED SEARCH PAGE (image13) — "Master Trade (Items Missing)", then the list
**Files** `dedicated-search.html`, `data/taxonomy.json`
**Now** Three entries only: "General Construction & Projec…", "Mechanical Trades (50)",
"All Master Trades (50)".
**Want** All 11, in the doc's order:

| # | Master Construction Trade Group |
|---|---|
| 1 | General |
| 2 | Architectural |
| 3 | Concrete & Masonry |
| 4 | Doors, Windows & Glass |
| 5 | Electrical & Low Voltage |
| 6 | Finishes |
| 7 | Mechanical |
| 8 | Sitework & Infrastructure |
| 9 | Specialty |
| 10 | Wood & Carpentry |
| 11 | Other |

**Blocker** The workbook has **no `master_trade` column**. Per D2, derive from
`construction_divisions_served` using Appendix A — **Appendix A needs your sign-off.**
**Done when** All 11 render with live counts summing to 1,463 (unenriched rows counted
under whatever Appendix A assigns them), and each is a working link per 4.6.

#### DS-03 · Master Trade entries all link through ⚠️
**Doc** DEDICATED SEARCH PAGE — "Make sure worksheep links all of these"
**Files** `dedicated-search.html`
**Want** Per 4.6, all 11 are live links to filtered results.
**Done when** Each of the 11 navigates to Dedicated Results filtered to that group with
a non-zero count, or is visibly disabled if the group is genuinely empty.

#### DS-04 · Vendor count → 1,463 ⚠️
**Doc** DEDICATED SEARCH PAGE — "600 vendor matches"
**Files** `dedicated-search.html`
**Now** "600 Vendor matches".
**Want** 1,463, per `G-01`.
**Done when** Count reads 1,463 and tracks live as facets are applied.

#### DS-05 · Rename to Dedicated Search Page ✅
**Doc** DEDICATED RESULTS PAGE (image14) — "Change Link to Dedicated Search Page"
**Files** `dedicated-search.html`
**Now** `<h1 class="phead">DEDICATED SELECTION PAGE</h1>`; back-link reads "Back to
Advanced Search Results".
**Want** H1 becomes `DEDICATED SEARCH PAGE`, per the §2 naming.
**Also** The orange button on `advanced-search-results.html:271` currently reads
"Dedicated Selection" → "Dedicated Search". And the `?ref=selection` back-label on
`dedicated-results.html:161` reads "Back to Dedicated Selection" → "Back to Dedicated
Search". The word "Selection" should not survive anywhere.
**Done when** `grep -ri "dedicated selection"` over the repo returns nothing.

---

### 5.6 Dedicated Results

> `dedicated-results.html`. A separate file from §5.3 — see §2. Reached only from
> Dedicated Search.

#### DR-01 · Rename to Dedicated Results Page ✅
**Doc** DEDICATED RESULTS PAGE (image15) — "Change to Dedicated Results Page"
**Files** `dedicated-results.html`
**Now** `<h1 class="phead">DEDICATED SEARCH RESULTS PAGE</h1>` (line 164), overwritten
by JS to `"<Category> Vendors"` when a category is active.
**Want** Static H1 becomes `DEDICATED RESULTS PAGE`.
**Done when** With no category selected, H1 reads exactly that.

#### DR-02 · The "Back to Home" view belongs on the Search Page ✅
**Doc** DEDICATED RESULTS PAGE (image17) — "Name it Search Page."
**Files** `dedicated-results.html`, `results.html`
**Now** With no `ref` flag this file renders "<Category> Vendors / N Vendors Found /
‹ Back to Home" — screenshotted in the correction doc and annotated "Name it Search
Page". That is the stopgap standing in for the missing `results.html`.
**Want** That view is served by **`results.html`** (`SR-00`), not by this file. This
correction is therefore satisfied by `SR-00` + `SR-09`, not by renaming anything here.
**Done when** Arriving from a homepage category tile lands on `results.html`, titled
Search Results; `dedicated-results.html` no longer serves that entry point.

#### DR-10 · Retire the dual-mode back-link flag ✅
**Doc** Consequence of the §2 flow
**Files** `dedicated-results.html:157-161`
**Now** Back-link defaults to `index.html` / "Back to Home", switching to
`dedicated-search.html` / "Back to Dedicated Selection" only when `?ref=selection` is
present.
**Want** Dedicated Results is reachable only from Dedicated Search, so the back-link is
unconditionally `dedicated-search.html` / "Back to Dedicated Search" (wording per
`DS-05`). The `ref` branch and its inline script go.
**Depends on** `SR-09` — do not remove the fallback while homepage tiles still land here.
**Done when** No `ref=selection` logic remains and the back-link always names Dedicated
Search.

#### DR-03 · "Advanced Search" button → "Change Search" ✅
**Doc** DEDICATED RESULTS PAGE (image16) — "Change button from 'Advanced Search' to
'Change Search'"
**Files** `dedicated-results.html:175`
**Now** `<a class="btn-act btn-adv" href="advanced-search-results.html">…Advanced Search</a>`
**Want** Label `Change Search`. Target and styling unchanged.
**Done when** Button reads "Change Search" in both modes and still reaches Advanced
Search Results.

#### DR-04 · Vendor logos ⛔
**Doc** DEDICATED RESULTS PAGE (image18) — "Need.logos for vendors"
**Files** `dedicated-results.html`, `advanced-search-results.html`, `assets/icons/`
**Now** Vendor cells show name + domain as text, no logo. `assets/icons/` holds 176
cached `.ico` favicons. `logo_url_or_file` reads `"Research Needed"` for all 1,463 rows.
**Want** A logo beside every vendor name, as in the reference.
**Blocker** No logo source. The 863 unenriched rows have **no domain**, so a favicon
cannot even be fetched for them.
**Plan** Extend `build/fetch-icons.ps1` across every row that has a website; fall back
to the existing styled letter-circle otherwise.
**Done when** Every row shows a logo or a letter-circle, none broken; images lazy-load;
row height unchanged.

#### DR-05 · Actions column restructure ✅
**Doc** DEDICATED RESULTS PAGE (image19-22) — "Change action to globe, bookmark with
view profile below… Top Alignment: bookmark icon and globe icon side-by-side at the top…
Bottom Alignment: 'View Profile' directly beneath" *(covers P25, P28, P30, P92-96)*
**Files** `dedicated-results.html`
**Now** Stacked vertically: a navy **View Profile** button on top, a **Visit Website**
outline button with an external-link icon below.
**Want**
```
┌─────────────────┐
│   🌐    🔖      │  ← globe (visit website) + bookmark (save), side by side, top
│  [View Profile] │  ← full-width button, beneath
└─────────────────┘
```
Globe replaces the "Visit Website" text button. Bookmark is new here.
**Done when** Both icons sit side by side above a full-width View Profile button; globe
opens the vendor site in a new tab; bookmark toggles saved state and persists across
reload; both have accessible labels.

#### DR-06 · Remove the row-select checkbox column ✅
**Doc** DEDICATED RESULTS PAGE (image22) — "Remove Checkboxes: Delete the entire
far-left column containing the row selection checkboxes"
**Files** `dedicated-results.html`, `advanced-search-results.html` *(the equivalent on
`results.html` is `SR-05`, where it is a build-time non-event)*
**Now** Both tables open with `<th style="width:2.5%" class="ck">` (3% on Advanced)
holding a select-all checkbox, and a checkbox per row.
**Want** Column gone — header, select-all, and every row cell.
**Scope** Table row-selection only. Sidebar **facet** checkboxes stay — the reference
keeps them.
**Done when** No `.ck` column in either table, widths re-balanced to 100%, and no
orphaned select-all JS.

#### DR-07 · "TRADES SERVED" → "TRADES" ✅
**Doc** DEDICATED RESULTS PAGE (image23) — "Delete 'Served' under Trades"
**Files** `dedicated-results.html`, `vendor-profile.html`
**Now** Column header reads `TRADES SERVED`. `vendor-profile.html` uses the same wording
in its card.
**Want** `TRADES` in both.
**Done when** `grep -ri "trades served"` returns nothing.

#### DR-08 · Reorder to Trades · Divisions · Master Trades ⛔
**Doc** DEDICATED RESULTS PAGE (image24) — "Order: Trades - Divisions - Master Trades.
So, you first have to rename Trades served to trades and then rearrange then in the
mentioned order."
**Files** `dedicated-results.html`
**Now** `… CATEGORIES · DIVISIONS · TRADES SERVED · MASTER TRADES · AVAILABLE ON · ACTIONS`
**Want** `… CATEGORIES · TRADES · DIVISIONS · MASTER TRADES · QUICK FACTS · ACTIONS`
**Depends on** `DR-07` (rename first, then reorder — the doc is explicit about the order
of operations), and D3 for content.
**Consistency** Agrees with `AS-01`: Categories → Trades → Divisions → Master Trades.
`results.html` currently disagrees — see 4.10.
**Done when** Header and every row cell follow the new order with no mismatch.

#### DR-09 · "AVAILABLE ON" → "QUICK FACTS" + sort arrows ✅
**Doc** DEDICATED RESULTS PAGE (image25) — "Change 'Available On' to 'Quick Facts' plus
Up/Down arrows"
**Files** `dedicated-results.html`
**Now** Header `AVAILABLE ON`, no sort control. Cells list Cloud-Based / Mobile App with
a `+1 more` expander.
**Want** Header `QUICK FACTS` with `↑↓`, matching sortable neighbours.
**Note** Aligns with `vendor-profile.html`, which already has a "Quick Facts" card.
Column **content** is unchanged — this is a rename, not a re-spec.
**Done when** Header reads QUICK FACTS with working sort arrows.

---

### 5.7 Vendor

> `vendor-profile.html`

#### V-01 · Facebook and YouTube on every vendor ⛔
**Doc** VENDORS — "FB and Youtube on all of them"
**Files** `vendor-profile.html`
**Now** All eight icons — LinkedIn, Instagram, Facebook, YouTube, TikTok, Houzz,
Pinterest, X — are already hard-coded in `.social-grid` (lines 262-271) and therefore
render on every vendor. **Every `href` is `#`.**
**Reading** Since the icons already appear universally, this is a **data** request: every
vendor needs real Facebook and YouTube URLs.
**Blocker** No social columns in the workbook.
**Done when** Facebook and YouTube resolve to real profiles for every vendor that has
one, and icons for absent profiles are hidden rather than linking nowhere.

#### V-02 · Complete the Contact Information card ⚠️
**Doc** VENDORS — "Include all items in 'Contact Info'"
**Files** `vendor-profile.html`
**Now** Three rows — address (`#ci-addr`), phone (`#ci-phone`), email (`#ci-email`) —
defaulting to `—`. In practice most vendors show country only, "Contact via website",
and a generic `info@<domain>`.
**Want** Per 4.7, populate all three for every vendor.
**Done when** All three carry real values, or the row is hidden when genuinely unknown —
no card shows a bare `—`.

#### V-03 · "Save Vendor" in orange ✅
**Doc** VENDORS (image26) — "'Save Vendor' in Orange"
**Files** `vendor-profile.html`
**Now** `.btn-save{…color:var(--blue)…}` (line 53) — renders `#1B5FD0`.
**Want** `var(--orange)` = `#F26A1B` (page-local palette, §2). Text and bookmark icon
both orange; `currentColor` on the SVG means the colour change carries automatically.
**Done when** Label and icon render `#F26A1B` in default and saved states, with a
distinguishable hover.

---

## 6. Data work

Ordered by what blocks the most corrections.

| # | Task | Status | Unblocks |
|---|---|---|---|
| 1 | Import `..._COMPLETED.xlsx` → `tools-data.js` / `tools.json`, 1,463 rows | ✅ ready | G-01, DS-04, SR-00 |
| 2 | Import the 4-level taxonomy → a new `data/construction-taxonomy.json` | ✅ ready | DS-02, AS-05 |
| 3 | Join the client's classification on `record_id`, with validation below | ⏳ awaiting file | SR-06, AS-01, DS-03, DR-08 |
| 4 | Extend favicon fetch to the 638 rows with a website | ✅ ready | DR-04, SR-00 |
| 5 | Normalise `pricing_model` → Purchase Options; `public_private` → Company Type | ✅ ready | AS-06 |
| 6 | Source Markets Served + Peer Reviewed (**no column exists**) | ⛔ blocked | AS-06 |
| 7 | Source social profile URLs | ⛔ blocked | V-01, H-07 |
| 8 | Source contact details | ⛔ blocked | V-02 |
| 9 | Source the 825 missing websites | ⛔ blocked | DR-04, DR-05 |

Tasks 1, 2, 4 and 5 can start now. **Task 3 is the critical path** — it gates the
"WHAT DO YOU DO?" card and three columns on every results page, and it is now with the
client rather than blocked on an unanswered question.

**Task 3 — validate on import.** The classification arrives as a flat
`record_id | master_trade | primary_trade | cross_trade` file. Check it before trusting it:

- all 1,463 `record_id`s present, each matching an existing row
- `master_trade` ∈ the 11, exact string match
- `primary_trade` ∈ the 50, exact string match
- **`primary_trade` sits under `master_trade`** per `HIERARCHY_4_LEVEL` — the client's own
  integrity rule, and the check most likely to catch real errors
- `cross_trade` ∈ {`Yes`, `No`}
- `division_number` handled as a **string** throughout — `00`–`09` collapse if parsed as
  integers

Report mismatches rather than importing silently. The client wants to review the
classification before the database changes, so a validation report is the natural
artefact to send back.

---

## Appendix A — Master Trade → Division → Trade

**Authoritative. Supplied by the client 2026-08-31** in
`CTD_Master_Trades_Divisions_Trades_Subtrades (1).xlsx`, sheets `MASTER_TRADES`,
`DIVISIONS`, `TRADES`, `SUBTRADES`, `HIERARCHY_4_LEVEL`.

My earlier proposed mapping is deleted — this replaces it entirely. Import the file rather
than transcribing from this table; it is reproduced here for reference only.

| Master Trade | Divisions | Parent Trades |
|---|---|---|
| 1 General Construction & Project Delivery | 00, 01, 02 *(+15–20 reserved)* | Preconstruction & Contracting · General Conditions & Project Services · Existing Conditions & Site Investigation |
| 2 Structural | 03, 04, 05, 06 | Concrete · Masonry · Metals · Carpentry, Plastics & Composites |
| 3 Building Envelope | 07, 08 | Roofing, Waterproofing & Insulation · Doors, Frames, Glazing & Openings |
| 4 Interior Finishes | 09 | Interior Finishes |
| 5 Specialty Building Systems | 10, 11, 12, 13, 14 | Specialties · Building Equipment · Furnishings · Special Construction · Elevators & Conveying Systems |
| 6 Fire & Safety | 21 | Fire Suppression |
| 7 Mechanical | 22, 23 *(+24 reserved)* | Plumbing · HVAC |
| 8 Electrical & Technology | 25, 26, 27, 28 *(+29 reserved)* | Integrated Automation · Electrical · Communications · Electronic Safety & Security |
| 9 Civil & Sitework | 31, 32, 33 *(+30 reserved)* | Earthwork · Exterior Improvements · Utilities |
| 10 Transportation & Infrastructure | 34, 35 *(+36–39 reserved)* | Transportation · Waterway & Marine Construction |
| 11 Industrial & Process / Energy & Power | 40–46, 48 *(+47, 49 reserved)* | Process Integration · Material Processing · Water & Wastewater · Electrical Power Generation |

**Structure notes**

- **50 divisions**, CSI `00`–`49`. Reserved divisions are kept and labelled *Future Scope*
  so numbering stays complete — render them, or filter on `active_flag`, but do not
  renumber.
- **Trade is currently one umbrella per Division** — 50 Trades for 50 Divisions. The real
  granularity is at Subtrade (1,000 records, ~20 per division). If the UI needs Trade to
  be more discriminating than Division, that is a taxonomy question for the client, since
  today the two levels are 1:1.
- **`EXISTING_1000_TRADES`** preserves the original 1,000-row CTD trade taxonomy unchanged,
  in case the earlier flat list is needed for migration.
- Join key is `division_number` (two-digit, zero-padded — keep it a **string**, not an
  integer, or `00`–`09` will collapse).

---

## Appendix B — File inventory

| Page | File | Status | Corrections |
|---|---|---|---|
| Home / Hero | `index.html` | exists | H-01 … H-07, SR-09 |
| Search / Results | `results.html` | **must be created** | SR-00 … SR-06, DR-02 |
| Advanced Search / Results | `advanced-search-results.html` | exists | AS-01 … AS-06, DR-06 |
| Dedicated Search | `dedicated-search.html` | exists | DS-01 … DS-05 |
| Dedicated Results | `dedicated-results.html` | exists | DR-01, DR-03 … DR-10 |
| Vendor | `vendor-profile.html` | exists | V-01 … V-03, DR-07 |
| Hero asset | `assets/ctd/hero_image.jpg` | exists | H-02 |
| Category icons | `assets/logos/*.png` (12) | exists | H-01 |
| Data | `assets/tools-data.js`, `data/*.json` | exists | G-01, §6 |
| Build spec | `specs/search-page-desktop.md`, `-mobile.md` | exists | input to SR-00 |

**Counts:** 41 corrections — 22 ✅ unblocked, 9 ⚠️ assumption-backed, 10 ⛔ blocked on
data or on the missing page.

**Suggested order**

*Phase 1 — ✅ **SHIPPED 2026-09-01**, 17 corrections. Full log and verification in §3.3:*
H-03, H-04, H-05, H-06, H-07, AS-02, AS-03, AS-04, DS-01, DS-05, DR-01, DR-03, DR-05,
DR-06, DR-07, DR-08 *(column reorder only)*, DR-09, V-03.

*Phase 2 — next. Needs §6 tasks 1, 2, 4 (all ready to run):*
G-01, G-02, DS-02, DS-04, DR-04, AS-05 (facet list only),
`SR-00` with the software axis fully live and the construction axis display-only,
then SR-09 and DR-10.

*Phase 3 — blocked on §6 task 3 (vendor → Master Trade / Trade mapping, item 4.15):*
SR-06, AS-01, DS-03, DR-08, and the "WHAT DO YOU DO?" card of SR-00.

*Parallel, independent of all the above:*
H-01 (needs your ruling), H-02 (external regeneration), AS-06 (needs 4.1-4.4),
V-01, V-02 (need source data).
