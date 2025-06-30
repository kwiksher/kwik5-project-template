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
    y = display.actualContentHeight-10,
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
    local app = App.get()
    for i = 1, #self.commands do
      local eventName = "editor.classEditor." .. self.commands[i]
    if app.context.commands[eventName] == nil then
        app.context:mapCommand(
          eventName,
          "editor.controller." .. self.commands[i]
        )
      end
    end
end
--
function M:create(UI)
    -- print("create", self.name)
    local group = display.newGroup()

    local function doAB(event)

    end

    local function killAB()
        timer.cancel(abTimer)
    end

    local function tap(event)
      print("tap")
        -- self.target.x = group.ptA.x
        -- self.target.y = group.ptA.y
        -- --
        -- -- control
        -- local props = M.useClassEditorProps()
        -- print(props.properties.duration)

        -- transition.to(self.target, {
        --     time =tonumber(props.properties.duration),
        --     x = group.ptB.x,
        --     y = group.ptB.y,
        --     onComplete = killAB
        -- })
        -- abTimer = timer.performWithDelay(1, doAB, 0)

        UI.scene.app:dispatchEvent {
          name = "editor.anim.preview" ,
          UI = UI,
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
      parent   = group,
      text     = "A->B",
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
    group:insert(rect)
    group:insert(obj)
    rect:setFillColor(0,0,0.8)
    obj.rect = rect
    self.AtoB = obj
    self.group = group

end
--
function M:didShow(UI)
  self.AtoB:addEventListener("tap", self.AtoB)
end
--
function M:didHide(UI)
  self.AtoB:removeEventListener("tap", self.AtoB)
end
--
function M:destroy() end

function M:toggle()
  self.AtoB.isVisible = not self.AtoB.isVisible
  self.AtoB.rect.isVisible = self.AtoB.isVisible
end

function M:show()
  self.AtoB.isVisible = true
  self.AtoB.rect.isVisible = self.AtoB.isVisible
end

function M:hide()
  self.AtoB.isVisible = false
  self.AtoB.rect.isVisible = self.AtoB.isVisible
end
--
return M
