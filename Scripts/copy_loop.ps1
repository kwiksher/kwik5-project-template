# copy_loop.ps1
$windowTitle = 'Corona Simulator'   # change to a unique substring of the Simulator window title
$logFile = Join-Path (Get-Location).Path 'log.txt'  # place log in the current working directory
$last = ''

$ws = New-Object -ComObject WScript.Shell

# default process name pattern to detect the Corona Simulator (can be adjusted)
$simProcessPattern = 'Corona*'

try {
  while ($true) {
    # exit if Corona Simulator process is not present (safe check using pattern)
    $sim = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like $simProcessPattern -or $_.ProcessName -like '*Corona*' -or $_.ProcessName -like '*Simulator*' }
    if (-not $sim) {
      Write-Output 'Corona Simulator not running; stopping copy loop.'
      break
    }

    if ($ws.AppActivate($windowTitle)) {
      Start-Sleep -Milliseconds 3000
      $ws.SendKeys('^a')
      Start-Sleep -Milliseconds 50
      $ws.SendKeys('^c')
      Start-Sleep -Milliseconds 60

      $clip = Get-Clipboard -TextFormatType Text -ErrorAction SilentlyContinue
      if ($clip -and $clip -ne $last) {
        Set-Content -Path $logFile -Value $clip -Encoding UTF8
        $last = $clip
      }
    }
    Start-Sleep -Seconds 5
  }
} catch {
  $msg = $null
  if ($PSItem -and $PSItem.Exception) { $msg = $PSItem.Exception.Message }
  if ([string]::IsNullOrEmpty($msg)) { $msg = ($PSItem | Out-String).Trim() }
  if ([string]::IsNullOrEmpty($msg)) { $msg = 'Unknown error' }
  Write-Error ("copy_loop.ps1 error: " + $msg)
}