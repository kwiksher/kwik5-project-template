@echo off
setlocal enabledelayedexpansion

REM Variables
set "REPO=kwiksher/kwik5-project-template"
set "SOLAR2D_DIR=.\Solar2D"
set "LUA_MODULES_TARGET=%SOLAR2D_DIR%\lua_modules"
set "PLUGIN_DIR=%SOLAR2D_DIR%\lua_modules\kwiksher"
set "SKINS_DIR=%APPDATA%\Corona Labs\Corona Simulator\Skins"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads"
set "TEMP_PLUGIN_FILE=%DOWNLOADS_DIR%\plugin-kwik.tgz"
set "TEMP_SRC_FILE=%DOWNLOADS_DIR%\kwik5-project-template-src.tgz"
set "EXTRACT_DIR=%DOWNLOADS_DIR%\kwik5-project-template-src"

REM Create the plugin directory if it doesn't exist
if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"

REM Create the skins directory if it doesn't exist
if not exist "%SKINS_DIR%" mkdir "%SKINS_DIR%"

REM Fetch the latest release information
echo Fetching information about the latest release...
echo https://api.github.com/repos/%REPO%/releases/latest
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (Invoke-WebRequest -Uri 'https://api.github.com/repos/%REPO%/releases/latest' -UseBasicParsing).Content}" > "%DOWNLOADS_DIR%\release_info.json"
if %errorlevel% neq 0 (
    echo Failed to connect to GitHub API. Please check your internet connection.
    exit /b 1
)

REM Extract the download URL for plugin-kwik.tgz
echo Extracting download URL for plugin-kwik.tgz...
for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%DOWNLOADS_DIR%\release_info.json' | ConvertFrom-Json; $asset = $json.assets | Where-Object { $_.name -like '*plugin-kwik.tgz' }; $asset.browser_download_url}"') do (
    set "PLUGIN_URL=%%a"
)

REM Extract the download URL for Source code (tar.gz)
echo Extracting download URL for source code...
for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%DOWNLOADS_DIR%\release_info.json' | ConvertFrom-Json; $json.tarball_url}"') do (
    set "SRC_URL=%%a"
)

REM Download the plugin-kwik.tgz file
echo Downloading plugin from !PLUGIN_URL!...
if "!PLUGIN_URL!"=="" (
    echo Could not find plugin-kwik.tgz in the latest release.
    exit /b 1
)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!PLUGIN_URL!' -OutFile '%TEMP_PLUGIN_FILE%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download the plugin. Please check your internet connection.
    exit /b 1
)
echo Download complete.

REM Remove old plugin files before extraction
echo Removing old plugin files...
if exist "%PLUGIN_DIR%\kwik.lua" del /q "%PLUGIN_DIR%\kwik.lua"
if exist "%PLUGIN_DIR%\kwik" rmdir /s /q "%PLUGIN_DIR%\kwik"
echo Old files removed.

REM Extract the plugin-kwik.tgz file
echo Installing plugin to %PLUGIN_DIR%...
powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%TEMP_PLUGIN_FILE%', '%PLUGIN_DIR%')}"
if %errorlevel% neq 0 (
    echo Failed to extract the plugin. The file may be corrupted.
    exit /b 1
)
echo Plugin installed successfully!

REM Download the Source code (tar.gz) file
echo Downloading source code from !SRC_URL!...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!SRC_URL!' -OutFile '%TEMP_SRC_FILE%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download the source code. Please check your internet connection.
    exit /b 1
)
echo Source code download complete.

REM Remove old extracted files and target lua_modules
echo Cleaning up old files for lua_modules...
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"
REM Only remove contents of lua_modules except for kwiksher
if exist "%LUA_MODULES_TARGET%" (
    for /d %%d in ("%LUA_MODULES_TARGET%\*") do (
        if /i not "%%~nxd"=="kwiksher" (
            rmdir /s /q "%%d"
        )
    )
    for %%f in ("%LUA_MODULES_TARGET%\*") do (
        if /i not "%%~nxf"=="kwiksher" (
            del /q "%%f"
        )
    )
)

REM Extract the tarball
echo Extracting source code...
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"
REM Convert Windows paths to Unix-style paths for tar
set "UNIX_TEMP_SRC_FILE=%TEMP_SRC_FILE:\=/%"
set "UNIX_TEMP_SRC_FILE=%UNIX_TEMP_SRC_FILE:C:=/c%"
set "UNIX_EXTRACT_DIR=%EXTRACT_DIR:\=/%"
set "UNIX_EXTRACT_DIR=%UNIX_EXTRACT_DIR:C:=/c%"
echo Extracting with tar: !UNIX_TEMP_SRC_FILE! to !UNIX_EXTRACT_DIR!
tar -xzf "!UNIX_TEMP_SRC_FILE!" -C "!UNIX_EXTRACT_DIR!"
if %errorlevel% neq 0 (
    echo tar command failed, trying PowerShell approach...
    powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%TEMP_SRC_FILE%', '%EXTRACT_DIR%')}"
)

