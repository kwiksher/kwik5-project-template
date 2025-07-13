local AC = require("commands.kwik.actionCommand")
local json = require("json")
local controller = require(kwikGlobal.ROOT.."editor.group.index").controller
local util        = require(kwikGlobal.ROOT.."editor.util")

--
local useJson = false
--
local command = function (params)
	local UI    = params.UI
  print("--- group.remove ----")

  local props = controller:useClassEditorProps(UI)

  local workMap = {}
  for i, entry in next, props.layersTableSelections do
    print(i, entry.obj.text)
    -- for k, v in pairs(entry) do
    --   print(k, v)
    -- end
    workMap[entry.obj.text] = true
  end

  local newLayersTable = {}
  for i=1, #props.layersTable do
    -- remove them from layersTableSelections
    local value = props.layersTable[i].text
    print(i, value) -- 1, hello

    if workMap[value] == nil then
      newLayersTable[#newLayersTable+1] = value
    end
  end
  --
  local model = util.createIndexModel(UI.scene.model)

  controller.workTable = newLayersTable
  controller.iterator(model.components.layers, nil, 1)

  -- local boxData = util.read( UI.editor.currentBook, UI.page, filterFunc)

  -- layersbox
  UI.editor.layerJsonStore:set{layers = model.components.layers}
  -- layersTable
  UI.editor.groupLayersStore:set({members = newLayersTable})

  --
end
--
local instance = AC.new(command)
return instance
