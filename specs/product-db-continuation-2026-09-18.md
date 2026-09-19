# Product database continuation, vendors 561–1381 (2026-09-18)

## Why

Deryck was building the vendor/product database in ChatGPT. On 2026-09-18
he handed it over ("finish it up… it's your problem now") and asked to be
told if the structure changes. ChatGPT delivered two complete checkpoints,
then stopped:

| File | Vendors | Kept | Products | IDs |
|---|---|---|---|---|
| `CTD_Segment_1_Vendors_1_420_DEVELOPER_HANDOFF_COMPLETE.xlsx` | 1–420 | 417 | 1,571 | VP000001–VP001571 |
| `CTD_Segment_2A_Vendors_421_560_DEVELOPER_HANDOFF_COMPLETE.xlsx` | 421–560 | 136 | 476 | VP001572–VP002047 |

The remaining vendors are **561–1381, 821 in total**. The registry comes
from `VENDORS_NORM` in the old 3-segment zip, and the hints come from
`Combined_Vendors_1463`.

Working folder, outside the repo because the client data isn't
committed: `C:\Users\User\Desktop\Claude\CTD-product-db\`
(`inputs/`, `ref/`, `research/`, `out/`, `build_batch.py`).

## Structure: unchanged

Each batch file has the same sheets, columns and cell formats as the
421–560 handoff: `VENDORS_NORM`, `PRODUCTS_NORM`, the 6 lookups, the 5
product junctions, `VENDOR_MARKET_SECTOR`, `PRODUCT_MAPPING_QUEUE`,
`EXCLUDED_VENDORS`, plus `RULES`, `CHANGES`, `HANDOFF` and `QA_SUMMARY`.

- **IDs continue.** Vendor IDs come from the registry (561 = V0565).
  Product IDs start at VP002048. Junction IDs follow ChatGPT's formula,
  using n as the product number:

  | Junction | ID |
  |---|---|
  | category | n·100 + cat |
  | subcategory | n·1000 + sub |
  | master group | n·100 + mg |
  | division | n·100 + div |
  | trade | n·10000 + trade |

- Lookups are copied verbatim from the 421–560 file: 13 categories, 77
  subcategories, 13 master groups, 51 divisions and 425 trades, each
  counting its ALL wildcard row.
- Deryck's 22 RULES apply as written.

**One addition, `DUPLICATES` + `CONSOLIDATED_VENDORS` sheets.** ChatGPT
listed the same product under several vendor rows of one company. Forma
Build appears 5 times, and 229 of the 2,047 products are repeats, which
breaks Deryck's rule R07. From 561 on:

- A product that already exists for the same parent company is not added
  again. It gets a `DUPLICATES` row pointing at the existing product ID.
- A vendor row that is only a product or brand of a company already in
  the database (e.g. "Zoho Projects" once Zoho is in) goes to
  `CONSOLIDATED_VENDORS` with the existing Vendor_ID. It is not kept as a
  zero-product vendor.

The 229 repeats already in 1–560 are cleaned up at the final merge, not
in these batch files. Deryck is told about this addition, since he asked
to be told of any change.

## Research standard, per vendor

1. Establish the current company: renamed, acquired or defunct. Record
   the official site and the parent company.
2. Apply the inclusion test (R02–R05). Excluded vendors go to
   `EXCLUDED_VENDORS` with a reason and an evidence URL.
3. List every current qualifying construction-technology product. Each
   one gets a Source_URL, preferring the vendor's own product page, and
   is never guessed (R01, R06). Anything that can't be verified is left
   out and noted.
4. Map each product:
   - **Subcategories:** chosen from the 77. Categories are derived from
     them.
   - **Trades:** chosen from the 424 CSI-coded trades, or `0` (ALL) only
     for construction-wide tools (R18). Divisions and Master Groups are
     derived from the trades, so a product can never be Mechanical +
     Concrete.
5. Record the vendor's Market Sectors (0–7). Mark each one VERIFIED when
   the site names that market, otherwise DERIVED, the same as ChatGPT's
   basis field.

Research goes to `research/<audit>.json`, one file per vendor.
`build_batch.py` validates every ID against the lookups, dedupes against
1–560 and the earlier batches, assigns IDs and writes the batch xlsx
with its QA sheet.

## Batches

A 20-vendor test batch first (561–580), for Sakib to judge quality, time
and usage. After that, 100 vendors per file, to the same standard.

## Build log

**Test batch, vendors 561–580 (20 vendors), 2026-09-18.** Web-researched
each vendor, wrote `research/<audit>.json`, ran `build_batch.py 561 580`.

| | |
|---|---|
| Kept | 14 |
| Excluded | 3 — Auditoria (no construction customer/product), Azure Printed Homes (sells finished homes, not tech), Beamery (generic HR/recruiting, no construction module) |
| Consolidated | 3 — Autodesk, B2W Software, Beam AI were generic duplicate rows for companies already in 1–560; pointed at their existing Vendor_ID instead of being added again |
| Products | 28, across e.g. Elecosoft (Asta Powerproject family), Bentley Systems (MicroStation, SYNCHRO 4D, OpenRoads Designer, ProjectWise, STAAD.Pro, PLAXIS 2D, AutoPIPE), Aurigo, Avontus, Bad Elf, Balko, Basepin, BasisBoard, BayesMap, Bellum Smart, ATIS.cloud, Attentive.ai, Atvero, Augmenta |
| New duplicates against 1–560 | 0 |

Checked: no duplicate or orphaned IDs, every Category/Subcategory/Master
Group/Division/Trade reference resolves, and every product's Division and
Master Group agree with its Trade (0 mismatches). Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_580.xlsx`.

