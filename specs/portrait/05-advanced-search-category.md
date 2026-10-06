# 05 — Advanced Search: "About the Vendor" > Category (portrait)

**Template:** `Category.png` — Active bottom tab: **Search**.
Advanced Search is one page, drawn six times to show what appears when its arrows are pressed (05-10).
This image shows About the Vendor open on its Category tab. Shared structure is described here; 06-10 list only what differs.

## Layout, top to bottom

1. **Header** — shared. Search placeholder: `Search everything`.
2. **Back link** — `‹ Back to Search Results`.
3. **Title** — `Advanced Search`, with a people icon and `938 vendor matches` below it.
4. **Advanced Filters panel** — navy bar, funnel icon, title `Advanced Filters`, chevron-up (**expanded**).
   Five rows, each: checkbox, bold label, count (blue), chevron-down:

   | Row | Count |
   |---|---|
   | Evaluation Options | 3 |
   | Company Size | 5 |
   | Markets Served | 8 |
   | Purchase Options | 3 |
   | Available On | 4 |

5. **About the Vendor** — navy bar, cube icon, chevron-up (**expanded**). Inside:
   - Three segmented tabs: `Product` (green cube) | `Subcategory` (layers) | `Category` (list icon, **active**: orange fill, white text).
   - A white card:
     - Search box `Search category...` (magnifier at left)
     - Heading row: `Category` (bold) at left, `Records` at right
     - Five rows: checkbox, name (bold), one-line description (blue-gray), record count at right (blue)
     - Bottom left `+ more...` (blue bold); bottom right an outlined `Clear` button.
6. **About the Buyer** — navy bar, people icon, chevron-down (**collapsed**).
7. **Sticky action bar** — orange `Search Vendors (938)` (magnifier) and outlined `Reset All Selections` (reset icon).
8. **Bottom navigation** — shared, Search active.

## Rows in this state

| Category | Description | Records |
|---|---|---|
| BIM & Documents | Manage building models and project documents | 284 |
| Project Management | Plan, coordinate, and track project work | 219 |
| AI & Automation | Automate tasks and support decisions | 217 |
| Safety & Compliance | Manage safety programs and requirements | 172 |
| Finance & Payroll | Track finances, job costs, and payroll | 125 |

## Behavior

- The page has two accordion groups, **About the Vendor** and **About the Buyer**. In every template only one is open
  at a time (the other is collapsed). The open one shows its three tabs.
- Only one tab is active at a time; tapping a tab swaps the list (Product / Subcategory / Category, or Master Group / Divisions / Trades).
- The search box filters the list as the user types. `+ more...` reveals the rest of the list. `Clear` clears the checked items in this list only.
- `Reset All Selections` clears every selection on the page. `Search Vendors (N)` shows the live match count and opens Advanced Results.
- Tapping a row's chevron in **Advanced Filters** expands that filter's options (not drawn open).

## Template notes

- The page title count `938 vendor matches` and the button `Search Vendors (938)` are the unfiltered totals.
- **Markets Served shows 8** in the panel. The data now has 15 real markets, so the count must follow the data.
- `Evaluation Options` (3), `Purchase Options` (3) and parts of `Available On` have no vendor data yet in the real data (they are 0 in landscape).
- The Advanced Filters rows have a checkbox next to the title and a chevron. The checkbox has no clear meaning; the review notes ask to remove it.
- Counts next to the filters are drawn in this state, but not in 06, 08 and 09.
