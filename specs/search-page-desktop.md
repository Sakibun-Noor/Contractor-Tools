# Search Results Page — Desktop Spec

Source design: `07.23.26 Search Results LandscapeFF.png` (1672×941)
Target file: `results.html`
Data source: `assets/tools-data.js` (`window.TOOLS`, 600 vendors)

## Palette (sampled from the design)
- Navy (header, footer, table header, primary button): `#00164B`
- Navy hover/deep: `#001238`
- Orange accent (TRADE, PRODUCT, logo bar): `#F26A1B`
- Blue (MASTER TRADE, CATEGORY headings + links): `#1B5FD0`
- Vendor link blue: `#1C57B8`
- Green (DIVISION, SUBCATEGORY headings): `#158526`
- Alt-row cream: `#FBF6EF`
- Border/line: `#E4E9F0`
- Page background: `#FFFFFF`
- Muted text: `#6B7793`

## Layout (top → bottom)

### 1. Header (sticky, navy `#00164B`)
- Left: logo block — building mark + "THE CONSTRUCTION / TECHNOLOGY / DIRECTORY" (orange TECHNOLOGY).
- Center: large rounded search input, placeholder `Search Company, Product, Category, Trade or Keyword`, magnifier button on the right (navy).
- Right: 4 icon+label nav items — **About Us · Contact Us · Add / Modify Info · Home** (white, circular line icons above labels).

### 2. Title row
- Left: `SEARCH RESULTS` (H1, heavy, navy) + subline `1,248 companies match your search criteria.` (count is live = filtered vendor count).
- Right: 3 buttons — `☆ Save Search` (white, outline), `⭳ Export Results` (white, outline), `⚑ Advanced Filters` (solid navy, white text).

### 3. Two-question panel (2 white cards side by side, subtle border + shadow)
Each card: bold question label + a `Start typing…` search input (magnifier), then 3 columns, each with a colored icon + heading, 4 sample links, and a `View all … ›` link.

- **Left card — "WHAT DO YOU DO?"**
  - MASTER TRADE (blue): General Contractors & Project Delivery · Industrial Trades · Electrical & Technology Trades · Civil & Sitework → View all master trades
  - DIVISION (green): 00 – General · 01 – General Work of Practice · 02 – HVAC · 31 – Drywall → View all divisions
  - TRADE (orange): Concrete Contractor · HVAC Contractor · Electrical Contractor · Plumbing Contractor → View all trades
- **Right card — "WHAT ARE YOU LOOKING FOR?"**
  - CATEGORY (blue): live from the 12 real categories → View all categories
  - SUBCATEGORY (green): Project Scheduling · Daily Logs · RFIs · Project Collection → View all subcategories
  - PRODUCT (orange): sample product names → View all products

Clicking a CATEGORY link filters the results table by that category.

### 4. Results table (full width, bordered)
- Header row: navy `#00164B` background, white text. Columns:
  `# | VENDORS | CATEGORIES | SUBCATEGORIES | PRODUCTS | MASTER TRADES | DIVISIONS | TRADES | ACTIONS`
- Every sortable column header shows a `↑↓` sort control; clicking sorts by that column.
- Rows alternate white / cream `#FBF6EF`. Each row:
  - `#`: rank within the current page.
  - VENDORS: favicon + vendor name (blue link → `/tool/<cat>/<slug>.html`).
  - CATEGORIES / SUBCATEGORIES / PRODUCTS / MASTER TRADES / DIVISIONS / TRADES: value text + a blue `more…` link where the field has extra items.
  - ACTIONS: globe icon (visit site), bookmark icon (save), `View Profile` blue link.
- Data mapping (real where available, placeholder until the taxonomy file lands):
  - VENDORS = `t.n`, CATEGORIES = category labels of `t.c`, SUBCATEGORIES = `t.sub` — **real**.
  - PRODUCTS, MASTER TRADES, DIVISIONS, TRADES = derived/placeholder for now; swap in real values when the Master-Trade→Division→Trade taxonomy + product data are provided.

### 5. Pagination row
- Left: `1,248 vendors match your search criteria` (live count).
- Center: `‹  1 2 3 4 5 … 125  ›` (current page navy-filled).
- Right: `Results per page: [10 ▾]` (10 / 25 / 50).

### 6. Footer
- Reuse the approved footer image `assets/hero/footer-hero-desktop.webp` with hotspot overlay (identical to the homepage footer).

## Interactions
- Header search + both `Start typing…` inputs filter the table live.
- Column sort on header click.
- Category links + pagination + per-page selector all update the table.
- Save Search = copy shareable link (no login). Export Results / Advanced Filters = wired later.
