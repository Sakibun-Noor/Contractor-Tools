# Hierarchy classification import

**Source:** `CTD_Combined_Vendor_Master_1463_HIERARCHY_CLASSIFIED.xlsx`, received 2026-09-01
**Supersedes:** `CTD_Combined_Vendor_Master_1463(1).xlsx`
**Unblocks:** the open dependency in `corrections-2026-08-23.md` §3.2 — "Master Trade / Trade
have no per-vendor column"
**Correction IDs:** `HX-01` … `HX-08`

---

## 1. What the file actually contains

Eighteen sheets. Two of them matter.

**`Combined_Vendors_1463`** — the same 1,463 rows as before, joined on `vendor_row_id`,
plus three new columns: `master_trade`, `primary_trade`, `cross_trade`. No blanks.
**On top of that, the 863 stub rows have been filled in** — category, subcategory,
product names, description, pricing model and company size all went from empty to
populated.

**`Hierarchy_Reference`** — the trade/division lookup. Redundant: the taxonomy workbook we
already import carries the identical mapping, and this copy has mojibake in its twelve
"Future Scope – Division NN" labels. **Read the taxonomy workbook, not this sheet.**

### Validation run before writing a line of code

| Check | Result |
|---|---|
| `primary_trade` values used | 19, **all 19 match `construction-taxonomy.json`** |
| `master_trade` values used | 11, all match |
| Rows where `master_trade` contradicts the taxonomy's own trade → master-trade | **0** |
| `vendor_row_id` unique | yes, 1,463 / 1,463 |
| `record_id` unique | **no — 1,413 distinct.** Join on `vendor_row_id` only. |

---

## 2. What it does not fix

### 2.1 Master Trade is 96% one bucket

| Master Trade | Vendors |
|---|---:|
| General Construction & Project Delivery | **1,400** |
| Civil & Sitework | 21 |
| Structural | 14 |
| Electrical & Technology | 10 |
| Specialty Building Systems | 6 |
| Mechanical | 5 |
| Building Envelope | 4 |
| Interior Finishes · Transportation & Infrastructure · Industrial & Process | 1 each |
| Fire & Safety | **0** |

Trade is nearly as concentrated: `01 – General Conditions & Project Services` (937) plus
`00 – Preconstruction & Contracting` (349) is 88% of the directory.

### 2.2 It was derived from the software category

The QA sheet's own `reason` column reads, verbatim:
`"software category: Project Management; mapped to General Construction & Project Delivery > General Conditions & Project Services"`.

Measured: **85.7% of rows are predictable from `primary_category` alone.** Only ~14%
carries information the Software taxonomy did not already have. This is the axis collapse
ruled out in §3.1 of the master spec — an estimating tool may serve electrical *or*
concrete. The file agrees with itself here: confidence is Medium on 1,289 of 1,463,
`cross_trade = Yes` on 1,403, and its summary sheet states *"Primary = best single home for
filtering; not a claim that the vendor serves only that trade."*

**Decision: import anyway** (client answer, 2026-09-01) and report the numbers to Deryck.
The filter works, it beats a disabled facet stuck at (0), and he gets to decide whether to
reclassify.

### 2.3 The enrichment is structured, not verified

Across all 863 newly filled rows: `public_private` = "Unknown / Verify",
`revenue_status` = "Not Researched / Verify", `free_trial_available` = "Unknown / Verify",
`company_size_served` ends in "/ Verify", `baseline_status` = "Verification Pending".
Descriptions are unique per vendor but generated from 331 templates — 100 of them read
*"&lt;Name&gt; drawings software or technology used in construction and built-environment
workflows."*

### 2.4 Still absent

- **Subtrade.** No per-vendor column. Level 4 of the Construction taxonomy stays unbuilt.
- **`construction_divisions_served`** is still 85% "ALL" — unusable as a filter, since
  nearly every vendor then matches every value. Not the source for the Division facet.

---

## 3. Trade and Division are the same axis

`construction-taxonomy.json` maps trade → division **1:1 across all 50** (50 trades ↔ CSI
divisions 00–49). `Preconstruction & Contracting` *is* Division 00. Shipping both as
separate filters would put two controls in the sidebar that always return the same rows.

**Decision:** merge into **one** facet carrying both vocabularies —
`01 – General Conditions & Project Services`. Deryck's naming, the CSI number the industry
searches by, one sidebar slot instead of two.

