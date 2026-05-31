# Pre-downloads every tool's favicon into assets/icons/{domain}.ico
# so the built site is fully self-contained (no third-party runtime requests).
# Run: powershell -ExecutionPolicy Bypass -File fetch-icons.ps1

$ErrorActionPreference = 'Continue'

$root     = Split-Path -Parent $PSScriptRoot
$dataFile = Join-Path $root 'data\tools.json'
$iconsDir = Join-Path $root 'assets\icons'

if (-not (Test-Path $iconsDir)) { New-Item -ItemType Directory -Path $iconsDir | Out-Null }

$data = Get-Content -Path $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json

# Collect unique domains across all categories
$domains = @{}
foreach ($c in $data.categories) {
    foreach ($t in $c.tools) {
        if ($t.domain) { $domains[$t.domain] = $true }
    }
}
$domainList = $domains.Keys | Sort-Object

Write-Host "Fetching $($domainList.Count) unique favicons..."

# Sources to try (in order). Each must accept a {0} placeholder for the domain.
$sources = @(
    'https://icons.duckduckgo.com/ip3/{0}.ico',
    'https://www.google.com/s2/favicons?domain={0}&sz=128',
    'https://icon.horse/icon/{0}'
)

$ok = 0; $fail = 0; $i = 0
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

foreach ($d in $domainList) {
    $i++
    $outPath = Join-Path $iconsDir "$d.ico"
    if (Test-Path $outPath) {
        # Already cached
        $ok++
        continue
    }
    $got = $false
    foreach ($srcTpl in $sources) {
        $url = $srcTpl -f $d
        try {
            Invoke-WebRequest -Uri $url -OutFile $outPath -TimeoutSec 8 -UseBasicParsing -ErrorAction Stop
            $size = (Get-Item $outPath).Length
            if ($size -gt 80) { $got = $true; break }
            else { Remove-Item $outPath -ErrorAction SilentlyContinue }
        } catch {
            if (Test-Path $outPath) { Remove-Item $outPath -ErrorAction SilentlyContinue }
        }
    }
    if ($got) {
        $ok++
        if ($i % 25 -eq 0) { Write-Host "  [$i/$($domainList.Count)] OK ($ok) / fallback ($fail)" }
    } else {
        $fail++
    }
}

Write-Host ""
Write-Host "Done: $ok cached, $fail fell back to letter icons."
Write-Host "Output: $iconsDir"
