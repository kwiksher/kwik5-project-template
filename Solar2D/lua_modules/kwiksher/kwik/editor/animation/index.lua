
local current = ...
local parent,  root = newModule(current)
--
local pointA        = require(parent.."pointA")
local pointB        = require(parent.."pointB")
local AtoBbutton    = require(parent.."AtoBbutton")
local selectbox      = require(root.."parts.selectbox")
-- local classProps    = require(root.."parts.classProps")
--
-- local classProps    = require(kwikGlobal.ROOT.."editor.parts.baseProps").new({width=50})
local classProps              = require(kwikGlobal.ROOT.."editor.parts.classProps")
-- classProps.onTapLayerSet = table:mySet{"to"}
-- function classProps:setActiveProp(layer, class)
--   print("setActiveProp", layer)
--   local name =self.activeProp
--   local value = layer
--   local UI = self.UI
--   local obj = self:getObj(name)
--   obj.field.text = value
--   --
-- end

local filterProps = require(parent.."filterProps")
local breadcrumbsProps = require(parent.."breadCrumbProps")
local referencePoint = require(parent.."referencePoint")
--
local pathProps= require(parent.."pathProps")
--
local pointABbox    = require(parent.."pointABbox")
local actionbox = require(kwikGlobal.ROOT.."editor.parts.actionbox")
local buttons       = require(root.."parts.buttons")

local model         = require(parent.."model")

-- local model = require(parent.."model")
local controller = require(parent.."controller")

----------
local M = require(root.."parts.baseClassEditor").new(model, controller)

M.x				= display.contentCenterX + 480/2
M.y				= 20
-- M.y				= (display.actualContentHeight-1280/4 )/2
M.width = 80
M.height = 16

function M:init(UI)
  -- printKeys(UI.editor.editorTools)
  -- UI.editor.editorTools["animation"] = self

  self.UI = UI
  self.group = display.newGroup()
  UI.editor.viewStore.animation = self.group

  selectbox     : init(UI, self.x + self.width/2, self.y, self.width*0.74, self.height)
  classProps   : init(UI, self.x + self.width, self.y,  self.width, self.height)
  classProps.model = model.props
  classProps.type  = current

  breadcrumbsProps   : init(UI, self.x + self.width, self.y+248,  self.width, self.height)
  breadcrumbsProps.model = model.breadcrumbs
  ---
  referencePoint   : init(UI, self.x + self.width, self.y+264,  self.width, self.height)
  referencePoint.model = model.referencePoint
    -- as same position as breadcrumbs
  filterProps   : init(UI, self.x + self.width-12, self.y+240,  self.width+30, self.height)
  ---
  pathProps:init(UI, self.x + self.width, self.y+240,  self.width, self.height)
  --
  -- pointABbox   : init(UI, display.contentWidth*0.25,  display.contentHeight*0.75,  self.width, self.height)
  pointABbox   : init(UI,  self.x + self.width/2 + 10,  display.contentHeight*0.78,  self.width, self.height)
  pointA       : init(UI, 0, 0,  self.width, self.height)
  pointB       : init(UI, 0, 0,  self.width, self.height)
  AtoBbutton   : init(UI, self.x + self.width * 9, self.y,  self.width, self.height)
  actionbox: init(UI, self.x + self.width, display.contentCenterY - 60, self.width, self.height)
  -- actionbox.props = {
  --   {name="onComplete", value=""}
  -- }

  buttons:init(UI)
  -- --

  controller:init{
    selectbox      = selectbox,
    classProps    = classProps,
    breadcrumbsProps = breadcrumbsProps,
    referencePoint = referencePoint,
    pathProps = pathProps,
    filterProps = filterProps,
    pointA        = pointA,
    pointB        = pointB,
    AtoBbutton    = AtoBbutton,
    pointABbox    = pointABbox,
    actionbox = actionbox,
    buttons       = buttons
  }

  controller.view = self

  --UI.useClassEditorProps = function(self) return controller:useClassEditorProps(self) end


  --self.group:translate(200, 0)
  --
end

return M
