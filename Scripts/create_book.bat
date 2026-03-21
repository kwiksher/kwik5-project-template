@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"

REM Check if the required arguments are provided
if "%~1"=="" (
    echo Error: No destination provided.
    echo Usage: create_book.bat [dst] [book] [pages]
    exit /b 1
)

if "%~2"=="" (
    echo Error: No book name provided.
    echo Usage: create_book.bat [dst] [book] [pages]
    exit /b 1
)

REM Set variables from arguments
set "dst=%~1"
set "book=%~2"
set "pages=%~3"

REM Set default pages if none are provided
if "%pages%"=="" (
    set "pages=page1"
)

set tmp=

REM Create the book directory structure
mkdir "%dst%\App\%book%" 2>nul
cd /d "%dst%\App\%book%" || exit /b 1

for %%p in (%pages%) do (
    set page=%%p
    set tmp=!tmp!'%%p',
    echo !page!

    mkdir "assets\images\%%p" 2>nul
    mkdir "commands\%%p" 2>nul
    mkdir "components\%%p" 2>nul
    mkdir "components\%%p\audios" 2>nul
    mkdir "components\%%p\audios\long" 2>nul
    mkdir "components\%%p\audios\short" 2>nul
    mkdir "components\%%p\audios\sync" 2>nul
    mkdir "components\%%p\groups" 2>nul
    mkdir "components\%%p\layers" 2>nul
    mkdir "components\%%p\page" 2>nul
    mkdir "components\%%p\timers" 2>nul
    mkdir "components\%%p\variables" 2>nul
    mkdir "components\%%p\joints" 2>nul
    mkdir "models\%%p" 2>nul

    copy /Y "%SCRIPT_DIR%background.lua" "components\%%p\layers\background.lua" >nul

    REM Create %%p.lua at the book root (same as create_book.command)
    echo local sceneName = ... > "%%p.lua"
    echo -- >> "%%p.lua"
    echo local scene = require^('controller.scene'^).new^(sceneName, { >> "%%p.lua"
    echo     components = { >> "%%p.lua"
    echo       layers = { { background={} } }, >> "%%p.lua"
    echo       audios = { }, >> "%%p.lua"
    echo       groups = { }, >> "%%p.lua"
    echo       timers = { }, >> "%%p.lua"
    echo       variables = { }, >> "%%p.lua"
    echo       page = { } >> "%%p.lua"
    echo     }, >> "%%p.lua"
    echo     commands = { }, >> "%%p.lua"
    echo     onInit = function^(scene^) print^("onInit"^) end >> "%%p.lua"
    echo }^) >> "%%p.lua"
    echo -- >> "%%p.lua"
    echo return scene >> "%%p.lua"
)

echo !tmp!

cd /d "%dst%\App\%book%"

REM Create index.lua file using individual echo commands
echo local scenes = { > index.lua
echo !tmp! >> index.lua
echo } >> index.lua
echo return scenes >> index.lua

cd /d "%dst%\App\%book%\assets"

REM Create model.lua file using individual echo commands
echo local M = { > model.lua
echo   audios = {}, sprites = {}, videos = {} >> model.lua
echo } >> model.lua
echo return M >> model.lua

endlocal
exit /b