**Vendors 561–680 (120 vendors), 2026-09-18.** Same process, larger run.
ChatGPT's own run had stalled at vendor 560, so this is where Claude took
over.

| | |
|---|---|
| Kept | 82 |
| Excluded | 26 — generic tools with no construction-specific product (BigTime, Beamery-pattern, Cerebro, BusyLamp, Auditoria...), consumer-facing (Azure Printed Homes), post-construction facilities/property/ESG management with no matching CTD category (Building Engines, BuildingMinds, Buildium), unverifiable names (Bloqable, BlueSky, BuildGrid, BuildHub, BuildTrek, CalCon Calculator, Cambria Systems, Centricity, Cert-In Software, buildrfi) |
| Consolidated | 12 — duplicate/placeholder vendor rows for companies already in the database (Autodesk ×2, B2W Software ×2, Bluebeam, Newforma/BIM Track ×2, Arcoro/BirdDogHR, Buildcon Technologies, Buildr CRM) |
| Products | 107, incl. Elecosoft, Bentley Systems, Aurigo, Bosch RefinemySite, Boston Dynamics, Built Robotics, Caterpillar (Cat Command/Grade/Detect/VisionLink), Carlson Software, Certainty 3D, Canvas (JLG), 15 BIM-viewer/collaboration tools (BIMcollab, BIMData, BIMeta, BIMobject, BIMsmith, BIMspot, Catenda Hub/Bimsync, BIMx, Bimbeats, Bimsheet, BIM Vision...) |
| New duplicates against 1–560 | 1 caught and skipped — busybusy was already listed under vendor 130 in Segment 1 |

Checked: same integrity pass as before (0 duplicate/orphaned IDs, every
lookup reference resolves, every consolidation target exists) — clean
across all 635 vendors and 2,154 products now in the combined data.
Output: `CTD-product-db/out/CTD_Segment_2B_Vendors_561_680.xlsx`.

**Vendors 561–760 (200 vendors), 2026-09-18.** Continued straight through
in the same process, larger checkpoint.

| | |
|---|---|
| Kept | 136 |
| Excluded | 43 |
| Consolidated | 21 |
| Products | 166 |
| New duplicates against 1–560 | 4 caught and skipped |

New exclusion pattern established in this stretch: post-construction
facility/property/asset-management tools (Building Engines, BuildingMinds,
Buildium, CIM.io, Copperleaf) don't fit any of CTD's 13 categories, since
none of them cover facilities management — these are excluded the same
way as generic non-construction tools.

Checked: same full integrity pass, clean across all 689 vendors and 2,213
products now in the combined data (0 duplicate/orphaned IDs, every lookup
reference resolves, every consolidation target exists — including targets
in the original 1–560 files, like CraneView correctly pointing at
Versatile). Output: `CTD-product-db/out/CTD_Segment_2B_Vendors_561_760.xlsx`.

**Vendors 561–840 (280 vendors), 2026-09-18.** Continued straight through.

| | |
|---|---|
| Kept | 188 |
| Excluded | 64 |
| Consolidated | 28 |
| Products | 219 |
| New duplicates against 1–560 | 4 caught and skipped |

Two more exclusion patterns confirmed in this stretch: (1) reseller/
training/consulting/dealer firms that don't develop their own product
(CRB Software, Digital Drafting Systems) are excluded the same as
BuildingPoint Northeast earlier; (2) industry standards bodies /
consortia (Digital Twin Consortium) are excluded — a trade association
isn't a technology product. Also confirmed several products already
present under a different vendor name get merged in rather than
duplicated (e.g. EADOC and EasyPower into Bentley Systems, Elecosoft
into itself, Disperse into OpenSpace, StructionSite into DroneDeploy).

Checked: same full integrity pass, clean across all 741 vendors and
2,266 products (0 duplicate/orphaned IDs, every consolidation target
resolves). Output: `CTD-product-db/out/CTD_Segment_2B_Vendors_561_840.xlsx`.

**Vendors 561–894 (334 vendors), 2026-09-18/19.** Continued straight
through until this session's web-search tool budget (200 calls) ran out
mid-batch on vendor 895.

| | |
|---|---|
| Kept | 220 |
| Excluded | 78 |
| Consolidated | 36 |
| Products | 251 |
| New duplicates against 1–560 | 4 caught and skipped |

