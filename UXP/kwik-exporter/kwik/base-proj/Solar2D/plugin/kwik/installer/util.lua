local M = {
  commands = {}
}
local json = require("json")
local lfs = require( "lfs" )

function M.isDir(name)
	if type(name)~="string" then return false end
	local cd = lfs.currentdir()
	local is = lfs.chdir(name) and true or false
	lfs.chdir(cd)
	return is
end

M.split = function(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
        table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or 
                 archInfo == "IA64" or archInfo == "ARM"                 
--
local COPY, MOVE, MKDIR
if isWindows then
   COPY = function(src, dst)
      local _src = src:gsub('/', '\\')
      local _dst = dst:gsub('/', '\\')
      table.insert(M.commands, 'xcopy "'..src..'" "'..dst..'" /s/e/i/Y')
   end
   MOVE = function (name)
    local _src = src:gsub('/', '\\')
    local _dst = dst:gsub('/', '\\')
    table.insert(M.commands, 'xcopy "'..src..'" "'..dst..'" /s/q')
   end
   MKDIR = function(path)
    local _path = path:gsub('/', '\\')
    -- Use md instead of mkdir and ensure it creates all intermediate directories
    table.insert(M.commands, 'if not exist "'.. _path ..'" md "'.. _path ..'" 2>nul')
   end

elseif system.getInfo("platform") == "macos" then
   COPY = function(src, dst)
      local _src = src:gsub(' ','\\ ')
      local _dst = dst:gsub(' ','\\ ')
      table.insert(M.commands, 'cp -Rf '.._src..' '.._dst)
   end
   MOVE = function (src, dst)
    local _src = src:gsub(' ','\\ ')
    local _dst = dst:gsub(' ','\\ ')
    table.insert(M.commands, 'mv '.._src..' '.._dst)
  end
   MKDIR = function(path)
    local _path= path:gsub(' ','\\ ')
     table.insert(M.commands, 'mkdir -p '.._path)
   end
end

M.install = function(asset, baseDirectory, dst)
  local _src = system.pathForFile("", baseDirectory ):gsub("/./", "")
  local _dst = dst:gsub("/./", "")
  if asset.folders == nil then
    print(_src.."/"..asset.path, _dst.."/")
    COPY(_src.."/"..asset.path, _dst.."/")
  else
    for i, folder in next, asset.folders do
      print(_src.."/"..asset.path.."/"..folder, _dst.."/"..asset.path.."/")
      COPY(_src.."/"..asset.path.."/"..folder, _dst.."/"..asset.path.."/")
    end
  end
end

M.backup = function(asset, dst)
  local _dst = dst:gsub("/./", "")
  --
  if not M.isDir(_dst) then
    MKDIR(_dst)
  end
  --
  if asset.folders == nil then
    print(asset.path, _dst.."/"..asset.path)
    COPY(asset.path, _dst.."/"..asset.path)
  else
    for i, folder in next, asset.folders do
      print(asset.path.."/"..folder, _dst.."/"..asset.path.."/"..folder)
      COPY(asset.path.."/"..folder, _dst.."/"..asset.path.."/"..folder)
    end
  end
end


return M

