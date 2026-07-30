# Search Results Page — Mobile Spec

Source design: `07.23.26 Search Results PortraitFF.png` (941×1672)
Same page as desktop (`results.html`) — this spec covers only what changes below the `760px` breakpoint. Same palette and content as `search-page-desktop.md`.

## Reflow (top → bottom)

### 1. Header (navy, stacks)
- Row 1: logo (left) + the 4 nav items (About Us · Contact Us · Add / Modify Info · Home) to the right, smaller.
- Row 2: full-width search input with magnifier button.

### 2. Title row (stacks)
- `SEARCH RESULTS` + count on top.
- The 3 buttons (Save Search / Export Results / Advanced Filters) wrap onto their own row below the title, full-width-ish.

### 3. Two-question panels (stack vertically)
- "WHAT DO YOU DO?" card first, then "WHAT ARE YOU LOOKING FOR?" card below it.
- Inside each card the 3 taxonomy columns stay as columns while width allows, collapsing toward a single column on the narrowest phones.

### 4. Results table
- Keep the same columns as desktop (do **not** drop columns).
- Wrap the table in a horizontally-scrollable container (`overflow-x:auto`) so the full column set is preserved and the **page itself never scrolls sideways** — only the table does.
- Rows are taller to fit wrapped multi-line cell text, matching the portrait mockup.

### 5. Pagination (stacks / wraps)
- Count line, then the page controls, then `Results per page` wrap onto separate lines.

### 6. Footer
- Swap to `assets/hero/footer-hero-mobile.webp` (shown at `≤760px` via the same `view-desktop` / `view-mobile` toggle used on the homepage).

## Rules
- No horizontal overflow on the page body at any width (only the table container scrolls).
- All hotspots / links remain percentage- or flex-based so nothing drifts across phone sizes.
- Touch targets ≥ 40px tall.
