# 12 — Portrait build log (2026-10-06)

All portrait code lives in `m/` (new). **No landscape file and no shared file was edited.**
Checked by md5 before/after: `index.html`, `results.html`, `advanced-search.html`, `advanced-results.html`,
`vendor-profile.html`, `assets/filters.js`, `autosuggest.js`, `actions.js`, `tools-data.js`, `taxonomy-data.js`, `vercel.json`
are byte-identical. `git status` shows only `m/` and `specs/portrait/`.

## Files

| File | Built from | Notes |
|---|---|---|
| `m/index.html` | 01-home | hero composed from existing art (`mobile-hero-final.png` + `hero-title.png`) |
| `m/search.html` | 02, 03 | both tabs in one page (`?tab=work`) |
| `m/advanced-search.html` | 05-10 | one page, sections expand; Advanced Filters + About the Vendor / Buyer |
| `m/results.html` | 04 | Advanced Results |
| `m/vendor.html` | 11 | Vendor Page |
| `m/m.css`, `m/m.js`, `m/m-desc.js` | shared | header, bottom nav, icons, autosuggest copy, descriptions |

Shared data/logic is read-only: `tools-data.js`, `taxonomy-data.js`, `filters.js`, `actions.js`.
Autosuggest is a portrait copy inside `m.js` because `assets/autosuggest.js` links to landscape pages.

## Decisions made without an answer (change on request)

1. CSI codes hidden (names only), as told to the client for landscape. Templates show them.
2. Result values are blue links, as drawn (no hover on touch).
3. Bottom tabs: Home = home, Search = Search / Results, Directory = Advanced Search, Vendors = Advanced Results (all vendors), Content = "coming soon" message (no page exists).
4. Vendor Page section titles follow the template ("Divisions of Work", "Construction Trades").
5. Vendor Page keeps the "ALL ..." wildcard for Master Groups / Divisions / Trades, as landscape's Vendor Page does.
6. Advanced Filters group checkbox = select / clear every option in that group.
7. Advanced Results "Quick Facts" = Cloud-Based (+ API Available); "Available On" = Web Access or Mobile App. The data has one list; this splits it.
8. Sizes are about 1.3x the template's proportions so text is readable on a real phone. Quick Facts columns on the Vendor Page stack icon over value, and its chevron sits top-right, so five columns fit.

## Gaps that need the client

- **Descriptions** under list items exist only for the items the template shows, plus the 12 categories. Seven category one-liners are drafted by us from the client's tooltips (marked in `m-desc.js`). All other subcategories, products, divisions and trades show no description line.
- **Hero** is taller than the template (2.7:1 vs about 3.2:1) because our art cannot be cropped to the template's shape without losing the workers or the AI icons.
- **Vendor logos** are small favicons scaled up, so they look soft (same data as landscape).
- **Phones are not redirected yet.** `vercel.json` is untouched. Until a rewrite rule is added, portrait is reachable only at `/m/`.

## Verified

Chrome emulation at 320, 360, 390 and 430 px wide: no horizontal overflow on any page (320 clips the four Advanced Results buttons slightly before the final font fix; rechecked at 360-430 clean).
No console errors on any page. Flow tested: Advanced Search filters (26 matches) -> Advanced Results (26). Counts match the template's sample data (categories 284/219/217/172/125, master groups 90/67/79/24/24, trades 87/83/76/74/74).