Checked: same full integrity pass, clean across all 773 vendors and
2,298 products. Output: `CTD-product-db/out/CTD_Segment_2B_Vendors_561_894.xlsx`.

**Vendors 561–942 (382 vendors), 2026-09-19.** Continued from the
search-budget pause.

| | |
|---|---|
| Kept | 246 |
| Excluded | 90 |
| Consolidated | 46 |
| Products | 278 |
| New duplicates against 1–560 | 4 caught and skipped |

Checked: clean across all 799 vendors and 2,325 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_942.xlsx`.

**Vendors 561–980 (420 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 270 |
| Excluded | 100 |
| Consolidated | 50 |
| Products | 304 |
| New duplicates against 1–560 | 5 caught and skipped |

Checked: clean across all 823 vendors and 2,351 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_980.xlsx`.

**Vendors 561–1000 (440 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 283 |
| Excluded | 105 |
| Consolidated | 52 |
| Products | 320 |
| New duplicates against 1–560 | 5 caught and skipped |

Checked: clean across all 836 vendors and 2,367 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1000.xlsx`.

**Vendors 561–1031 (471 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 305 |
| Excluded | 114 |
| Consolidated | 52 |
| Products | 342 |
| New duplicates against 1–560 | 5 caught and skipped |

Checked: clean across all 858 vendors and 2,389 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1031.xlsx`.

**Vendors 561–1051 (491 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 320 |
| Excluded | 119 |
| Consolidated | 52 |
| Products | 358 |
| New duplicates against 1–560 | 5 caught and skipped |

Checked: clean across all 873 vendors and 2,405 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1051.xlsx`.

**Vendors 561–1060 (500 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 326 |
| Excluded | 120 |
| Consolidated | 54 |
| Products | 364 |
| New duplicates against 1–560 | 5 caught and skipped |

Checked: clean across all 879 vendors and 2,411 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1060.xlsx`.

**Vendors 561–1096 (536 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 348 |
| Excluded | 127 |
| Consolidated | 61 |
| Products | 387 |
| New duplicates against 1–560 | 7 caught and skipped |

Checked: clean across all 901 vendors and 2,434 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1096.xlsx`.

**Vendors 561–1160 (600 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 389 |
| Excluded | 141 |
| Consolidated | 70 |
| Products | 432 |
| New duplicates against 1–560 | 7 caught and skipped |

Checked: clean across all 942 vendors and 2,479 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1160.xlsx`.

**Vendors 561–1200 (640 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 416 |
| Excluded | 148 |
| Consolidated | 76 |
| Products | 459 |
| New duplicates against 1–560 | 7 caught and skipped |

Checked: clean across all 969 vendors and 2,506 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1200.xlsx`.

**Vendors 561–1226 (666 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 433 |
| Excluded | 154 |
| Consolidated | 79 |
| Products | 476 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 986 vendors and 2,523 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1226.xlsx`.

Session WebSearch budget (200 calls) hit exhaustion again mid-batch at vendor 1226.

**Vendors 561–1266 (706 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 459 |
| Excluded | 160 |
| Consolidated | 87 |
| Products | 502 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 1,012 vendors and 2,549 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1266.xlsx`.

Note: audit 1261/1262 (Synchro / Synchro 4D) turned out to duplicate Bentley Systems, already
added back at audit 580 in the first test batch (Vendor_ID V0584) — caught by the automated
dedup check and consolidated correctly.

**Vendors 561–1286 (726 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 473 |
| Excluded | 164 |
| Consolidated | 89 |
| Products | 516 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 1,026 vendors and 2,563 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1286.xlsx`.

**Vendors 561–1306 (746 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 486 |
| Excluded | 166 |
| Consolidated | 94 |
| Products | 529 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 1,039 vendors and 2,576 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1306.xlsx`.

**Vendors 561–1326 (766 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 499 |
| Excluded | 171 |
| Consolidated | 96 |
| Products | 542 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 1,052 vendors and 2,589 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1326.xlsx`.

**Vendors 561–1346 (786 vendors), 2026-09-19.**

| | |
|---|---|
| Kept | 512 |
| Excluded | 175 |
| Consolidated | 99 |
| Products | 555 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 1,065 vendors and 2,602 products. Output:
`CTD-product-db/out/CTD_Segment_2B_Vendors_561_1346.xlsx`.

**Vendors 561–1381 (821 vendors) — FULL RANGE COMPLETE, 2026-09-19.**

| | |
|---|---|
| Kept | 535 |
| Excluded | 184 |
| Consolidated | 102 |
| Products | 578 |
| New duplicates against 1–560 | 9 caught and skipped |

Checked: clean across all 1,088 vendors and 2,625 products (combined Segment 1 + 2A + 2B).
Output: `CTD-product-db/out/CTD_Segment_2B_Vendors_561_1381.xlsx`.

This is the last audit number in the original 1,463-vendor master list. The full continuation
(vendors 561–1381) is done. Next step, if wanted: merge Segment 1 (1–420) + Segment 2A (421–560)
+ Segment 2B (561–1381) into one complete developer-handoff database file.
