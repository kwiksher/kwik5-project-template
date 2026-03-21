@echo off
setlocal enabledelayedexpansion

REM --version: print local and remote version, then exit
if /i "%1"=="--version" (
    REM local version
    set "LOCAL_VERSION=not-installed"
    if exist "%PLUGIN_DIR%\version.txt" (
        set /p LOCAL_VERSION=<"%PLUGIN_DIR%\version.txt"
    )

    REM fetch release info
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (Invoke-WebRequest -Uri 'https://api.github.com/repos/%REPO%/releases/latest' -UseBasicParsing).Content}" > "%DOWNLOADS_DIR%\release_info.json"
    if %errorlevel% neq 0 (
        echo Failed to connect to GitHub API. Please check your internet connection.
        exit /b 1
    )

    for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%DOWNLOADS_DIR%\release_info.json' | ConvertFrom-Json; $json.tag_name}"') do (
        set "REMOTE_TAG=%%a"
    )

    set "NEW_VERSION=%REMOTE_TAG%"

    for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%DOWNLOADS_DIR%\release_info.json' | ConvertFrom-Json; $asset = $json.assets | Where-Object { $_.name -like '*version.txt' }; if($asset){ $asset.browser_download_url }}"') do (
        set "VERSION_ASSET_URL=%%a"
    )

    if defined VERSION_ASSET_URL (
        powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%VERSION_ASSET_URL%' -OutFile '%DOWNLOADS_DIR%\version.txt' -UseBasicParsing }"
        if exist "%DOWNLOADS_DIR%\version.txt" (
            set /p "NEW_VERSION"=<"%DOWNLOADS_DIR%\version.txt"
            if exist "%PLUGIN_DIR%\version.txt" (
                set /p "OLD_VERSION"=<"%PLUGIN_DIR%\version.txt"
            ) else (
                set "OLD_VERSION=not-installed"
            )
            copy /Y "%DOWNLOADS_DIR%\version.txt" "%PLUGIN_DIR%\version.txt" >nul 2>&1 || echo Failed to copy version.txt to %PLUGIN_DIR%
            del /q "%DOWNLOADS_DIR%\version.txt"
        )
    )

    echo Local version:  %LOCAL_VERSION%
    echo Remote version: %NEW_VERSION%
    exit /b 0
)

REM Check for --regonly argument
if /i "%1"=="--regonly" (
    call :install_registry_only
    exit /b
)

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
    pause
    exit /b 1
)

REM --- New: fetch version.txt asset and compare with local version ---
set "TEMP_VERSION_FILE=%DOWNLOADS_DIR%\kwik_version.txt"
for /f "tokens=*" %%a in ('powershell -Command "& {$json = Get-Content '%DOWNLOADS_DIR%\release_info.json' | ConvertFrom-Json; $asset = $json.assets | Where-Object { $_.name -like '*version.txt' }; if($asset){ $asset.browser_download_url }}"') do (
    set "VERSION_ASSET_URL=%%a"
)
if defined VERSION_ASSET_URL (
    echo Downloading version.txt from release asset...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%VERSION_ASSET_URL%' -OutFile '%TEMP_VERSION_FILE%' -UseBasicParsing }"
    if exist "%TEMP_VERSION_FILE%" (
        set /p "NEW_VERSION"=<"%TEMP_VERSION_FILE%"
        if exist "%PLUGIN_DIR%\version.txt" (
            set /p "OLD_VERSION"=<"%PLUGIN_DIR%\version.txt"
        ) else (
            set "OLD_VERSION=not-installed"
        )
        echo Old version: %OLD_VERSION%
        echo New version: %NEW_VERSION%
        copy /Y "%TEMP_VERSION_FILE%" "%PLUGIN_DIR%\version.txt" >nul 2>&1 || echo Failed to copy version.txt to %PLUGIN_DIR%
        del /q "%TEMP_VERSION_FILE%"
    ) else (
        echo Failed to download version.txt from release assets. Skipping version update.
    )
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
    pause
    exit /b 1
)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!PLUGIN_URL!' -OutFile '%TEMP_PLUGIN_FILE%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download the plugin. Please check your internet connection.
    pause
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
tar -xzf "%TEMP_PLUGIN_FILE%" -C "%PLUGIN_DIR%"
if %errorlevel% equ 0 (
    echo Plugin extracted successfully using tar.
) else (
    echo tar command failed or is not available. Trying PowerShell...
    powershell -Command "& { try { Expand-Archive -Path '%TEMP_PLUGIN_FILE%' -DestinationPath '%PLUGIN_DIR%' -Force } catch { Write-Host 'PowerShell Expand-Archive failed.'; exit 1 } }"
    if %errorlevel% neq 0 (
        echo Failed to extract plugin using all available methods.
        pause
        exit /b 1
    )
)
echo Plugin installed successfully!

REM Download the Source code (tar.gz) file
echo Downloading source code from !SRC_URL!...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!SRC_URL!' -OutFile '%TEMP_SRC_FILE%' -UseBasicParsing}"
if %errorlevel% neq 0 (
    echo Failed to download the source code. Please check your internet connection.
    pause
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

REM Attempt to use tar.exe first, as it's most reliable
tar -xzf "%TEMP_SRC_FILE%" -C "%EXTRACT_DIR%"
if %errorlevel% equ 0 (
    echo Source code extracted successfully using tar.
) else (
    echo tar command failed or is not available. Trying PowerShell...
    powershell -Command "& {
        try {
            Expand-Archive -Path '%TEMP_SRC_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force
        } catch {
            Write-Host 'PowerShell Expand-Archive failed. This may require the Microsoft.PowerShell.Archive module.'
            Write-Host 'Please ensure you are running Windows 10+ or have PowerShell 5.1+ with the module installed.'
            exit 1
        }
    }"
    if %errorlevel% neq 0 (
        echo Failed to extract source code using all available methods.
        pause
        exit /b 1
    )
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
    pause
    exit /b 1
)

