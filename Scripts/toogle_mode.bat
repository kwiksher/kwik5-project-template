@echo off
setlocal EnableExtensions EnableDelayedExpansion

if "%~1"=="" goto usage

if /I "%~1"=="debug" (
    set "MODE=debug"
    set "SCALE=adaptive"
) else if /I "%~1"=="dev" (
    set "MODE=development"
    set "SCALE=adaptive"
) else if /I "%~1"=="prod" (
    set "MODE=production"
    set "SCALE=letterbox"
) else (
    goto usage
)

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fI"

set "MAIN_FILE=%PROJECT_ROOT%\Solar2D\main.lua"
set "CONFIG_FILE=%PROJECT_ROOT%\Solar2D\config.lua"

if not exist "%MAIN_FILE%" (
    echo Error: main file not found: %MAIN_FILE%
    exit /b 1
)

if not exist "%CONFIG_FILE%" (
    echo Error: config file not found: %CONFIG_FILE%
    exit /b 1
)

set "PWSH_MAIN_FILE=%MAIN_FILE%"
set "PWSH_CONFIG_FILE=%CONFIG_FILE%"
set "PWSH_MODE=%MODE%"
set "PWSH_SCALE=%SCALE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference = 'Stop';" ^
    "$mainPath = $env:PWSH_MAIN_FILE;" ^
    "$configPath = $env:PWSH_CONFIG_FILE;" ^
    "$mode = $env:PWSH_MODE;" ^
    "$scale = $env:PWSH_SCALE;" ^
    "$mainText = Get-Content -LiteralPath $mainPath -Raw;" ^
    "$modeCount = [regex]::Matches($mainText, '^(?!\s*--)\s*env\.mode\s*=', [System.Text.RegularExpressions.RegexOptions]::Multiline).Count;" ^
    "if ($modeCount -ne 1) { Write-Error ('env.mode assignment not found or ambiguous (found {0})' -f $modeCount); exit 1 }" ^
    "$mainText = [regex]::Replace($mainText, '^(?!\s*--)(\s*env\.mode\s*=\s*)\x22[^\x22]*\x22', ('$1' + [char]34 + $mode + [char]34), [System.Text.RegularExpressions.RegexOptions]::Multiline);" ^
    "Set-Content -LiteralPath $mainPath -Value $mainText;" ^
    "$configText = Get-Content -LiteralPath $configPath -Raw;" ^
    "$scaleCount = [regex]::Matches($configText, '^(?!\s*--)\s*scale\s*=', [System.Text.RegularExpressions.RegexOptions]::Multiline).Count;" ^
    "if ($scaleCount -ne 1) { Write-Error ('scale assignment not found or ambiguous (found {0})' -f $scaleCount); exit 1 }" ^
    "$configText = [regex]::Replace($configText, '^(?!\s*--)(\s*scale\s*=\s*)\x22[^\x22]*\x22(,?)', ('$1' + [char]34 + $scale + [char]34 + '$2'), [System.Text.RegularExpressions.RegexOptions]::Multiline);" ^
    "Set-Content -LiteralPath $configPath -Value $configText;"

if errorlevel 1 exit /b 1

echo Set env.mode=%MODE% and scale=%SCALE%
exit /b 0

:usage
echo Usage: toogle_mode.bat debug^|dev^|prod
exit /b 1