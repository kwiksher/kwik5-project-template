local M = {}
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local editorUtil = require(kwikGlobal.ROOT.."editor.util")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")

function M.get()
  --
  local path =system.pathForFile( "components/custom", system.ResourceDirectory)
  local success = lfs.chdir( path ) -- isDir works with current dir
  local classes = {}
  if success then
    for file in lfs.dir( path ) do
      if util.isFile(file) then
          table.insert(classes, {name = file, path= util.PATH(path.."/"..file)})
      end
    end
  end
  return classes
end
--
function M.put(className)
  -- see editor/util saveLua()
  local dst = "components/custom" .."/"..className..".lua"
    local output = [[
      local M = {}
      --
      function M:init(UI)
      end
      --
      function M:create(UI)
      end
      --
      function M:didShow(UI)
        self.obj = UI.layers[self.name]
      end
      --
      function M:didHide(UI)
      end
      --
      function M:destroy(UI)
      end
      --
      M.new = function(instance)
        return setmetatable(instance, {__index=M})
      end
      --
      return M
    ]]
    --
    editorUtil.mkdir("components","custom")
    --
    local path = system.pathForFile(dst, system.TemporaryDirectory) --system.TemporaryDirectory)
    --print(path)
    local file, errorString = io.open(path, "w+")
    if not file then
      print("File error: " .. errorString)
    else
       file:write(output)
       io.close(file)
    end
    --
    scripts.publish({dst})
    --
  return true
end
return M