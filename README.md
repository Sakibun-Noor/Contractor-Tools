# Deryck

A static directory site cataloguing 300 contractor tools across 6 trades. Each tool gets its own SEO-optimized detail page.

- **Stack:** Plain HTML + Tailwind CDN. No build framework, no runtime JavaScript framework.
- **Output:** the **repo root** *is* the deployable site (works on Vercel, Netlify, GitHub Pages, Cloudflare Pages, S3, an Nginx box, a USB stick — no config required).
- **Pages:** 1 home + 6 category + 300 tool + 1 404 = **308 HTML files** + sitemap + robots.

## Project layout

```
Contractor-Tools/
├── index.html                ← homepage (deployable site root)
├── 404.html                  ← not-found page
├── sitemap.xml, robots.txt   ← SEO
├── category/                 ← 6 category pages
├── tool/<category>/          ← 300 tool detail pages
├── assets/
│   ├── hero.jpg              ← AI-generated cinematic plumbing hero
│   ├── style.css             ← custom CSS (layered on Tailwind)
│   └── icons/                ← 176 pre-cached favicons (one per domain)
├── data/
│   ├── tools_text.txt        ← extracted source content (input)
│   └── tools.json            ← structured data the build reads
├── build/
│   ├── parse-tools.ps1       ← rebuilds tools.json from tools_text.txt
│   ├── fetch-icons.ps1       ← downloads each tool's favicon to assets/icons/
│   ├── build-site.ps1        ← renders all 308 HTML pages at the repo root
│   └── serve.ps1             ← tiny static HTTP server for local preview
├── README.md
└── .gitignore
```

Most static hosts will ignore the non-HTML directories (`data/`, `build/`) when serving — but if you want to be explicit, exclude them in your host's deploy config.

## How to rebuild

From a PowerShell prompt:

```powershell
# 1. (Optional) Re-parse the source text into tools.json
powershell -ExecutionPolicy Bypass -File build\parse-tools.ps1

# 2. (Optional) Re-fetch favicons (only needed if you change/add domains)
powershell -ExecutionPolicy Bypass -File build\fetch-icons.ps1

# 3. Render the whole site
powershell -ExecutionPolicy Bypass -File build\build-site.ps1
```

## How to preview locally

```powershell
powershell -ExecutionPolicy Bypass -File build\serve.ps1
# then open http://127.0.0.1:8765/
```

## Before deploying to production

Edit the top of `build/build-site.ps1`:

```powershell
$siteHost = 'https://deryck.example.com'   # ← change to your real domain
```

Then re-run the build. This updates canonical URLs, sitemap entries, and Open Graph URLs.

## What ships in each page

- **Homepage:** Cinematic dark plumbing hero with site name + tagline, stats banner (300 tools / 6 trades / direct links / free), about block, 6 category cards.
- **Category page:** Breadcrumb, title, 3-column responsive card grid of all 50 tools in that category. Each card has the tool's favicon, name, domain, and one-line description.
- **Tool detail page:** Breadcrumb, large favicon, tool name + domain, blue "Visit official site" CTA, full description, 4 related tools in the same category.
- **All pages:** Per-page `<title>`, meta description, canonical URL, Open Graph + Twitter Card tags, JSON-LD structured data (WebSite / ItemList / BreadcrumbList).

## Branding tokens

| | Value |
|---|---|
| Site name | Deryck |
| Accent | `#3B82F6` (electric blue) |
| Ink | `#0F172A` (slate-900) |
| Background | `#FFFFFF` (white) with subtle blueprint grid |
| Font | Inter (Google Fonts) |
| Hero | Dark blue / charcoal / matte black cinematic plumbing flat-lay |

## Notes

- Favicons are pre-cached locally for reliability and performance. If a domain's icon was unreachable at build time, that tool falls back to a styled letter circle. Fewer than 10 of 300 tools fall back in the current build.
- Tailwind is loaded via the Play CDN for simplicity. For a production deployment with smaller CSS, swap to a real Tailwind build step.
- The `build/serve.ps1` server is for local preview only. In production, serve `dist/` from any static host.
