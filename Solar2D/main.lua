local kwik = require "plugin.kwik"
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
    name = "book",
    editor = true,
    gotoPage = "landscape",
    language = "", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = true,
    unitTest = false,
    httpServer = false,
    showPageName = true
  }
elseif mode == "production" then
  props = {
    name = "book",
    editor = false,
    gotoPage = "landscape",
    language = "", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false
  }
end

-- kwik.restore()
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
  if system.getInfo("platform") == "win32" then
    src = '"' .. src:gsub("/", "\\") .. '"'
    dst = '"' .. src:gsub("/", "\\") .. '"'
  else
    src = src:gsub(" ", "\\ ")
    dst = src:gsub(" ", "\\ ")
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
        local scripts = {
          'ln -s ../../kwik5-plugin plugin',
          'mv '..src..'kwik '..src..'/_kwik',
          'mv '..src..'kwik.lua '..src..'/_kwik.lua',
        }
        for i, v in next, scripts do
          os.execute(v)
        end
        return false
      end
      --]]
    elseif mode == "production" then
      if not isDir("plugin") then
        --
        local scripts = {
          "mkdir plugin",
          "cp -f " .. src .. "kwik.lua plugin",
          "cp -rf " .. src .. "kwik plugin",
          "rm -rf " .. dst
        }
        --
        for i, v in next, scripts do
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
