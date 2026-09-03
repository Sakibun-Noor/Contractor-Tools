# Display format — landscape alignment (desktop + laptop)

**Source:** `09.02.26 Display Format Corrections.docx`, received 2026-09-03 (client, via Sakib),
plus a screenshot of the homepage on the client's laptop.
**Client's words:** the site "looks broken on the homepage and other pages" — misaligned
between his desktop PC (large monitor) and his laptop (smaller screen). The doc he
attached is a generic AI write-up on responsive layout — not a correction list.
Directionally right, not a spec.
**Scope:** **landscape only — desktop monitors and laptop screens.** Phone / portrait
tablet layouts are explicitly out of scope for this round and are not to be touched.
**Correction IDs:** `DF-01`, `DF-02`

---

## 1. What actually breaks — audit, 2026-09-03

Tested the live site (`contractor-tools-six.vercel.app`) across landscape viewport sizes.
The report reproduces.

### 1.1 The client's screenshot — homepage category grid overlaps its own labels

Reproduced at any viewport **≥ 1024 px wide and roughly ≤ 700 px tall**. That is a
common laptop case:

| Laptop | OS scaling | CSS viewport | Result |
|---|---|---|---|
| 1920×1080, 15" | 150% | ~1280×590 | **breaks** |
| 1920×1080 | 125% | 1536×864 | fine |
| 1536×864, 13" | 100% | 1536×738 | fine |
| 1366×768 | 100% | 1366×651 | borderline / breaks with a bookmarks bar |

At 1536×625, measured in-browser:

- `.fold-100` is locked to `height: 625px` (`100vh`).
- The 4-row fold grid (`grid-rows-[auto auto minmax(0,1fr) auto]`) hands the category
  `<section>` only **169 px**.
- Inside it, the tile grid is `grid-cols-6 grid-rows-2 h-full`, and every tile carries
  `min-height: 88px` (the icon-collapse floor added in a prior round).
- Two rows of 88 px tiles need 176 px. In a **fixed-height** CSS grid that is shorter
  than the sum of its row minimums, the rows don't push the container taller — **they
  overlap**. Measured: row-1 tile bottom 492 px, row-2 tile top 470 px → the rows
  overlap by ~22 px, so row-2 icons paint on top of row-1 labels ("ESTIMATING,
  TAKEOFF", "PROJECT MANAGEMENT", "DISPATCH" all get an icon through the text).
- The page **scrolls anyway** (`scrollHeight` 857 > 625). So the `100vh` lock is
  already failing its own "everything on one screen" goal at this size — it just fails
  by overlapping instead of by scrolling cleanly.

**Root cause:** `height: 100vh` (a *fixed* height) on `.fold-100`, combined with a
category row whose real minimum (2 × 88 px tiles + heading) the fold math doesn't
reserve. This is the "fold arithmetic is fragile" note from the last handoff, hitting
for real.

### 1.2 The other five pages — cramped at short heights, not broken

`results.html`, `advanced-search-results.html`, `dedicated-search.html`,
`dedicated-results.html`, `vendor-profile.html` all use the same
`height:100vh;height:100dvh` shell — **but** each has an inner `overflow:auto` scroll
region, so at short heights they degrade to "only ~2–3 table rows visible, scroll inside
the box" rather than overlapping. Functional; tight under ~620 px tall.

Two concrete clips at 1440×560, both content inside an `overflow:hidden` shell child:

- `vendor-profile.html`: the left rail's **"Request a Demo" / "Save Vendor"** buttons
  are cut off at the fold.
- `advanced-search-results.html`: the last visible table row's **"View Profile"**
  button is cut mid-height.

### 1.3 What is *not* the problem

The doc's theory ("no `max-width` container, elements stretch flat on big monitors") is
not what's happening — the layout already caps every section (`max-w-[1620px]`,
`max-w-[1760px]`, etc.) and does not stretch on wide monitors. The bug is purely the
vertical `100vh` lock on short viewports.

---

## 2. Decisions

1. **Keep the one-screen look where it fits; scroll gracefully where it doesn't.**
   Don't rip out the fold design — on viewports tall enough for it (≈1536×760 and up,
   which includes the client's desktop) it stays pixel-identical. Below that, the page
   grows by whatever it needs and the window scrolls a little. The client never
   complained about scrolling — only about overlap.