### 3.1 That frees the slot the old "Trade" filter was misusing

Today's `tr` field is `trades_served` = `GC, Commercial, Residential, Specialty Trades`.
Those are **not trades** — they are contractor types, and the client's own QA sheet names
that column `current_contractor_types_served`. With a real Trade facet arriving, leaving
this one labelled "Trade" would be actively misleading.

**Rename `tr`'s display label to "Contractor Type".** Filter key, values and behaviour
unchanged — label only.

---

## 4. Fixes

### HX-01 · Point the importer at the new workbook
`build/import-vendors.ps1` `$VendorXlsx` default → the HIERARCHY_CLASSIFIED file. Join key
stays `vendor_row_id`; `record_id` is not unique and must not be used.

### HX-02 · Emit the hierarchy per vendor
Add to each `window.TOOLS` record:

- `mt` — `master_trade` verbatim
- `dv` — the merged label, `divisionNumber + ' – ' + primary_trade`, resolved through
  `construction-taxonomy.json` so the number and the name can never drift apart

Fail the build loudly if a `primary_trade` is missing from the taxonomy — a silent
mismatch is how a facet quietly empties.

### HX-03 · Strip the "/ Verify" workflow suffix
`company_size_served` reaches the UI as `All Sizes / Verify`. That is an internal note, not
a size. Strip the trailing `/ Verify`, which also merges those rows with the plain
`All Sizes` ones already present.

### HX-04 · Real Master Trade and Division facets
`assets/filters.js`: build `masterTrades` from `t.mt` and `divisions` from `t.dv`, and
filter `apply()` on those fields directly. **Delete `DIV_MAP` and `MT_MAP`** — the invented
category → division guesses they held are superseded by real per-vendor data, and `MT_MAP`
still contains two master trades that do not exist in the client's hierarchy ("Mechanical
Trades", "All Master Trades").

### HX-05 · Relabel Trade → Contractor Type
Sidebar heading, selector-card heading, results-table column and chip label. Four pages.
Filter key `tr` unchanged.

### HX-06 · Merge the Division and Trade controls
**Corrected while building.** This was written expecting a taxonomy-Trade control to drop.
There isn't one: every "TRADE" control on the site is fed by `tr` = `trades_served`, which
HX-05 establishes is contractor types. So **no control is removed**. The `div` facet — the
only one carrying the taxonomy — is retitled **TRADE / DIVISION** and its values become
`NN – Trade Name`. After the two renames the three construction facets are distinct:

| Facet | Key | Source |
|---|---|---|
| Master Trade | `mt` | `master_trade` |
| Trade / Division | `div` | `primary_trade` → division via the taxonomy |
| Contractor Type | `tr` | `trades_served` |

### HX-07 · Hide unverified vendor fields
The vendor page must not print `Unknown / Verify` or `Not Researched / Verify` at a reader.
Suppress any field that is empty or matches `/^(unknown|not researched)\b.*verify/i` and
hide the surrounding row entirely — the pattern V-05 already uses for social icons. The
field returns per-vendor the moment a real value lands.

### HX-08 · Divisions cell is now single-valued
AS-11 showed up to 2 divisions then `more…`, reading from the invented `DIV_MAP` which gave
some vendors several. Real data gives each vendor exactly one primary trade, so the cell
shows one value and `more…` never appears. Leave `moreCell(…,2,…)` in place — it costs
nothing and starts working the day a vendor carries more than one.

---

## 5. Acceptance

| # | Check |
|---|---|
| 1 | `tools-data.js` has 1,463 records, every one with a non-empty `mt` and `dv` |
| 2 | Master Trade facet live: 11 entries, General Construction & Project Delivery at 1,400, Fire & Safety at 0 and disabled |
| 3 | Trade/Division facet live: 19 entries with counts, labelled `NN – Trade Name` |
| 4 | Checking a Master Trade narrows the table, and the count matches §2.1 |
| 5 | No page shows two filters that return identical result sets |
| 6 | "Contractor Type" replaces "Trade" as a label on all four pages; `?tr=` URLs still work |
| 7 | No `Verify` or `Not Researched` string is visible anywhere on the site |
| 8 | Company Size facet has no `/ Verify` entries and no duplicate "All Sizes" |
| 9 | 863 previously-blank vendors now show a category, subcategory and description |
| 10 | Every page: fold still equals viewport, no horizontal scroll, no console errors |

