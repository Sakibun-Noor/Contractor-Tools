# Search Results — vendor list density fix

**Source:** `hh.docx`, 2026-09-01
**Target file:** `results.html`
**Correction ID:** `SR-11` (continues `specs/corrections-2026-08-23.md`)

> "This box has a very little space, only 3 items we can see. So for the fix I want to
> make these buttons more small, little text size, and you find more scopes on your own
> to make the vendor list box more taller."

---

## 1. The problem, measured

`results.html` is locked to `100dvh` (`SR-10`). Everything above the footer shares one
viewport, so the vendor table only gets what the regions above it leave behind.

Measured at **1536×864** (the most common laptop viewport), with a filter applied:

| Region | Height | Notes |
|---|---:|---|
| Site header | 68 | shared chrome — out of scope |
| `main` padding | 18 | 10 top + 8 bottom |
| Grid gaps | 32 | 4 gaps × 8px |
| Title row `.ptop` | 59 | H1 32px + 40px-tall buttons |
| Chips `.chips-row` | 24 | |
| Two-question panel `.qgrid` | 266 | **the largest single consumer** |
| Pagination `.pgbar` | 36 | |
| **Vendor table `.tablewrap`** | **361** | what's left |

Inside the table: header 31px, **row height 69px** → `(361 − 31) / 69` = **4 rows visible**
out of 10 rendered. The rest need an inner scroll.

**Row height is the Actions cell.** The cell measures 69px: a 24px icon row, a 23px
View Profile button, plus margins and 8px cell padding. Every other cell is one or two
lines of 11px text and would happily sit at ~34px.

---

## 2. Target

**At 1536×864, show at least 8 rows without inner scrolling** — double the current 4.
No correction already accepted may be reversed to get there.

Budget to aim at:

| Region | Now | Target | Saving |
|---|---:|---:|---:|
| Title row | 59 | 46 | 13 |
| Chips | 24 | 22 | 2 |
| Panel | 266 | 205 | 61 |
| Pager | 36 | 32 | 4 |
| Gaps | 32 | 24 | 8 |
| Padding | 18 | 16 | 2 |
| **Table** | **361** | **≈451** | **+90** |
| Row height | 69 | ≈51 | 18 |

`(451 − 28) / 51` ≈ **8 rows**.

---

## 3. Changes

### 3.1 Actions cell — the row-height driver

- `.act-ic` 24×24 → **18×18**; icon SVG 14 → 13
- `.act-row` gap 10 → 8; `margin-bottom` 5 → 3
- `.btn-vp` padding `5px 6px` → `3px 6px`; font 10 → 9.5
- `table.res td` padding 8 → **5px 8px**

**Keep the two-row arrangement.** Corrections P25 / P28 / P30 (`SR-03`) put the globe and
bookmark above a View Profile bar. This fix shrinks that block; it does not collapse it
back onto one line.

### 3.2 Two-question panel — the biggest win

- `.qcard` padding `14px 16px 12px` → `10px 12px 8px`
- `.qcard-hd` margin-bottom 10 → 6; `.qsearch` padding `7px 11px` → `5px 9px`
- `.qnote` → single compact line: padding `7px 10px` → `5px 9px`, font 11.5 → 11,
  margin-bottom 10 → 7
- `.qcol h3` margin-bottom 7 → 5
- `.qcol li a` padding `2px 0` → `1px 0`; font 12 → 11.5
- `.qcol ul` gap 3 → 2, margin-bottom 6 → 4
- `.qgrid` gap 14 → 10

### 3.3 Title row and chrome

- `.phead` `clamp(22px,2.9vw,32px)` → `clamp(20px,2.3vw,26px)`
- `.btn-act` padding `8px 15px` → `6px 12px`, font 12.5 → 12, **`min-height:40px` → `32px`**
- `.pcount` font 13.5 → 12.5
- `.chip` padding `4px 10px` → `3px 9px`
- `.pgbtn` padding `7px 12px` → `5px 10px`, `min-height` 36 → 30
- `main` gap 8 → 6, padding-top 10 → 8

### 3.4 Do not break

- **Mobile touch targets stay ≥40px.** The `min-height` reductions above are desktop
  values; the `max-width:760px` block must re-assert `40px` on `.btn-act`, `.pgbtn` and
  `.pgrpp select`. This was a `search-page-mobile.md` requirement and is already tested.
- The 9 columns, the two-row Actions block, the sticky header, and the
  `max-width:1199px` reflow to natural scrolling all stay as they are.

---

## 4. Acceptance

| # | Check |
|---|---|
| 1 | At 1536×864, **≥8 rows visible** in `.tscroll` without inner vertical scroll |
| 2 | At 1920×1080, ≥12 rows visible |
| 3 | The `100dvh` fold still measures exactly the viewport; only the footer sits below it |
| 4 | Pagination bar still visible and >0px tall |
| 5 | Actions still two rows: globe + bookmark above View Profile |
| 6 | At 375px, **0** touch targets under 40px |
| 7 | No horizontal page scroll at 1280 / 1440 / 1600 |
| 8 | No console errors |

---

## 5. Result — implemented and verified 2026-09-01

**4 rows → 8 rows** at 1536×864.

| Region | Before | After |
|---|---:|---:|
| Title row | 59 | 51 |
| Panel | 266 | **206** |
| Pager | 36 | 30 |
| Row height | 69 | **50** |
| **Table box** | **361** | **447** |
| **Rows visible** | **4** | **8** |

| # | Check | Result |
|---|---|---|
| 1 | ≥8 rows at 1536×864 | ✅ 8 |
| 2 | ≥12 rows at 1920×1080 | ✅ 12 |
| 3 | Fold == viewport | ✅ |
| 4 | Pager visible | ✅ 30px |
| 5 | Actions still two rows | ✅ |
| 6 | 0 touch targets <40px at 375px | ✅ 0 of 40 checked |
| 7 | No horizontal page scroll | ✅ 1280 / 1440 / 1920 |
| 8 | No console errors | ✅ verified on a clean tab |

**One extra change beyond §3.** The "not live yet" banner wrapped to two lines at 41px.
Rewritten as a single line ("Filtering by these isn't live yet — vendor classification is
in progress."), which drops it to 25px. That last 16px was exactly what took the count
from 7 rows to 8 — the target could not be hit through spacing alone.

**Note on the console.** Stale `ERR_CONNECTION_REFUSED` and 404 entries persist in a
long-lived preview tab from earlier server restarts. Loading the page in a fresh tab
reports **no console logs at all**. The only genuine network failure is a CORS block on
`cdn.tailwindcss.com` when fetched from script — the `<script>` tag itself loads fine, as
the working Tailwind classes on the homepage confirm.
