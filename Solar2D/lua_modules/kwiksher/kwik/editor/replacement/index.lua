local current = ...
local parent,  root = newModule(current)
--
local model      = require(parent.."model")

local selectbox      = require(root.."parts.selectbox")
local classProps    = require(root.."parts.classProps")
local actionbox = require(root.."parts.actionbox")
local buttons       = require(root.."parts.buttons")

local controller = require(parent.."controller.index")
local listbox = require(parent.."listbox")
local listPropsTable = require(parent.."listPropsTable")
local listButtons = require(parent.."listButtons")
--
local audioProps = require(parent.."audioProps")
local textProps = require(parent.."textProps")

--
--
-- function controller:useClassEditorProps()
-- end

local M          = require(root.."parts.baseClassEditor").new(model, controller)
--
M.x				= display.contentCenterX + 480/2
M.y				= 20
-- M.y				= (display.actualContentHeight-1280/4 )/2
M.width = 80
M.height = 16

function M:init(UI)
  -- singleton because reset is called from selectTool
  if self.group then return end
  ---
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group

  selectbox     : init(UI, self.x + self.width/2, self.y, self.width*0.74, self.height)
  -- selectbox:init(UI, self.x, self.y, self.width/2, self.height)
  classProps:init(UI, self.x + self.width, self.y,  self.width+20, self.height)
  --classProps.model = {}
  classProps.type  = current

  --
  -- print("@@@@@", classProps.x + self.width*2, classProps.y)
  actionbox:init(UI, self.x + self.width,display.actualContentCenterY)
  buttons:init(UI)

  audioProps:init(UI, self.x + self.width, display.contentCenterY - 100,  self.width+20, self.height)
  textProps:init(UI, self.x + self.width, display.contentCenterY+ 40,  self.width+20, self.height)

  UI.useClassEditorProps = function() return controller:useClassEditorProps(UI) end

  --
  self.controller:init{
    selectbox      = selectbox,
    classProps     = classProps,
    actionbox      = actionbox,
    buttons        = buttons,
    listbox        = listbox,
    listPropsTable = listPropsTable,
    listButtons    = listButtons,
    audioProps     = audioProps,
    textProps      = textProps
  }

  self.controller.view = self


end
--
return M
