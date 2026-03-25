param(
  [string]$DbHost,
  [int]$DbPort,
  [string]$DbUser,
  [string]$DbPassword,
  [string]$Databases,
  [string]$OutputRoot,
  [int]$Threads = 8,
  [int]$Rows = 500000
)
$defaultHost = if ($DbHost) { $DbHost } else { Read-Host "MySQL host (default 127.0.0.1)" }
if (-not $defaultHost) { $defaultHost = "127.0.0.1" }
$defaultPort = if ($DbPort) { $DbPort } else { [int](Read-Host "MySQL port (default 3306)") }
if (-not $defaultPort) { $defaultPort = 3306 }
$defaultUser = if ($DbUser) { $DbUser } else { Read-Host "MySQL user" }
if (-not $DbPassword) {
  $secure = Read-Host "MySQL password" -AsSecureString
  $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
  $DbPassword = $plain
}
$dbs = if ($Databases) { $Databases } else { Read-Host "Comma separated database list (e.g. db1,db2)" }
$root = if ($OutputRoot) { $OutputRoot } else { Read-Host "Output directory (default D:\backup)" }
if (-not $root) { $root = "D:\backup" }
if (-not (Test-Path $root)) { New-Item -ItemType Directory -Force $root | Out-Null }
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$dumpName = "dump_$ts"
$dumpDir = Join-Path $root $dumpName
New-Item -ItemType Directory -Force $dumpDir | Out-Null
$cnfPath = Join-Path $dumpDir "mydumper.cnf"
@"
[client]
host=$defaultHost
port=$defaultPort
user=$defaultUser
password=$DbPassword
"@ | Set-Content -Encoding ASCII $cnfPath
function Find-Exe([string]$name) {
  $cmd = (Get-Command $name -ErrorAction SilentlyContinue)
  if ($cmd) { return $cmd.Source }
  $fallback = "C:\Program Files\mydumper\bin\$name"
  if (Test-Path $fallback) { return $fallback }
  return $null
}
$mydumperExe = Find-Exe "mydumper.exe"
if (-not $mydumperExe) { Write-Host "mydumper.exe not found"; exit 1 }
$args = @("--defaults-file", "$cnfPath", "-o", "$dumpDir", "-B", "$dbs", "-t", "$Threads", "--rows=$Rows", "--verbose", "2")
$logPath = Join-Path $dumpDir "mydumper.log"
$errLogPath = Join-Path $dumpDir "mydumper.err.log"
$proc = Start-Process -FilePath $mydumperExe -ArgumentList $args -NoNewWindow -PassThru -RedirectStandardOutput $logPath -RedirectStandardError $errLogPath
if (-not $proc) {
  Write-Host "Failed to start mydumper process"
  exit 1
}
Start-Sleep -Milliseconds 500
function DirSizeGB([string]$path) {
  $sum = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
  if (-not $sum) { $sum = 0 }
  return [math]::Round($sum/1GB,3)
}
$spinner = @("|","/","-","\")
$i = 0
while (-not $proc.HasExited) {
  $sizeGB = DirSizeGB $dumpDir
  $sym = $spinner[$i % $spinner.Length]
  Write-Host ("[{0}] Writing {1} GB to {2}" -f $sym, $sizeGB, $dumpDir)
  Start-Sleep -Seconds 2
  $i++
}
$exitCode = $proc.ExitCode
$finalGB = DirSizeGB $dumpDir
if (Test-Path $errLogPath) {
  $errContent = Get-Content $errLogPath -ErrorAction SilentlyContinue
  if ($errContent) {
    Add-Content -Path $logPath -Value $errContent
  }
}
Write-Host ("Done. ExitCode={0}, Size={1} GB, Dir={2}" -f $exitCode, $finalGB, $dumpDir)
Write-Host ("Log: {0}" -f $logPath)
