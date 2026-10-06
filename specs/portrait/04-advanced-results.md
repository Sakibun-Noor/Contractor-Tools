# 04 — Advanced Results (portrait)

**Template:** `04_Advanced_Results.png` — Active bottom tab: **Search**.

## Layout, top to bottom

1. **Header** — shared. Search placeholder: `Search by Keyword`.
2. **Back link** — `‹ Back to Advanced Search`.
3. **Title row** — `Advanced Results` (large bold) with a people icon and `938 vendors found` on the same line.
4. **Action buttons** — four outlined buttons in one row, blue text and icon:
   `Save Search` (star), `Export Results` (download), `Share Results` (share), `Change Search` (filter lines).
5. **Detail selector** — label `Show details by (select one):`, then six toggle buttons in two rows of three:
   - Row 1: `Category` (**selected**: orange document icon, orange underline), `Subcategory`, `Product`
   - Row 2: `Master Group`, `Divisions`, `Trades`
6. **Result cards** (five per page), each:
   - Left: vendor logo. Next to it: vendor name (bold navy), domain (blue), one-line description (blue).
   - Right: globe icon (visit website), bookmark icon (save), and an underlined `View Profile` link.
   - Divider, then a detail row: orange document icon + label `Category` + a comma-separated list, ending with a `... more...` link when long.
   - Divider, then a two-part row: cloud icon `Quick Facts: Cloud-Based, Mobile App` | divider | phone icon `Available On: Web, iOS & Android`.
7. **Pagination** — `«`, `‹`, `Page 1 of 188`, `›`, `»`, `1-5 of 938 vendors`, and an orange `More Results ›` button.
8. **Bottom navigation** — shared, Search active.

## Sample cards in the template

| Vendor | Domain | Description | Category row |
|---|---|---|---|
| Intuit | quickbooks.intuit.com | Accounting and financial management for contractors. | Finance & Payroll, Procurement, Accounting, Estimating ... more... |
| SAP | sap.com | Procurement and finance for construction teams. | Procurement, Finance & Payroll, Project Management, Analytics ... more... |
| Coupa | coupa.com | Spend management and procurement for builders. | Procurement, AI & Automation, Spend Management, Supplier Management ... more... |
| Procore | procore.com | Project management and field operations for builders. | Project Management, Document Management, Estimating & Takeoff, Safety & Compliance ... more... |
| Autodesk | autodesk.com | Design and construction collaboration software. | Document Management, Project Management |

Every card shows Quick Facts `Cloud-Based, Mobile App` and Available On `Web, iOS & Android`.

## Behavior (inferred; the template only shows the Category state)

- **Show details by** is single-select ("select one"). It most likely decides which one detail row each card shows
  (Category, Subcategory, Product, Master Group, Divisions or Trades). The template only draws the Category row, so how the
  other five look is not specified. To confirm with the client.
- `Save Search`, `Export Results`, `Share Results` act on the whole result set (as in landscape).
  `Change Search` returns to Advanced Search with the selections kept.
- Globe opens the vendor website; bookmark saves the vendor; `View Profile` opens the Vendor Page.
- `... more...` expands the full list for that card.
- Paging is 5 vendors per page (188 pages for 938 vendors). `More Results ›` loads the next page.

## Template notes

- The description line under each name is a short one-line summary. The live data has a ~100-word biography; portrait needs a one-line version or a clamp.
- Category names such as "Spend Management", "Supplier Management", "Analytics" and "Document Management" are not among the 12 categories.
  Real data will show the 12 category names.
- `Quick Facts` and `Available On` overlap in meaning here (both about deployment); the template shows both.
- Only 5 cards fit per screen at this card height.
