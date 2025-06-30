-- print("kwik", "hello")
local Library = require "CoronaLibrary"
--
--local pluginPath="plugin"
local pluginPath= "kwiksher"

--
local lib = {}
if pluginPath == "plugin" then
  lib = Library:new {name = "kwik", publisherId = "com.kwiksher"}
end

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                   archInfo == "IA64" or archInfo == "ARM"

---
-- Global
kwikGlobal = {}
--
local kwikPath
if pluginPath == nil then
  kwikGlobal.PATH = "kwik/"
  kwikGlobal.ROOT = "kwik."
  -- print("system.pathForFile", system.pathForFile(nil, system.ResourceDirectory))
  kwikPath = (system.pathForFile(kwikGlobal.PATH, system.ResourceDirectory) or "kwik").."/"
else
  kwikGlobal.PATH = "lua_modules/"..pluginPath.."/kwik/"
 kwikGlobal.ROOT = pluginPath..".kwik."
  -- kwikGlobal.ROOT = "kwik."
  kwikPath = (system.pathForFile(kwikGlobal.PATH, system.ResourceDirectory) or "").."/"
end
--
-- print("kwik", "kwikGlobal.Path",kwikGlobal.PATH)
-- print("kwik", "kwikGloabl.ROOT",kwikGlobal.ROOT)
-- print("kwik", "kwikPath",kwikPath)

local folders = {
  ".",
-- "assets",
-- "assets/images",
-- "assets/images/easing",
-- "assets/images/filters",
-- "assets/images/icons",
-- "assets/images/particles",
-- "assets/kwik",
-- "assets/mui",
-- "assets/mui/icon-font",
"commands",
"commands/app",
"commands/common",
"commands/kwik",
"components",
"components/bookstore",
"components/bookstore/controller",
"components/bookstore/model",
"components/bookstore/smc",
"components/bookstore/view",
"components/common",
"components/custom",
"components/kwik",
"components/mui",
"controller",
-- "editor",
-- "editor/action",
-- "editor/action/actionCommand",
-- "editor/action/controller",
-- "editor/animation",
-- "editor/asset",
-- "editor/asset/controller",
-- "editor/asset/img",
-- "editor/audio",
-- "editor/audio/controller",
-- "editor/audio/img",
-- "editor/book",
-- "editor/controller",
-- "editor/controller/BTree",
-- "editor/controller/properties",
-- "editor/controller/selector",
-- "editor/controller/shape",
-- "editor/group",
-- "editor/group/controller",
-- "editor/interaction",
-- "editor/kwik_json",
-- "editor/layer",
-- "editor/lib",
-- "editor/lib/metalua",
-- "editor/lib/metalua/compiler",
-- "editor/lib/metalua/compiler/bytecode",
-- "editor/lib/metalua/compiler/parser",
-- "editor/lib/metalua/compiler/parser/annot",
-- "editor/lib/metalua/extension",
-- "editor/lib/metalua/grammar",
-- "editor/lib/metalua/treequery",
-- "editor/page",
-- "editor/parts",
-- "editor/physics",
-- "editor/physics/controller",
-- "editor/picker",
-- "editor/replacement",
-- "editor/replacement/controller",
-- "editor/replacement/particles",
-- "editor/scripts",
-- "editor/shape",
-- "editor/timer",
-- "editor/timer/controller",
-- "editor/trash",
-- "editor/variable",
-- "editor/variable/controller",
"com",
"com/gieson",
"lustache",
"materialui",
"materialui/material-design-icons",
"nanostores",
"nanostores/lib",
"nanostores/scripts",
"plugin",
-- "plugin/mouseHover",
"pretty",
"pretty/json",
"robotlegs",
"spyric",
"transition2lib",
-- "installer",
-- "installer/lustache",
-- "installer/Skins",
-- "lib",
-- "server",
-- "server/controller",
-- "server/docs",
-- "server/pegasus",
-- "server/sampleUI",
-- "server/tests",
-- "template",
-- "template/assets",
-- "template/assets/audios",
-- "template/assets/audios/long",
-- "template/assets/audios/short",
-- "template/assets/audios/sync",
-- "template/assets/audios/sync/en",
-- "template/assets/audios/sync/jp",
-- "template/assets/fonts",
-- "template/assets/images",
-- "template/assets/images/pageX",
-- "template/assets/particles",
-- "template/assets/sprites",
-- "template/assets/thumbnails",
-- "template/assets/videos",
-- "template/commands",
-- "template/commands/pageX",
-- "template/components",
-- "template/components/pageX",
-- "template/components/pageX/animation",
-- "template/components/pageX/animation/defaults",
-- "template/components/pageX/audio",
-- "template/components/pageX/audio/defaults",
-- "template/components/pageX/group",
-- "template/components/pageX/group/defaults",
-- "template/components/pageX/interaction",
-- "template/components/pageX/interaction/defaults",
-- "template/components/pageX/layer",
-- "template/components/pageX/layer/defaults",
-- "template/components/pageX/page",
-- "template/components/pageX/page/controllers",
-- "template/components/pageX/page/defaults",
-- "template/components/pageX/physics",
-- "template/components/pageX/physics/defaults",
-- "template/components/pageX/replacement",
-- "template/components/pageX/replacement/defaults",
-- "template/components/pageX/replacement/particles",
-- "template/components/pageX/replacement/particles/defaults",
-- "template/components/pageX/shape",
-- "template/components/pageX/timer",
-- "template/components/pageX/timer/defaults",
-- "template/components/pageX/variable",
-- "template/components/pageX/variable/defaults",
-- "template/models",
-- "template/models/pageX",
-- "test",
-- "test/animation",
-- "test/book",
-- "test/bookTest",
-- "test/github",
-- "test/interaction",
-- "test/keyboard",
-- "test/lingualSample",
-- "test/replacement",
}

