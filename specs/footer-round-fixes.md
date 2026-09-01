# FOOTER round — 12 fixes

**Source:** `FOOTER.docx`, 2026-09-01
**Correction IDs:** `F-01`, `H-09`, `SR-12`, `AS-09`–`AS-11`, `DS-06`, `DR-11`, `V-05`–`V-08`

---

## 1. Footer

### F-01 · `FAQ · Glossary` → `FAQ / Glossary`
**Doc** "FAQ / GLOSSARY - write in this way"
**Now** Renders `FAQ · Glossary` (middot separator).
**Do** Swap the middot for a forward slash. All six pages.
**Note** Keeping Title Case, not all-caps — every sibling link in that column
("Technology Guides", "Privacy Policy") is Title Case, and the note's caps read as the
doc's own heading style. One-line change if he wants literal caps.

---

## 2. Home page

### H-09 · Category band → the 4th swatch
**Doc** "Need lighter shade of blue background behind categories. Choose the 4th one."
**Now** `#A8CEEE → #C4DEF4`.
**Do** The image is the four-way comparison from 2026-09-01: 1 `#071536`, 2 `#0F2E63`,
3 `#A8CEEE` (current), **4 `#DCEEFB`**. Revert to the original
`from-[#DCEEFB] to-[#E9F5FD]`.
**Note** This reverses the earlier "make it more dark blue" request. Doing exactly as
asked; flagged so nobody is surprised.

---

## 3. Search Results

### SR-12 · Add a Back to Home link
**Doc** "No Back to Home Page link like other page."
**Now** `results.html` has no `.back-link`; every other page in the flow has one.
**Do** Add `‹ Back to Home` → `index.html`, styled and positioned as on the other pages.
It sits in the title row, so it must not cost the table any height.

---

## 4. Advanced Search

### AS-09 · Remove the `#` column
**Doc** "Remove # column from all the pages where it exists because we need space."
**Now** Present on `advanced-search-results.html`, `dedicated-results.html`, `results.html`.
**Do** Drop the header and cell from all three, rebalance widths to 100%, fix `colspan`.

### AS-10 · Actions → globe + bookmark above View Profile
**Doc** "View Profile goes beneath Bookmark and Globe like we did in the search page."
**Now** Advanced Search still renders a single inline row.
**Do** Reuse the `.act-row` + `.btn-vp` pattern already on `results.html` and
`dedicated-results.html`, including the bookmark toggle.

### AS-11 · Show more than one division per row
**Doc** "Need to show more than 1 division, when more than one can be shown"
**Now** `moreCell(divs, 1, …)` — one value plus `more…`.
**Do** Show up to 2, then `more…`. Two fits the row height; three would push it.

---

## 5. Dedicated Search

### DS-06 · Advanced Filters panel, no scroll
**Doc** "Filters missing… add advanced filters… I don't want scroll in advanced filters
section. Make it like the reference image. You will only change the advanced filter
section of dedicated search page."
**Now** 2 groups (Company Size, Available On) in a fixed-height box that scrolls and
visibly clips its third row.
**Do** Five groups in one row, per that page's own reference:

| # | Group | Options |
|---|---|---|
| 1 | Evaluation Options | Peer Web Research · Demos Available · Peer Reviews |
| 2 | Company Type | Public Company · Private Company |
| 3 | Markets Served | 10, in **two internal sub-columns** so the group stays short |
| 4 | Purchase Options | Subscription · One-Time Purchase · Contract Or Quote |
| 5 | Available On | Web Browser · Mobile App · Desktop Software |

Markets Served: Col/Varsity Sports · Commercial · Education · Energy / Utilities ·
Government / Public Sector · Healthcare · Nonprofit · Manufacturing · Residential ·
Retail / Hospitality.

Remove the internal scroll — `max-height` off, `overflow` visible.

> ⚠️ **These labels differ from the Advanced Search page reference**, which had
> Free Trial / Freemium, Demo on Available, Peer Reviewed, Contract Per Quarter, and a
> different Markets list. Two pages will show two different filter vocabularies. Building
> to the instruction ("only change the dedicated search page"), but this should be
> reconciled — see §7.

---

## 6. Dedicated Results

### DR-11 · "Says 1 to 10 but only 6 showing"
**Doc** "Need 10 Search Results / Page. It says 1 to 10 but only 6 results showing."
**Cause** Confirmed bug, not a setting. `.tscroll` is `overflow-y:hidden`, so rows that
don't fit are rendered but **unreachable** — no scrollbar, no way to get to them. Ten are
in the DOM; on a shorter viewport only six are visible.
**Do** `overflow:auto` with a sticky header — the same fix already applied to
`advanced-search-results.html` (AS-08) and `results.html`.

