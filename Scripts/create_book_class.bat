@echo off
setlocal enabledelayedexpansion

cd Solar2D

REM Default values
set dst=.
set book=MyBook
set pages_input=page1
set src=lua_modules/kwiksher/resources/template/components/pageX/layer/bg.lua
set class=button
for %%i in (!src!) do set layer=%%~ni

REM Parse command-line arguments
:parse_args
if "%~1"=="" goto :end_parse_args
set arg=%~1
if "!arg:~0,6!"=="--dst=" (
  set dst=!arg:~6!
)
if "!arg:~0,7!"=="--book=" (
  set book=!arg:~7!
)
if "!arg:~0,8!"=="--pages=" (
  set pages_input=!arg:~8!
)
if "!arg:~0,6!"=="--src=" (
  set src=!arg:~6!
  for %%i in (!src!) do set layer=%%~ni
)
if "!arg:~0,8!"=="--class=" (
  set class=!arg:~8!
)
shift
goto :parse_args
:end_parse_args

echo pages_input is: !pages_input!

REM Convert pages_input to array (comma-separated list)
set pages=!pages_input:,= !

echo Parsed pages:
for %%p in (!pages!) do (
  echo %%p
)

mkdir "!dst!\App\!book!" 2>nul
set book_path=!dst!\App\!book!

set tmp=
for %%p in (!pages!) do (
  set page=%%p
  set tmp=!tmp!'%%p', 
  
  mkdir "!book_path!\assets\images\!page!" 2>nul
  mkdir "!book_path!\commands\!page!" 2>nul
  mkdir "!book_path!\components\!page!" 2>nul
  mkdir "!book_path!\components\!page!\audios" 2>nul
  mkdir "!book_path!\components\!page!\audios\long" 2>nul
  mkdir "!book_path!\components\!page!\audios\short" 2>nul
  mkdir "!book_path!\components\!page!\audios\sync" 2>nul
  mkdir "!book_path!\components\!page!\groups" 2>nul
  mkdir "!book_path!\components\!page!\layers" 2>nul
  mkdir "!book_path!\components\!page!\page" 2>nul
  mkdir "!book_path!\components\!page!\timers" 2>nul
  mkdir "!book_path!\components\!page!\variables" 2>nul
  mkdir "!book_path!\components\!page!\joints" 2>nul
  mkdir "!book_path!\models\!page!" 2>nul

  copy "!src!" "!book_path!\components\!page!\layers\!layer!.lua"
  set src_class=!src:%layer%=%layer%_%class%!
  copy "!src_class!" "!book_path!\components\!page!\layers\!layer!_!class!.lua"
  powershell -Command "$s = Get-Content -Raw '!book_path!\components\!page!\layers\!layer!_!class!.lua'; $s = $s -replace 'emitter_gemini\.lua','!page!.json'; [System.IO.File]::WriteAllText('!book_path!\components\!page!\layers\!layer!_!class!.lua',$s,(New-Object System.Text.UTF8Encoding $False))"

  echo local sceneName = ... > "!book_path!\!page!.lua"
  echo -- >> "!book_path!\!page!.lua"
  echo local scene = require('controller.scene').new(sceneName, { >> "!book_path!\!page!.lua"
  echo     components = { >> "!book_path!\!page!.lua"
  echo       layers = { { !layer! = { class= { "!class!" }} } }, >> "!book_path!\!page!.lua"
  echo       audios = { }, >> "!book_path!\!page!.lua"
  echo       groups = { }, >> "!book_path!\!page!.lua"
  echo       timers = { }, >> "!book_path!\!page!.lua"
  echo       variables = { }, >> "!book_path!\!page!.lua"
  echo       page = { } >> "!book_path!\!page!.lua"
  echo     }, >> "!book_path!\!page!.lua"
  echo     commands = { }, >> "!book_path!\!page!.lua"
  echo     onInit = function(scene) print("onInit") end >> "!book_path!\!page!.lua"
  echo }) >> "!book_path!\!page!.lua"
  echo -- >> "!book_path!\!page!.lua"
  echo return scene >> "!book_path!\!page!.lua"
)

echo !tmp!

echo local scenes = { > "!book_path!\index.lua"
echo !tmp! >> "!book_path!\index.lua"
echo } >> "!book_path!\index.lua"
echo return scenes >> "!book_path!\index.lua"

echo local M = { > "!book_path!\assets\model.lua"
echo   audios = {}, sprites = {}, videos = {} >> "!book_path!\assets\model.lua"
echo } >> "!book_path!\assets\model.lua"
echo return M >> "!book_path!\assets\model.lua"
