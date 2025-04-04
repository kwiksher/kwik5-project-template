@echo off
setlocal enabledelayedexpansion

REM Variables
set "REPO=kwiksher/kwik5-project-template"
set "PLUGIN_NAME=plugin"
set "PLUGIN_DIR=%APPDATA%\Corona Labs\Corona Simulator\Plugins\%PLUGIN_NAME%"
set "SKINS_DIR=%APPDATA%\Corona Labs\Corona Simulator\Skins"
set "TEMP_FILE=%TEMP%\plugin.data.tgz"
set "TEMP_DIR=%TEMP%\kwik_plugin_temp"
set "START_SOLAR2D_URL=https://raw.githubusercontent.com/kwiksher/kwik5-project-template/main/Scripts/startSolar2D.bat"
set "START_SOLAR2D_PATH=%SKINS_DIR%\startSolar2D.bat"
set "SOLAR2D_REG_URL=https://raw.githubusercontent.com/kwiksher/kwik5-project-template/main/Scripts/solar2d.reg"
set "SOLAR2D_REG_PATH=%TEMP%\solar2d.reg"

REM Create the plugin directory if it doesn't exist
if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"

REM Create the skins directory if it doesn't exist
if not exist "%SKINS_DIR%" mkdir "%SKINS_DIR%"

REM Fetch startSolar2D.bat file
echo Downloading startSolar2D.bat...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%START_SOLAR2D_URL%' -OutFile '%START_SOLAR2D_PATH%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download startSolar2D.bat. Please check your internet connection.
    echo Continuing with plugin installation...
) else (
    echo startSolar2D.bat downloaded successfully to %START_SOLAR2D_PATH%
)

REM Fetch solar2d.reg file
echo Downloading solar2d.reg...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%SOLAR2D_REG_URL%' -OutFile '%SOLAR2D_REG_PATH%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download solar2d.reg. Please check your internet connection.
    echo Continuing with plugin installation...
) else (
    echo solar2d.reg downloaded successfully to %SOLAR2D_REG_PATH%
    
    REM Import the registry file
    echo Importing solar2d.reg to Windows registry...
    reg import "%SOLAR2D_REG_PATH%" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Failed to import solar2d.reg. Please run this script as administrator.
        echo You can manually import the registry file from: %SOLAR2D_REG_PATH%
    ) else (
        echo solar2d.reg imported successfully. Solar2D URL scheme is now registered.
        del "%SOLAR2D_REG_PATH%"
    )
)

REM Fetch the latest release information
echo Fetching information about the latest release...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (Invoke-WebRequest -Uri 'https://api.github.com/repos/%REPO%/releases/latest' -UseBasicParsing).Content}" > "%TEMP%\release_info.json"
if %errorlevel% neq 0 (
    echo Failed to connect to GitHub API. Please check your internet connection.
    exit /b 1
)

REM Extract the download URL for plugin.data.tgz
echo Extracting download URL...
for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%TEMP%\release_info.json' | ConvertFrom-Json; $asset = $json.assets | Where-Object { $_.name -like '*plugin.data.tgz' }; $asset.browser_download_url}"') do (
    set "DOWNLOAD_URL=%%a"
)

REM Check if we found a download URL
if "!DOWNLOAD_URL!"=="" (
    echo Could not find plugin.data.tgz in the latest release.
    echo Please check if the file exists in the latest release of %REPO%.
    exit /b 1
)

REM Download the plugin.data.tgz file
echo Downloading plugin from !DOWNLOAD_URL!...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile '%TEMP_FILE%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download the plugin. Please check your internet connection.
    exit /b 1
)
echo Download complete.

REM Remove old files before extraction
echo Removing old plugin files...
if exist "%PLUGIN_DIR%\kwik.lua" del /q "%PLUGIN_DIR%\kwik.lua"
if exist "%PLUGIN_DIR%\kwik" rmdir /s /q "%PLUGIN_DIR%\kwik"
echo Old files removed.

REM Extract the plugin.data.tgz file using PowerShell and 7-Zip
echo Installing plugin to %PLUGIN_DIR%...

REM Create temp extraction directory
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Check if 7-Zip is installed and in PATH
where 7z >nul 2>nul
if %errorlevel% neq 0 (
    echo 7-Zip not found. Using PowerShell tar extraction...
    
    REM Using PowerShell to extract
    powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%TEMP_FILE%', '%TEMP_DIR%')}"
) else (
    echo Extracting with 7-Zip...
    7z x "%TEMP_FILE%" -o"%TEMP_DIR%" -y
)

REM Copy extracted files to the plugin directory
xcopy /E /I /Y "%TEMP_DIR%\*" "%PLUGIN_DIR%\"
if %errorlevel% neq 0 (
    echo Failed to install the plugin. The file may be corrupted.
    exit /b 1
)
echo Plugin installed successfully!

REM Create the kwikEditorLandscape.lua skin file
echo Creating Kwik Editor Landscape skin file...
(
echo simulator =
echo {
echo   device = "win32",
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

REM Clean up
del "%TEMP_FILE%"
rmdir /s /q "%TEMP_DIR%"
del "%TEMP%\release_info.json"

REM Extract release tag for final message
for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%TEMP%\release_info.json' -ErrorAction SilentlyContinue | ConvertFrom-Json; $json.tag_name}"') do (
    set "RELEASE_TAG=%%a"
)

REM Final message
echo Installation complete. Plugin version: !RELEASE_TAG!
echo You can now use the plugin in the Solar2D Simulator.
echo Kwik Editor Landscape skin is available in the Simulator.
echo Solar2D URL scheme handler is installed with startSolar2D.bat.
echo.
echo IMPORTANT: If the registry import failed, please run this script as administrator
echo or manually import the registry file from: %SOLAR2D_REG_PATH%

endlocal