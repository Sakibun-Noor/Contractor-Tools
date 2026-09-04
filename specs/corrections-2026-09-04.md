# 09.04.26B corrections — quick items

**Source:** `09.04.26B Corrections.docx`, received 2026-09-04 (client, via Sakib). 22
items across Miscellaneous, Footer, Home, Search/Results, Advanced Search/Results,
Dedicated Search, Dedicated Results, and Vendor Page (10 colour mockups attached).
**Scope of this round:** only the items confirmed quick — a few minutes each, no
data model changes, don't depend on answers to the open questions below. The client
explicitly deferred the Vendor Page template. Everything else from the doc (7 bigger
items + 2 held items below) is a separate, later round.
**Correction IDs:** `QC-01` … `QC-07` (Quick Correction)

---

## 1. What shipped

### QC-01 · Search/Results — rename header
`<h1 class="phead">` "SEARCH RESULTS" → **"SEARCH / RESULTS"**.

### QC-02 · Search/Results — "< Back to Home" above the header
Was sharing the count line (a deliberate space-save from a prior round, SR-12). Moved
to its own row above `SEARCH / RESULTS`, at the client's request. Costs a few px of
table height on short screens - accepted.

**Implementation note:** `main` on this page is `display:grid` with an explicit
`grid-template-rows` list, one track per direct child. Adding `.back-link` as a new
child in front of `.ptop` without adding a 6th row track silently shifted every
element after it into the wrong grid row - the two-question panel collapsed to 0
height and the results table painted over it. Fixed by adding the row track. Left an
inline comment warning the next person this grid needs its child count and its
`grid-template-rows` list kept in sync.

### QC-03 · Search/Results — company count to the left margin
Now its own line under the header (a side effect of QC-02 - once the back-link
left the `.pcount` row, the count text became the sole item on it, at the left
margin). `.pcount-sep` (the separator between the two) removed as dead CSS.

### QC-04 · Search/Results — delete the "Now live…" banner
Removed the `#do-note` banner ("Now live — every vendor carries a master trade and a
trade/division") from the "WHAT DO YOU DO?" panel - leftover announcement copy from
the hierarchy-import round, no longer needed. `.qnote` CSS (now unused) removed too.

### QC-05 · Dedicated Results — fix the "Change Search" link
Was `href="advanced-search-results.html"`; client reported it should go back to
Dedicated Search. Fixed to `href="dedicated-search.html"`.

### QC-06 · Homepage — hero art swap (fixes the clipped Safety icon)
Client reported "Part of Safety is cut off." Root cause: the DF-01b short-landscape
rule (`specs/display-format-2026-09-02.md`) crops the hero on short viewports with
`object-position: center 28%`, biased to protect the top hexagons - which sacrifices
bottom content, where SAFETY sits. That crop was tuned against the 2026-09-02 art
(5.15:1); the client supplied a new, shorter crop of the same composition,
**1798×321 = 5.60:1** (`assets/ctd/hero_image.jpg`, was 2172×422). The new file's
content runs close to edge-to-edge vertically (cranes near row 0, the SAFETY label
near the last row) - there is no safe margin left for *any* object-position crop to
land in without clipping something.

**Fix:** swapped the file in, updated `.hero-band`'s `aspect-ratio` to match exactly
(2172/422 → 1798/321 - keeps the "box ratio == image ratio, nothing ever cropped"
invariant from the original hero design), and **removed** the DF-01b `max-height` /
`object-position` crop entirely - the shorter ratio alone now does the space-saving
job the crop used to do, at zero crop risk. Verified in-browser: at 1280×590 the hero
renders at its full natural height (226px) with all six hexagons visible and the
homepage still fits one screen (`findBottomVsViewport: 0`); at 1280×560 it's a
negligible 8px of scroll, still zero cropping.

### QC-07 · Homepage — Safety icon "cut off" (folded into QC-06)
Same root cause as QC-06; no separate fix needed once the hero stopped being cropped.

---

## 2. Held, not done this round

- **"Center all SECTION LABELS"** (client's own doc says "(unsure)," both times it
  appears) — the labels in question (`.qcard-hd h2` on Search/Results,
  `.sel-card-hd h3` on Dedicated Search) sit in flex header bars alongside a search
  box or a sort button. Centering the text does nothing visible (auto-width flex
  item); centering the *bar* would displace the control next to it. Given the
  client's own hedge and the real risk of silently breaking those bars, held for a
  decision rather than guessed at.
- **Renaming the 6 page `<title>` tags** to the client's canonical list (Home Page,
  Search/Results Page, …) — on inspection, `index.html`'s `<title>` is a deliberately
  written SEO title ("Find the Right Software for Your Construction Business"), not
  literally "Home Page." Changing it without confirming that's actually wanted risks
  an SEO regression for no visible user benefit. Folded into the open "pages are out
  of order" question below rather than executed blindly.
- Move Company Size into the Advanced Filters panel, the taxonomy relabeling, the new
  orange section bars, the footer restructure, multi-product display, the Advanced
  Search Description column / "more…" link, the Dedicated Results scroll-list change,
  and the AI-logo click-through — all confirmed as "more than a few minutes," queued
  for their own round once the client answers the open questions.

## 3. Open questions sent to the client

1. Public/Private company filter shows 0 for both, greyed out - confirmed this is
   unpopulated data (`public_private = "Unknown / Verify"` for every vendor, per
   `hierarchy-import.md` §2.3), not a bug. Keep hidden until real data, or show it
   with 0s now?
2. "Replicate the category page so I can format it" - which page, and duplicate vs.
   feedback on the existing one?
3. "Pages are out of order" - order of what: nav menu, URL/file order, or the
   click-through sequence? (Also covers the page-title-rename question above.)

---

## 4. Build log — 2026-09-04

Verified in-browser (local build):

| Check | Result |
|---|---|
| Search/Results header, back-link, count position | Correct at 1280×590 and 1536×864; two-question panel no longer collapses (grid row-count bug caught and fixed before shipping) |
| "Now live…" banner gone | Confirmed, no stray references left in JS or CSS |
| Dedicated Results "Change Search" → Dedicated Search | Confirmed via link inspection |
| Hero swap - all 6 hexagons visible | 1280×590, 1280×560, 1280×720, 1536×864, 1920×1080 - no cropping anywhere (`object-position: 50% 50%`, `max-height: none` at every size) |
| Homepage still fits one screen at 1280×590 | `findBottomVsViewport: 0` |
| No console errors, no new horizontal scroll | Confirmed on Search/Results and homepage |