2. **`min-height` instead of `height`** on the fold wrapper: the fold is a *minimum*
   canvas, not a straitjacket.
3. **Give the category row a real pixel floor** so it can never be handed less space
   than two rows of tiles need. Plain pixel value, not `min-content` — per the
   vendor-page grid-trap note in the last handoff, `min-content` is unreliable with
   flex/overflow children.
4. Preserve every cross-browser fallback already in the files: `vh` before `dvh`, the
   `@supports not (aspect-ratio)` hero min-height, the no-Tailwind guard rules. The fix
   edits values, not the fallback structure.
5. **Do not touch the existing mobile / `max-lg` / `max-width:1199px` blocks.** They
   already release the fold below desktop; out of scope this round and no reason to
   disturb them.

---

## 3. Fixes

### DF-01 · Homepage — release the fold height, floor the category row
`index.html`, `<style>` block and the `.fold-100` wrapper.

- `.fold-100`: `height: 100vh; height: 100dvh;` → `min-height: 100vh; min-height: 100dvh;`
  (keep both lines, vh first — the dvh fallback rationale in the inline comment still
  holds).
- Leave `@media (max-width: 1023px) { .fold-100 { height: auto } }` as-is — it only
  overrides `height`, which no longer exists; harmless, and it's mobile territory.
- Fold grid template: `grid-rows-[auto_auto_minmax(0,1fr)_auto]` →
  `grid-rows-[auto_auto_minmax(220px,1fr)_auto]`.
  220 px ≈ heading (~30 px at desktop clamp) + 2 × 88 px tiles + the wrapper's bottom
  padding + margin. Above the fold's slack point this row is still effectively `1fr`
  and nothing changes; below it, 220 px is the floor on how far the row can be
  squeezed, so tiles get ≥ ~93 px each — no overlap.
- Belt-and-suspenders: add `min-h-[176px]` to the inner tile-grid `<div>`
  (`grid-cols-6 grid-rows-2 …`) so the two tile rows keep their combined floor even if
  the wrapper math is ever disturbed again.

**Verify DF-01 at:** 1280×590, 1280×720, 1366×640, 1366×768, 1440×560, 1440×900,
1536×610, 1536×625, 1536×864, 1600×900, 1920×1080, 1920×1080@125% (=1536×864),
1920×1080@150% (=1280×720), 2560×1440.
Pass = no icon touches a label at any of them; category grid fully visible (after a
short scroll where the screen is genuinely too short); and at 1536×864 / 1920×1080 the
page still fits one screen with no scrollbar and is visually identical to the current
build.

### DF-02 · The other five pages — stop clipping actionable controls at the fold
Keep the `100dvh` shell (these pages scroll internally), but a **button must never be
half-cut by `overflow:hidden`**.

- `vendor-profile.html`: the left rail — let its own content scroll (`overflow-y:auto;
  min-height:0` on the rail) or otherwise stop the shell clipping its buttons, without
  changing the right-hand content column.
- `advanced-search-results.html` / `dedicated-results.html`: the results `.tscroll`
  box already scrolls; the clip is the wrapper sitting 1–2 px short of a full row. Add
  a small bottom padding / `scroll-padding-block-end` inside `.tscroll` so the last
  row's action button is always fully reachable.
- Re-check `results.html`, `dedicated-search.html` at 1440×560 and 1280×600 — apply the
  same treatment only where a control is actually clipped; if it's just tight
  whitespace, leave it.

**Verify DF-02 at:** 1280×600, 1366×640, 1440×560, 1536×720 on all five pages.
Pass = every button fully visible or reachable by scrolling within its own region; no
new horizontal scroll; tall-viewport layout unchanged.

---

## 4. Acceptance (whole round)