---

## 6. To raise with Deryck

1. The Master Trade distribution above, with the `reason` column as evidence that it was
   mapped from software category. His call whether to reclassify.
2. Fire & Safety has zero vendors and will render greyed out.
3. Subtrade is still missing — level 4 cannot be built.
4. The 863 enriched rows are unverified by the file's own status columns. We are hiding
   those fields rather than printing "Verify" at his users.
5. Still open from the previous round: the two divergent filter vocabularies between
   Advanced Search and Dedicated Search (`footer-round-fixes.md` §9).

---

## 7. Build log — 2026-09-01

All eight done. All ten acceptance checks verified in-browser at 1536×864. No console
errors and no horizontal scroll on any of the six pages.

| # | Check | Result |
|---|---|---|
| 1 | 1,463 records, every one with `mt` and `dv` | 1463 / 1463 / 1463 |
| 2 | Master Trade facet live | 11 entries; GC & Project Delivery **1400**, Fire & Safety **0** and disabled |
| 3 | Trade/Division facet live | 35 entries, **19 with vendors**, labelled `NN – Trade Name`; no "Future Scope" rows |
| 4 | Filtering narrows, counts match §2.1 | `mt=Civil & Sitework` → **21**, `Structural` → **14**, `Fire & Safety` → **0**, `div=03 – Concrete` → **9** |
| 5 | No two filters return identical sets | Master Trade / Trade-Division / Contractor Type are three distinct sources |
| 6 | "Contractor Type" replaces "Trade" on four pages | done; `?tr=GC` still returns 982 |
| 7 | No `Verify` / `Not Researched` visible | zero occurrences in `tools-data.js` and on all six pages |
| 8 | Company Size clean | `All Sizes (747)`, `Small / Mid-Market (388)`, `Mid-Market / Enterprise (212)`, `Enterprise (60)`, `Small Business (56)` — no `/ Verify`, no duplicate |
| 9 | 863 blank vendors now populated | e.g. BlueSky → Document Management / Drawings, real description and pricing |
| 10 | Fold, scroll, console | clean on all six |

### Beyond the eight, because the data arrived

- **`results.html`'s left card is live.** "WHAT DO YOU DO?" listed the hierarchy greyed out
  with the note *"Filtering by these isn't live yet."* All three columns now filter, with
  counts. That note is gone.
- **The Master Trade column on `results.html`** was a hardcoded `—`. It renders the real
  value, and the divisions cell moved to `moreCell(…, 2, …)` to match AS-11.
- **`pricing_model` is real** for all 1,463, so the vendor page stopped deriving pricing
  from company size.
- **Free Trial no longer asserts "Yes" at every vendor.** The page printed "Free Trial: Yes"
  for all 1,463 while the workbook only knows for 61 (39 Yes, 22 No). The row now hides on
  the other 1,402.
- **The vendor page's Divisions card stopped padding itself** from a hardcoded list of
  twelve, which claimed every vendor served Concrete through Conveying Equipment.

### One bug worth recording

The free-trial branch first matched **zero** "No" rows. The regex had been written as
`'^No'`, and `` was consumed as a literal backspace character before it reached the
file — `^No<BS>` matches nothing. Visible only under `cat -A`. Fixed to `'^No'`.

### Left alone, deliberately

`vendor-profile.html`'s **Key Products**, **Subcategories** and **Categories** cards are
still padded with invented filler (`'Digital Takeoff'`, `'BIM & Design Coordination'`, and
product names built by concatenation). Same class of problem as the Divisions card, but
outside this import: fixing them is a design decision about what those cards should show
when a vendor has one real value, and that is Deryck's call, not a silent rewrite. Raised
in §6.

---

## 8. HX-09 · Correction — `CTD_Construction_Hierarchy_VALIDATED_4_LEVEL.xlsx`

**Source:** received 2026-09-02, in reply to §6 of this spec.

This file corrects two things §2 and §3 got from the client's own prior workbook.

### 8.1 The Master Trade grouping was wrong — 11 names replaced with 12, validated

