# Parses the extracted docx text into structured tools.json
# Run: powershell -File parse-tools.ps1

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$srcText = Join-Path $root 'data\tools_text.txt'
$outJson = Join-Path $root 'data\tools.json'

if (-not (Test-Path $srcText)) {
    throw "Source text file not found at $srcText. Run the extract step first."
}

$lines = Get-Content -Path $srcText -Encoding UTF8

$categories = @()
$currentCategory = $null
$currentTool = $null

function To-Slug {
    param([string]$s)
    $slug = $s.ToLower()
    $slug = $slug -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')
    return $slug
}

foreach ($line in $lines) {
    if ($line -match '^\[Heading1\]\s+\d+\.\s+(.+)$') {
        # Save previous category
        if ($currentTool -and $currentCategory) {
            $currentCategory.tools += $currentTool
            $currentTool = $null
        }
        if ($currentCategory) {
            $categories += $currentCategory
        }
        $catName = $Matches[1].Trim()
        $currentCategory = [PSCustomObject]@{
            name  = $catName
            slug  = (To-Slug $catName)
            tools = @()
        }
        continue
    }

    # Tool name line: "[] 1. ToolName" (style is empty)
    if ($line -match '^\[\]\s+(\d+)\.\s+(.+)$') {
        if ($currentTool -and $currentCategory) {
            $currentCategory.tools += $currentTool
        }
        $toolName = $Matches[2].Trim()
        $currentTool = [PSCustomObject]@{
            position    = [int]$Matches[1]
            name        = $toolName
            slug        = (To-Slug $toolName)
            url         = ''
            domain      = ''
            description = ''
        }
        continue
    }

    if ($line -match '^\[ListBullet\]\s+Website:\s+(.+)$' -and $currentTool) {
        $url = $Matches[1].Trim()
        $currentTool.url = $url
        try {
            $uri = [System.Uri]$url
            $h = $uri.Host
            if ($h.StartsWith('www.')) { $h = $h.Substring(4) }
            $currentTool.domain = $h
        } catch {
            $currentTool.domain = ''
        }
        continue
    }

    if ($line -match "^\[ListBullet\]\s+Why it'?s needed:\s+(.+)$" -and $currentTool) {
        $currentTool.description = $Matches[1].Trim()
        continue
    }
}

# Flush the last tool and category
if ($currentTool -and $currentCategory) {
    $currentCategory.tools += $currentTool
}
if ($currentCategory) {
    $categories += $currentCategory
}

# Make slugs unique within a category (some tools share names across cats; that's fine globally)
foreach ($cat in $categories) {
    $seen = @{}
    foreach ($t in $cat.tools) {
        $base = $t.slug
        $n = 2
        while ($seen.ContainsKey($t.slug)) {
            $t.slug = "$base-$n"
            $n++
        }
        $seen[$t.slug] = $true
    }
}

$result = [PSCustomObject]@{
    siteName   = 'Deryck'
    tagline    = 'A curated reference of 300 essential contractor tools across six trades.'
    categories = $categories
}

$json = $result | ConvertTo-Json -Depth 6
Set-Content -Path $outJson -Value $json -Encoding UTF8

$total = ($categories | ForEach-Object { $_.tools.Count } | Measure-Object -Sum).Sum
Write-Host "Wrote $outJson"
Write-Host "Categories: $($categories.Count)"
foreach ($c in $categories) { Write-Host ("  - {0,-45} {1} tools" -f $c.name, $c.tools.Count) }
Write-Host "Total tools: $total"
