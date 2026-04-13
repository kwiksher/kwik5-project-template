@echo off
setlocal

set TARGET=Solar2D/fonts
if not exist "%TARGET%" mkdir "%TARGET%"

echo Downloading Roboto and Noto Sans JP fonts...

REM --- Base URLs ---
set ROBOTO_BASE=https://github.com/google/fonts/raw/main/apache/roboto
set NOTO_BASE=https://github.com/google/fonts/raw/main/ofl/notosansjp

REM --- Roboto files ---
set ROBOTO_FILES=Roboto-Regular.ttf Roboto-Bold.ttf Roboto-Italic.ttf Roboto-Medium.ttf

REM --- Noto Sans JP files ---
set NOTO_FILES=NotoSansJP-Regular.ttf NotoSansJP-Bold.ttf NotoSansJP-Medium.ttf

echo.
echo === Fetching Roboto fonts ===
for %%F in (%ROBOTO_FILES%) do (
    echo Downloading %%F...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%ROBOTO_BASE