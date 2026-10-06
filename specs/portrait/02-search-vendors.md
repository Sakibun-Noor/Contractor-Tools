# 02 — Search / Results: "Search Vendors" tab (portrait)

**Template:** `Search_Vendors.png` — Active bottom tab: **Search**.

## Layout, top to bottom

1. **Header** — shared. Search placeholder: `Search everything`. (The frame has rounded top corners in the image.)
2. **Back link** — `‹ Back to Home Page` (blue, chevron at left).
3. **Title** — `Search / Results` — large bold, with the "/" in orange.
4. **Tabs** (two equal halves, rounded):
   - `Search Vendors` — **active**: orange fill, white text.
   - `Search By Construction Work` — inactive: pale blue fill, blue text.
5. **Three collapsed selectors** (white rounded rows, bold navy label, chevron-down at right):
   - `Category` (list icon)
   - `Subcategory` (layers icon)
   - `Product` (cube icon)
6. **Primary button** — full width, orange, magnifier icon, label `Search Vendors`.
7. **Link** — `Advanced Search ›`, centered, blue underlined.
8. **Result bar** — left `938 Vendors Found` (bold navy); right a dropdown `⇅ Sort: Relevance ⌄`.
9. **Result cards** (white, rounded, one per vendor), each:
   - Top row: vendor logo, vendor name (bold navy), domain (blue), and a navy `View Profile` button at right.
   - A thin divider, then a **3-column grid, two rows**. Small gray caps label above blue values.
     - Row 1: `CATEGORIES` | `SUBCATEGORIES` | `PRODUCTS`
     - Row 2: `MASTER GROUPS` | `DIVISIONS` | `TRADES`
   - Each cell shows two values then a `+N more...` link.
10. **Pagination** — `1` (active, navy) `2` `3` `…` `5` `›`, and at right `Results per page:` with a `25` dropdown.
11. **Bottom navigation** — shared, Search active.

## Sample cards in the template

**Intuit** (green "qb" logo, quickbooks.intuit.com)
- CATEGORIES: Finance & Payroll, Procurement, +2 more...
- SUBCATEGORIES: Accounting, Payroll, +6 more...
- PRODUCTS: QuickBooks Enterprise (wraps to 2 lines), QuickBooks Online, +6 more...
- MASTER GROUPS: Electrical, HVAC & Mechanical, +10 more...
- DIVISIONS: Utilities, Exterior Improvements, +48 more...
- TRADES: Electrical Contractors, Plumbing Contractors, +285 more...

**SAP** (blue SAP logo, sap.com)
- CATEGORIES: Procurement, Finance & Payroll, +3 more...
- SUBCATEGORIES: Procurement, Invoicing, +5 more...
- PRODUCTS: SAP Ariba Buying and..., SAP Ariba Contracts, +5 more...
- MASTER GROUPS / DIVISIONS / TRADES: same as Intuit.

## Behavior (inferred from the template and landscape; the template only shows the closed state)

- The three selectors open to a list of options (chevron expands). Not drawn open in this template.
- `Search Vendors` applies the selected Category / Subcategory / Product and refreshes the results.
- `Advanced Search ›` opens the Advanced Search page.
- `View Profile` opens the Vendor Page. Values in each cell are links to a filtered search.
- Sort: Relevance (other options not shown). Results per page: 25 (other options not shown).

## Template notes

- Card shows no verified check mark and no bookmark here (the earlier template review had both).
- Values are blue in the image. In landscape the client asked for black text, blue + underline on hover only.
  Touch screens have no hover, so the portrait link style needs a client decision.
- "938 Vendors Found" is the unfiltered total.
