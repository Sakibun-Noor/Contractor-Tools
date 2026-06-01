# Removes the white background from the logo via edge flood-fill, auto-crops, saves PNG.
param(
  [string]$In  = 'C:\Users\Sakib Jawad\Desktop\Anti Grav\logo\Annotation 2026-06-01 190718.png',
  [string]$Out = 'C:\Users\Sakib Jawad\Desktop\Anti Grav\repo\assets\logo.png'
)
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile($In)
$w = $src.Width; $h = $src.Height
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($src, 0, 0, $w, $h)
$g.Dispose(); $src.Dispose()

# Read pixels into arrays via LockBits for speed
$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$bytes = New-Object byte[] ($data.Stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
$stride = $data.Stride

function IsBg([int]$x, [int]$y) {
  $i = $y * $stride + $x * 4
  # BGRA order - strict white only, so the fill cannot leak through anti-aliased gaps into enclosed light areas (e.g. the lens)
  return ($bytes[$i] -gt 244 -and $bytes[$i+1] -gt 244 -and $bytes[$i+2] -gt 244)
}

$visited = New-Object 'bool[]' ($w * $h)
$queue = New-Object System.Collections.Generic.Queue[int]
# seed from all border pixels
for ($x = 0; $x -lt $w; $x++) {
  foreach ($y in @(0, ($h-1))) { $idx = $y*$w+$x; if (-not $visited[$idx] -and (IsBg $x $y)) { $visited[$idx]=$true; $queue.Enqueue($idx) } }
}
for ($y = 0; $y -lt $h; $y++) {
  foreach ($x in @(0, ($w-1))) { $idx = $y*$w+$x; if (-not $visited[$idx] -and (IsBg $x $y)) { $visited[$idx]=$true; $queue.Enqueue($idx) } }
}
while ($queue.Count -gt 0) {
  $idx = $queue.Dequeue()
  $x = $idx % $w; $y = [math]::Floor($idx / $w)
  $i = $y * $stride + $x * 4
  $bytes[$i+3] = 0  # alpha = 0
  foreach ($d in @(@(1,0),@(-1,0),@(0,1),@(0,-1))) {
    $nx = $x + $d[0]; $ny = $y + $d[1]
    if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
      $nidx = $ny*$w+$nx
      if (-not $visited[$nidx] -and (IsBg $nx $ny)) { $visited[$nidx]=$true; $queue.Enqueue($nidx) }
    }
  }
}

# Defringe: erode the thin near-white halo ringing the artwork (pixels touching transparency).
# Interior light areas (e.g. the lens) are never adjacent to transparency, so they are untouched.
for ($pass = 0; $pass -lt 2; $pass++) {
  $toClear = New-Object System.Collections.Generic.List[int]
  for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
      $i = $y * $stride + $x * 4
      if ($bytes[$i+3] -eq 0) { continue }
      if ($bytes[$i] -lt 232 -or $bytes[$i+1] -lt 232 -or $bytes[$i+2] -lt 232) { continue }
      $touch = $false
      foreach ($d in @(@(1,0),@(-1,0),@(0,1),@(0,-1))) {
        $nx = $x + $d[0]; $ny = $y + $d[1]
        if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
          if ($bytes[$ny*$stride + $nx*4 + 3] -eq 0) { $touch = $true; break }
        }
      }
      if ($touch) { $toClear.Add($i) }
    }
  }
  foreach ($i in $toClear) { $bytes[$i+3] = 0 }
}

[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length)
$bmp.UnlockBits($data)

# Auto-crop to non-transparent bounding box
$minX=$w; $minY=$h; $maxX=0; $maxY=0
for ($y=0; $y -lt $h; $y++) {
  for ($x=0; $x -lt $w; $x++) {
    $a = $bytes[$y*$stride + $x*4 + 3]
    if ($a -gt 10) { if ($x -lt $minX){$minX=$x}; if ($x -gt $maxX){$maxX=$x}; if ($y -lt $minY){$minY=$y}; if ($y -gt $maxY){$maxY=$y} }
  }
}
$pad = 6
$minX=[math]::Max(0,$minX-$pad); $minY=[math]::Max(0,$minY-$pad)
$maxX=[math]::Min($w-1,$maxX+$pad); $maxY=[math]::Min($h-1,$maxY+$pad)
$cw = $maxX-$minX+1; $ch = $maxY-$minY+1
$crop = New-Object System.Drawing.Bitmap $cw, $ch, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cg = [System.Drawing.Graphics]::FromImage($crop)
$cropRect = New-Object System.Drawing.Rectangle $minX, $minY, $cw, $ch
$cg.DrawImage($bmp, (New-Object System.Drawing.Rectangle 0,0,$cw,$ch), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$cg.Dispose()

$dir = Split-Path $Out -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$crop.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output ("Saved $Out  (" + $cw + "x" + $ch + " from " + $w + "x" + $h + ")")
$crop.Dispose(); $bmp.Dispose()
