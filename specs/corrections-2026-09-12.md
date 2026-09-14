# Corrections round — 2026-09-12F doc

Source: `09.12.26F Corrections.docx` (Deryck, via WhatsApp) + Sakib's red-text
annotations on the same doc + the WhatsApp thread.

## Root cause found before anything else

Deryck's screenshots and ours were never the same screen. His laptop
(1920×1080 physical @ 150% Windows scaling) renders a **1265×553 CSS-pixel**
browser viewport. Every page had only ever been tuned down to ~1280×590
(the "Path B" short-landscape breakpoint from `display-format-2026-09-02.md`).
Reproduced live at 1265×553:

| Page | What breaks | Cause |
|---|---|---|
| Homepage | INSIGHTS 2nd description line clipped below the fold | The category-tile row is hard-floored at `minmax(220px,1fr)`; at 553px tall that floor alone overflows the shell by ~12px |
| Advanced Search / Results | 0 result rows visible | `.af-panel` (filters) is an unconstrained `auto` row (`max-height:none`); it ate the entire budget and left the table's `minmax(0,1fr)` row nothing |
| Dedicated Search | All 6 selector-card lists render ~12px tall — "no records" | Same shape of bug: `.af-panel` above the cards is unconstrained; the cards' row is `minmax(0,1fr)` and collapsed to near-zero |

`results.html` and `dedicated-results.html` do **not** have this bug — their
tables already scroll internally via `.tscroll` (3 and 7 of 10 rows visible
respectively at 1265×553, nothing invisible, just a normal internal scroll).

This round's build fixes the three broken pages using the same pattern
already proven on the homepage elsewhere in this file: give the
must-be-visible content a **real minimum** (`minmax(Npx,1fr)` instead of
`minmax(0,1fr)`), and put the **discretionary** content (the filter panel)
on an internal scrollbar once height is short enough that it would otherwise
steal the floor's space. Nothing changes above ~720px tall — this only
engages on short laptop screens.

## In scope this round (no client answer needed — either a bug fix or
already marked "Do it" / "DO IT" in Sakib's red annotations)

1. Homepage — tighten the category-tile row floor and the FIND/LEARN/
   RESEARCH/INSIGHTS band padding at very short heights so nothing clips
   down to ~550px tall, without touching the already-verified ~590px tuning.
2. Dedicated Search — cap `.af-body` (the top filter panel) with an internal
   scrollbar at short heights, and give the 6 selector-card lists a real
   floor so at least a few records are always visible.
3. Advanced Search / Results — same pattern: cap `.af-body`, give the
   results table row a real floor. Column/group layout is **not** touched
   here (see "Held back" below).
4. Search / Results — "View all…" → "view more…" wording (doc: "DO IT").
5. Search / Results — shorten the ACTIONS column / View Profile button width
   (doc: "if you understand do the change").

## Held back — needs Deryck's answer first

Sent as a WhatsApp question 2026-09-12; waiting on reply.

- Left orange bar label: "About the Customer" vs "About the Construction Pro".
- Whether Company Type (0 vendors, no real data) stays in the Advanced
  Filters group or is dropped, before restructuring `.af-body` into
  Dedicated-Search-style single horizontal row (doc items 7/12).
- Column order change (Vendors, Categories, Subcategories, Products, Major
  Groups, Divisions, Trades, Actions) — whether it also applies to Advanced
  Search Results and Dedicated Results, not just Search/Results.
- Sort arrows on Divisions/Major Groups + TRADES/DIVISIONS short header
  renames — bundled into the same confirmation message.
- The new right-side "Advanced Filters" accordion on Search/Results
  (doc item 5) — new construction, holds until the naming/Company Type
  questions above are settled since it reuses the same filter groups.

## Explicitly paused

- Vendor Page colorize (doc item 19) — Deryck's own instruction: "we will
  pause this vendor page work for now... leave it as it is for now."

## Build log

(filled in after each piece ships)

### 2026-09-12 — short-viewport fixes + two approved tweaks (shipped)

