local M = {}
M.name = ...
M.weight = 1
--
-- local button = require("com.gieson.Button")
-- local tools = require("com.gieson.Tools")
---
local App = require("Application")
M.commands = {"preview"}

local abTimer = {}

local props = {
    x = display.contentCenterX,
    y = display.actualContentHeight-40,
    -- y = display.actualContentHeight-10,
    width = 40,
    height = 20,
    textSize = 12,
    abSpeed = 2000,
    prevPos = {x = 0, y = 0},
    prevSP_x = 0,
    prevSP_y = 0,
    currentTime = 0,
    prevTime = 0,
}

---
function M:init(UI)
  -- if not self.contextInit then
    -- print(debug.traceback())
    local app = App.get()
    for i = 1, #self.commands do
      local eventName = "editor.classEditor." .. self.commands[i]
      if app.context.commands[eventName] == nil then
        app.context:mapCommand(
          eventName,
          kwikGlobal.ROOT.."editor.controller." .. self.commands[i]
        )
      end
    end
  --   self.contextInit = true
  -- end
end
--
function M:create(UI)
  self.UI = UI
    -- print("create", self.name, UI)
    self.group = display.newGroup()

    local function doAB(event)

    end

    local function killAB()
        timer.cancel(abTimer)
    end

    local function tap(event)
      print("tap")
        -- self.target.x = self.group.ptA.x
        -- self.target.y = self.group.ptA.y
        -- --
        -- -- control
        -- local props = M.useClassEditorProps()
        -- print(props.properties.duration)

        -- transition.to(self.target, {
        --     time =tonumber(props.properties.duration),
        --     x = self.group.ptB.x,
        --     y = self.group.ptB.y,
        --     onComplete = killAB
        -- })
        -- abTimer = timer.performWithDelay(1, doAB, 0)
        print(UI)
        UI.scene.app:dispatchEvent {
          name = "editor.classEditor.preview" ,
          UI = UI,
          tool = "animation",
          class = UI.editor.currentClass,
          props = self.useClassEditorProps(UI)
        }


      end

    -- Bump down a bit
    -- AtoBbutton = button:newButton{
    --     id = "ab",
    --     callback = abPress,
    --     label = "A -> B",
    --     textSize = props.textSize,
    --     width = props.width,
    --     height = props.height,
    --     x = props.x,
    --     y = props.y
    -- }
    local options = {
      parent   = self.group,
      text     = "preview",
      x        = props.x,
      y        = props.y,
      --width    = props.width,
     -- height   = props.height,
      font     = native.systemFont,
      fontSize = 10,
      align    = "left"
    }

    local obj = display.newText( options )
    --obj.anchorY=0.5
    obj.tap = tap

    local rect = display.newRoundedRect( obj.x, obj.y,obj.width+10, obj.height+2, 10)
    self.group:insert(rect)
    self.group:insert(obj)
    rect:setFillColor(0,0,0.8)
    obj.rect = rect
    self.obj = obj

end
--
function M:didShow(UI)
  self.obj:addEventListener("tap", self.obj)
end
--
function M:didHide(UI)
  if self.obj then
    self.obj:removeEventListener("tap", self.obj)
  end
end
--
function M:destroy()
  if self.obj then
    self.obj.rect:removeSelf()
    self.obj:removeSelf()
  end
end

function M:toggle()
  self.obj.isVisible = not self.obj.isVisible
  self.obj.rect.isVisible = self.obj.isVisible
end

function M:show()
  self.obj.isVisible = true
  self.obj.rect.isVisible = self.obj.isVisible
end

function M:hide()
  self.obj.isVisible = false
  self.obj.rect.isVisible = self.obj.isVisible
end
--
return M
