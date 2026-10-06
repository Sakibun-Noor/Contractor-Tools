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

## Update 2026-10-06 (client answers)

- **Phone redirect: approved.** `vercel.json` now redirects phone user agents (iPhone, iPod, Android phones, Windows Phone, BlackBerry) from `/`, `/index.html`, `/results.html`, `/advanced-search.html`, `/advanced-results.html`, `/vendor-profile.html` to the matching `/m/` page (temporary 307). Tablets and desktops are not redirected. **Untested on Vercel** (cannot run Vercel routing locally); test on a real phone right after the push. To undo, delete the six new entries at the top of `redirects`.
- **CSI codes hidden: confirmed.** Deryck: division numbers are meaningless to the user; use only the text name for the first four digits (Divisions = xx 00 00, Trades = xx xx 00). Our data already follows this. Only 5 trades carry a six-digit code (Surveyors, Selective Demolition, Green Roof Contractors, TAB, Dewatering); the code is hidden, so they show as names.
- **Link color: black.** Result values and descriptions are black. There is no hover on touch, so a pressed link turns blue + underlined. "+N more..." and domain links stay blue, as on landscape.
- **Bottom tabs: confirmed** (Directory = Advanced Search, Vendors = Advanced Results, Content = coming-soon message).
- Deryck asked for an explanation or screenshots on (a) Quick Facts and Save Vendor appearing twice, and (b) link color on touch. Annotated image: C:\Users\User\Desktop\ctd\for-deryck\vendor-page-duplicates.png.

## Decisions made without an answer (change on request)

1. (answered) CSI codes hidden.
2. (answered) Result values are black.
3. (answered) Bottom tabs: Home = home, Search = Search / Results, Directory = Advanced Search, Vendors = Advanced Results (all vendors), Content = "coming soon" message (no page exists).
4. Vendor Page section titles follow the template ("Divisions of Work", "Construction Trades").
5. Vendor Page keeps the "ALL ..." wildcard for Master Groups / Divisions / Trades, as landscape's Vendor Page does.
6. Advanced Filters group checkbox = select / clear every option in that group.
7. Advanced Results "Quick Facts" = Cloud-Based (+ API Available); "Available On" = Web Access or Mobile App. The data has one list; this splits it.
8. Sizes are about 1.3x the template's proportions so text is readable on a real phone. Quick Facts columns on the Vendor Page stack icon over value, and its chevron sits top-right, so five columns fit.

## Gaps that need the client

- **Descriptions** under list items exist only for the items the template shows, plus the 12 categories. Seven category one-liners are drafted by us from the client's tooltips (marked in `m-desc.js`). All other subcategories, products, divisions and trades show no description line.
- **Hero** is taller than the template (2.7:1 vs about 3.2:1) because our art cannot be cropped to the template's shape without losing the workers or the AI icons.
- **Vendor logos** are small favicons scaled up, so they look soft (same data as landscape).
- **Phone redirect** is in `vercel.json` but untested on Vercel until it is pushed.

## Verified

Chrome emulation at 320, 360, 390 and 430 px wide: no horizontal overflow on any page (320 clips the four Advanced Results buttons slightly before the final font fix; rechecked at 360-430 clean).
No console errors on any page. Flow tested: Advanced Search filters (26 matches) -> Advanced Results (26). Counts match the template's sample data (categories 284/219/217/172/125, master groups 90/67/79/24/24, trades 87/83/76/74/74).
