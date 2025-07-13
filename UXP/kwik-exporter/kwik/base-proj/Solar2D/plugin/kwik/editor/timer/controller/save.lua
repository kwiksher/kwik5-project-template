local name = ...
local parent, root = newModule(name)
local util         = require(kwikGlobal.ROOT.."editor.util")
local controller   = require(root.."index").controller
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
--
local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local args = {
      UI            = params.UI,
      book          = params.book or  params.UI.editor.currentBook,
      page          = params.page or params.UI.page,
      updatedModel  = util.createIndexModel(params.UI.scene.model),
      props = {properties      = params.properties or controller.classProps:getValue()},
      completebox   = params.actionbox or controller.actionbox,
      isNew         = params.isNew
    }
    local selectbox     = params.selectbox or controller.selectbox
    args.selected      =  selectbox.selection or {}
    --
    args.class         = "timer"
    --
    args.name          = args.selected.timer
    args.newName       = params.newName
    if controller.picker then
      printKeys(controller.picker)
      args.newName = controller.picker:getValue()
      args.name = args.newName
    end
    --
    args.append        = function(value, index)
        local dst = args.updatedModel.components.timers or {}
        if index then
          dst[index] = value
        else
          dst[#dst + 1] = value
        end
    end

    scripts.publish(params.UI, args, controller)
   end
)
--[[
components
  ├── timers
  │     ├── timerOne.lua
  │     └── timerTwo.lua
  ├── index.lua

  models
  ├── timers
  │     ├── timerOne.json
  │     └── timerTwo.json

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
    "timers": ["timerOne", "timerTwo"]
  }
}

timerOne.json
{
  "name": "timerOne",
  "actionName": "variableAction",
  "delay": 0,
  "iterations": 1
}
]]
--
return instance