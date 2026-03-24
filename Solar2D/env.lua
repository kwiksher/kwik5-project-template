local M = {}
local lfs = require("lfs")

-- Get the correct resource directory path
local resourcePath = system.pathForFile("", system.ResourceDirectory)
package.path = resourcePath .. "/lua_modules/?.lua;" .. resourcePath .. "/lua_modules/?/?.lua;"..package.path
-- print("Resource path:", resourcePath)
-- print("Package path:", package.path)
-- print("Trying to require kwiksher.kwik...")

--
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local lldebugger = loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH"))()
  lldebugger.start()
end

local archInfo = system.getInfo("architectureInfo")
      local isWindows = archInfo == "x86" or archInfo == "x64" or
                       archInfo == "IA64" or archInfo == "ARM"


local  function createSymbolicLink()
  -- Check if the file exists using absolute path
  local file_path = resourcePath .. "/lua_modules/kwiksher/kwik.lua"
  local file = io.open(file_path, "r")
  if file then
      print("File exists:", file_path)
      file:close()
      return true
  else
    print("File NOT found:", file_path)
    if isWindows then
      print("You may need to run as administrator",
            'runas /user:Administrator "cmd /c mklink /D lua_modules\\kwiksher ..\\..\\kwik5-plugin"')
    else
      local scripts = {
        'mkdir -p '..resourcePath ..'/lua_modules && cd ' .. resourcePath ..'/lua_modules && ln -s ../../../kwik5-plugin kwiksher',
      }
      for i, v in next, scripts do
        print(v)
        os.execute(v)
      end
    end
    --print(system.getInfo("architectureInfo"))
    return false
  end
end

function M.setPlugin(mode)
  local script
  local src = "./lua_modules/kwiksher/kwik/"
  local current_path = system.pathForFile(src, system.ResourceDirectory)
  -- print(current_path)
  if current_path == nil or not lfs.chdir(current_path) then
    print("###")
    print("### Please use installer.sh(mac) or installer.bat(win) to set up kwik")
    print("###")
    if mode == "debug" then
      createSymbolicLink()
    else
      -- Check for installer files

      local path
      path = system.pathForFile("", system.ResourceDirectory).."/../"
      if isWindows then
        path = path:gsub('/', '\\')
      end

      if path then
        print("Found installer file:", path)
        local cmd = 'cd "'.. path.. '"; source update_kwik.sh'
        if isWindows then
           cmd = "cd .. & start cmd /k call update_kwik.bat"
        end
        print(cmd)
        os.execute(cmd)
      else
        print("No installer found. Please download and run the appropriate installer:")
        print("https://github.com/kwiksher/kwik5-project-template/tree/develop")
      end
    end
    return false
  end

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

  local archInfo = system.getInfo("architectureInfo")
  local isWindows = archInfo == "x86" or archInfo == "x64" or
                   archInfo == "IA64" or archInfo == "ARM"
  --
  if isWindows then
    -- Use the correct path for Windows
    src = '"' .. src:gsub("/", "\\") .. '"'
  else
    src = src:gsub(" ", "\\ ")
  end
  --
  -- print(system.getInfo("environment") )
  if system.getInfo("environment") == "simulator" then
    if mode == "development" then
      if isDir(".template") then
        -- print("development")
        local scripts = {
          'pwd && mv .template template'
        }
        for i, v in next, scripts do
          os.execute(v)
        end
        return false
      end
    elseif mode == "production" then
      if isDir("template") then
        --
        local scripts
        if isWindows then
          scripts = {
            'move template .template',
          }
        else
          scripts = {
            'pwd && mv template .template',
          }
        end
        --
        print(system.getInfo("architectureInfo"))

        for i, v in next, scripts do
          print("Executing: " .. v)
          os.execute(v)
        end
        return false
      end
    end
  end
  return true
end

return M