REM Find the extracted folder (it will be named kwiksher-kwik5-project-template-*)
for /d %%d in ("%EXTRACT_DIR%\kwiksher-kwik5-project-template-*") do (
    set "EXTRACTED_SUBDIR=%%d"
    goto :found_subdir
)
:found_subdir

echo --- DEBUG INFO ---
echo EXTRACT_DIR is: %EXTRACT_DIR%
echo EXTRACTED_SUBDIR is: !EXTRACTED_SUBDIR!
echo Listing contents of EXTRACT_DIR:
dir "%EXTRACT_DIR%"
if defined EXTRACTED_SUBDIR (
    echo Listing contents of EXTRACTED_SUBDIR:
    dir /s "!EXTRACTED_SUBDIR!"
)
echo --- END DEBUG INFO ---

if not defined EXTRACTED_SUBDIR (
    echo Failed to find extracted source directory.
    exit /b 1
)

REM Copy lua_modules to the target location
echo Copying lua_modules to %LUA_MODULES_TARGET%...
if exist "!EXTRACTED_SUBDIR!\Solar2D\lua_modules" (
    xcopy /E /I /Y /Q "!EXTRACTED_SUBDIR!\Solar2D\lua_modules" "%LUA_MODULES_TARGET%\"
) else (
    echo lua_modules not found in source tarball, copying from ..\kwik5-project-template\Solar2D...
    if exist "..\kwik5-project-template\Solar2D\lua_modules" (
        xcopy /E /I /Y /Q "..\kwik5-project-template\Solar2D\lua_modules" "%LUA_MODULES_TARGET%\"
        echo Copied lua_modules from local ..\kwik5-project-template\Solar2D.
    ) else (
        echo lua_modules not found in ..\kwik5-project-template\Solar2D. Aborting.
        exit /b 1
    )
)

REM Copy Scripts/startSolar2D.bat to Corona Simulator directory
echo Copying startSolar2D.bat to Corona Simulator directory...
set "CORONA_SIMULATOR_DIR=%APPDATA%\Corona Labs\Corona Simulator"
if not exist "%CORONA_SIMULATOR_DIR%" mkdir "%CORONA_SIMULATOR_DIR%"
if exist "!EXTRACTED_SUBDIR!\Scripts\startSolar2D.bat" (
    copy /Y "!EXTRACTED_SUBDIR!\Scripts\startSolar2D.bat" "%CORONA_SIMULATOR_DIR%\"
    echo startSolar2D.bat copied successfully.
) else (
    echo Scripts/startSolar2D.bat not found in source tarball, checking local path...
    if exist "..\kwik5-project-template\Scripts\startSolar2D.bat" (
        copy /Y "..\kwik5-project-template\Scripts\startSolar2D.bat" "%CORONA_SIMULATOR_DIR%\"
        echo startSolar2D.bat copied from local path.
    ) else (
        echo Scripts/startSolar2D.bat not found. Skipping.
    )
)

REM Create the kwikEditorLandscape.lua skin file
echo Creating Kwik Editor Landscape skin file...
(
echo simulator =
echo {
echo   device = "desktop-1920x1080",
echo   screenOriginX = 0,
echo   screenOriginY = 0,
echo   screenWidth = 590,
echo   screenHeight = 960,
echo   iosPointWidth = 590,
echo   iosPointHeight = 960,
echo   deviceImage = nil,
echo   displayManufacturer = "Kwiksher",
echo   displayName = "Kwik Landscape",
echo   windowTitleBarName = "Kwik Editor Landscape"
echo }
) > "%SKINS_DIR%\kwikEditorLandscape.lua"
echo Kwik Editor Landscape skin file created.

REM Create the kwikEditorPortrait.lua skin file
echo Creating Kwik Editor Portrait skin file...
(
echo simulator =
echo {
echo   device = "desktop-1920x1080",
echo   screenOriginX = 0,
echo   screenOriginY = 0,
echo   screenWidth = 960,
echo   screenHeight = 590,
echo   deviceImage = nil,
echo   displayManufacturer = "",
echo   displayName = "Kwik Portrait",
echo   supportsScreenRotation = false,
echo   windowTitleBarName = "Kwik Portrait Editor"
echo }
) > "%SKINS_DIR%\kwikEditorPortrait.lua"
echo Kwik Editor Portrait skin file created.

REM Clean up
echo Cleaning up temp files...
if exist "%TEMP_PLUGIN_FILE%" del /q "%TEMP_PLUGIN_FILE%"
if exist "%TEMP_SRC_FILE%" del /q "%TEMP_SRC_FILE%"
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"

REM Extract release tag for final message
for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%DOWNLOADS_DIR%\release_info.json' -ErrorAction SilentlyContinue | ConvertFrom-Json; $json.tag_name}"') do (
    set "RELEASE_TAG=%%a"
)

REM Final message
echo Installation complete. Plugin version: !RELEASE_TAG!
echo You can now use the plugin in the Solar2D Simulator.
echo Kwik Editor Landscape skin is available in the Simulator.

endlocal