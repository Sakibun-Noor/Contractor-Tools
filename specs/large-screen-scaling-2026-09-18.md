# Large-screen scaling (2026-09-18)

## Report

Deryck sent screenshots of all five pages from his desktop. Measured from
them, his browser window was about 5,100 × 2,000 CSS px (a 5K2K ultrawide
at 100%, or a large monitor with the browser zoomed out). Reproduced at
5120 × 2000 on Search / Results:

| | Before |
|---|---|
| Content width | 1,680px of 5,120 (33%) |
| Table text | 11px |
| Empty space under the 10 result rows | 1,208px |

Cause: every page caps its content at ~1,620–1,760px wide and uses
`clamp()` sizes that stop growing around 1920 × 1080, while the shell
fills the full height. On a screen much bigger than 1920 × 1080 the page
stays small and narrow and stretches vertically into empty space.

## Fix

`assets/ctd-scale.js`, loaded in `<head>` on all five pages. When the
window is larger than 1920 × 1080 in both directions, the whole page is
scaled by `min(width / 1920, height / 1080)` with CSS `zoom`, so it looks
like the tested 1920 × 1080 layout, just larger. At 1920 × 1080 and below
nothing changes. It re-runs on resize. This is a size rule, not a device
rule — the same thing happens on any large screen.

Supporting changes:
- `zoom` also multiplies viewport units, so a `100dvh` shell rendered at
  1.85× the screen (3,700px on a 2,000px window). Each page's one-screen
  height is now `calc(100dvh / var(--ctd-zoom, 1))`.
- The Search / Results description tooltip positioned itself from the
  button's on-screen rect (scaled pixels) into `left/top` (page pixels):
  it landed ~1,350px away. Converted with `CTD_zoom()`; now sits under the
  (i) as before.
- Homepage: the hero is full-bleed, so on a screen wider than 16:9 it's
  taller than at 1920 × 1080 and the fold ran 36px past the screen at
  5120 × 2000. When scaled (`.ctd-scaled`), the fold is locked to one
  screen so the category row takes what's left (374px, floor 220px); the
  tiles get a little shorter and never overlap.

Browsers without CSS `zoom` (Firefox before 126) simply don't scale and
look as they did before.

## Verified

All five pages at 5120 × 2000, 3840 × 2000, 2560 × 1300, 1920 × 1080 and
1265 × 553: above-the-fold area exactly one screen, footer starts at the
fold line, no horizontal scroll, no uncaught errors. Zoom 1.85 / 1.85 /
1.2 / 1 / 1. Homepage tiles never overlap (shortest 156px at 5120 × 2000).
At 5120 × 2000 table text renders at ~20px and content spans 61% of the
width; the rest is side margin, because a 2.5 : 1 ultrawide is wider than
the 16 : 9 layout being scaled.
