
local current = ...
local parent,  root = newModule(current)
--
local AtoBbutton    = require(parent.."AtoBbutton")
local selectbox      = require(kwikGlobal.ROOT.."editor.parts.selectbox")
-- local classProps    = require(root.."parts.classProps")
--
local classProps    = require(kwikGlobal.ROOT.."editor.parts.baseProps").new({width=50})
--
local pointABbox    = require(parent.."pointABbox")
local actionbox = require(kwikGlobal.ROOT.."editor.parts.linkbox").new()
local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")

local model         = require(parent.."model")

-- local model = require(parent.."model")
local controller = require(parent.."controller")

----------
local M = require(kwikGlobal.ROOT.."editor.parts.baseClassEditor").new(model, controller)

function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group

  selectbox     : init(UI, self.x + self.width/2, self.y, self.width*0.74, self.height)
  classProps   : init(UI, self.x + self.width*1.5 + 2, self.y,  self.width, self.height)
  classProps.model = model.props
  classProps.type  = current

  --
  pointABbox   : init(UI, display.contentWidth*0.25,  display.contentHeight*0.75,  self.width, self.height)
  AtoBbutton   : init(UI, self.x + self.width * 9, self.y,  self.width, self.height)
  actionbox: init(UI, self.x + self.width*2.5, self.y+self.height+3, nil, nil, "action")
  buttons:init(UI)
  -- --

  controller:init{
    selectbox      = selectbox,
    classProps    = classProps,
    AtoBbutton    = AtoBbutton,
    pointABbox    = pointABbox,
    actionbox = actionbox,
    buttons       = buttons
  }

  controller.view = self

  UI.useClassEditorProps = function() return controller:useClassEditorProps() end

  --
end

return M
