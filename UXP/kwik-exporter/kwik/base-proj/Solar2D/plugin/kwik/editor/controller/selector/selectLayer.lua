local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
--
local useJson = false

local propsButtons = require(kwikGlobal.ROOT.."editor.parts.propsButtons")
local propsTable = require(kwikGlobal.ROOT.."editor.parts.propsTable")


local function getFileName(layerName, class)
  if class then
    return layerName.."_"..class
  else
    return layerName
  end
end

--
local command = function (params)
	local UI    = params.UI
  local layerName =  params.layer or "index"
  -- print(layerName, params.isIndex)
  if params.isIndex then
    layerName = layerName ..".index"
  end
	-- local path = UI.page .."/"..getFileName(layerName, params.class)..".json"

  local className = nil
  if params.class then
    className = UI.editor:getClassFolderName(params.class)
  end
  local pathMod = "App."..UI.editor.currentBook..".components."..UI.page ..".layers."..params.path..getFileName(layerName, params.class)

  --
  -- selectLayer comes from contextButton.modify
  --
  if UI.editor.currentType == "group" then
    pathMod = "App."..UI.editor.currentBook..".components."..UI.page ..".groups."..params.path..getFileName(layerName, params.class)
  elseif UI.editor.currentType == "variable" then
    pathMod = "App."..UI.editor.currentBook..".components."..UI.page ..".variables."..params.path..getFileName(layerName, params.class)
  elseif UI.editor.currentType == "timer" then
    pathMod = "App."..UI.editor.currentBook..".components."..UI.page ..".timers."..params.path..getFileName(layerName, params.class)
  elseif UI.editor.currentType == "joint" then
    pathMod = "App."..UI.editor.currentBook..".components."..UI.page ..".joints."..params.path..getFileName(layerName, params.class)
  end
  ---
  local pathJson = "App/"..UI.editor.currentBook.."/models/"..UI.page .."/"..params.path..getFileName(layerName, className)..".json"
  local path = system.pathForFile( pathJson, system.ResourceDirectory)
  -- print("pathMod", pathMod)
  if path == nil then
    print("Error to find", pathJson)
    -- return
  else
    print("selectLayer", path, params.isIndex )
  end
  -- print(debug.traceback())

  UI.editor.currentTool = propsTable

  UI.editor:setCurrnetSelection(params.layer, params.class, nil, params.suffix)
  --print(UI.editor.currentLayer)

  local rootGroup = UI.editor.rootGroup
  if params.show~=nil and rootGroup.propsTable then
    if propsTable.isVisible then
      propsTable:hide()
    else
      propsTable:show()
    end
  else
    UI.editor.editPropsLabel = getFileName(layerName, params.class)
    -- local decoded, pos, msg = json.decodeFile( path )
    local decoded = require(pathMod:gsub("/", "."))
    if not decoded then
      print( "Decode failed at "..tostring(pos)..": "..tostring(msg), path, params.isIndex  )
    elseif (params.class =="animation") then
      print( "animation is decoded!" )
      --UI.editor.propsStore:set(decoded)
    else
      print( "props is decoded!" )
      -- print(json.prettify(decoded))
      propsTable:didHide(UI)
      propsTable:destroy(UI)
      propsTable:init(UI)
      --
      propsTable:setValue(decoded)
      propsTable:create(UI)
      propsTable:didShow(UI)
      propsTable:show()
      propsButtons:show()
    end
    --
    --
    UI.editor.rootGroup:dispatchEvent{name="labelStore",
      currentBook= UI.editor.currentBook,
      currentPage= UI.page,
      currentLayer = UI.editor.currentLayer}
  end
--
end
--
local instance = AC.new(command)
return instance
