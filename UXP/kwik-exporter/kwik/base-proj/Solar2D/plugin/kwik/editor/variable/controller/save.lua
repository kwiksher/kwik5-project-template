local name = ...
local parent, root = newModule(name)
local util         = require(kwikGlobal.ROOT.."editor.util")
local controller   = require(root.."index").controller
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
--
local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI = params.UI
    local args = {
      UI            = UI,
      book          = params.book or  UI.book,
      page          = params.page or UI.page,
      updatedModel  = util.createIndexModel(UI.scene.model),
      props         = {properties = params.properties or controller.classProps:getValue()},
      completebox   = params.actionbox or controller.actionbox,
      isNew         = params.isNew
    }
    local selectbox     = params.selectbox or controller.selectbox
    args.selected      =  selectbox.selection or {}
    --
    args.class         = "variable"
    --
    args.name          = args.selected.variable -- this comes from variableTable == selectbox
    args.newName       = params.newName
    if controller.picker then
      args.newName = controller.picker:getValue()
      args.name = args.newName
    end
    ---
    args.append        = function(value, index)
      local dst = args.updatedModel.components.variables or {}
      if index then
        dst[index] = value
      else
        dst[#dst + 1] = value
      end
    end
    scripts.publish(UI, args, controller)
   end
)
--[[
components
  ├── variables
  │     ├── varOne.lua
  │     └── varTwo.lua
  ├── index.lua

  models
  ├── variables
  │     ├── varOne.json
  │     └── varTwo.json

index.json
  {
  "commands": [],
  "name": "page3",
  "pageNum": 3,
  "components": {
    "layers": [
    ],
    "groups": [],
    "page": [],
    "variables": ["varOne", "varTwo"]
  }
}

varOne.json
{
  "_type": "false",
  "_name": "newVar",
  "value": "",
  "isSave": "",
  "isAfter": "true",
  "isLocal": "true"
}
]]
--
return instance