---

## 7. Vendor page

### V-05 · Remove social icons without content
**Doc** "Remove Social Media Icons unless they have content on there. So you need to check
for each tool."
**Now** All 8 render on every vendor with `href="#"` — none has a real URL.
**Do** Render only icons with a real URL. Since no vendor has any, the section hides
entirely; it reappears per-vendor as soon as URLs exist. The whole block hides when a
vendor has none, so no empty heading is left behind.

### V-06 · Reverse Save Vendor colours
**Doc** "Background tile is in (dark) Orange and Text Content + Bookmark is in white"
**Now** Transparent background, orange text and icon.
**Do** Dark orange filled tile, white label and bookmark.

### V-07 · Back link wording
**Doc** "It should read 'back to Dedicated Results' format."
**Now** Breadcrumb `Home › Search Results › Procore`.
**Do** Replace with a `‹ Back to Dedicated Results` link matching the other pages.

### V-08 · "Save Page" → "Save Vendor"
**Now** Top-right button says "Save Page". (The bookmark under the logo already says
Save Vendor.)
**Do** Rename it.

---

## 8. Acceptance

| # | Check |
|---|---|
| 1 | Footer reads `FAQ / Glossary` on all six pages |
| 2 | Category band is `#DCEEFB → #E9F5FD` |
| 3 | Search Results has a working Back to Home link |
| 4 | No `#` column on any of the three results tables; widths still total 100% |
| 5 | Advanced Search actions are two rows; bookmark toggles and persists |
| 6 | Divisions cell shows up to 2 values then `more…` |
| 7 | Dedicated Search filters: 5 groups, **no internal scroll**, nothing clipped |
| 8 | Dedicated Results: all 10 rows reachable at 864px and below |
| 9 | Vendor: no social block; Save Vendor is an orange tile with white content; back link reads Back to Dedicated Results; button says Save Vendor |
| 10 | Every page: fold still equals viewport, no horizontal scroll, no console errors |

---

## 9. Raised, not actioned

The two filter vocabularies (§5) now diverge between Advanced Search and Dedicated Search.
Worth settling on one list and driving both pages from it.

---

## 10. Build log — 2026-09-01

All twelve done, all ten acceptance checks verified in-browser at **1536×864** and
**1366×660**. No console errors and no horizontal scroll on any of the six pages.

| ID | Result |
|----|--------|
| F-01 | `<span>/</span>` separator on all six footers. Stale comment in `ctd-chrome.css` updated too. |
| H-09 | `index.html` band back to `from-[#DCEEFB] to-[#E9F5FD]`. 13 icons, **0 overlaps**. |
| SR-12 | `‹ Back to Home` → `index.html`, placed **on the count line** rather than in a row of its own — verified same `top` as `#hero-count`, so the table kept all 10 rows. |
| AS-09 | `#` column gone from all three tables — headers now 7 / 10 / 8, `colspan` matched. |
| AS-10 | `.act-row` (globe + bookmark, `display:flex`) above a block `.btn-vp`. Bookmark toggles `aria-pressed` and survives via `CTD_ACTIONS`. |
| AS-11 | `moreCell(divs,2,…)` — e.g. `03 – Concrete / 04 – Masonry / +3 more…`. |
| DS-06 | Five `.af-col` columns, `max-height:none; overflow:visible`. `scrollHeight === clientHeight` (245px), nothing clipped. Markets Served on a 2fr track split into two sub-columns of five. |
| DR-11 | `.tscroll` → `overflow:auto` + sticky header. All 10 rows reachable at 660px (scrollable, last row scrolls into view) and all 10 visible outright at 864px. |
| V-05 | No social block rendered — `[class*=social]` returns nothing. |
| V-06 | `.btn-save` = `rgb(210,84,10)` on `rgb(255,255,255)`. |
| V-07 | `‹ Back to Dedicated Results` → `dedicated-results.html`. |
| V-08 | Both controls read "Save Vendor"; no "Save Page" left in the DOM. |

### Two judgement calls, flagged

1. **Company Size kept.** §5's table lists five groups and Company Size is not among
   them, but it is one of only two filters on that panel with real backing data.
   Dropping it for four that filter nothing would have been a functional regression the
   client did not ask for. It sits stacked beneath Company Type, inside column 2, so the
   row still reads as the five groups from the reference.
2. **The four unbacked groups render disabled at (0)**, same as on
   `advanced-search-results.html` — the panel matches the reference without offering
   filters that cannot work. They go live the moment the columns exist.

§9 still stands: the two pages now show two different filter vocabularies.