- `index.html` — new `@media (max-height:570px)` block tightens the
  category-tile row floor (220px → 204px, still above the 176px hard tile
  floor) and the Discovery-pathways band padding (9px → 6px). Verified
  1265×553 (Deryck's actual window): fold now fits exactly, 0px overflow,
  INSIGHTS 2nd line fully visible. 1280×590 unchanged (still an exact fit,
  as before). No change at ≥720px tall.
- `dedicated-search.html` — new `@media (max-height:720px)` block caps
  `.af-body` at 150px with its own scrollbar and gives the 6 selector-card
  row a 200px floor (`main`'s grid-template-rows). Verified 1265×553: every
  card now shows ~3 real records instead of an empty 12px box. 1280×590
  and 1536×864 unaffected/unconstrained as designed.
- `advanced-search-results.html` — same pattern: `.af-body` capped at
  130px scrollable, `.main-col`'s table row floored at 230px. Verified
  1265×553 and 1280×590: exactly 5 result rows visible (client's stated
  goal), 0 → 5. 1536×864 and 1920×1080 unaffected.
- `results.html` — "View all X ›" renamed to "view more…" on all 6 panel
  links (doc: "DO IT"), with the original wording kept as an `aria-label`
  for screen readers. Destinations/behaviour unchanged for now (mt/div/tr
  still go to Dedicated Search, cat/sub/prod still expand in place) —
  the doc's "will trigger the Advanced Search / Results Page" note is
  folded into the held-back items above since it overlaps the pending
  accordion/column questions.
- `results.html` — ACTIONS column narrowed 8.5% → 7%, VENDORS widened
  20.5% → 22% to use the freed space. "View Profile" button verified
  intact (no text wrap/clip) at 1265×553 through 1920×1080.

All four pages re-verified at 1265×553, 1280×590, 1536×864 and 1920×1080:
no horizontal scroll, no console errors.

### 2026-09-13 — Deryck's answers implemented (091326 Corrections.docx)

Client answered the 3 pending questions by returning the same doc with red
replies:

- Left orange bar name → "About the Construction Pro". Right bar (already
  proposed) → "About the Product". Applied on `results.html`,
  `dedicated-search.html`, `advanced-search-results.html`.
- Company Type → "Hide it. We will be populating it on next update."
  Hidden with `style="display:none"` on the `.af-grp` block rather than
  deleted, on `dedicated-search.html` and `advanced-search-results.html`,
  so turning it back on later is a one-line change.
- Column order (Vendors, Categories, Subcategories, Products, Major
  Groups, Divisions, Trades, Actions) confirmed "Yes" for Search/Results,
  Advanced Search Results, and Dedicated Results. Applied to
  `results.html` and `dedicated-results.html` (header + row-render both
  reordered, checked cell-for-cell against the new headers).

**Held back:** `advanced-search-results.html` does not currently have a
Construction Trades column at all — applying the order literally means
*adding* a column, not just reordering one. Left this page's table order
untouched until the client/Sakib confirms whether to add that column.

Also pushed back (in a WhatsApp reply, not yet sent) on the client's
"what about other screen sizes" concern from the same doc: the short-
viewport fix already is a CSS media-query range, not anything tied to his
specific resolution — the site already uses `clamp()`, CSS Grid/Flexbox
and relative units everywhere, which is exactly the fix he described.

Verified all four pages at 1265×553 and 1536×864: bar names, hidden
Company Type, and new column order all correct; row data still lines up
cell-for-cell with its header after the reorder; 5 rows still visible on
Advanced Search Results and list boxes still populated on Dedicated
Search (no regression from the 09-12 short-viewport fix); no horizontal
scroll; no console errors.

### 2026-09-13 (2) — "Major Groups" renamed to "Master Groups" (WhatsApp)

Client, via WhatsApp: "I changed the Name Master Trades to Master Groups.
Please change Master Trades everywhere to Master Groups. It'll allow you
to use Trades so there's no redundancy with the name 'Master Trades' and
'Trades'," then confirmed both axis triads directly: "Category -
Subcategory - Product" and "Master Groups - Divisions - Trades."

The site's live label was "Major Groups" (not "Major Trades" — the client
is renaming from his own older mockup terminology), so this was a
sitewide text rename, display copy only:

- `results.html`, `advanced-search-results.html` (sidebar + table),
  `dedicated-search.html` (selector card), `dedicated-results.html`
  (table), `vendor-profile.html` (info card) — every heading, table
  header, chip/export label dictionary, footer link, and comment
  containing "Major Groups" / "MAJOR GROUPS" changed to "Master Groups" /
  "MASTER GROUPS".
- `assets/filters.js` comment updated to match (was already stale re:
  the 2026-09-05 rename to begin with).
- Nothing else touched: the `mt` field key, `mtNames`/`mtsOf`/`.sb-mt`
  identifiers, and the `?mt=` URL param are internal, not display text,
  and stayed exactly as they were — this is a label change only.

This also confirms, in passing, that "Divisions" and "Trades" (not
"Divisions of Work" / "Construction Trades") are the client's own
preferred short forms — one half of the still-open sort-arrows/header-
shortening question from the first corrections round.

Verified all 5 pages at 1536×864 and 1265×553 (client's screen): label
reads correctly everywhere, no header wrap/overflow, no horizontal
scroll, no console errors.

### 2026-09-14 — Divisions/Trades rename, sort arrows, Trades column (A+B)

Client confirmed in WhatsApp, "everywhere": "Divisions of Work" is now
"Divisions", "Construction Trades" is now "Trades". Sitewide rename
(display text only, same method as the Master Groups rename) across
`results.html`, `advanced-search-results.html`, `dedicated-search.html`,
`dedicated-results.html`, `vendor-profile.html`. Deliberately excluded
`trades/index.html` — that's a separate SEO landing page ("All
Construction Trades"), not a filter facet label, unrelated to this round.

Also shipped, both confirmed "Yes":
- Sort arrows added on Master Groups and Divisions columns on
  `results.html` and `dedicated-results.html` (Categories, Subcategories,
  Products and Trades already had them). `results.html`'s Master Groups
  column holds one value per vendor, so it sorts on the raw `mt` field
  directly; everywhere else Master Groups/Divisions render multiple
  values per vendor, so a `mtNames`/`divNames` virtual sort key
  (`mtsOf(t).join(', ')` / `divsOf(t).join(', ')`) was added to each
  page's `sortValue()`, matching the pattern `advanced-search-results.html`
  already used for its own divNames/mtNames.
- Advanced Search Results: added a Trades column (9th column, "Trades"),
  reordered the other 6 into Vendors, Description, Categories,
  Subcategories, Products, Master Groups, Divisions, Trades, Actions to
  match the rest of the site. Column widths rebalanced to fit 9 columns
  at 100%. `colspan` on the empty-state row bumped from 8 to 9.

Verified all 4 pages at 1536×864 and 1265×553 (client's screen): labels
correct everywhere, new column's data lines up with its header, sort
clicks on all 4 new arrows actually reorder the table (not just render),
still 5 rows visible on Advanced Search Results with the extra column, no
horizontal scroll, no console errors.

Held for the layout rebuild spec (see below): the 3-column page
restructure for Search/Results and Advanced Search Results.