| # | Check |
|---|---|
| 1 | Homepage: no label/icon overlap at any tested landscape size 1024–2560 wide |
| 2 | Homepage at 1536×864 and 1920×1080: fits one screen, no vertical scrollbar, visually identical to the pre-fix build |
| 3 | Homepage: category grid fully visible (small scroll allowed only where the screen is genuinely too short) |
| 4 | Five inner pages: no button clipped at the fold at 1280×600 / 1440×560 |
| 5 | All six pages: no horizontal scroll at 1024, 1280, 1366, 1440, 1536, 1920, 2560 |
| 6 | No console errors on any page at any tested size |
| 7 | Tailwind-blocked fallback (`index.html`): fold still doesn't stack into a pile |
| 8 | Phone / portrait layouts unchanged from the current build (diff shows no rule touched inside a mobile media query) |

---

## 5. To raise with Deryck

1. The fix is straightforward and shipping. The site will look identical on his big
   monitor; on the laptop the category tiles will sit correctly and the page may scroll
   ~50–80 px depending on the exact screen — that's expected and correct, not a
   regression.
2. For the record: his laptop screen size and Windows display scaling
   (Settings › Display › Scale) — lets us confirm against his exact viewport, though
   the fix already covers the whole landscape range.

---

## 6. Build log

### DF-01 — 2026-09-03

