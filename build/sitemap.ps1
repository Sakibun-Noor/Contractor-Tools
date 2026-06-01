# Rebuilds sitemap.xml by scanning all generated + existing HTML pages.
# Idempotent. Run: powershell -File build/sitemap.ps1
param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path,
  [string]$Domain = "https://deryck.example.com",
  [string]$LastMod = (Get-Date -Format 'yyyy-MM-dd')
)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$skipDirs = @('build', 'assets', 'data', '.git', '.claude')

$urls = New-Object System.Collections.Generic.List[string]
$files = Get-ChildItem -Path $Root -Recurse -Filter *.html -File
foreach ($f in $files) {
  $rel = $f.FullName.Substring($Root.Length).TrimStart('\','/').Replace('\','/')
  $top = ($rel -split '/')[0]
  if ($skipDirs -contains $top) { continue }
  if ($f.Name -eq '404.html') { continue }
  if ($rel -eq 'index.html') { $loc = "$Domain/"; $pri = '1.0' }
  elseif ($f.Name -eq 'index.html') { $loc = "$Domain/" + ($rel -replace 'index\.html$',''); $pri = '0.8' }
  else { $loc = "$Domain/$rel"; $pri = '0.6' }
  $urls.Add("  <url><loc>$loc</loc><lastmod>$LastMod</lastmod><changefreq>weekly</changefreq><priority>$pri</priority></url>")
}

$sorted = $urls | Sort-Object -Unique
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sb.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
foreach ($u in $sorted) { [void]$sb.AppendLine($u) }
[void]$sb.AppendLine('</urlset>')
[System.IO.File]::WriteAllText((Join-Path $Root 'sitemap.xml'), $sb.ToString(), $utf8NoBom)
Write-Output ("sitemap.xml written with " + $sorted.Count + " URLs")
