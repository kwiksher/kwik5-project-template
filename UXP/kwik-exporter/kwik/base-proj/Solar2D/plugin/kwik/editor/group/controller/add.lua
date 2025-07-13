local AC = require("commands.kwik.actionCommand")
local json = require("json")
local App = require("Application")

local util        = require(kwikGlobal.ROOT.."editor.util")
local controller = require(kwikGlobal.ROOT.."editor.group.index").controller
--
local useJson = false
--
local command = function (params)
	local UI    = params.UI
  -- print("----- group.add ----")

  local props = controller:useClassEditorProps(UI)
  -- for k, v in pairs(props) do print("", k, v) end

  local workTable = {}
  for i=1, #props.layersboxSelections do
    -- add them to layersTable
    local obj = props.layersboxSelections[i]
    if obj.parentObj then
      local parentText = util.getLayerPath(obj):gsub("/",".") --  "- GroupA.Ellipse"
      workTable[#workTable + 1] = parentText
    else
      workTable[#workTable + 1] = obj.text
    end
  end

  local newLayersTable = {}
  for i=1, #props.layersTable do
    -- remove them from layersTableSelections
    local value = props.layersTable[i].text
    print(i, value) -- 1, hello
    newLayersTable[#newLayersTable+1] = value
  end

  for i, v in next, workTable do
    newLayersTable[#newLayersTable + 1] = v
  end

  --
--  local boxData = util.read( UI.editor.currentBook, UI.page, filterFunc)
  local model = util.createIndexModel(UI.scene.model)

  controller.workTable = workTable
  controller.iterator(model.components.layers, nil, 1)

  UI.editor.layerJsonStore:set{layers = model.components.layers} -- layersbox

  -- for i=1, #model.components.layers do
  --   print(i, model.components.layers[i].name, model.components.layers[i].isFiltered)
  -- end
  --print(json.prettify(newLayersTable))
  UI.editor.groupLayersStore:set({members = newLayersTable}) -- layersTable

--
end
--
local instance = AC.new(command)
return instance
