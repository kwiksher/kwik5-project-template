# copy_loop.ps1
$consoleTitle = 'Corona Simulator Console'   # title of the console window to send Ctrl+A/Ctrl+C to
$simulatorTitle = 'Solar2D - Solar2D Simulator'  # title of the simulator window to restore focus to
$logFile = Join-Path (Get-Location).Path 'log.txt'  # place log in the current working directory
$last = ''

#
# open the log file in VS Code once when the script starts, it works in vscode live share, not work in remoote SSH terminal
#
# function Open-LogFile([string]$path) {
#   if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path -Force | Out-Null }
#   if (Get-Command code -ErrorAction SilentlyContinue) {
#     try { & code -r -- $path } catch { }
#   } else {
#     try { & open -a "Visual Studio Code" $path } catch { }
#   }
# }
#
# Open-LogFile $logFile

$ws = New-Object -ComObject WScript.Shell

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# default process name pattern to detect the Corona Simulator (can be adjusted)
$simProcessPattern = '*Solar2D Simulator*'

try {
    # exit if Corona Simulator process is not present (safe check using pattern)
    $sim = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like $simProcessPattern -or $_.ProcessName -like '*Corona*' -or $_.ProcessName -like '*Simulator*' }
    if (-not $sim) {
      Write-Output 'Corona Simulator not running; stopping copy loop.'
      break
    }

    # get the Solar2D Simulator window handle to restore focus after copying
    $simProc = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*$simulatorTitle*" }
    $simHwnd = if ($simProc) { [IntPtr]$simProc[0].MainWindowHandle } else { [IntPtr]::Zero }
    $prevWindow = if ($simHwnd -ne [IntPtr]::Zero) { $simHwnd } else { [Win32]::GetForegroundWindow() }
    if ($ws.AppActivate($consoleTitle)) {
      Start-Sleep -Milliseconds 200
      $ws.SendKeys('^a')
      Start-Sleep -Milliseconds 50
      $ws.SendKeys('^c')
      Start-Sleep -Milliseconds 60

      $clip = Get-Clipboard -TextFormatType Text -ErrorAction SilentlyContinue
      if ($clip -and $clip -ne $last) {
        Set-Content -Path $logFile -Value $clip -Encoding UTF8
        $last = $clip
      }

      if ($prevWindow -ne [IntPtr]::Zero) { [Win32]::SetForegroundWindow($prevWindow) | Out-Null }
    }
} catch {
  $msg = $null
  if ($PSItem -and $PSItem.Exception) { $msg = $PSItem.Exception.Message }
  if ([string]::IsNullOrEmpty($msg)) { $msg = ($PSItem | Out-String).Trim() }
  if ([string]::IsNullOrEmpty($msg)) { $msg = 'Unknown error' }
  Write-Error ("copy_log.ps1 error: " + $msg)
}