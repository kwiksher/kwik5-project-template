@echo off
setlocal enabledelayedexpansion

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
set dst=%~1
set book=%~2
set pages=%~3

REM Set default pages if none are provided
if "%pages%"=="" (
    set pages=page1
)

set tmp=

REM Create the book directory structure
mkdir %dst%\App\%book%
cd %dst%\App\%book%

for %%p in (%pages%) do (
    set page=%%p
    set tmp=!tmp!'%%p', 
    echo !page!
  
    mkdir assets\images\%%p
    mkdir commands\%%p
    mkdir components\%%p
    mkdir components\%%p\audios
    mkdir components\%%p\audios\long
    mkdir components\%%p\audios\short
    mkdir components\%%p\audios\sync
    mkdir components\%%p\groups
    mkdir components\%%p\layers
    mkdir components\%%p\page
    mkdir components\%%p\timers
    mkdir components\%%p\variables
    mkdir components\%%p\joints
    mkdir models\%%p
  
    copy "%~dp0background.lua" components\%%p\layers\background.lua
  
    cd components\%%p
    
    REM Create index.lua file using individual echo commands
    echo local sceneName = ... > index.lua
    echo -- >> index.lua
    echo local scene = require^('controller.scene'^).new^(sceneName, { >> index.lua
    echo     components = { >> index.lua
    echo       layers = { { background={} } }, >> index.lua
    echo       audios = { }, >> index.lua
    echo       groups = { }, >> index.lua
    echo       timers = { }, >> index.lua
    echo       variables = { }, >> index.lua
    echo       page = { } >> index.lua
    echo     }, >> index.lua
    echo     commands = { }, >> index.lua
    echo     onInit = function^(scene^) print^("onInit"^) end >> index.lua
    echo }^) >> index.lua
    echo -- >> index.lua
    echo return scene >> index.lua
    
    cd ..\..
)

echo !tmp!

cd %dst%\App\%book%

REM Create index.lua file using individual echo commands
echo local scenes = { > index.lua
echo !tmp! >> index.lua
echo } >> index.lua
echo return scenes >> index.lua

cd %dst%\App\%book%\assets

REM Create model.lua file using individual echo commands
echo local M = { > model.lua
echo   audios = {}, sprites = {}, videos = {} >> model.lua
echo } >> model.lua
echo return M >> model.lua

endlocal
exit /b
