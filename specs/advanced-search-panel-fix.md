# Advanced Search — filters panel and sidebar density

**Source:** `This is the reference advanced search page and the below one is the current Advanced search page.docx`, 2026-09-01
**Target file:** `advanced-search-results.html`
**Correction IDs:** `AS-06` (carried over from `corrections-2026-08-23.md`), `AS-07`, `AS-08`

> "Look at the reference Advanced filters section. This has more options but the
> current shows company size and available on. Make it like the reference one and remove
> any 3 points from markets served so that it fits in the screen well. If you still face
> problem to fix everything in a screen then show vendors till 7 not 10 like the search
> result page."
>
> "Make this section like this. The current one shows 12 options and then shows view more,
> if it shows 4 and then says show more then I think it will also fit in the screen."

---

## 1. Measured now — 1536×864

| Region | Value |
|---|---|
| Advanced Filters body | 2 groups, 2 columns, 138px, **scrolls internally** |
| Sidebar box | 796px |
| Sidebar content | **2,218px** — 2.8× overflow |
| Table box | 500px, row 47px, 10 rows visible |

Sidebar facets, untruncated:

| Facet | Items | Height |
|---|---:|---:|
| Categories | 12 | 376 |
| Subcategories | 8 | 272 |
| Products | 8 | 272 |
| Master Trades | 11 | 366 |
| Divisions | 8 | 272 |
| **Trades** | **22** | **636** |

---

## 2. Changes

### AS-06 · Advanced Filters → 5 groups in 3 columns

Replace Company Size + Available On with the reference layout:

| Column | Groups |
|---|---|
| 1 | **Evaluation Options** — Free Trial / Freemium · Demo on Available · Peer Reviewed<br>**Purchase Options** — Subscription · One-Time Purchase · Contract Per Quarter |
| 2 | **Company Type** — Public Company · Private Company<br>**Available On** — Web Browser · Mobile App · Desktop Software |
| 3 | **Markets Served** — 7 entries, see below |

**Markets Served: 10 → 7.** Removing three, per the instruction:

| Removed | Why |
|---|---|
| `Indutrdura` | Not a word — a typo in the reference artwork |
| `Infrastructure` | Overlaps *Civil / Heavy Highway* |
| `Industrial` | Overlaps *Energy / Utilities* and *Civil / Heavy Highway* |

Kept: Civil / Heavy Highway · Commercial · Education · Energy / Utilities ·
Government / Public Works · Healthcare · Retail / Hospitality.
*Chosen to leave seven non-overlapping markets. Swap freely — these are display-only
until the data exists (open item 4.1).*

Each of the three columns then runs ~150px, so the panel needs `max-height` raised from
`16vh` and must not scroll internally.

**Company Size is dropped from the panel** — it is absent from the reference. It still
has real data, so it stays available as a sidebar facet rather than being lost.

### AS-07 · Sidebar facets truncate to 5 + "view more"

The reference shows **5 rows per facet** then `view more …`. Current code deliberately
renders every option; the comment says truncating risked a URL filter landing outside the
visible slice.

Keep that safety: when a filter arrives via URL for an item outside the first 5, that
facet auto-expands so the checked box is visible.

Expected: sidebar content 2,218px → roughly 1,000px.

> The instruction suggests 4. The reference shows 5. Building 5 and measuring; dropping to
> 4 only if 5 does not fit.

### AS-08 · Table must scroll, not clip

`.tscroll` is `overflow-y:hidden`. Rows that do not fit are **silently unreachable** —
there is no way to scroll to them. Today 10 of 10 fit so it is invisible; once the filter
panel grows it would start hiding rows.

Change to `overflow:auto`, matching `results.html`, and make the header sticky.

**This replaces the "show 7 not 10" fallback.** Rather than an odd page size, the table
shows as many rows as fit and scrolls for the rest, so the page still occupies one screen
and no vendor becomes unreachable.

---

## 3. Acceptance

| # | Check |
|---|---|
| 1 | Advanced Filters shows 5 groups in 3 columns |
| 2 | Markets Served lists exactly 7; no `Indutrdura` |
| 3 | Advanced Filters panel does **not** scroll internally at 1536×864 |
| 4 | Each sidebar facet shows ≤5 rows plus a working "view more" |
| 5 | A URL filter for an item outside the first 5 still shows as checked |
| 6 | Sidebar content height reduced by ≥50% |
| 7 | The 100dvh fold still equals the viewport; only the footer sits below |
| 8 | No row is unreachable — table scrolls rather than clipping |
| 9 | No horizontal page scroll at 1280 / 1440 / 1600 |
| 10 | No console errors |

---

## 4. Result — implemented and verified 2026-09-01

| # | Check | Result |
|---|---|---|
| 1 | 5 groups, 3 columns | ✅ Evaluation Options · Purchase Options · Company Type · Available On · Markets Served |
| 2 | Markets Served = 7, no typo | ✅ |
| 3 | Panel does not scroll internally | ✅ 201px, fits |
| 4 | ≤5 rows per facet + view more | ✅ all 7 facets |
| 5 | URL filter outside the first 5 still visible | ✅ auto-expands, checked, others stay capped |
| 6 | Sidebar content down ≥50% | ⚠️ 2,218 → 1,398 (**37%**) — see note |
| 7 | Fold == viewport | ✅ at 1280 / 1536 / 1920 |
| 8 | No unreachable rows | ✅ 10 rendered, 12–17 fit depending on height |
| 9 | No horizontal page scroll | ✅ |
| 10 | No console errors | ✅ |

**On #6.** 37%, not the 50% targeted — because a **seventh** facet was added. Company
Size was in the Advanced Filters panel, and the reference drops it from there; since it
has real data for all 1,463 vendors, deleting it would have silently removed a working
filter. It moved to the sidebar instead. Per-facet the reduction is much larger
(Categories 376→170, Trades 636→170); the sidebar now holds 7 facets in less space than
6 used before.

**A bug found while implementing #5.** `renderSidebar()` ran at script load, before the
URL query was parsed, so `activeFilters` was still empty and the auto-expand could never
trigger — a filter arriving via URL for an item past the cut filtered the table correctly
but showed nothing checked. Fixed by re-rendering the sidebar inside `prep()` once
`activeFilters` is known.

**On the "show 7 vendors not 10" fallback.** Not needed. With `AS-08` the table scrolls
instead of clipping, and 12–17 rows fit depending on viewport height, so all 10 are
visible without shrinking the page size.