Three changed declarations in `index.html` (plus comment rewrites), and the same two
rules mirrored into `assets/tailwind-fallback.css` so the no-CDN path gets the fix
(that file's stated job is preventing this exact tile overlap). Fallback cache query
bumped `?v=202609021320` → `?v=202609031600`.

| | before | after |
|---|---|---|
| `.fold-100` (inline `<style>`) | `height:100vh;height:100dvh` | `min-height:100vh;min-height:100dvh` |
| `.fold-100` wrapper grid | `grid-rows-[auto_auto_minmax(0,1fr)_auto]` | `grid-rows-[auto_auto_minmax(220px,1fr)_auto]` |
| inner tile grid `<div>` | `min-h-0` | `min-h-[176px]` |

Verified against a local build (`build/serve.ps1`), in-browser, at 10 landscape sizes
plus the Tailwind-blocked fallback:

| Viewport | Result |
|---|---|
| 1280×590 (15" 1080p @150% — the client's likely screen) | no overlap; all 12 tiles within the viewport; worst label→next-icon gap **+12 px** (was −10 px). Fold grew to 623 px, ~33 px scroll for the FIND bar. |
| 1536×610 (matches the client's screenshot) | no overlap |
| 1536×625, 1440×560 | no overlap; last tile row 14–24 px below the fold |
| 1280×720, 1366×768 | still exactly one screen, no overlap |
| 1536×864 (1080p @125%), 1920×1080, 2560×1440 | fold == viewport, FIND bar within the fold, visually identical to the pre-fix build |
| 1024×690 (narrowest before the mobile breakpoint) | clean, one screen |
| Tailwind CDN blocked, 1280×590 | fallback stylesheet active (`tailwind` undefined), no overlap — identical to the CDN path |

No console errors and no horizontal scroll at any size. Phone / `max-lg` blocks not
touched (`git diff` shows no rule changed inside a mobile media query).

Shipped straight to `main` (auto-deploys) at the user's instruction so Deryck can check
it on his laptop.

### DF-01b — 2026-09-03 (follow-up: "content section is below the fold")

Deryck's reply after DF-01 deployed: the overlap was gone, but on his laptop the
FIND/LEARN/RESEARCH/INSIGHTS bar now sat ~27 px below the fold and he wanted it back
on one screen. He suggested a shorter hero image; the two crops he sent
(`1798×875` with white letterbox ≈ 4.5:1 content, then `houhj.jpg` 1798×335 = 5.37:1)
were both ~the same ratio as the live 5.15:1 art, so they'd save ~10 px — not enough.

Chosen fix ("Path B"): tighten the four above-the-fold bands **only on short landscape
viewports**, no new art. One media query added to `index.html`'s `<style>`:

```
@media (min-width: 1024px) and (max-height: 720px) {
  .fold-100 > header > div        { height: clamp(58px, 9vh, 76px); }   /* 76 → 58 */
  .hero-band                       { max-height: 37vh; }                 /* caps the hero on short screens */
  .hero-band img                   { object-position: center 28%; }      /* crop downward, protect the top hexagons */
  section[... "Workflow categories"] > h2      { padding-block: 3px; }
  section[... "Discovery pathways"] a          { padding-block: 9px; }
}
```

All semantic selectors — applies with or without the Tailwind CDN, no
`tailwind-fallback.css` change needed. Only ever tightens; the 88 px tile floor from
the DF-01 block still holds, so icons can't collapse. `> 720 px` tall is untouched.

Verified in-browser (local build) — "above-fold fits" = the FIND bar's bottom is at or
above the viewport bottom:

| Viewport | above-fold fits | overlap | worst label→icon | notes |
|---|---|---|---|---|
| 1280×590 (client's likely screen) | ✅ fold 590 | none | +25 px | header 58, hero 218, tiles 111 |
| 1280×560 | ✅ fold 560 | none | +20 px | hero 207, hexagons still intact |
| 1280×600 / 1280×720 | ✅ | none | +27 / +35 | |
| 1440×620, 1600×680 | ✅ | none | +25 / +29 | |
| 1366×768 (media query off) | ✅ one screen | none | — | **identical to DF-01** |
| 1536×864, 1920×1080 (media query off) | ✅ one screen | none | — | **identical to DF-01**, hero `max-height: none`, `object-position: 50% 50%` |
| no-Tailwind fallback @1280×600 | ✅ | none | +27 | identical to the CDN path |

No console errors, no horizontal scroll at any size.

### DF-02 — 2026-09-03

Re-audited all five inner pages at 1280×590 (the client's viewport). Only one had a
genuine broken state:

| Page | Short-landscape behaviour | Action |
|---|---|---|
| **vendor-profile.html** | The `100dvh` grid shell compressed `main`'s rows — the `.vendor-top` row was handed 182 px when its rail needs 238 px for the Visit / Demo / Save buttons, so the info-card grid painted **on top of** the "Save Vendor" button (`elementFromPoint` returned `.lcard-hd`, not the button — genuinely unclickable). | **fixed** |
| results.html | Table ~2 rows but `.tscroll` scrolls internally; pagination fully visible; nothing unreachable. | left as-is |
| advanced-search-results.html | Advanced Filters panel is tall, table ~2.5 rows, but `.tscroll` scrolls; pagination visible; panel is user-collapsible. | left as-is |
| dedicated-search.html | Selector cards short but `.sel-list` scrolls; "Search Vendors" button fully visible; no overlap. | left as-is |
| dedicated-results.html | `.tscroll` gets ~400 px (~7 rows); fine. | left as-is |

**vendor-profile.html fix** — one new media query, mirroring the page's existing
`@media (max-width: 999px)` mobile unlock but for short landscape:

```
@media (min-width: 1000px) and (max-height: 720px) {
  .page-above-fold { height: auto; display: block; overflow: visible; }
  .page-above-fold > * { overflow: visible; }
  main { height: auto; display: block; overflow: visible; }
  .vendor-top { margin-bottom: 14px; }
  .vendor-list-grid { margin-bottom: 14px; }
  .vendor-bottom { margin-bottom: 8px; }
  .lcard-body { max-height: 150px; }
  .bcard { max-height: 220px; overflow-y: auto; }
}
```

Drops the vertical `100dvh` lock and lets the page flow and scroll normally — no grid,
so no row compression, so no overlap. Column counts unchanged (still a wide screen);
card bodies kept scrollable so they don't run long. Nothing structural touched, and
`> 720 px` tall is byte-for-byte the current layout.

Verified in-browser:

| Viewport | vendor-profile |
|---|---|
| 1280×590, 1280×720, 1440×620, 1600×680 | shell unlocked; Visit / Demo / **Save** + the 3 top-action buttons all clickable; no `.vcard` ↔ info-grid overlap; footer not overlapped; no horizontal scroll; page scrolls ~350 px |
| 1280×725, 1280×760 | grid lock still active, no overlap (transition across 720 is clean) |
| 1366×768, 1536×864, 1920×1080 | `display: grid`, fits one screen — **identical to the current build** |
| 900×700 (mobile-ish) | `@media (max-width: 999px)` block owns it, unchanged |

No console errors. The other four pages were left untouched — deliberately, to avoid
regressing the SR-11 density / advanced-filter-panel / footer rounds when nothing on
them is actually unreachable.
