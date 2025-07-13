local M = {}
--
local MultiTouch = require("dmc_multitouch")
--

M.pinchHandler = function(event)
  local obj = event.target
  local props = obj.pinch
  local UI = props.UI
    if event.phase == "moved" then
      if props.actions.onMoved then
          UI.scene:dispatchEvent({name=props.actions.onMoved, event=event })
      end
  elseif event.phase == "ended" then
    if props.actions.onEnded then
        UI.scene:dispatchEvent({name=props.actions.onEnded, event=event })
    end
  end
  return true
end
---
function M:setPinch(UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  self.obj        = sceneGroup[layerName]
  if self.isPage then
    self.obj = sceneGroup
  end
  self.obj.pinch = self
end

function M:activate(UI)
  local obj = self.obj
  if obj == nil then return end
  --- as same as drag except activate with rotate
  local options = {}
  if self.properties.constrainAngle then
    options.constrainAngle=self.properties.constrainAngle
  end
  if self.properties.xStart then
    options.xBounds ={ self.properties.xStart, self.properties.xEnd }
  end
  if self.properties.yStart then
    options.yBounds ={ self.properties.yStart, self.properties.yEnd }
  end
  --
  if self.properties.move then
    MultiTouch.activate( obj,  "move", {"single"})
  end
  MultiTouch.activate( obj, "scale", "multi", {minScale = self.properties.scaleMin, maxScale = self.properties.scaleMax })
  obj:addEventListener( MultiTouch.MULTITOUCH_EVENT,self.pinchHandler)
end
--
function M:deactivate(UI)
  local obj = self.obj
  obj:removeEventListener( MultiTouch.MULTITOUCH_EVENT,self.pinchHandler)
  if self.properties.move then
    MultiTouch.dactivate( obj,  "move", {"single"})
  end
  MultiTouch.deactivate( obj, "rotate", "single")
end
--
-- Helper function to calculate distance
local function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Pinch Gesture Emulation for Multi-touch
function M.createPinchEmulator(target, callback)
  local emulator = {}
  emulator.target = target
  emulator.callback = callback

  local touch1 = nil
  local touch2 = nil
  local initialDistance = nil

  local function handleTouch(event)
    if event.phase == "began" then
      --print("event began", event.id ~= (touch and touch1.id) )
      if not touch1 then
        touch1 = event
      elseif not touch2 and event.id ~= touch1.id then  -- Ensure it's a different touch
        touch2 = event
        initialDistance = distance(touch1.x, touch1.y, touch2.x, touch2.y)
      end
    elseif event.phase == "moved" then
      print("event moved")
      if touch1 and touch2 then
        local currentDistance = distance(touch1.x, touch1.y, touch2.x, touch2.y)
        local scaleFactor = currentDistance / initialDistance
        print("scaleFactor", scaleFactor)
        if emulator.callback then
          emulator.callback(scaleFactor)  -- Call the callback with the scale factor
        end

        -- Update touch positions for smooth scaling even with finger movement
        if event.id == touch1.id then
            touch1 = event
        elseif event.id == touch2.id then
            touch2 = event
        end

      end
    elseif event.phase == "ended" or event.phase == "cancelled" then
      print("event ended")
      if event.id == touch1.id then
       -- touch1 = touch2
        --touch2 = nil
        --initialDistance = nil -- Reset
      elseif event.id == touch2.id then
        touch2 = nil
        initialDistance = nil -- Reset
      end
    end

    return true -- Prevent other touch listeners from receiving the event (optional)
  end


  -- Add touch event listener to the target display object
  target:addEventListener("touch", handleTouch)

  emulator.removeSelf = function()
      target:removeEventListener("touch", handleTouch)
      emulator.target = nil
      emulator.callback = nil
      touch1 = nil
      touch2 = nil
      initialDistance = nil
  end

  return emulator
end

--[[
  local myObject = display.newRect(display.contentCenterX, display.contentCenterY, 200, 100)
  myObject:setFillColor(1, 0, 0)

  local pinchEmulator = createPinchEmulator(myObject, function(scale)
    print("Scale Factor:", scale)
    myObject:setScale(scale, scale) -- Scale the object
  end)

  -- To remove the pinch emulation (important for cleanup):
  -- pinchEmulator.removeSelf()
--]]
-- Example usage:

M.set = function(model)
  return setmetatable( model, {__index=M})
end
--
return M