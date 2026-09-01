# Vendor page — middle section framing

**Source:** `Above on is Reference.docx`, 2026-09-02 — *"The framing of the middle
section is not correct in vendor page. Division, master trade all columns looks weird
I want it to look like the below one."*
**Scope:** the six-column info-card row only (`#info-cards` / `.vendor-list-grid`).
Nothing else on the vendor page.

---

## 1. What the reference (image) shows vs. what's live

The attached reference is the original Procore design mock — six equal columns,
uniform height, each list starting at the top and scrolling if it overflows:
Divisions Served, Trades Served, Master Categories Served, Key Products, Subcategories,
Categories. All six were rich (10–14 items) because the mock predates real per-vendor
data — every list was invented for the demo.

The live page structurally matches that (same six equal-width columns, same uniform
height, same top-anchored scroll — confirmed in-browser: `grid-template-columns:
repeat(6, minmax(0,1fr))`, every card the same measured width and height, `scrollTop:0`
on every card, first list item rendering first). **The columns are not different
widths and are not showing scrolled-to-the-bottom content in the current build** —
that specific glitch does not reproduce here at `1536×864`. Most likely a mid-load
screenshot (the page shows a bare "Loading…" state for a beat before data populates —
reproduced during testing) or a stale cache on the machine the screenshot was taken on.

### What is real, and does explain "looks weird"

Since `hierarchy-import.md` (HX-04/HX-09), **Division** and **Master Trade** each carry
exactly one real value per vendor — the client's own classification, not a synthetic
list. Rendered top-anchored in a box sized to match the other four columns, one line of
text sits at the top of a mostly-empty ~148px box. Next to four columns still showing
8–12 lines each, the row reads as broken: two columns look like they failed to load.

### What's unrelated and explicitly not touched here

`Key Products`, `Subcategories`, and `Categories` are still populated from invented
filler (a hardcoded list, and product names built by string concatenation) —
flagged as a separate, undecided item in `hierarchy-import.md` §6 ("Deryck's call, not
a silent rewrite"). This spec does not touch that. Making Division/Master Trade's
correctness match the other four columns' *fakeness* is not on the table; only how the
now-correct sparse columns are framed is.

---

## 2. Fix

### VM-01 · Center a card's content only when it doesn't need to scroll
A card whose list fits without overflowing gets `justify-content:center` on
`.lcard-body`, so one line of real data reads as a deliberate, calm answer instead of
top-left flotsam in a lot of white space. A card whose list overflows keeps normal
top-anchored scroll — **must not** apply `justify-content:center` to a scrolling
container: Chrome will center the *scroll range* itself, letting `scrollTop` start
negative and hiding the first items until the user scrolls up past zero. That failure
mode looks exactly like the reported bug (blank space, a couple of lines pinned to the
bottom, a scrollbar) — the fix must not accidentally build the thing it's fixing.

Decided per-card, after render, by measuring: `ul.scrollHeight <= body.clientHeight`.

### VM-02 · Defensive scroll reset
Whatever produced the client's screenshot, resetting `body.scrollTop = 0` on every
render costs nothing and rules out a stale-scroll-position explanation outright.

---

## 3. Acceptance

| # | Check |
|---|---|
| 1 | All six cards remain equal width and equal height |
| 2 | Division / Master Trade (1 item): item is vertically centered, no scrollbar |
| 3 | Key Products / Subcategories / Categories (overflowing): unchanged — top-anchored, scrollbar, `scrollTop` starts at 0 |
| 4 | No card ever shows blank space above its content with a scrollbar present |
| 5 | Verified on a vendor with a real single Division + Master Trade (STACK) and re-checked after a fresh load, not just the first paint |

---

## 4. Build log — 2026-09-02

Root cause landed on: the reported bug (uneven columns, content scrolled to the
bottom) does not reproduce in this build — most likely a mid-load screenshot or a
stale cache. What's real and worth fixing is the visual mismatch VM-01 targets, and
that's what shipped.

| # | Check | Result |
|---|---|---|
| 1 | Six cards equal width/height | Confirmed unchanged — `234.8×176.55` on every card at 1536×864 |
| 2 | Division / Master Trade centered, no scrollbar | `is-short: true`, `scrollH === clientH` (148/148) |
| 3 | Key Products / Subcategories / Categories unchanged | `is-short: false`, `scrollH 180–264 > clientH 148`, top-anchored |
| 4 | No card shows blank-then-content-at-bottom | `scrollTop: 0` on all six, on every card |
| 5 | Re-checked on a second vendor (PlanSwift) after a fresh load | Same 3-short/3-scrolling split, fold intact, no console errors, no horizontal scroll |

Contractor Types also came out `is-short` on both vendors tested (4 items comfortably
fit the box) — expected, not special-cased; it's the same measurement, not a fourth
rule.
