# CTD portrait (mobile) — template specs

**Scope:** the portrait (phone) version only. Landscape is finished and frozen —
no landscape CSS, markup text or JS behavior may change (see the `ctd-landscape-only-scope` memory).
All portrait work is scoped to portrait-only rules or new files.

**Source:** the client's portrait templates, `C:\Users\User\Desktop\ctd\CTDPORTRAITTEMP\updatedvendorpages\`
(Home, Search, Advanced Search, Advanced Results) plus the Vendor Page template, which is not in that folder
and was attached to the chat (confirmed by Sakib, 2026-10-06). Each template is a ~941 x 1672 px image (about 9:16).
These specs describe exactly what is drawn. Where a template looks wrong or disagrees with
another template or the live site, it is listed under **Template notes** and NOT silently fixed.

## Pages

| # | Spec | Template image |
|---|---|---|
| 01 | [01-home.md](01-home.md) | `01_Home_Page.png` |
| 02 | [02-search-vendors.md](02-search-vendors.md) | `Search_Vendors.png` |
| 03 | [03-search-by-construction-work.md](03-search-by-construction-work.md) | `Search_By_Construction_Work.png` |
| 04 | [04-advanced-results.md](04-advanced-results.md) | `04_Advanced_Results.png` |
| 05 | [05-advanced-search-category.md](05-advanced-search-category.md) | `Category.png` |
| 06 | [06-advanced-search-subcategory.md](06-advanced-search-subcategory.md) | `Subcategory.png` |
| 07 | [07-advanced-search-product.md](07-advanced-search-product.md) | `Product.png` |
| 08 | [08-advanced-search-master-group.md](08-advanced-search-master-group.md) | `Master_Group.png` |
| 09 | [09-advanced-search-divisions.md](09-advanced-search-divisions.md) | `Divisions.png` |
| 10 | [10-advanced-search-trades.md](10-advanced-search-trades.md) | `Trades.png` |
| 11 | [11-vendor-page.md](11-vendor-page.md) | vendor page image (PlanSwift) |

Pages 05-10 are one page, Advanced Search, shown six times on purpose (confirmed by Sakib, 2026-10-06): each image shows how
the page looks after the user presses an arrow and that list opens. Pressing **About the Vendor** opens Product / Subcategory /
Category; pressing **About the Buyer** opens Master Group / Divisions / Trades. Build one page whose sections expand, not six pages.
The Advanced Filters rows have arrows too, but no template shows them open. Pages 02 and 03 are two tabs of one page, Search / Results.

## Round 2 (2026-10-08): updated templates and corrections

The client's updated templates and corrections document **supersede specs 02-04 and 05-11** for Search, Advanced Search, Advanced Results and the
Vendor Page. Home (01) is unchanged. Read [13-corrections-2026-10-08.md](13-corrections-2026-10-08.md) first; it lists every correction, how it was interpreted,
and the conflicts between templates. Old specs are kept for history only.

## Shared elements (the same on every page)

**Header (top, navy).** Logo at left (building icon, "THE / CONSTRUCTION / TECHNOLOGY / — DIRECTORY —", "TECHNOLOGY" in orange).
A white rounded search field with a magnifier at its left, then a white hamburger (three-line) icon at far right.
There is exactly one search control. There is no separate search icon.

**Bottom navigation (fixed, white, rounded top).** Five tabs, icon above label:
Home, Search, Directory, Vendors, Content. The active tab is orange, the others navy.

**Colors (as drawn).** Navy header and section bars, light-blue page background, orange primary
buttons and active tabs, blue links, white rounded cards with a soft shadow.

**Fonts.** Rounded sans-serif; page titles are large bold navy/black.

## Cross-template inconsistencies (need a decision before building)

1. **Search placeholder differs by page:** Home "Search Company, Product, Category, Trade or Keyword";
   Search Vendors, Search By Construction Work and all Advanced Search states "Search everything";
   Advanced Results and Vendor Page "Search by Keyword". (Landscape is also not identical across pages: Advanced Search says "Start your search here".)
2. **Bottom navigation labels** here are Home / Search / Directory / Vendors / Content. The earlier
   template review used Home / Search / Categories / Vendors / More. These templates are newer; we use these.
3. **Where each bottom tab goes is not specified** (Directory? Vendors? Content?). To confirm with the client.
4. **Counts and sample data** (938 vendors, 125 vendors, 8 Markets Served, Divisions/Trades with CSI codes)
   are sample numbers in the images, not live data.
5. **CSI codes** appear in the Divisions and Trades lists ("03 00 00 — Concrete") although the client
   asked on 2026-09-19 to hide all CSI codes. Landscape hides them.
6. **Labels on the Vendor Page** ("DIVISIONS OF WORK", "CONSTRUCTION TRADES") are the old names;
   the live site and the other templates say "Divisions" and "Trades".
