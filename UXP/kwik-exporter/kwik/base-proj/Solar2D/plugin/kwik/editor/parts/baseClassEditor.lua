
local current = ...
local parent,  root = newModule(current)

--
local selectbox      = require(parent.."selectbox")
local classProps    = require(parent.."classProps")
local actionbox = require(parent.."actionbox")
local buttons       = require(parent.."buttons")

--local model         = require(parent.."model")

-- local model = require(parent.."model")

-- mui?
local classSelector -- class
local autoPlaySwitch
local delayInput
local durtionInput
local loopInput
local reverseSwitch
local resetAtEndSwitch
local esingSelector
-- etc
--

----------
local M = {
    x				= display.contentCenterX/2,
    y				= 20,
    -- y				= (display.actualContentHeight-1280/4 )/2,
    width = 80,
    height = 16,
}

--
-- please override the init funciion
--
function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group

  selectbox     : init(UI, self.x + self.width/2, self.y, self.width*0.74, self.height)
  -- selectbox:init(UI, self.x, self.y, self.width/2, self.height)
  classProps:init(UI, self.x + self.width*1.5, self.y,  self.width, self.height)
  classProps.model = self.model.props
  classProps.type  = current

  --
  actionbox:init(UI)
  buttons:init(UI)

  UI.useClassEditorProps = function() return controller:useClassEditorProps() end

  --
  self.controller:init()
  self.controller.view = self
end

function M:toggle ()
  --print(debug.traceback())
  self.isVisible = not self.isVisible
  if self.isVisible then
    self.controller:hide()
  else
    self.controller:show()
  end
end

function M:hide ()
  --print(debug.traceback())
  self.controller:hide()
end

function M:show()
  -- print("show")
  self.controller:show()
end
--
function M:create(UI)
  -- print("-- create ---", self.model.id)
  -- print(debug.traceback())
  for k, v in next, self.controller.viewGroup do
    -- print("viewGroup", k)
    v:create(UI)

    if system.orientation == "portrait" then
      -- local delta_x = 400
      -- if v.group then
      --   v.group:translate(delta_x, 0)
      -- end
      -- UI.editor.rootGroup.buttons:split() -- this is baseButtons.lua
    end

  end
  self.controller:hide()
end
--
function M:didShow(UI)
  -- print(self.model.id, self.controller.viewGroup)
  for k, v in pairs(self.controller.viewGroup) do
    v:didShow(UI)
  end
end
--
function M:didHide(UI)
  for k, v in pairs(self.controller.viewGroup) do
    v:didHide(UI)
  end
end
--
function M:destroy()
  for k, v in pairs(self.controller.viewGroup) do
    v:destroy(UI)
  end
  if self.group then
    self.group:removeSelf()
  end
  self.group = nil
end

M.new = function(model, _controller)
  local controller = _controller or require(root.."controller.index").new()
  local instance = {model=model, controller = controller}
	return setmetatable(instance, {__index=M})
end

return M