The old `master_trade` column (used throughout §1–§7) is superseded. This workbook's
`DEVELOPER_NOTES` sheet, Rule 6: *"The former 1,000 synthetic Trade rows must not be
imported into production."* — confirming the old taxonomy workbook's Trade/Subtrade
sheets (1,000 rows, 20 per division) were invented, not sourced. The 12 Master Trades are
now the validated list:

| Old (11) | New (12) |
|---|---|
| General Construction & Project Delivery | **General Construction** |
| Structural | Structural |
| Building Envelope | Building Envelope |
| Interior Finishes | **Interiors** |
| Specialty Building Systems | **Specialties & Equipment** |
| Fire & Safety | **Fire Protection** |
| Mechanical | **split →** Plumbing (div 22) / HVAC & Mechanical (div 23–24) |
| Electrical & Technology | **split →** Electrical (div 25–26) / Communications & Security (div 27–29) |
| Civil & Sitework | Civil & Sitework |
| Transportation & Infrastructure | **merged →** Infrastructure & Industrial |
| Industrial & Process / Energy & Power | **merged →** Infrastructure & Industrial |

**Fix:** `mt` is no longer read from the vendor workbook's `master_trade` column at all.
It's recomputed from the vendor's own division number (already known and unaffected by
this correction) against this workbook's `DIVISIONS` sheet, which maps every one of the
50 divisions to exactly one of the 12 Master Trades. This sidesteps the two-way splits
entirely — division 22 is unambiguously Plumbing, division 26 unambiguously Electrical —
without touching or re-trusting the vendor file's own (now-superseded) column.

### 8.2 "Trade / Division" was never really Trade

This workbook's `DEVELOPER_NOTES` Rule 1: *"Do not treat Division and Trade as the same
field."* Real Trade is a narrower published MasterFormat Section below the division root
(example: `31 23 00 – Excavation and Fill`, beneath Division `31 00 00 – Earthwork`) and
needs a licensed CSI dataset this workbook explicitly does not include in bulk — commercial
reproduction of MasterFormat numbers/titles requires a CSI license. Only 20 verified
example Trade/Subtrade pairs are provided, covering roughly a third of the divisions — not
a usable per-vendor facet.

What §3 built as "Trade / Division" was, honestly, Division the whole time: the vendor
file's `primary_trade` values matched the old taxonomy's synthetic 50-row list 1:1 with
division number, so at vendor granularity there never was a level below Division.

**Fix:** the facet is relabelled **DIVISION** everywhere (sidebar, selector card, table
column, chips, vendor-page card, `FILTER_LABELS`/`LABELS` dictionaries). Filter key `div`
and behaviour are unchanged. `dv`'s label now comes from this workbook's official CSI
division name (e.g. `01 – General Requirements`) rather than the old taxonomy's
CTD-styled per-division synonym (`01 – General Conditions & Project Services`) — one
source of truth instead of two.

### 8.3 What's still needed

Confirmed by this workbook, not resolved by it: real Trade and Subtrade (levels 3–4)
require either a licensed MasterFormat 2026 dataset from CSI, or a decision to launch with
Division-level granularity only. Put to the client in §6.

### Build log

`build/import-vendors.ps1` gains `$HierarchyXlsx` (default alongside `$VendorXlsx` on
Desktop/CTD). `$TaxonomyXlsx`'s old MASTER_TRADES/DIVISIONS/SUBTRADES sheets are no longer
read; only its `TRADES` sheet survives, and only to look up which division number a
vendor's `primary_trade` string belongs to — arithmetic, not vocabulary, and never exposed
to the site. `data/construction-taxonomy.json` / `assets/taxonomy-data.js` drop `trades`
and `subtrades` entirely; `masterTrades` (12) and `divisions` (50) now come from the
validated workbook.

Verified in-browser at 1536×864: `mt=Electrical` → 9, `HVAC & Mechanical` → 4,
`Plumbing` → 1, `Communications & Security` → 1, `Infrastructure & Industrial` → 2 (sum of
the two merged old groups). `Fire Protection` → 0, correctly disabled. All 12 Master
Trades and division labels render correctly on `advanced-search-results.html`,
`results.html`, `dedicated-search.html`, `dedicated-results.html`, `vendor-profile.html`.
No "Verify" string, no console errors, no horizontal scroll. One JS-generated "view more
trades" link (unrelated to the static-HTML relabelling, driven by `SB_FACETS` in
`advanced-search-results.html`) was caught in testing and fixed to "view more contractor
types".