REM Copy Simulator skin files from the extracted source tree instead of embedding
REM their contents directly in this installer.
set "SOURCE_SKINS_DIR=!EXTRACTED_SUBDIR!\Scripts"
if not exist "!SOURCE_SKINS_DIR!" (
    echo Scripts directory not found in extracted source tree. Aborting.
    pause
    exit /b 1
)

REM Copy lua_modules to the target location
echo Copying lua_modules to %LUA_MODULES_TARGET%...
if exist "!EXTRACTED_SUBDIR!\Solar2D\lua_modules" (
    echo Copying lua_modules, excluding kwiksher...
    robocopy "!EXTRACTED_SUBDIR!\Solar2D\lua_modules" "%LUA_MODULES_TARGET%" /E /XD kwiksher
) else (
    echo lua_modules not found in source tarball, copying from ..\kwik5-project-template\Solar2D...
    if exist "..\kwik5-project-template\Solar2D\lua_modules" (
        echo Copying lua_modules from local ..\kwik5-project-template\Solar2D, excluding kwiksher...
        robocopy "..\kwik5-project-template\Solar2D\lua_modules" "%LUA_MODULES_TARGET%" /E /XD kwiksher
        echo Copied lua_modules from local ..\kwik5-project-template\Solar2D.
    ) else (
        echo lua_modules not found in ..\kwik5-project-template\Solar2D. Aborting.
        pause
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

call :install_skin_file "kwikEditorLandscape_mac.lua" "kwikEditorLandscape.lua"
call :install_skin_file "kwikEditorLandscape2x_mac.lua" "kwikEditorLandscape2x.lua"
call :install_skin_file "kwikEditorPortrait_mac.lua" "kwikEditorPortrait.lua"
call :install_skin_file "kwikEditorPortrait2x_mac.lua" "kwikEditorPortrait2x.lua"

call :install_registry_only

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
echo Kwik Editor Landscape, Landscape 2x, Portrait, and Portrait 2x skins are available in the Simulator.

pause
endlocal
exit /b

:install_registry_only
    REM Create solar2d.reg with dynamic user path
    echo Creating solar2d.reg with dynamic user path...
    set "SOLAR2D_REG_FILE=%~dp0solar2d.reg"

    echo --- DEBUG: Registry File Path ---
    echo Attempting to create file at: %SOLAR2D_REG_FILE%
    echo Current directory is: %cd%
    echo Script directory is: %~dp0
    echo --- END DEBUG ---

    set "ESCAPED_APPDATA=%APPDATA:\=\\%"
    (
    echo Windows Registry Editor Version 5.00
    echo.
    echo [HKEY_CLASSES_ROOT\solar2d]
    echo @="URL:solar2d Protocol"
    echo "URL Protocol"=""
    echo.
    echo [HKEY_CLASSES_ROOT\solar2d\shell\open\command]
    echo @="\"!ESCAPED_APPDATA!\\Corona Labs\\Corona Simulator\\startSolar2D.bat\" \"%%1\""
    ) > "%SOLAR2D_REG_FILE%"

    REM --- DEBUG: Check file creation ---
    if exist "%SOLAR2D_REG_FILE%" (
        echo SUCCESS: solar2d.reg was created successfully.
    ) else (
        echo ERROR: Failed to create solar2d.reg.
        echo Please check write permissions for the directory: %~dp0
        pause
        goto :eof
    )
    REM --- END DEBUG ---

    echo solar2d.reg created at %SOLAR2D_REG_FILE%

    REM Optionally install the registry entry
    echo.
    set /p "INSTALL_REGISTRY=Do you want to install the Solar2D protocol handler? (y/n): "
    if /i "!INSTALL_REGISTRY!"=="y" (
        echo Installing Solar2D protocol handler...
        regedit /s "%SOLAR2D_REG_FILE%" 2>nul
        if !errorlevel! equ 0 (
            echo Solar2D protocol handler installed successfully.
            echo You can now use URLs like: solar2d://open?url=file://path/to/main.lua
        ) else (
            echo Failed to install registry entry. Please run as Administrator and try:
            echo   regedit /s "%SOLAR2D_REG_FILE%"
            pause
        )
    ) else (
        echo Skipped registry installation.
        echo To install later, run as Administrator:
        echo   regedit /s "%SOLAR2D_REG_FILE%"
    )
    echo.
goto :eof

:install_skin_file
    set "SOURCE_FILE=%~1"
    set "DEST_FILE=%~2"

    if not exist "!SOURCE_SKINS_DIR!\!SOURCE_FILE!" (
        echo Missing skin template: !SOURCE_SKINS_DIR!\!SOURCE_FILE!
        pause
        exit /b 1
    )

    copy /Y "!SOURCE_SKINS_DIR!\!SOURCE_FILE!" "%SKINS_DIR%\!DEST_FILE!" >nul
    if errorlevel 1 (
        echo Failed to install !DEST_FILE! from !SOURCE_FILE!
        pause
        exit /b 1
    ) else (
        echo Installed !DEST_FILE! from !SOURCE_FILE!
    )
    goto :eof