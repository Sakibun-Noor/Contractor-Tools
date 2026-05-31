# Minimal static HTTP server for previewing dist/
# Run: powershell -ExecutionPolicy Bypass -File serve.ps1
param([int]$Port = 8765)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Split-Path -Parent $PSScriptRoot)

Add-Type -AssemblyName System.Web

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.xml'  = 'application/xml; charset=utf-8'
  '.txt'  = 'text/plain; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.png'  = 'image/png'
  '.gif'  = 'image/gif'
  '.ico'  = 'image/x-icon'
  '.webp' = 'image/webp'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Host "Serving $root at http://127.0.0.1:$Port/"

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response

    $relUrl = [System.Web.HttpUtility]::UrlDecode($req.Url.AbsolutePath)
    $rel = $relUrl.TrimStart('/')
    if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }
    if ($rel.EndsWith('/')) { $rel += 'index.html' }

    $path = Join-Path $root $rel.Replace('/', '\')

    if (Test-Path $path -PathType Container) {
      $path = Join-Path $path 'index.html'
    }

    if (-not (Test-Path $path -PathType Leaf)) {
      $res.StatusCode = 404
      $body = [System.Text.Encoding]::UTF8.GetBytes("404: $rel")
      $res.OutputStream.Write($body, 0, $body.Length)
      $res.Close()
      continue
    }

    try {
      $ext = [System.IO.Path]::GetExtension($path).ToLower()
      $ct = $mime[$ext]
      if (-not $ct) { $ct = 'application/octet-stream' }
      $res.ContentType = $ct
      $bytes = [System.IO.File]::ReadAllBytes($path)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {
      $res.StatusCode = 500
    } finally {
      $res.Close()
    }
  }
}
finally {
  $listener.Stop()
}
