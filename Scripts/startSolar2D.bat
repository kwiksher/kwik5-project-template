@echo off
setlocal EnableDelayedExpansion

rem ---------- new option parsing (aligned with startSolar2D.command) ----------
set "SCALE_ARG=1x"
set "SKIN=KwikEditorLandscape"
set "SINGLETON=0"

:parse_args
if "%~1"=="" goto args_parsed
if "%~1"=="-scale" (
    shift
    call set "SCALE_ARG=%%~1"
    shift
    goto parse_args
)
if "%~1"=="--scale" (
    shift
    call set "SCALE_ARG=%%~1"
    shift
    goto parse_args
)
if "%~1"=="--singleton" (
    set "SINGLETON=1"
    shift
    goto parse_args
)
rem unknown arg -> keep for URI behavior
set "ARG_REMAIN=%~1"
shift
set "URI=%ARG_REMAIN%"
goto parse_args

:args_parsed
if /i "%SCALE_ARG%"=="1x" (set "SKIN=KwikEditorLandscape")
if /i "%SCALE_ARG%"=="1"  (set "SKIN=KwikEditorLandscape")
if /i "%SCALE_ARG%"=="2x" (set "SKIN=KwikEditorLandscape2x")
if /i "%SCALE_ARG%"=="2"  (set "SKIN=KwikEditorLandscape2x")

if /i "%SCALE_ARG%"=="1x" goto _scale_ok
if /i "%SCALE_ARG%"=="1" goto _scale_ok
if /i "%SCALE_ARG%"=="2x" goto _scale_ok
if /i "%SCALE_ARG%"=="2" goto _scale_ok
echo Invalid scale: %SCALE_ARG%. Use 1x or 2x
exit /b 1
:_scale_ok

if "%SINGLETON%"=="1" echo [debug] SINGLETON=1, attempting to stop Corona Simulator instance(s)...
if "%SINGLETON%"=="0" echo [debug] SINGLETON=0, skipping taskkill
if "%SINGLETON%"=="1" (
    echo [debug] tasklist for Corona Simulator.exe:
    tasklist /fi "imagename eq Corona Simulator.exe" /fo csv /nh
    for /f "tokens=2 delims=," %%i in ('tasklist /fi "imagename eq Corona Simulator.exe" /fo csv /nh') do (
        echo [debug] killing PID %%~i ^(Corona Simulator.exe^)
        taskkill /pid %%~i /f
    )
    echo [debug] tasklist for Corona.Console.exe:
    tasklist /fi "imagename eq Corona.Console.exe" /fo csv /nh
    for /f "tokens=2 delims=," %%i in ('tasklist /fi "imagename eq Corona.Console.exe" /fo csv /nh') do (
        echo [debug] killing PID %%~i ^(Corona.Console.exe^)
        taskkill /pid %%~i /f
    )
    echo [debug] taskkill done
)

rem ---------- path and URI handling ----------
if not defined URI (
    echo No URI provided. Launching default project...
    set "filePath=%CD%\Solar2D\main.lua"
) else (
    set "filePath=%URI%"
    rem parse uri-style "...url=file://...&skin=..."
    for /f "delims=&" %%a in ("!filePath!") do set "part=%%a"
    set "filePath=!part:~4!"
)

rem fallback default path if parsing failed
if not defined filePath set "filePath=%CD%\Solar2D\main.lua"

rem replace path styles
set "filePath=!filePath:file://=!"
set "filePath=!filePath:%%5C=\!"
set "filePath=!filePath:/=\!"
set "filePath=!filePath:%%20= !"

rem ---------- sync main.lua scale variable if possible ----------
set "MAIN_DIR=%CD%\Solar2D"
set "MAIN_FILE=%MAIN_DIR%\main.lua"
if exist "%MAIN_FILE%" (
    powershell -NoProfile -Command "(Get-Content '%MAIN_FILE%') -replace '(scale\s*=\s*)\d+', '${1}%SCALE_ARG:~0,1%' | Set-Content '%MAIN_FILE%'"
)

rem ---------- set simulator device in registry ----------
reg add "HKCU\Software\Ansca Corona\Corona Simulator\Preferences" /v "Device" /t REG_SZ /d "%SKIN%" /f >nul

rem ---------- start simulator ----------
start "" "C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe" "%filePath%"


