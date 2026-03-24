<#
.SYNOPSIS
  Analyze C:\ for space usage (screen only).
  Displays total drive space info, Top 40 biggest folders (to 4 levels deep),
  and Top 40 largest individual files with size & last modified date.

.NOTES
  - No prompts.
  - Defaults: Path = C:\, Top = 40, IncludeHidden = $false, FolderDepth = 4
  - Run: .\Find-DriveHogs.ps1
  - Optional: .\Find-DriveHogs.ps1 -Path D:\ -Top 50 -FolderDepth 3 -IncludeHidden
#>

[CmdletBinding()]
param(
  [ValidateScript({ Test-Path $_ -PathType Container })]
  [string]$Path = "C:\",

  [int]$Top = 40,

  # Max folder depth to scan for the folder analysis (0 = root only)
  [ValidateRange(0, 50)]
  [int]$FolderDepth = 4,

  # Include hidden and system items in calculations/output
  [switch]$IncludeHidden
)

# ---- Size formatter ----
function Format-Size([double]$bytes) {
  if ($bytes -lt 1KB) { return ("{0:N0} B" -f $bytes) }
  elseif ($bytes -lt 1MB) { return ("{0:N2} KB" -f ($bytes / 1KB)) }
  elseif ($bytes -lt 1GB) { return ("{0:N2} MB" -f ($bytes / 1MB)) }
  elseif ($bytes -lt 1TB) { return ("{0:N2} GB" -f ($bytes / 1GB)) }
  else { return ("{0:N2} TB" -f ($bytes / 1TB)) }
}

# ---- Folder size aggregation (depth-limited) ----
function Get-DirectorySizesToDepth {
  param(
    [Parameter(Mandatory)]
    [string]$BasePath,
    [int]$MaxDepth = 4,
    [switch]$Force
  )

  $dirSizes = @{}
  $dirLastWrite = @{}
  $queue = [System.Collections.Generic.Queue[object]]::new()

  $baseItem = Get-Item -LiteralPath $BasePath -ErrorAction Stop
  $queue.Enqueue([pscustomobject]@{ Item = $baseItem; Depth = 0 })
  $dirSizes[$baseItem.FullName] = 0L
  $dirLastWrite[$baseItem.FullName] = $baseItem.LastWriteTime

  $processed = 0
  while ($queue.Count -gt 0) {
    $node = $queue.Dequeue()
    $dir = $node.Item
    $depth = [int]$node.Depth
    $processed++

    if (($processed % 200) -eq 0) {
      $pct = 5 + [int](($depth / [math]::Max(1,$MaxDepth)) * 90)
      Write-Progress -Activity "Measuring folder sizes (to depth $MaxDepth)" -Status $dir.FullName -PercentComplete $pct
    }

    $files = @( Get-ChildItem -LiteralPath $dir.FullName -File -Force:$Force -ErrorAction SilentlyContinue )
    if ($files.Count -gt 0) {
      $sumHere = ($files | Measure-Object -Property Length -Sum).Sum
      $cur = $dir
      while ($null -ne $cur) {
        $key = $cur.FullName
        if (-not $dirSizes.ContainsKey($key)) {
          $dirSizes[$key] = 0L
          try { $dirLastWrite[$key] = (Get-Item -LiteralPath $key -ErrorAction Stop).LastWriteTime }
          catch { $dirLastWrite[$key] = $null }
        }
        $dirSizes[$key] += [long]$sumHere
        if ($key -ieq $baseItem.FullName) { break }
        $cur = $cur.Parent
      }
    }

    if ($depth -lt $MaxDepth) {
      $children = @( Get-ChildItem -LiteralPath $dir.FullName -Directory -Force:$Force -ErrorAction SilentlyContinue )
      foreach ($child in $children) {
        $queue.Enqueue([pscustomobject]@{ Item = $child; Depth = $depth + 1 })
        if (-not $dirSizes.ContainsKey($child.FullName)) {
          $dirSizes[$child.FullName] = 0L
          $dirLastWrite[$child.FullName] = $child.LastWriteTime
        }
      }
    }
  }
  Write-Progress -Activity "Measuring folder sizes (to depth $MaxDepth)" -Completed

  foreach ($path in $dirSizes.Keys) {
    [pscustomobject]@{
      Type         = "Folder"
      Name         = $path
      SizeBytes    = [long]$dirSizes[$path]
      Size         = Format-Size $dirSizes[$path]
      'Last Write' = $dirLastWrite[$path]
    }
  }
}

$forceFlag = $IncludeHidden.IsPresent
Write-Host "Analyzing: $Path" -ForegroundColor Cyan

# --- Drive space info ---
$drive = Get-PSDrive -Name ($Path.Substring(0,1)) -ErrorAction SilentlyContinue
if ($null -ne $drive) {
  $free = Format-Size $drive.Free
  $used = Format-Size ($drive.Used)
  $total = Format-Size ($drive.Used + $drive.Free)
  Write-Host "`n=== Drive Info for $($drive.Name):\ ===" -ForegroundColor Yellow
  Write-Host ("Total: {0} | Used: {1} | Free: {2}`n" -f $total, $used, $free) -ForegroundColor Green
}

# --- 1) Shadow Copy storage space ---

Write-Host "=== Volume Shadow Copies ==="

vssadmin list shadowstorage

# --- 2) Biggest folders ---
Write-Host "`n=== Biggest folders under $Path (Top $Top, scanned to depth $FolderDepth) ===`n" -ForegroundColor Yellow
$folderResults = Get-DirectorySizesToDepth -BasePath $Path -MaxDepth $FolderDepth -Force:$forceFlag |
  Sort-Object SizeBytes -Descending |
  Select-Object Type, Size, Name, 'Last Write' |
  Select-Object -First $Top
$folderResults | Format-Table -AutoSize

# --- 3) Largest files ---
Write-Progress -Activity "Finding largest files" -Status "Walking tree…" -PercentComplete 20
$largestFiles = Get-ChildItem -LiteralPath $Path -Recurse -File -Force:$forceFlag -ErrorAction SilentlyContinue |
  Sort-Object Length -Descending |
  Select-Object @{n="Size";e={ Format-Size $_.Length }},
                @{n="Name";e={$_.FullName}},
                @{n="Last Write";e={$_.LastWriteTime}} -First $Top
Write-Progress -Activity "Finding largest files" -Completed

Write-Host "`n=== Largest individual files under $Path (Top $Top) ===`n" -ForegroundColor Yellow
$largestFiles | Select-Object Size, Name, 'Last Write' | Format-Table -AutoSize

Write-Host "`nTip: Heavy hitters often include Windows Update cache (C:\Windows\SoftwareDistribution\Download), WinSxS, Temp, Downloads, and browser caches. Review before deleting." -ForegroundColor DarkCyan
