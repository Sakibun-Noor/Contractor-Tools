# Merge + rename the search pages (2026-09-15)

## What the client asked (WhatsApp, 2026-09-15)

Deryck asked "make a case for why we need both" Search / Results and
Advanced Search / Results, then proposed combining them. Confirmed twice,
using his own "former / proposed" wording:

| Former | Proposed | File |
|---|---|---|
| Search / Results + Advanced Search / Results | **Search / Results** | `results.html` |
| Dedicated Search | **Advanced Search** | `advanced-search.html` |
| Dedicated Results | **Advanced Results** | `advanced-results.html` |

"The names 'Advanced Search / Results', 'Dedicated Search' and 'Dedicated
Results' will no longer exist."

For the combined Search / Results page:

1. "Let's use scroll boxes and checkboxes for all 6 sections." Show 12 of
   each before "view more…" (we proposed 12, he: "Agreed").
2. "Let's make description a tool tip (i)" — no Description column.
3. Right-side Advanced Filters panel stays ("Yes").
4. "view more…" goes to Advanced Search ("Yes. Please remember: the future
   Advanced Search page shows everything. So there will be extensive use of
   scroll boxes … since it's the final search page.")

Real list sizes, for the record: 12 Categories, 12 Master Groups, 22 Trades,
35 Divisions, 71 Subcategories, 71 Products. (His "49 divisions" includes 14
"Reserved for Future Expansion" slots in `taxonomy-data.js`; `filters.js`
drops those. He accepted that.)

## Decisions made without asking him

- **Base page:** `results.html` keeps its address — the homepage tiles,
  header search and footer "Find" all point there. The former Advanced
  Search / Results already had the checkbox sidebar, so its component is
  what moved in; yesterday's link-list sidebar on `results.html` was
  replaced.
- **Real file renames**, not just new headings (`git mv`), so the URL no
  longer contradicts the page name. The three retired addresses stay as
  tiny redirect stubs (`location.replace` + noscript meta refresh,
  `noindex`, canonical) that keep the query string, so bookmarks and the
  links Deryck has been opening still land on the same selection.
- **Equal-height boxes:** the six sidebar cards are `flex:1 1 0` so every
  section is on screen at once and each list scrolls in its own box (his
  earlier "all the same size with view more at the bottom"). A
  `min-height:104px` floor stops a box collapsing on a short screen; below
  that the column itself scrolls.
- **Tooltip** is one `position:fixed` element on `<body>`, not a child of
  the cell, so the table's own scroll box can't clip it. Opens on hover,
  keyboard focus or click; closes on leave, blur, Escape, outside click or
  any scroll. Flips above the icon near the bottom of the screen.
- **Hidden-active guard:** a filter arriving by URL for an item past the
  first 12 (e.g. `?sub=Generative AI`, item 41) is appended to its box,
  ticked. Without it the box wouldn't render that checkbox, and the next
  change event — which rebuilds `filters` from whatever is ticked — would
  silently drop it.
- **Not built:** carrying the current selection into Advanced Search. That
  page doesn't read URL filters at all; it'd be new behaviour nobody asked
  for. Noted as a possible follow-up.

## Build log

### Shipped 2026-09-15

**Renames**
- `git mv dedicated-search.html advanced-search.html`,
  `git mv dedicated-results.html advanced-results.html`.
- Every internal link repointed across `index.html`, `results.html`,
  `advanced-search.html`, `advanced-results.html`, `vendor-profile.html`
  (footer "Search", back-links, "Change Search", Search Vendors CTA, table
  cell links, header search on the vendor page). Repo-wide grep for the
  three old filenames outside the stubs and `specs/` returns nothing.
- Titles / H1s / back-link labels: ADVANCED SEARCH PAGE, ADVANCED RESULTS
  PAGE, "Back to Search / Results", "Back to Advanced Search", "Back to
  Advanced Results"; Advanced Results' saved-search fallback name. A blanket
  filename sed also rewrote three code comments into nonsense ("Matches
  results.html" inside results.html) — reworded by hand.

**Search / Results (`results.html`)**
- Sidebar: six `.sb-card` checkbox sections (Categories, Subcategories,
  Products | Master Groups, Divisions, Trades) under the two orange bars,
  `SB_LIMIT = 12`, "view more…" in a footer below each scroll box →
  `advanced-search.html` (context kept in `aria-label`).
- No new change-handler needed: the document-level handler added for the
  right filters panel on 2026-09-14 already rebuilt `filters` from every
  checked `[data-filter]` on the page, so the sidebar boxes plugged into it.
  `renderSidebar()` replaced the old `renderPanel()` in `applyAndRender()`.
- Removed the "Advanced Filters" button (it linked to the retired page) —
  and the startup code that set its `href`, which would otherwise have
  thrown on a null element and stopped the whole script.
- Vendor cell: `(i)` button beside the name when the vendor has a
  description.
- Column widths: Actions was 7% of a table that is now ~1,000px wide, so
  it had shrunk to 70px and "View Profile" was clipped. Now 9.5%
  (Vendors 21, Subcategories 11.5, Products 12); still sums to 100.

**Verified** (1265×553 client screen, 1536×864, 1920×1080; no console errors
on any page)
- Merged page: fold exactly viewport height with no internal overflow, no
  horizontal scroll, table overflow 0 at 1536+, View Profile not clipped.
  Boxes: 5.4 rows each at 1920×1080 with the column not scrolling; 3.5 at
  1536×864; 2.6 at 1265×553 where the column scrolls (floor reached).
- Left filter 1,463 → 289 with chip + URL; combined with a right-panel
  filter → 31; Clear all → 1,463 and nothing ticked.
- `?sub=Generative AI` (item 41): rendered ticked (13 in box), survives
  ticking another box.
- Homepage tile `results.html?cat=accounting-payroll` arrives ticked.
- Tooltip shows the vendor's text, stays inside the viewport, hides on leave.
- `advanced-search-results.html?cat=crm-sales&sz=Enterprise` →
  `results.html` with both filters applied (7 vendors).
- `dedicated-search.html` → Advanced Search: all 71/71/12/22/35/12 items in
  scroll boxes; tick one → Search Vendors → `advanced-results.html?sub=…`
  (211 vendors), back-link and Change Search → Advanced Search.
- `dedicated-results.html?sz=Enterprise` → `advanced-results.html?sz=Enterprise`.
- Vendor profile back-link → Advanced Results.
- Advanced Search and Advanced Results at 1265×553: fold intact, no h-scroll.
