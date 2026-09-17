# Corrections round — 09.17.26 doc (2026-09-17)

Source: `09.17.26 Corrections.docx`, Sakib's red review notes, and Deryck's
green replies in `09.17.26 Corrections response - Sakib review.docx`.
Only items both sides agreed on are built here. Landscape desktop/laptop
only ([[ctd-landscape-only-scope]]).

Deryck raised twice that fixes must not be "adjusted for each device". Every
rule below is a screen-size *range* (or no media query at all) — never one
screen. Each item is checked at 1265×553, 1536×864 and 1920×1080.

## Not in this round

- Orange line under the header — Sakib decided against it (Deryck: "not a
  big deal").
- About Us / Contact Us / Update Info pages — need page content from Deryck.
- Missing-filters explanation — Deryck wants a call.
- Center-link error messages — Deryck is re-checking.
- Vendor page — shipped earlier today (`vendor-page-rebuild-2026-09-17.md`).

## Universal

**VC-01 Sort arrows.** One control per column that flips ascending ↔
descending (already how `sortBy` works). Replace the "↑↓" text glyphs with
thin SVG arrows (Deryck: "Use thin up/down arrows"). The arrow for the
current direction is shown solid on the sorted column so the flip is
visible. Applies to Search / Results, Advanced Results and the card headers
on Advanced Search.

**VC-02 "About the Construction Pro" → "About the Buyer"** everywhere it
appears (Search / Results left nav, Advanced Search group bar).

## Home page

**VC-03 Tile hover.** No white background on hover — the tile keeps the
section's blue. The icon lift stays. Add the optional darker-blue outline
Deryck suggested so the hovered tile is still clear.

## Search / Results

**VC-04 No horizontal scroll.** Remove the centre column's side padding so
the table runs up to both navs (also VC-05). Tighten Vendors, Divisions,
Trades and Actions; long values end in "…" rather than wrapping. Size the
table's minimum width so it fits the narrowest supported landscape screen;
below that it still scrolls inside its own box instead of squashing.

**VC-05 Single margin.** Only the table's own border remains between the
table and the side navs.

**VC-06 Widen Master Groups and Subcategories** so their sort arrows are
fully visible; width comes from the four tightened columns.

**VC-07 Center the header labels.** Row content stays left-aligned
(agreed).

**VC-08 Search box at the top of the left nav** (Deryck: "Please do").
Typing filters all six lists at once; clearing it restores them.

**VC-09 New Divisions icon.** The current one has a plus sign and looks like
the Categories grid. Use a distinct layered-stack icon.

**VC-10 Deselect bug.** Subcategories and Products share one field, so a
value was ticked in both boxes and unticking one left the twin ticked.
Unticking either box now removes the value from both.

**VC-11 Full "view more" wording:** view more categories… / subcategories… /
products… / master groups… / divisions… / trades…

**VC-12 "ADVANCED FILTERS" on one line** in the right column at every
supported width.

**VC-13 Filter counts always visible, on the right** (Deryck: "I prefer them
on right side of content"). Name shortens with "…"; the count never does.

## Advanced Search

**VC-14 Visible scroll bars** on every list and on the filter panel — wider
and darker than today's 5px light-grey bar, so they can't be missed.

**VC-15 Markets Served in one column**, inside its own scroll box so the
taller group doesn't push the six lists down.

**VC-16 Search box wording:** "Search trades…", "Search divisions…",
"Search master groups…".

**VC-17 "Clear" button** instead of the "Clear Products" text link, one per
card.

## Advanced Results

**VC-18 Center the header labels** (rows stay left).

**VC-19 Widen Master Groups and Subcategories** so the arrows show.

## Build log

### Shipped 2026-09-17

All 19 items built. No item uses a single-screen rule.

- **VC-01** `.sic` spans on Search / Results and Advanced Results, and the
  six card sort buttons on Advanced Search, now hold a thin two-arrow SVG.
  `markSort()` runs after every sort and gives the sorted column
  `is-asc` / `is-desc`, which makes that direction's arrow solid.
  (Subcategories and Products both sort on `sub`, so both light up.)
- **VC-02** both bars renamed. Repo grep for "Construction Pro" only hits
  "Construction Project Management" on the old static pages.
- **VC-03** `hover:bg-white/60` removed from the 12 tiles; a
  `::after` 2px blue outline shows on hover/focus. No new Tailwind classes,
  so `tailwind-fallback.css` needs no change.
- **VC-04/05** centre column side padding removed (the back link, title,
  chips and pager keep their own inset); table wrapper keeps only top/bottom
  borders. Table `min-width` 980px → 820px. Measured: 820px is the true
  floor — at 800px "MASTER GROUPS" clips its arrow. At the navs' minimum
  widths the centre column is ~850px, so 1265px-wide screens and up have no
  horizontal scroll.
- **VC-06** widths now Vendors 18.5 / Categories 11.5 / Subcategories 14 /
  Products 12 / Master Groups 14 / Divisions 11 / Trades 9.5 / Actions 9.5.
- **VC-07 / VC-18** header text centred; row cells still start-aligned.
- **VC-08** `#sb-q` at the top of the left nav; `renderFacet` filters each
  list by the typed text (first 12 matches, "No matches" when empty) and
  still appends any ticked value that falls outside the matches.
- **VC-09** Divisions icon → three-layer stack.
- **VC-10** change handler copies a `sub` checkbox's state to its twin
  before rebuilding `filters`.
- **VC-11** the link under each left-nav box reads "view more categories…" etc.
- **VC-12** `.af-hd h3` nowrap with a slightly smaller clamp.
- **VC-13** filter count moved out of the label into its own right-aligned
  span (Search / Results `.af-ct`; Advanced Search `.ct` on filter rows and
  card rows, which keeps the two pages consistent). Card sort now compares
  the label only, not label + count.
- **VC-14** scroll bars: `scrollbar-color` #8A97AD on #EEF2F7 plus wider
  WebKit bars on Advanced Search lists, the Markets Served box, and the
  Search / Results left-nav lists.
- **VC-15** Markets Served one column in `.af-scroll` (max 112px ≈ 5 rows);
  panel grid rebalanced to `1fr 1fr 1.25fr 1fr 1fr`.
- **VC-16** placeholders updated. **VC-17** six `<button>` "Clear" controls.
- **VC-19** Advanced Results widths: Vendor 13, Description 10,
  Subcategories 10.5, Master Groups 10, Trades 9.5, Quick Facts 10.

**Verified** at 1265×553, 1536×864, 1920×1080 (no uncaught errors; the only
404s are vendor icon files that don't exist, pre-existing and covered by
the letter fallback):
- Search / Results: table overflow 0, no page h-scroll, fold intact, every
  header arrow inside its column, View Profile not clipped, (i) visible,
  "ADVANCED FILTERS" one line, 0 of 24 filter counts cut.
- `?sub=Drawings` → untick in Products → both boxes clear, 211 → 1,463.
- Search "elec" → Master Groups: Electrical; Divisions: 26, 28, 48; Trades:
  Electrical; others "No matches". Ticked Electrical while filtered →
  cleared search → still ticked, lists back to 12.
- Sorting Master Groups twice → `is-asc` then `is-desc`, only one column
  marked.
- Advanced Search: Markets Served 10 items, 1 column, scrolls; list scroll
  bars 15px; placeholders and bar name correct; tick 2 categories
  (1,463 → 377) → Clear → 0 ticked, 1,463; card sort A–Z / Z–A by name.
- Advanced Results: headers centred, all arrows inside at 1265 and 1536.
- Home: 12 tiles, none with the white hover class; outline rule present.
