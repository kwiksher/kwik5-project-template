@echo off
for /f %%i in ('tasklist 2^>^&1') do (
    if /i %%i==Corona (
        taskkill /im "Corona Simulator.exe" /f
        taskkill /im "Corona.Console.exe" /f
        goto ENDLOOP;
    )
)
:ENDLOOP
setlocal EnableDelayedExpansion

:: If no URI is passed, launch the default project directly
if "%~1"=="" (
    echo No URI provided. Launching default project...
    set "filePath=%~dp0..\Kwik5 Proj\Solar2D\main.lua"
    set "skin=kwikEditorLandscape"
    goto :start_simulator
)

:: Save input to debug file for inspection
echo Input: %1 > "%~dp0\debug_input.txt"

:: Parse the custom URI passed as %1
set "uri=%~1"

:: Save the original URI
echo Original URI: %uri% > "%~dp0\tmp.txt"

:: Extract the file path more reliably
set "tempStr=%uri:*url=url%"
set "tempStr=!tempStr:*url=!"
if "!tempStr:~0,1!"=="=" set "tempStr=!tempStr:~1!"

:: Find the position of "&skin=" if it exists
set "filePath=!tempStr!"
for /f "delims=" %%a in ("!tempStr!") do (
    set "test=%%a"
    set "pos=0"
    :loop
    if "!test:~0,6!"=="&skin=" (
        set "filePath=!tempStr:~0,%pos%!"
        set "skin=!test:~6!"
        goto found
    )
    set /a pos+=1
    set "test=!test:~1!"
    if not "!test!"=="" goto loop
)
:found

:: If no skin parameter found, set default
if not defined skin set "skin=kwikEditorLandscape"

:: Remove "file://" from the file path if it exists
set "filePath=!filePath:file://=!"

:: Replace %%5C with backslash (note the escaped % character)
set "filePath=!filePath:%%5C=\!"

:: Replace forward slashes with backslashes
set "filePath=!filePath:/=\!"

:: Unescape %20 to space
set "filePath=!filePath:%%20= !"

:: Save the parsed parameters for debugging
echo filePath=!filePath! >> "%~dp0\tmp.txt"
echo skin=!skin! >> "%~dp0\tmp.txt"

:start_simulator
:: Start the Solar2D Simulator with the parsed arguments
start "" "C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe" "!filePath!" /skin="!skin!"