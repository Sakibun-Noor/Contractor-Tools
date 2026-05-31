# Runs the full Deryck pipeline end-to-end:
#   1. (optional) parse-tools.ps1  - regenerate data/tools.json from source text
#   2. enrich-data.ps1              - add trades/sizes/useCases/pricing/pros/cons/alternatives
#   3. curated-data.ps1             - regenerate data/curated.json (best-for, vs pairs, workflows)
#   4. build-site.ps1               - render homepage + categories + tool pages + 404
#   5. build-ecosystem.ps1          - render /pricing, /alternatives, /compare, /best,
#                                     /trade, /software-category, /workflow, /directory, /quiz
#                                     + regenerate sitemap with all URLs
#
# Run:  powershell -ExecutionPolicy Bypass -File build-all.ps1

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

function Run-Step { param([string]$label, [string]$file)
    Write-Host ''
    Write-Host "=== $label ===" -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File (Join-Path $here $file)
    if ($LASTEXITCODE -ne 0) { throw "$label failed (exit $LASTEXITCODE)" }
}

Run-Step 'Enrich data'    'enrich-data.ps1'
Run-Step 'Curate content' 'curated-data.ps1'
Run-Step 'Build site'     'build-site.ps1'
Run-Step 'Build ecosystem' 'build-ecosystem.ps1'

Write-Host ''
Write-Host '=== Done ===' -ForegroundColor Green
