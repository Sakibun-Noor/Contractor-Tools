# Layout rebuild — Search/Results & Advanced Search/Results (2026-09-14)

## Background

Deryck's original landscape (16:9) design for both pages was a 3-column
layout: left nav (facets), center (results), right (filters). At some
point in this engagement the filters moved to a horizontal bar above the
table (Advanced Search Results, per code comments "AS-06/FC-05 — per the
client") and Search/Results grew a two-panel top section instead of a
sidebar. Deryck says the top-bar version was actually meant for a 9:16
**portrait** layout and landed on landscape by mistake ("I take the
blame. Let's get it back"). Confirmed via WhatsApp 2026-09-14: rebuild
both pages back to left / center / right, landscape/desktop only — no
portrait or mobile work, per [[ctd-landscape-only-scope]].

## D. Advanced Search Results — smaller change, do first

Already has the right shell shape (`.page-body` = sidebar + main-col).
Just needs the filter panel moved from a horizontal bar above the table
into a third column on the right.

**Before:**
```
.page-body { grid-template-columns: minmax(230px,17%) minmax(0,1fr); }
  aside.sidebar               (existing, unchanged — already correct)
  div.main-col { grid-template-rows: auto auto auto auto minmax(0,1fr) auto; }
    a.back-link
    div.ptop
    div.chips
    div.af-panel               <-- MOVES OUT
    div.tablewrap               (fr row)
    div.pgbar
```

**After:**
```
.page-body { grid-template-columns: minmax(230px,17%) minmax(0,1fr) minmax(220px,19%); }
  aside.sidebar                (unchanged)
  div.main-col { grid-template-rows: auto auto auto minmax(0,1fr) auto; }  <- af-panel row removed
    a.back-link
    div.ptop
    div.chips
    div.tablewrap                (fr row — gets the height back)
    div.pgbar
  aside.filters-col             <-- NEW, af-panel content lives here now
    div.af-panel (restyled: single vertical column, not 3-across)
```

`.filters-col` mirrors `.sidebar`'s own CSS almost exactly (full height,
independent `overflow-y:auto`, `border-left` instead of `border-right`)
so it behaves the same way — its own scrollbar if content is tall,
never pushes the table around.

`.af-body` changes from `grid-template-columns:repeat(3,1fr)` (3 groups
across) to a single stacked column (`display:flex;flex-direction:column`)
since it's now a narrow column, not a wide bar. The 6 filter groups
(Evaluation Options, Purchase Options, Company Type [stays hidden],
Available On, Markets Served, Company Size) keep their existing markup
and JS (`renderAfList`, `af-eval`/`af-purchase`/etc ids) — only the CSS
around them changes. The `.af-col:not(:last-child){border-right:...}`
divider rule is dropped (no longer meaningful in a single column).

No JS logic changes here at all — same ids, same render functions, same
checkbox behavior. This is a CSS/markup relocation only.

## C. Search/Results — bigger change, do second

Today `results.html` has no sidebar at all: `<main>` holds back-link,
ptop, chips, the two-panel `.qgrid` (About the Construction Pro / About
the Product bars + search boxes + 6 link-list columns with counts), the
results table, then pagination — all stacked in one column.

Client's answer to "shorten the two panels" was **"Eliminate. What do
you do and what you are looking for sections on left hand side is
enough."** Read together with "left nav" from the other answers: the
two orange bars + their live search boxes are removed; the 6 existing
facet link-lists (Master Groups, Divisions, Trades, Category,
Subcategory, Product — each already a live, working list with counts
and `results.html?x=y` links, built by the existing `renderCol()`/
`renderPanel()` JS) get **repositioned** into a left sidebar, not
rebuilt as checkboxes. This keeps 100% of the existing interaction
model (click a value → filters the table via URL param) — lower risk
than adopting Advanced Search Results' checkbox sidebar, and matches
his "is enough" (don't add new behavior, just move what's there).

**Before:**
```
.page-above-fold { grid-template-rows: auto minmax(0,1fr); }
  header
  main { grid-template-rows: auto auto auto auto minmax(0,1fr) auto; }
    a.back-link
    div.ptop
    div.chips-row
    div.qgrid                  <-- two orange bars + 2 search boxes + 6 qcol lists
    div.tablewrap                (fr row)
    div.pgbar
```

**After:**
```
.page-above-fold { grid-template-rows: auto minmax(0,1fr); }
  header
  div.page-body { grid-template-columns: minmax(230px,17%) minmax(0,1fr) minmax(220px,19%); }
    aside.sidebar                <-- NEW: the 6 qcol lists, restyled to match
                                     Advanced Search Results' .sidebar/.sb-* look
                                     (orange "About the Construction Pro" / "About
                                     the Product" bars kept as section dividers,
                                     same as AS page's sb-group bars — just the
                                     two SEARCH BOXES are dropped, not the bars)
    div.main-col { grid-template-rows: auto auto auto minmax(0,1fr) auto; }
      a.back-link
      div.ptop
      div.chips-row
      div.tablewrap                (fr row)
      div.pgbar
    aside.filters-col            <-- NEW: same Advanced Filters accordion as
                                     the D rebuild (Evaluation Options, Company
                                     Size, Available On, Markets Served,
                                     Purchase Options; Company Type hidden).
                                     This page never had one — new markup, but
                                     copied from the D version once that exists,
                                     not designed twice.
```

The existing `renderCol()`/`renderPanel()` JS keeps working as-is — only
the container markup around each `.qcol` list changes (drops the
`.qsearch` input, drops the `.q-group-bar` → becomes `.sb-group` styled
bar, wraps each list in an `.sb-card`-style block for visual consistency
with Advanced Search Results' sidebar). No filtering behavior changes.

New filters column reuses the exact af-panel/af-body markup and JS built
for D (same ids would collide if literally copy-pasted with the same
`id="af-eval"` etc — **give this page's copies distinct ids**, e.g.
prefix `sr-af-eval`, and wire the render calls to the new ids).

## What does NOT change on either page

- Table columns, sort arrows, row rendering — untouched (already fixed
  in the previous round).
- Company Type stays hidden (`display:none`) in both filter columns.
- The 100dvh no-scroll shell above the fold, released below
  `max-width:1023px`/`999px` for phone/tablet exactly as it is today —
  this rebuild only touches the ≥1024px desktop/laptop layout.
- The short-viewport (`max-height:570-720px`) fixes from the 2026-09-12
  round — will re-verify at 1265×553 after the rebuild, adjusting the
  filters-column's own max-height/scroll cap the same way `.af-body` was
  capped on Dedicated Search if the numbers don't already fit.

## Build order

1. D (Advanced Search Results) — smaller, no new sidebar to build, proves
   the "filters column" pattern once.
2. C (Search/Results) — reuses the proven filters-column CSS from step 1,
   builds the new sidebar from the existing qcol content.
3. Re-verify both at 1265×553, 1280×590, 1536×864, 1920×1080: no
   horizontal scroll, no console errors, filters still filter, sort
   arrows still sort, "view more" links still work.

## Build log

(filled in as each page ships)

### D shipped — Advanced Search Results (2026-09-14)

- `.page-body` is now a 3-column grid. Side columns deliberately lean
  (`minmax(205px,15%)` / `minmax(210px,16%)`): first pass used 17%/19%
  and the 9-column table overflowed its own box by 41px at 1536×864.
  At 15/16% the table fits with 0 overflow there.
- `.main-col` dropped from 6 rows to 5 (af-panel row removed).
- New `.filters-col` mirrors `.sidebar` — full height, own scrollbar,
  `border-left`. Verified it scrolls internally at 1265×553 rather than
  pushing the table.
- `.af-body` is a flex column instead of a 3-across grid;
  `.af-grp+.af-grp,.af-col+.af-col` get a hairline divider so all 6
  groups read as one list regardless of which `.af-col` they came from.
- `toggleAF()` rewritten to toggle `.is-collapsed` instead of writing
  `style.display='grid'` — the old version would have clobbered the new
  flex layout on first collapse/expand. Verified: collapses to `none`,
  reopens to `flex`.
- Removed the `max-height:130px` cap on `.af-body` in the short-viewport
  media query — obsolete now the filters have their own scrolling column.

Verified at 1536×864: 10 rows visible (was 5), table overflow 0, no page
h-scroll, no console errors. At 1265×553 (client's screen): 7 rows
visible, pager bottom 547 < 553 so nothing is pushed below the fold,
filters column scrolls internally, table scrolls inside its own box.
Filters still filter (Small/Mid-Market: 1,463 → 388, chip appears,
uncheck restores).

### C shipped — Search/Results (2026-09-14)

Same 3-column shell as D. `<main>` became `.page-body` holding
`aside.sidebar` + `.main-col` + `aside.filters-col`; `.main-col` runs
5 rows (back-link, ptop, chips, table, pager).

**Left column** is the old two-question panel restacked, not rebuilt:
`.qgrid`/`.qcard`/`.qcols` flipped from a 2×3 grid to plain blocks so the
6 facet lists stack vertically, each `.qcol` getting a divider. Both
orange bars were sitting adjacent at the top after the first pass (they
had been positioned by the old 2-column grid) — each is now moved
directly above the group it labels. The two "Start typing…" boxes are
gone per the client's "Eliminate"; `renderCol()` read those inputs
directly, so the lookup is now guarded and returns '' when they're
absent. All existing behaviour is untouched: same live counts, same
`results.html?x=y` links, same "view more…" expansion.

**Right column** is the same Advanced Filters panel as D, with ids
prefixed `sr-af-` so nothing collides. `renderAfList`/`afStub` ported
over. results.html had no live checkbox filtering before (it read filters
from the URL once at load), so a document-level `change` handler now
rebuilds `filters` from whatever is ticked and routes it through the
page's existing `applyAndRender(true)`. Added `syncAfChecks()` into that
same path so dropping a chip or hitting "Clear all" unticks the boxes.

`table.res` min-width trimmed 1120px → 980px: it was sized for a
full-page-width table and overflowed the narrower centre column by 116px.

Stale below-desktop rules that pointed at removed elements (`main{}`,
`.qcard-hd`, `.qcols` grid) cleaned up so the phone/tablet stack path
still works; no portrait/mobile design work beyond keeping it unbroken,
per [[ctd-landscape-only-scope]].

Verified 1536×864, 1280×590, 1920×1080 and 1265×553 (client's screen):
fold is exactly viewport height with no internal overflow, footer starts
exactly at the fold line, no page h-scroll, no console errors, table
overflow 0 at 1536+ . Filtering works end to end from the new column
(1,463 → 388, chip appears, URL updates to ?sz=..., dropping the chip
restores the count and unticks the box). Sidebar links keep their real
counts and `?mt=`/`?cat=` hrefs; all six "view more…" labels intact.
Advanced Search Results re-checked after C: unchanged, 10 rows at
1920×1080, 7 at 1265×553, pager inside the fold.
