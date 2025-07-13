local M={}
local shapes = require("shapes")
local keyEventManager = require("editor.keyEventManager")

function M:create(listener)
  self.triangle = shapes.triangle.right.tL( display.contentCenterX, display.contentCenterY, 10, 20 )
  self.triangle:rotate(45)
  self.triangle.anchorX = 0
  self.triangle.anchorY = 1
  self.listener = listener
end

function M:mouse(event)
  local function onColorSample( event )
    print( "Sampling pixel at position (" .. event.x .. "," .. event.y .. ")" )
    print( "R = " .. event.r )
    print( "G = " .. event.g )
    print( "B = " .. event.b )
    print( "A = " .. event.a )
    self.listener(event.r, event.g, event.b, event.a)
    self.triangle:setFillColor(event.r, event.g, event.b, event.a)
  end
  --
  self.triangle.x = event.x
  self.triangle.y = event.y
  if event.type == "down" then
    display.colorSample( event.x, event.y, onColorSample )
  end
end

function M:key(event)
  if event.phase == "up" and event.keyName == 'enter' then
    self:destroy()
  end
  return true
end

function M:show()
  native.setProperty("mouseCursorVisible", false)
  Runtime:addEventListener("mouse",self)
  keyEventManager.register("eyedropper", function(event) return self:key(event) end, 1)

end

function M:destroy()
  self.triangle:removeSelf()
  Runtime:removeEventListener("mouse",self)
  keyEventManager.unregister("eyedropper")
  native.setProperty("mouseCursorVisible", true)
end

return M