-- print("kwik", "package.path", package.path)
--[[
if lib.pacakge_path_added == nil then
  if package.path == "(null)/?.lua;(null)/?.lua;" then
    package.path = ""
  end
  -- /Users/ymmtny/Documents/GitHub/kwik-visual-code/develop/Solar2D/kwik-editor-proj/Solar2D_plugin/lib/util.lua
  for i, folder in next, folders do
    package.path = package.path .. ";" .. kwikPath .. folder .."/?.lua"
  end
  lib.pacakge_path_added = true
end
print(package.path)
--]]

lib.useGradientBackground = function(_num)
  -- display.setDefault( "background", 0.8, 0.8, 0.8 )
  -- display.setDefault( "background", 1, 1, 1 )

  -- Create a gradient effect using rectangles Good for emitting particles!
  ---[[
  local numRectangles = _num or 100
  local rectHeight = display.contentHeight / numRectangles
  for i = 1, numRectangles do
    local alpha = 1 - (i / numRectangles) -- Fade from opaque to transparent
    local rect = display.newRect(display.contentCenterX, rectHeight * (i - 0.5), display.contentWidth, rectHeight)
    rect:setFillColor(1, 1, 1, alpha) -- White to transparent gradient
    rect:toBack()
  end
  --]]
end

lib.restore = function()
  if isWindows  then
    os.execute('call "' .. system.pathForFile("undo_lua.bat", system.TemporaryDirectory) .. '"')
  else
    os.execute("cd " .. system.pathForFile("", system.TemporaryDirectory) .. "; source undo_lua.command")
  end
  -- native.requestExit()
  return true
end

lib.autoUpdate = function()
  --
  -- require("installer.index").init()
  --
end

lib.setCustomModule = function(pathMod, props)
  -- print("kwik", "setCustomModule", pathMod  )

  lib.lib={}
  lib.lib.util = require(kwikGlobal.ROOT.."lib.util")
  lib.pageCommond = require(kwikGlobal.ROOT.."components.bookstore.controller.pageCommand")
  lib.model = require(kwikGlobal.ROOT.."components.bookstore.model.base")
