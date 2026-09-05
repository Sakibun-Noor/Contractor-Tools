# 09.05.26 Final Corrections — taxonomy relabel, footer, and display changes

**Source:** `09.04.26B Corrections.docx` (2026-09-04) + `09.05.26 Final Corrections.docx`
(2026-09-05, Deryck's point-by-point answers to the open questions) + WhatsApp
follow-up resolving the last one ("replicate the category page").
**Status:** every item below is confirmed — Deryck estimated 5-6 hours and said
"Please Proceed." Nothing is blocked.
**Scope:** everything from the 09.04.26B doc *except* the items already shipped as
quick fixes (`specs/corrections-2026-09-04.md`, QC-01..07) and except the Vendor Page
template (explicitly deferred by the client).
**Correction IDs:** `FC-01` … `FC-08`

---

## 1. FC-01 · Taxonomy relabel, sitewide

**Rename:** `Master Trade(s)` → **Major Groups**, `Division` → **Divisions of Work**,
`Contractor Type(s)` → **Construction Trades**. Filter keys (`mt`, `div`, `tr`),
URL params, and underlying data values are **unchanged** — label text only, same
rule as HX-05 in `hierarchy-import.md`.

**Confirmed by audit — every literal string that needs to change:**

| Page | Static HTML labels (sidebar `<h3>`, table `<th>`, sel-card headers) | JS label dictionaries |
|---|---|---|
| `results.html` | lines ~278, 283, 288, 335-337, 390, 534 | none (chips render from a different path — verify in build) |
| `advanced-search-results.html` | lines ~236-262, 362, 404, 573, 774 | `FILTER_LABELS` (line 573): `tr:'Contractor Type', div:'Division', mt:'Master Trade'` |
| `dedicated-search.html` | lines ~283-308, 347, 414, 472 | `LABELS` (line 472): same three keys |
| `dedicated-results.html` | lines ~206-208, 250, 323, 521 | `FILTER_LABELS` (line 323): same three keys |
| `vendor-profile.html` | lines ~105, 305-307, 382, 634-635 | none found |
| `assets/filters.js` | comment references only (line 64, 90) — **values themselves need no change**, they're already the real taxonomy names (e.g. `"General Construction"`, `"01 – General Requirements"`); only the axis heading text changes | — |

Also check: "View all master trades ›" / "View all divisions ›" / "View all
contractor types ›" link text (results.html, ~line 279-289 area) and the footer's
"Master Trades" link (FC-02 renames this to "Major Groups" directly).

**Order matters within this item:** update the 3 `FILTER_LABELS`/`LABELS` JS objects
and the static headers/chips/links together per page, so a page is never left with
old labels in the sidebar but new ones in the filter chips (or vice versa).

## 2. FC-02 · Footer restructure — 5 sections

Current footer (`index.html`, and confirm it's shared markup or duplicated per page)
is 6 columns: brand, Company, Directory, Resources, Site Info, Follow Us.

**New structure**, per the client's table (exact cell mapping, confirmed from the
docx's own table, not just running text):

| COMPANY | DIRECTORY | RESOURCES | EXPLORE | SITE INFO |
|---|---|---|---|---|
| About Us | Categories | Technology Guides | Find | Privacy Policy |
| Contact Us | Products | Learn | Search | Terms of Use |
| Add / Modify Info | Major Groups | FAQ | Research | Site Map |
| Marketing | Trades | Glossary | Insights | Disclaimer |

Client's stated purpose: **free up vertical height** for more content in the upper
sections — so this is also a spacing/height task, not just relabeling columns.
"Follow Us" (social icons) isn't mentioned in his table; not asked to remove it —
keep it, confirm placement (likely as-is, alongside or below the 5 sections) rather
than guessing it should disappear.

`Find` keeps its existing link (`results.html`, was under "Resources"); `Search` is
new — points to `dedicated-search.html`. Everything else without an obvious existing
target stays `href="#"` like the rest of the current footer (none of the current
footer links go anywhere real except Find/Categories/logo).

## 3. FC-03 · New orange "About the Vendor" / "About the Customers" bars

Per the client's reference image (`specs/` — not stored, was inline in his docx):
a thin orange bar sits **above** each group of 3 filter-facet headings, spanning
exactly that group's width, bold white centered label inside.

- **"ABOUT THE VENDOR"** over: Products, Subcategories, Categories
- **"ABOUT THE CUSTOMERS"** over: Construction Trades, Divisions of Work, Major Groups

Note the column **order** in his mockup — Products first, then Subcategories, then
Categories (software axis), then Construction Trades, Divisions of Work, Major
Groups (construction axis). Confirm this matches (or deliberately reorders) each
page's current facet order before shipping — don't silently keep the old order under
a new bar if his mockup implies a swap.

Applies wherever these 6 facets appear as a group: `dedicated-search.html`'s
selector-grid is the clearest fit (6 `sel-card`s in a row already). Check
`results.html`'s two-question panel and `advanced-search-results.html`'s sidebar for
the same treatment — his doc says "multiple pages."

Client's own note: *"I can't get the alignment right on the orange bars"* — the bar's
width must track its group's width exactly (a `<div>` spanning `grid-column: span 3`
inside the same grid the facet cards use, not a separately-sized element guessed to
line up).

## 4. FC-04 · Multiple items per vendor, with "more…"

Show more than one Product / Subcategory / Trade / Division per vendor where the
data has more than one, truncate with a **"more…"** link (light blue, per the
original doc) once space runs out. **Exception:** Dedicated Search Page uses a
**scrollbar** instead of "more…" — it's the last search page before results, per the
client.

**Don't build this from scratch** — `dedicated-results.html` already has a
`moreCell(items, shown, formatItem)` helper (line ~411) doing exactly this pattern
for its Division/Contractor Type/Master Trade cells. Reuse or port that helper
wherever this is needed on `results.html` and `advanced-search-results.html`
(neither currently has it — their cells show one value with `text-overflow:ellipsis`,
not a "more…" expansion).

Vendor-profile.html's Key Products / Subcategories / Categories cards are explicitly
**out of scope** here — flagged separately in `hierarchy-import.md` §6 as invented
filler data, Vendor Page is deferred anyway.

## 5. FC-05 · Advanced Search / Results fixes

- **Move Company Size into Advanced Filters.** Currently in the left `.sidebar`
  (`advanced-search-results.html` line ~275, `<h3>COMPANY SIZE</h3>`) as its own
  facet block; `dedicated-search.html` already has Company Size *inside* its
  Advanced Filters panel (client's own screenshot of that page confirmed this,
  from the 09.04.26B analysis) — copy that pattern here.
- **Add the missing Description column.** The data (`t.x`) and its label already
  exist — it's in the CSV export column list (line ~770, `{label:'Description',
  get:function(t){return t.x;}}`) but never rendered in the visible table (`<th>`
  list at lines 357-363 has none). Add a `<th>DESCRIPTION</th>` + matching `<td>`
  and rebalance the `width:%` values (currently sum to exactly 100% across 7
  columns — adding an 8th needs the split redone, not just tacked onto the end).
- **Add "more…" to results** — see FC-04, same table.
- **Align left/center content edges.** Client's literal words: "make the horizontal
  endpoints the same for the left and center content" — the sidebar (`.sidebar`)
  and the main results column currently don't share a consistent right/left edge
  with the Advanced Filters panel above the table. Check in-browser at build time;
  likely a `max-width`/`margin` mismatch between `.sidebar` and `.af-panel`/table.

## 6. FC-06 · Dedicated Results — scrolling list, no data headers

- **Scrolling list**, same rationale as FC-04's Dedicated Search exception: it's
  heading toward the Vendor Page next, so show everything rather than paginating
  facts.
- **Drop the data headers.** Client's original wording (09.04.26B): *"No need to put
  data headers e.g. cloud based. Just list the items below each of these (in a
  scroll bar)."* Audited the current QUICK FACTS cell (`dedicated-results.html`
  line ~463): it already renders bare bulleted items (`Cloud-Based`, etc.) with
  **no bold header line above them** in the table cell itself — that part may
  already satisfy the request as written. The place that *does* show a bold
  section header above a plain list is `vendor-profile.html`'s "AVAILABLE ON" card
  — which is Vendor Page, deferred. **Verify against the live build before
  concluding no work is needed here** — don't assume the audit above is still
  accurate once FC-01..05 have changed the page.

## 7. FC-07 · AI logo icon → click-through

The homepage hero (`index.html` `.hero-band`) is a single flat raster image
(`assets/ctd/hero_image.jpg`) — the "AI" brain graphic the client means is baked
into the photo, not a separate DOM element. Making "the AI part of the image"
clickable means an absolutely-positioned transparent `<a href="results.html?cat=
ai-automation">` overlaid on `.hero-band`, sized/positioned in **percentages** of
the hero box (so it tracks the hero across every viewport width, matching how the
rest of the hero is built) rather than fixed pixels. Position/size the overlay by
inspecting where the AI bubble sits in `hero_image.jpg` (roughly centre-right,
~55-65% across, ~20-90% down — confirm exactly against the actual file before
shipping, don't eyeball it into the spec).

## 8. FC-08 · Page-identity / order check

Client's ask, now fully resolved via WhatsApp: when he clicks a homepage category
tile he lands on `results.html`, and needs it to be unambiguous which of the three
search-result-type pages he's on. **Partially already done** — `corrections-2026-
09-04.md` QC-01 renamed the `results.html` header to "SEARCH / RESULTS". This item
is the sitewide sweep to make sure the same is true everywhere:

- Verify each page's H1/header clearly states its own identity: Search / Results,
  Advanced Search / Results, Dedicated Search, Dedicated Results (Vendor Page
  deferred).
- Verify the click-through sequence actually flows Home → Search/Results →
  Advanced Search/Results → Dedicated Search → Dedicated Results → Vendor, per the
  client's explicit ordering, and that every "back" / "change search" / breadcrumb
  link matches that sequence (this is also where the QC-05 "Change Search" bug came
  from — check for siblings of that same mistake).

---

## 2. Decisions

1. **Labels only, never data.** FC-01 renames text a user reads; it must not touch
   filter keys, URL params, or the underlying vendor data. Same rule as every prior
   taxonomy round (HX-05/HX-06).
2. **Reuse `moreCell()` rather than re-inventing "more…"** (FC-04) — it already
   exists, is tested, and keeps behaviour consistent across pages.
3. **Re-audit FC-06 in-browser at build time**, not from this spec's notes alone —
   the codebase will have moved by the time it's built (FC-01 through FC-05 touch
   the same pages).
4. **FC-07's overlay is percentage-positioned**, not pixel-positioned, consistent
   with how the rest of the hero band is built (`aspect-ratio` sizing, no fixed
   heights) — a fixed-pixel hotspot would drift off the AI graphic at any width
   other than the one it was measured at.

## 3. Suggested build order

Smallest/most independent first, so partial progress is always shippable:

1. FC-08 (page-identity sweep) — mostly text, low risk, fast to verify
2. FC-02 (footer) — self-contained, one file (or shared partial) per page
3. FC-01 (taxonomy relabel) — mechanical but touches every page; do this before
   FC-03/FC-05 so the new bars/columns are built against the final label text
4. FC-03 (orange bars) — depends on FC-01's final facet order/labels
5. FC-05 (Advanced Search fixes) — Description column, Company Size move, alignment
6. FC-04 (more… display) — spans results.html + advanced-search-results.html
7. FC-06 (Dedicated Results) — re-audit first, may be partially done already
8. FC-07 (AI hero click-through) — independent, can slot in anywhere

## 4. Acceptance

| # | Check |
|---|---|
| 1 | No page shows "Master Trade," "Division," or "Contractor Type" anywhere — labels, chips, headers, footer, "view all" links |
| 2 | Filter keys (`mt`, `div`, `tr`) and `?mt=`/`?div=`/`?tr=` URLs still work exactly as before |
| 3 | Footer shows 5 sections with the client's exact link list on every page it appears on |
| 4 | Orange bars present, correctly widthed to their facet group, on every page with the 6-facet layout |
| 5 | A vendor with 3+ products/subcategories/trades/divisions shows more than one, with "more…" past the cutoff — except Dedicated Search, which scrolls |
| 6 | Advanced Search Results: Description column visible, Company Size in Advanced Filters not the sidebar, left/center edges aligned |
| 7 | Dedicated Results: scrollable, re-verified against the live build for the "data headers" question |
| 8 | Clicking the AI graphic in the homepage hero navigates to the AI & Automation category, at 3+ viewport widths |
| 9 | Every one of the 5 non-vendor pages states its own identity clearly; the click-through order matches Home → Search/Results → Advanced Search/Results → Dedicated Search → Dedicated Results |
| 10 | No new horizontal scroll, no console errors, landscape sizes only (per [[ctd-landscape-only-scope]]) |

---

## 5. Build log

### FC-08 · 2026-09-05

- `results.html` H1 → "SEARCH / RESULTS PAGE"; `advanced-search-results.html` H1 →
  "ADVANCED SEARCH / RESULTS PAGE" and its back-link → "Back to Search / Results";
  `dedicated-search.html` back-link → "Back to Advanced Search / Results".
  `dedicated-search.html` / `dedicated-results.html` H1s already matched the
  client's list.
- **The real cause of the "I didn't know where I was" complaint:**
  `dedicated-results.html` overwrote its `<h1>` with a contextual label
  ("Accounting & Payroll Vendors" / "Search Results: <q>") on every filter change —
  losing the page's own name. Fixed: `.phead` now stays "DEDICATED RESULTS PAGE"
  permanently; the contextual label moved to a new `.psub` subtitle line
  (`#page-sub`, hidden when empty). `CTD_saveSearch` re-pointed at the subtitle
  text so saved searches keep a meaningful name.
- Flow order verified: every back-link and forward button already follows Home →
  Search/Results → Advanced Search/Results → Dedicated Search → Dedicated Results
  (QC-05 fixed the one exception last round). No siblings of that bug found.
- In-browser at 1536×864: all four page identities correct, dedicated-results keeps
  its name with an "Accounting & Payroll vendors" subtitle under it, no horizontal
  scroll, no new console errors.

### FC-02 · 2026-09-05

Footer restructured on all 6 pages (5 with `class="site-footer"` + shared
`ctd-chrome.css`; `index.html` with Tailwind). Old 4-section body → the client's
5 sections, exact link list from the docx table:

| COMPANY | DIRECTORY | RESOURCES | EXPLORE | SITE INFO |
|---|---|---|---|---|
| About Us | Categories | Technology Guides | Find | Privacy Policy |
| Contact Us | Products | Learn | Search | Terms of Use |
| Add / Modify Info | Major Groups | FAQ | Research | Site Map |
| Marketing | Trades | Glossary | Insights | Disclaimer |

- "Marketing Opportunities" → "Marketing"; "Master Trades" → "Major Groups" (the
  footer instance of the FC-01 relabel, done early since it's isolated here); the
  old inline "FAQ / Glossary" line split into two normal links under RESOURCES.
- `Find` keeps `results.html`; `Search` is new → `dedicated-search.html`;
  everything else stays `href="#"` (matches the rest of the placeholder footer).
- Grid widened 6 → 7 tracks (brand + 5 sections + Follow Us). `ctd-chrome.css`
  `.site-footer__inner` updated in all 3 breakpoints; `index.html` `grid-cols-6` →
  `grid-cols-7` with `.grid-cols-7` added to `tailwind-fallback.css` (cache query
  bumped) so the no-CDN path stays correct — verified.
- Every column now has exactly 4 links (was up to 6 in Resources), so the footer
  content block is ~1-2 rows shorter — the vertical space the client asked for.
  Measured `.site-footer` height on `results.html`: 158px.
- Follow Us (social icons) kept — not mentioned for removal in the client's table.
- In-browser: 7 columns on every page, correct links, no horizontal scroll, fallback
  path renders identically.

### FC-01 · 2026-09-05

`Master Trade(s)` → **Major Groups**, `Division` → **Divisions of Work**,
`Contractor Type(s)` → **Construction Trades** — label text only. Filter keys
(`mt` / `div` / `tr`) and `?mt=` / `?div=` / `?tr=` URLs unchanged and verified
still working (chips render the new label from an old-key URL).

Every occurrence changed, by page:

| Page | What changed |
|---|---|
| `results.html` | two-question panel `<h3>` ×3, "View all …" links ×3, the `aria-label` on the panel search box, table `<th>` ×3, the `CHIP_LABEL` JS object, two stale comments corrected |
| `advanced-search-results.html` | sidebar `<h3>` ×3 + their HTML comments + static "view more …" placeholder links, `SB_FACETS` nouns (drive the dynamic "view more …" links), table `<th>` ×2, `FILTER_LABELS`, CSV export column labels ×2 |
| `dedicated-search.html` | 3 `sel-card` `<h3>` + `aria-label` + search `placeholder` + "Clear …" button ×3 each, `LABELS` JS object, one stale comment corrected |
| `dedicated-results.html` | table `<th>` ×3, `FILTER_LABELS`, CSV export column labels ×3 |
| `vendor-profile.html` | info-card `<div class="lcard-hd">` ×3, CSV export column labels ×3, one comment |
| `assets/filters.js` | one section-header comment (no functional change) |

In-browser, all 5 pages at 1536×864: every heading, chip, table column, "view
all/more" link and Clear button shows the new label; `?mt=General Construction`
→ chip "Major Groups: General Construction", `?tr=GC` → "Construction Trades:
GC", `?div=03 – Concrete` → "Divisions of Work: 03 – Concrete", each filtering
correctly. No horizontal scroll, no new console errors. Minor: on
`dedicated-search.html`'s narrow selector cards, "CONSTRUCTION TRADES" and
"DIVISIONS OF WORK" wrap to two lines in the card header — readable, the sort
button stays in place; can be tightened with a smaller header font if the
client wants one line.

### FC-03 · 2026-09-05

Orange grouping bars added, per the client's mockup ("ABOUT THE VENDOR" over
Products/Subcategories/Categories, "ABOUT THE CUSTOMERS" over the construction
facets). Implemented three ways to fit each page's existing layout:

- **`dedicated-search.html`** — the exact mockup layout (6 cards in a row). Two
  `.sel-group-bar` divs added as the first children of `.selector-grid`, each
  `grid-column: span 3`, so they sit in the *same grid* as the cards and can't
  drift out of alignment (the client's stated pain point). Verified: both bars'
  left/right edges match their 3 cards to the pixel (0 px diff). Column order
  here already matched the mockup (Product, Subcategory, Category | Construction
  Trades, Divisions of Work, Major Groups) - not reordered.
- **`results.html`** — the two-question panel is two side-by-side cards. Two
  `.q-group-bar` divs added to `.qgrid` (also a 2-col grid), one per panel:
  "About the Customers" over "WHAT DO YOU DO?" (construction axis), "About the
  Vendor" over "WHAT ARE YOU LOOKING FOR?" (software axis). The existing
  question headers stay below the bars.
- **`advanced-search-results.html`** — the facets are a vertical sidebar list,
  so the horizontal "bar over 3 columns" becomes a `.sb-group` section header:
  "About the Vendor" before Categories, "About the Customers" before Major
  Groups.

In-browser at 1280×720 / 1536×864: bars render, aligned, no horizontal scroll,
no new console errors, pages still fit the fold.

**Open, for the client to confirm:**
- Column *order* - the pages disagree today (dedicated-search has Product first
  per the mockup; the advanced-search sidebar and the nomenclature list have
  Categories first). FC-03 added the bars without reordering. If he wants one
  consistent order, that's a quick follow-up.
- On `advanced-search-results.html`, "About the Customers" currently also sits
  above the Company Size card (last in the sidebar). FC-05 moves Company Size
  into the Advanced Filters panel, which resolves this.

### FC-05 · 2026-09-05

All on `advanced-search-results.html`.

- **Company Size → Advanced Filters panel.** Removed the `sb-card sb-sz` from
  the sidebar and its `SB_FACETS` entry; added a `COMPANY SIZE` `af-grp` in the
  panel's 3rd column under Markets Served, populated by
  `renderAfList(#af-size, vocab.sizes, 'sz')` (same path Available On uses -
  real, live data). Filter key `sz` unchanged: verified clicking a box filters
  (1,463 → 60 for Enterprise), the chip reads "Company Size: Enterprise", and
  `?sz=Enterprise` in the URL pre-checks the box on load. The sidebar's
  "About the Customers" group now cleanly brackets exactly its 3 facets (this
  was the FC-03 open item).
- **Description column added** to the results table, 2nd column after Vendors,
  16% width, `class="desc-cell"` (one line, ellipsis, full text in `title=`).
  Column widths rebalanced (still sum to 100), `colspan` on the empty-state
  rows bumped 7 → 8, `table.res min-width` 900 → 960 (both the base rule and
  the ≤999px one) so 8 columns don't wrap; verified no internal table scroll
  at 1280 wide and none page-level at 1536.
- **"more…" on results** - already present. `advanced-search-results.html`'s
  render loop already wraps the Categories / Divisions / Major-Groups cells in
  the shared `moreCell()` helper (shows N, then "+X more…"). It rarely triggers
  for Divisions / Major Groups because each vendor carries exactly one value
  (data, not a code gap); it does trigger for Categories. No change needed.
  Deryck's note "…which will lead to Dedicated Search Page" - if he wants the
  "more…" to *link out to* Dedicated Search rather than expand in place, that's
  a small follow-up; flagging.
- **Left / centre alignment** - `.sidebar` padding changed `12px 0` →
  `8px 0 6px` to match `.main-col`'s vertical padding, so the two columns'
  top and bottom edges line up ("horizontal endpoints the same"). The phrase
  is genuinely ambiguous without his annotated screenshot - if he meant the
  left/right insets instead, quick follow-up.

In-browser at 1536×864 and 1280×620: Company Size filters from the panel,
Description column renders, no horizontal scroll (page or table), no console
errors.

### FC-04 · 2026-09-05

The "show N, then a light-blue 'more…'" pattern the client asked for was
**already built** on all three results pages via a shared `moreCell()` helper -
applied to every cell that can hold multiple values:

| Field | Data shape | "more…" applies? |
|---|---|---|
| Categories (`t.c`) | array | yes - shows 1, then "+N more…" |
| Construction Trades (`t.tr`) | array (STACK has 4: GC / Commercial / Residential / Specialty Trades) | yes |
| Divisions of Work (`t.dv`) | single value per vendor (HX-04) | no - nothing to expand |
| Major Groups (`t.mt`) | single value | no |
| Products / Subcategories (`t.sub`) | **single value** - the dataset has no product field; "Product" is `t.sub + ' Software'` | no |

So the honest state: "more…" fires for Categories and Construction Trades and
correctly does not for the rest, because each vendor carries exactly one of
them in the data.

**Polish applied this round:**
- `.more` restyled to a genuine **light blue** (`#4C9BE0`, was `--vlink`
  #1C57B8 italic) and given a hover underline - on all three pages, per the
  client's "more… in light blue".
- `results.html`'s `moreCell` brought in line with the other two: shows the
  count ("+3 more…" not just "more…") and gains a "show less" toggle.

Verified in-browser: at `results.html?cat=estimating-takeoff`, STACK's
Construction Trades cell shows "GC  +3 more…" in light blue; clicking expands
to all four with "show less", clicking that collapses. Same on
`dedicated-results.html`. No console errors, no horizontal scroll.

**To raise with the client:** "more than one software product for each vendor"
is not possible from the current data - there is one subcategory value per
vendor and no product list. He offered to help on the spreadsheet; a real
`products` column (a few per vendor) would make Products a true "more…" cell.

### FC-06 · 2026-09-05

`dedicated-results.html` only - the last list before the Vendor Page.

- **Scrolling cells instead of "more…".** The five multi-value cells
  (Key Products, Categories, Construction Trades, Divisions of Work, Major
  Groups) and the Quick Facts / Available-On cell now render **every** value
  inside a `div.cell-scroll` (`max-height: 46px; overflow-y: auto`, thin
  scrollbar) rather than showing one value + "+N more…". A vendor with ≤ ~4
  values sees them all with no scrollbar; a longer list scrolls in place.
  Verified: STACK's Construction Trades cell shows all of GC / Commercial /
  Residential / Specialty Trades; no "more…" link anywhere on the page.
- Removed the now-dead `moreCell` / `MORE_STORE` / `CTD_toggleMore` /
  `CTD_collapseMore` helpers and the `.more` CSS from this page (they stay on
  `results.html` and `advanced-search-results.html`, which still use "more…").
- **"Drop the data headers e.g. cloud based"** - audited: the current
  `dedicated-results.html` has **no per-cell data headers**. Available On
  renders bare items ("Cloud-Based", "Web Access", …) with no label prefix,
  and there was never a "Cloud Based" heading. The only place a bold section
  header sits above such a list is `vendor-profile.html`'s "AVAILABLE ON" card
  - which is the deferred Vendor Page. So this part is either already
  satisfied here or was about the vendor page; **flagged for the client** to
  point at a screenshot if something still reads as a stray header.

Verified at 1536×864 and 1280×620: cells list all values, page + table have
no horizontal scroll, the table body still scrolls vertically within its box,
pagination visible, FC-08 header/subtitle intact, no console errors.

### FC-07 — pending
