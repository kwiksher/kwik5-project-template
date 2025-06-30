local kwik = require "kwiksher.kwik"
local lfs = require("lfs")
--
system.setTapDelay(0.2)

--display.setDefault( "background", 0.2, 0.2, 0.2, 0.1 )
kwik.useGradientBackground()
--
local mode = "editing"
-- local mode = "production"
-- local mode = "dev"
--
local props
--
if mode == "editing" or mode == "dev" then
  props = {
    name = "{{book}}",
    editor = true,
    gotoPage = "{{page}}",
    language = "{{lang}}", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = true,
    unitTest = false,
    httpServer = false,
    showPageName = true
  }
elseif mode == "production" then
  props = {
    name = "{{book}}",
    editor = false,
    gotoPage = "{{page}}",
    language = "{{lang}}", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false
  }
end

--[[ create_book_bg.bat mybook "page1 page2"
--]]

--[[
  if kwik.restore() then
    native.showAlert("kwik", "restored, comment out kwik.restore()")
    return
  end
--]]
--
-- kwik.autoUpdate()

kwik.setCustomModule(
  "custom",
  {
    commands = {"myEvent"},
    components = {
      -- "align",
      "myComponent",
      "thumbnailNavigation",
      "index"
      -- "keyboardNavigation",
    }
  }
)

local function setPlugin(mode)
  local script
  local current_path = system.pathForFile("", system.ResourceDirectory)
  -- print(current_path)
  local ret = lfs.chdir(current_path)
  -- print(ret)
  local current_dir = lfs.currentdir(current_path)
  -- print("current_dir", current_dir)
  --
  local isDir = function(name)
    if type(name) ~= "string" then
      return false
    end
    local is = lfs.chdir(current_dir .. "/" .. name)
    -- print(is)
    if is then
      lfs.chdir(current_dir)
    end
    -- print(is and true or false)
    return is and true or false
  end
  --
  local src = "~/Library/Application Support/Corona/Simulator/Plugins/plugin/"
  local dst = "./plugin/kwik/template"

  local archInfo = system.getInfo("architectureInfo")
  local isWindows = archInfo == "x86" or archInfo == "x64" or
                   archInfo == "IA64" or archInfo == "ARM"
  --
  if isWindows then
    -- Use the correct path for Windows
    src = os.getenv("APPDATA") .. "\\Corona Labs\\Corona Simulator\\Plugins\\plugin\\"
    print("src", src)
    src = '"' .. src .. '"'
    dst = '"' .. dst:gsub("/", "\\") .. '"'
  else
    src = src:gsub(" ", "\\ ")
    dst = dst:gsub(" ", "\\ ")
  end
  --
  -- print(system.getInfo("environment") )
  if system.getInfo("environment") == "simulator" then
    if mode == "editing" then
      if isDir("plugin") then
        -- print("editing")
        local scripts = {
          'rm -rf ./plugin',
          'mv '..src..'_kwik '..src..'/kwik',
          'mv '..src..'_kwik.lua '..src..'/kwik.lua',
        }
        for i, v in next, scripts do
          os.execute(v)
        end
        return false
      end
    elseif mode == "dev" then
      if not isDir("plugin") then
        -- print("dev")
        local scripts
        if isWindows then
          -- print("You need to run as administrator",
          --      'runas /user:Administrator "cmd /c mklink /D plugin ..\\..\\kwik5-plugin"')

          -- Dynamically calculate the full path for `..\..\kwik5-plugin`
          local kwik5_plugin_path = current_dir .. "\\..\\..\\kwik5-plugin"
          kwik5_plugin_path = kwik5_plugin_path:gsub("/", "\\") -- Ensure Windows-style backslashes
          -- print("Full path to kwik5-plugin:", kwik5_plugin_path)

          -- Dynamically calculate the plugin path based on current directory
          local plugin_path = current_dir .. "\\plugin"
          plugin_path = plugin_path:gsub("/", "\\") -- Ensure Windows-style backslashes
          -- print("Full path to plugin:", plugin_path)

          scripts = {
            'move '..src..'kwik '..src..'\\_kwik',
            'move '..src..'kwik.lua '..src..'\\_kwik.lua',
          }

          -- Create the command using the dynamically calculated paths
          local command = string.format(
            'powershell.exe -Command "Start-Process cmd -ArgumentList \'/c mklink /D "%s" "%s"\' -Verb RunAs"',
            plugin_path, kwik5_plugin_path
          )
          -- print("Attempting to create a symbolic link as Administrator...")
          -- print(command)
          os.execute(command)
        else
          scripts = {
            'ln -s ../../kwik5-plugin plugin',
            'mv '..src..'kwik '..src..'/_kwik',
            'mv '..src..'kwik.lua '..src..'/_kwik.lua',
          }
        end
        -- print(system.getInfo("architectureInfo"))
        for i, v in next, scripts do
          os.execute(v)
        end
        return false
      end
    elseif mode == "production" then
      if not isDir("plugin") then
        --
        local scripts
        if isWindows then
          scripts = {
            "mkdir plugin",
            "copy " .. src .. "kwik.lua plugin\\",
            "xcopy /E /I " .. src .. "kwik plugin\\kwik",
            "rmdir /S /Q " .. dst:gsub("/", "\\")
          }
        else
          scripts = {
            "mkdir plugin",
            "cp -f " .. src .. "kwik.lua plugin",
            "cp -rf " .. src .. "kwik plugin",
            "rm -rf " .. dst
          }
        end
        --
        -- print(system.getInfo("architectureInfo"))
        for i, v in next, scripts do
          -- print("Executing: " .. v)
          os.execute(v)
        end
        return false
      end
    end
  end
  return true
end
--
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local lldebugger = loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH"))()
  lldebugger.start()
end
--
if setPlugin(mode) then
  kwik.bootstrap(props)
end
--


