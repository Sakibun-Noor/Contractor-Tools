# 03 — Search / Results: "Search By Construction Work" tab (portrait)

**Template:** `Search_By_Construction_Work.png` — Active bottom tab: **Search**.

## Layout, top to bottom

Same page and chrome as [02-search-vendors.md](02-search-vendors.md). Differences only:

1. **Tabs** — now `Search by Construction Work` is **active** (orange, white text) and `Search Vendors` is inactive
   (pale blue, blue text). The active tab has a small notch at its top-left corner in the image.
   (The tab text uses a lowercase "by"; the other tab's label and the button use a capital "By".)
2. **Three collapsed selectors**:
   - `Master Group` (list icon)
   - `Division` (layers icon) — singular here
   - `Trade` (cube icon) — singular here
3. **Primary button** — full width, orange, magnifier icon, label `Search By Construction Work`.
4. **Link** — `Advanced Search ›`.
5. **Result bar** — `125 Vendors Found`, `Sort: Relevance`.
6. **Result cards** — same card, but the two grid rows are **swapped**:
   - Row 1: `MASTER GROUPS` | `DIVISIONS` | `TRADES`
   - Row 2: `CATEGORIES` | `SUBCATEGORIES` | `PRODUCTS`
7. **Pagination** and **bottom navigation** — same as 02.

## Sample cards in the template

**Intuit** — MASTER GROUPS: Electrical, HVAC & Mechanical, +10 more... / DIVISIONS: Utilities, Exterior Improvements,
+48 more... / TRADES: Electrical Contractors, Plumbing Contractors, +285 more... / CATEGORIES: Finance & Payroll,
Procurement, +2 more... / SUBCATEGORIES: Accounting, Payroll, +6 more... / PRODUCTS: QuickBooks Enterprise,
QuickBooks Online, +6 more...

**SAP** — row 1 identical to Intuit; CATEGORIES: Procurement, Finance & Payroll, +3 more... / SUBCATEGORIES: Procurement,
Invoicing, +5 more... / PRODUCTS: SAP Ariba Buying and..., SAP Ariba Contracts, +5 more...

## Behavior

- Switching tabs swaps the three selectors, the button label and the order of the card grid.
- Same card actions as 02.

## Template notes

- The count `125 Vendors Found` does not match the unfiltered total of 938 shown on the other tab,
  although no filter is selected in the image. It is sample data; the real count must follow the filters.
- Selector icons repeat the Category / Subcategory / Product icons.
- Singular labels (`Division`, `Trade`) here vs plural (`Divisions`, `Trades`) in Advanced Search and on the cards.
