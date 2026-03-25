param(
  [string]$BackupDir,
  [string]$Mappings,
  [switch]$DropTables
)
function Find-Exe([string]$name) {
  $cmd = (Get-Command $name -ErrorAction SilentlyContinue)
  if ($cmd) { return $cmd.Source }
  $fallback = "C:\Program Files\mydumper\bin\$name"
  if (Test-Path $fallback) { return $fallback }
  return $null
}
if (-not $BackupDir) { $BackupDir = Read-Host "Backup directory (e.g. D:\backup\dump1)" }
if (-not (Test-Path $BackupDir)) { Write-Host "Backup directory not found"; exit 1 }
$myloaderExe = Find-Exe "myloader.exe"
if (-not $myloaderExe) { Write-Host "myloader.exe not found"; exit 1 }
$cnfGuess = Join-Path $BackupDir "mydumper.cnf"
if (-not (Test-Path $cnfGuess)) { $cnfGuess = "D:\backup\mydumper.cnf" }
if (-not (Test-Path $cnfGuess)) { Write-Host "defaults-file not found"; exit 1 }
$meta = Join-Path $BackupDir "metadata"
if (Test-Path $meta) {
  try {
    $bytes = [System.IO.File]::ReadAllBytes($meta)
    $filtered = New-Object System.Collections.Generic.List[byte]
    foreach ($b in $bytes) { if ($b -ne 13) { $filtered.Add($b) } }
    [System.IO.File]::WriteAllBytes($meta, $filtered.ToArray())
  } catch {}
}
if (-not $Mappings) { $Mappings = Read-Host "Mappings (src:dst pairs, comma separated e.g. trading_db:trading_db_restore,tick_monitor:tick_monitor_restore)" }
$pairs = $Mappings.Split(",") | Where-Object { $_ -match ":" }
$spinner = @("|","/","-","\")
$i = 0
foreach ($p in $pairs) {
  $src = $p.Split(":")[0].Trim()
  $dst = $p.Split(":")[1].Trim()
  $args = @("--defaults-file", "$cnfGuess", "-d", ".", "-s", "$src", "-B", "$dst", "--optimize-keys", "AFTER_IMPORT_ALL_TABLES")
  if ($DropTables) { $args += @("-o","DROP") }
  Push-Location $BackupDir
  $logPath = Join-Path $BackupDir ("restore_{0}_to_{1}.log" -f $src,$dst)
  $errLogPath = Join-Path $BackupDir ("restore_{0}_to_{1}.err.log" -f $src,$dst)
  $proc = Start-Process -FilePath $myloaderExe -ArgumentList $args -NoNewWindow -PassThru -RedirectStandardOutput $logPath -RedirectStandardError $errLogPath
  if (-not $proc) {
    Pop-Location
    Write-Host ("Failed to start restore process for {0}->{1}" -f $src, $dst)
    exit 1
  }
  Start-Sleep -Milliseconds 500
  while (-not $proc.HasExited) {
    $sym = $spinner[$i % $spinner.Length]
    Write-Host ("[{0}] Restoring {1} -> {2}" -f $sym, $src, $dst)
    Start-Sleep -Seconds 2
    $i++
  }
  if (Test-Path $errLogPath) {
    $errContent = Get-Content $errLogPath -ErrorAction SilentlyContinue
    if ($errContent) {
      Add-Content -Path $logPath -Value $errContent
    }
  }
  Pop-Location
  Write-Host ("Done {0}->{1}, ExitCode={2}, Log={3}" -f $src,$dst,$proc.ExitCode,$logPath)
}