-- -- lib.lib.util = require("lib.util")
  -- package.path = package.path .. ";" .. path .. "/?.lua;"

  lib.common = props
  require(kwikGlobal.ROOT.."controller.commonComponentHandler").pathMod = pathMod .. ".components."
  require(kwikGlobal.ROOT.."controller.ApplicationContext").pathMod = pathMod .. ".commands."

  for i, name in next, props.components do
    -- print("kwik", pathMod..".components."..name)
    local path = pathMod..".components."..name
    package.loaded[path] = require(path)
    -- package.preload[path] = require(path)
    -- print("kwik", package.loaded[path].test)
    if package.loaded[path] == nil then
      print("kwik", "Error not found", path)
      return false
    end
  end
  -- print("kwik", "setCustomModule","ended")
  return true
end

lib.bootstrap = function(props)
  -- print("kwik", "bootstrap")
  ---
  local controller = require(kwikGlobal.ROOT.."controller.index")
  props.common = lib.common
  kwikGlobal.gotoLastBook = props.gotoLastBook
  kwikGlobal.unitTest = props.unitTest
  kwikGlobal.httpSever = props.httpSever
  kwikGlobal.showPageName = props.showPageName
  --
  controller.bootstrap(props)
  -- print("kwik", "bootstrap", "ended")
end

-- lib.util = require(kwikGlobal.ROOT.."kwik.lib.util")
-- Return library instance

lib.original_require = require

require = function(...)
  local modName = ...

  -- Apply existing replacements
  modName = modName:gsub("checks", "checks")
  modName = modName:gsub("metalua.", "metalua.")
  modName = modName:gsub("materialui", "materialui")
  modName = modName:gsub("nanostores.index", "nanostores.nanostores")
  modName = modName:gsub("lib.clean%-stores", "nanostores.lib.clean-stores")
  modName = modName:gsub("lib.create%-derived", "nanostores.lib.create-derived")
  modName = modName:gsub("lib.create%-map", "nanostores.lib.create-map")
  modName = modName:gsub("lib.create%-store", "nanostores.lib.create-store")
  modName = modName:gsub("lib.define%-map", "nanostores.lib.define-map")
  modName = modName:gsub("lib.effect", "nanostores.lib.effect")
  modName = modName:gsub("lib.get%-value", "nanostores.lib.get-value")
  modName = modName:gsub("lib.keep%-active", "nanostores.lib.keep-active")
  modName = modName:gsub("lib.lualib_bundle", "nanostores.lib.lualib_bundle")
  modName = modName:gsub("lib.update", "nanostores.lib.update")

  -- Try direct require first
  -- local mod = lib.original_require(modName)
  -- if mod then
  --   return mod
  -- end

  -- Check in kwikGlobal.ROOT path first (common case)
  local success, result = pcall(lib.original_require, kwikGlobal.ROOT..modName)
  if success and result then
    return result
  end

  -- Check if modName starts with a folder name
  local firstPart = modName:match("^([^%.]+)")
  local isInFolders = false

  if firstPart then
    for _, folder in ipairs(folders) do
      if folder == firstPart or folder == "." then
        -- If module name already starts with a folder in our list,
        -- just try with kwikGlobal.ROOT
        local success, result = pcall(lib.original_require, kwikGlobal.ROOT..modName)
        if success and result then
          -- print("kwik", "Found module: " .. kwikGlobal.ROOT..modName)
          return result
        end
        isInFolders = true
        break
      end
    end
  end

  -- Only try prefixing with folders if the module doesn't already start with a folder
  if not isInFolders then
    for _, folder in ipairs(folders) do
      -- Convert folder path to module path format (replace / with .)
      local folderModule = folder:gsub("/", ".")
      if folderModule == "." then folderModule = "" end
      if folderModule ~= "" and not folderModule:match("^%.") then
        folderModule = folderModule .. "."
      end

      -- Try to load the module from this folder path
      local fullModName = kwikGlobal.ROOT .. folderModule .. modName
      local success, result = pcall(lib.original_require, fullModName)
      if success and result then
        -- print("kwik", "Found module in folder: " .. folder)
        return result
      end
    end
  end

  -- If we get here, module was not found
  -- print("kwik", "Module not found: " .. modName)
  result = lib.original_require(modName)
  return result
end

-- print("kwik", "loaded")
return lib
