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

### FC-03, FC-04, FC-05, FC-06, FC-07 — pending
