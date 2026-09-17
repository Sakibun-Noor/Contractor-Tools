# Vendor page rebuild — match the client's mockup (2026-09-17)

## Source

Deryck's full-page mockup of the vendor page, using Agave as the example
(sent 2026-09-17, same design as the colorized set in the 09.12.26F doc).
Instruction via Sakib: build it exactly as the image, with one change —
**text that is blue in the mockup is black, like the other pages.**

Also from the 09.17.26 corrections doc (Vendor Page section):
- "Please design so this content all goes above the fold."
- "Please normalize header, footer and go back links so they conform with
  rest of the page."

Scope is landscape desktop / laptop only, per [[ctd-landscape-only-scope]].
File: `vendor-profile.html` (address unchanged, `?s=<slug>`).

## Layout (top to bottom, left to right)

Measured from the 1672×941 mockup, expressed as proportions so it scales.

1. **Shared header** from `assets/ctd-chrome.css` — identical to every other
   page. Footer below the fold, also shared.
2. **Breadcrumb row.** Left: `‹ Back to Advanced Results › Vendor Profile`
   (mockup says "Back to Search Results"; the page before this one is
   Advanced Results since the 09-15 rename). Right: three outlined buttons
   with blue icons — Save Vendor (bookmark), Export Profile (download), Share.
3. **Identity banner** — one full-width bordered card, four zones split by
   thin vertical dividers:
   - logo mark + vendor name as a large bold wordmark
   - globe icon + website address
   - primary category name, bold
   - description, two lines
4. **Body** — two columns, left ≈ 18 % of the content width.
   - **Left column:** Visit Website (solid blue button), Request a Demo
     (white, outlined), Save Vendor (solid orange); then a **Typical
     Customers** card; then a **Company Biography** card that stretches to
     the bottom of the body.
   - **Right column:**
     - **Facts strip** — one card, four equal cells with blue line icons:
       Founded (calendar), Headquarters (map pin), Employees (people),
       Deployment (cloud). Small uppercase label above a bold value.
     - **Six list cards**, 3 × 2, equal size. Each has a tinted header bar
       with a colored icon, and "more…" bottom-right:

       | Card | Icon | Tint |
       |---|---|---|
       | Divisions | document | orange |
       | Trades | hard hat | blue |
       | Master Groups | people | green |
       | Key Products | gear | purple |
       | Subcategories | cube | red |
       | Categories | tag | teal |

     - **Bottom row**, three cards, widths ≈ 0.9 : 1 : 1.9 —
       Available On (device icon), Contact Information (mail icon),
       Quick Facts (info icon; Pricing Model and Industries on the left,
       Typical Customers on the right, split by a thin divider).

## Color

- All content text black (`--ink`, same as other pages): list items,
  values, description, biography, website address, category name, contact
  lines, quick-fact labels and values.
- Card titles navy (`--navy`), same as page headings elsewhere.
- Kept in color, as in the mockup: icons, header tints, the three left
  buttons (blue / white / orange), social and footer chrome.
- "more…" stays link-blue, matching every "view more…" on the other pages —
  it's a control, not content.
- Old taxonomy names in the mockup are replaced with the current ones:
  Divisions (not Divisions of Work), Trades (not Construction Trades),
  Master Groups (not Major Groups).

## Above the fold

The header, banner and body fill exactly one screen (`100dvh` shell, like
the other pages). The six list cards and the biography scroll inside their
own box when content is longer than the space. "more…" appears only when a
card's list is actually cut off; clicking it lets that card scroll. Checked
at 1265×553 (Deryck's laptop), 1536×864, 1672×941 (the mockup's own size)
and 1920×1080. If a screen
is too short even for the floor sizes, the page scrolls a little rather than
crushing a card.

## Data — real values only

The mockup was built from a screenshot of the *old* vendor page, which
padded three cards with invented lists shown on every vendor: Key Products
("Agave Mobile", "Agave Analytics", "AI & Automation Suite" …),
Subcategories (a fixed list of 12 starting "Digital Takeoff") and
Categories (the real one topped up to 12). It also invented an email
address (`info@<domain>`) and employee counts. None of that is in the
vendor data. The rebuild keeps the mockup's design and fills it only with
what the data actually holds, so a visitor never reads a claim about a
vendor that nobody verified.

| Mockup field | Source | When missing |
|---|---|---|
| Name, logo, website | `n`, `assets/icons/<domain>.ico`, `d` | letter mark |
| Category (banner) | first of `c` | — |
| Description (banner) | `x` | — |
| Divisions | `dv` | "Not yet classified" |
| Trades | `tr` | "Not yet classified" |
| Master Groups | `mt` | "Not yet classified" |
| Key Products | `sub` + " Software" (same rule as the Products column on the search pages) until Deryck's multi-product file lands | — |
| Subcategories | `sub` | — |
| Categories | `c` names | — |
| Available On / Deployment | `CTD_FILTERS.avail(sz)` — the same values the search-page filters use | — |
| Typical Customers | mapped from company size `sz` | — |
| Pricing Model | `pm` | — |
| Founded, Headquarters, Employees, email, Industries, Company Biography | not in the data; filled only for the few vendors in the page's curated `FACTS` table | "—" / "No company biography on file yet." |

Company-size mapping for Typical Customers:
All Sizes → Construction firms of all sizes · Small Business → Small
construction firms · Small / Mid-Market → Small to mid-size construction
firms · Mid-Market / Enterprise → Mid-size to enterprise construction firms
· Enterprise → Enterprise construction firms.

**To raise with Deryck:** he's building the new vendor file now. If it adds
columns for founded year, headquarters, employee count, contact email,
industries served, company biography, tagline and products, every empty
box on this page fills in with no further design work.

## Behavior kept from the current page

Save Vendor (both buttons toggle the same saved state), Export Profile
(CSV), Share, header search, favicon fallback, and the `FACTS` table for
vendors that have hand-checked details.

## Build log

### Shipped 2026-09-17

- `vendor-profile.html` style, main markup and script replaced; shared
  header/footer markup, script includes and the page address unchanged.
- First render at the mockup's own size (1672×941) showed stray characters
  beside the logo: the letter-mark fallback was a string inside an inline
  `onerror` attribute and its own quotes closed the attribute early. Logo
  and fallback are now built with DOM calls.
- Tuned against the mockup: vendor name and logo mark enlarged; bottom row
  made content-height (`auto`) instead of a share of the leftover height —
  it had come out almost twice the mockup's height; breadcrumb and top
  buttons sized up.
- Header search now goes to Search / Results (was Advanced Results with a
  raw, unencoded query).
- Old page invented Key Products, a fixed list of 12 Subcategories, padded
  Categories, `info@<domain>` emails and employee counts. All removed; see
  "Data — real values only" above.

**Verified** (no console errors apart from the expected 404 for a vendor
with no cached icon):
- 1672×941, 1536×864, 1920×1080, 1265×553: fold exactly one screen, footer
  starts at the fold line, no horizontal scroll, nothing below the fold.
- No content text computes blue (only icons, buttons, breadcrumb, "more…").
- Agave (4 trades): no "more…" — everything fits. SAP Ariba at 1265×553
  (6 trades): "more…" appears on Trades only; click → card scrolls, label
  "less"; click again → resets to top.
- Procore (curated facts): Founded 2002, HQ, 2,500+, email, industries
  all shown.
- Both Save Vendor buttons toggle one state and relabel together.
- WinEst (no cached icon): letter mark "W".
- Back link → advanced-results.html.
