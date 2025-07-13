local current = ...
local parent,  root = newModule(current)
--
local model      = require(parent.."model")

local selectbox     = require(parent.."selectbox")
local classProps    = require(parent.."classProps")
local actionbox     = require(root.."parts.actionbox")
local buttons       = require(parent.."buttons")
local layerTable    = require(root.."parts.layerTable")
local jointTable    = require(parent.."jointTable")
--
local util = require(kwikGlobal.ROOT.."editor.util")
local json = require("json")

local pointA        = require(root.."animation.pointA")
local pointB        = require(root.."animation.pointB")

local controller = require(parent.."controller.index").new{
  selectbox     = selectbox,
  classProps    = classProps,
  actionbox     = actionbox,
  buttons       = buttons,
  pointA        = pointA,
  pointB        = pointB
}
--
-- function controller:useClassEditorProps()
-- end

local M = require(root.."parts.baseClassEditor").new(model, controller)
M.controller.id = "physics"
M.x             = display.contentCenterX + 480/2
M.y             = 20
M.width         = 50
M.height        = 16
--
function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group

  selectbox:init(UI, display.contentCenterX-480/1.5, self.y, self.width, self.height)
  classProps:init(UI, self.x + self.width, self.y, 100, self.height)
  classProps.model = self.model.props
  classProps.type  = current

  --
  actionbox:init(UI, self.x+ self.width, display.contentCenterY)
  buttons:init(UI, self.x , display.contentHeight/2)
  -- print("@ buttons", buttons.id)
  pointA:init(UI, self.x + self.width * 5, self.y,  self.width, self.height)
  pointB:init(UI, self.x + self.width * 7, self.y,  self.width, self.height)

  UI.editor.editorTools.physics = self
  -- need to change it from parts.classProps to phsyics.classProps
  layerTable:setClassProps(classProps)
  --
  UI.useClassEditorProps = function()
    return controller:useClassEditorProps(UI)
  end
  buttons.useClassEditorProps = UI.useClassEditorProps
  --
  self.controller.view = self
  selectbox.classEditorHandler = function(decoded, index)
    -- print("classEditorHandler", index)
    -- print(json.encode(decoded))
    local value = selectbox.model[index]
    -- print(json.encode(value))
    self.controller:reset()
    classProps:setValue(value.entries)
    self.controller:redraw()
  end

end
--
return M
