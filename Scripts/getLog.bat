REM run the copy loop script from the same folder as the batch file (blocking)
REM
REM powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0copy_loop.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0copy_log.ps1"
