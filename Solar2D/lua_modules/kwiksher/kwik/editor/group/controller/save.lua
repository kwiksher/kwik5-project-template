local name = ...
local layersTable = require(kwikGlobal.ROOT.."editor.group.layersTable")
local util = require(kwikGlobal.ROOT.."editor.util")
local controller = require(kwikGlobal.ROOT.."editor.group.controller")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local json = require("json")

local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI    = params.UI
    UI.editor.currentTool = nil
    local props = controller:useClassEditorProps()
    print(name)
    -- for i, v in next, layersTable.objs do print(i, v.text) end

    print("properties")
    local newName
    for i, v in next, props.properties do
      print("", i ,v.name, v.value)
      if v.name == "_name" then
        newName = v.value
        break
      end
    end

    local updatedModel = util.createIndexModel(UI.scene.model)
    local index = params.index or #updatedModel.components.groups + 1
    if props.isNew or controller.isNew then
      print("new group")
      local newGroup = {name=newName}
      table.insert(updatedModel.components.groups, index, newGroup)
      print(json.prettify(updatedModel))
    elseif not props.isMove then
    else
      updatedModel.components.groups[index] = {name = newName}
    end

    print("members(layerTable)")
    for i, v in next, props.layersTable do
      print(i,  v)
    end
    props.members = props.layersTable
    -- for k, v in pairs(props.layersTable) do print("", k ,v.text) end
    scripts.publish(UI, {
      book=UI.editor.currentBook, page=UI.editor.currentPage or UI.page,
      updatedModel = updatedModel,
      layer = newName,
      class = "group",
      props = props},
      controller)

  end
)
--
return instance