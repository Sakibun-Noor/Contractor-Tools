# 13 — Portrait corrections, round 2 (client package of 2026-10-08)

**Sources:** `10.08.26 CTD Portrait Corrections.docx` (text + 8 small screenshots) and the updated templates in
`Downloads\rectdportraittemplates\` (+ its `READ_ME.txt`). The README says: templates are design references only; data and counts
are illustrative; multiple panels are scroll positions / states of one screen; on the vendor expanded board use the three RIGHT
panels, and `Collapsed_Top_and_Bottom.png` replaces its left panel.

The new templates **supersede** specs 02-11 for Search, Advanced Search, Advanced Results and the Vendor Page. Home is unchanged
visually. Landscape stays frozen (no landscape file or shared asset is edited; new data goes in portrait-only files).

## Corrections from the document, and what we do

### Home
| Client note | Interpretation / action |
|---|---|
| Pinch space so all 12 tiles come up above the fold | Hero, heading, tile gap and tile height scale with the screen height so the 12 tiles fit without scrolling (tested down to 360x640). The FIND/LEARN strip moves below the fold. |
| Send Contact us Page / Send Update Info page | The menu links must go to real pages. Added portrait **Contact Us** and **Update Info** pages. Their content/form is not supplied, so they are structured placeholders (needs client content). |
| "Please type your search" | Shown as a message when the search box is submitted empty (instead of opening an empty search). Placeholders stay as in the templates. |
| Put link on "AI" | The AI graphic in the hero links to the AI & Automation category (same as landscape). |
| Better differentiate FIND and RESEARCH | RESEARCH gets its own icon (bar chart) and color distinct from FIND (blue magnifier). Their copy is the client's; both still read "…technology providers" and the client may want new wording. |
| Need content for FIND, LEARN, RESEARCH, INSIGHTS / Need Content | New **Content** page with those four sections (placeholders; content to come from the client). The Content tab and the four strip items open it. |

### Search / Results
| Client note | Action |
|---|---|
| Change to Sort: Company Name; remove drop down | The sort control is a fixed label "Sort: Company Name" (A to Z), no dropdown. |
| Use longer arrows, switch to right side | The arrow on "Refine These Results" and "Find Similar Vendors" is a long arrow pinned to the right end of the button. |
| Add Save Link (bookmark) | Bookmark icon on every result card (saves the vendor). |
| "…presenting this only to show the look and feel" | The two screenshots in the document are look-and-feel only; the folder templates are the spec. |

### Advanced Search
| Client note | Action |
|---|---|
| "Reset All Selections" -> "Clear All Selections" | Done (label). |
| Expand Everything (Advanced Filters, About the Vendor, About the Buyer) | Written against the old accordion layout. The new three-tab layout makes all three groups reachable at once (tabs); the Filters tab rows are individually expandable. |
| Sub-selections in Advanced Filters use radio checkmark buttons (reference image) | Options inside Additional Filters use the round green check style from the reference image (ring, green ring with dot when selected). They remain multi-select. |
| "About the Vendor" must open "Category" first | Vendor Solutions opens on its Category step (Category -> Subcategory -> Products). Construction Work Served opens on Master Group. |

### Advanced Results / Vendor Page
| Client note | Action |
|---|---|
| Likes image #2 (vendor page) but it must expand to show everything, default collapsed, sectional + global expand | Vendor sections default collapsed; each opens on its own; "Expand / Collapse" link toggles all. |
| Please add Footer | A footer is added to every portrait page (company, directory, resources, site info, social, copyright; same links as landscape). |
| Master Groups > Divisions > Trades; Categories > Subcategories > Products | Vendor Page section order follows this (Categories, Subcategories, Products, Master Groups, Divisions, Trades). |
| Add the quick-facts strip info into Quick Facts | One **Quick Facts** section holds Founded, Headquarters, Employees, Deployment, Market Sector, Pricing Model. This also removes the duplicate Quick Facts and the duplicate Save Vendor (one bookmark at the top). |

## Templates -> behavior (new)

- **Search (two modes):** white panel with three labelled dropdowns (Category/Subcategory/Product or Master Group/Division/Trade), cascading
  (each dropdown lists only children of the one above). One orange button. Then "N Vendors Found", the fixed sort label, a full-width
  "Refine These Results ->" button (opens Advanced Search with the selections carried over), and cards with a bookmark,
  labelled rows ending in a blue "(+N)", and a "Find Similar Vendors ->" button (same category/subcategory or master group/division).
- **Advanced Search:** three tabs; two cascading steps of three lists each with "(N selected)" counts, a breadcrumb, a "selected so far" summary line,
  a search box and a scrolling checkbox list; a Filters tab with Evaluation Options, Company Size, Markets Served, Purchase Options, Available On, Add-on Services
  (each "Any" or "N selected", expandable); a collapsible "Selected Criteria (N)" list; "Search Vendors (N)" and "Clear All Selections".
- **Advanced Results:** cards collapsed by default (Vendor Solutions / Construction Work Served / Additional Filters summary lines with [+N],
  "Show Details", "View Profile"); expanded cards show icon rows per field. Global "Expand / Collapse" link. Bookmark top-right of each card.
- **Vendor Page:** see above.

## Conflicts inside the templates (decisions)

1. The new templates draw different header logos and bottom-nav icons from board to board. We keep one header and one bottom nav
   (the same ones as before); only text, structure and behavior follow the templates.
2. The Advanced Results board still shows the old header and an older bottom nav ("Categories", "More"). We keep the current nav
   (Home, Search, Directory, Vendors, Content) and mark Vendors as the active tab on Advanced Results and the Vendor Page, as the vendor boards do.
3. Search placeholders by page: Home = long text; Search and Advanced Search = "Search everything…"; Advanced Results = the long text; Vendor = "Search construction technology vendors…".
4. "Options shown are illustrative" and example names in the templates are not shown; real data is used. The template example "Windows" and
   "Add-on Services" have no data: Add-on Services is shown with no options yet.
5. Cascading needs parent/child links that the site data lacks, so a portrait-only file `m/m-hier.js` is generated from the master database by
   `build/portrait-hierarchy.py`. It does not touch landscape data files.
