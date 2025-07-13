local M = {}
--
M.shakeHandler = function(event)
  local target = event.target
  local props = event.target.shake
  local UI = props.UI
  if(event.isShake == true) then
        UI.scene:dispatchEvent({name=props.actions.onComplete, event=event })
  end
  return true
end
---
function M:setShake(UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  self.obj        = sceneGroup[layerName]
  self.UI = UI
  if self.isPage then
    self.obj = sceneGroup
  end
  self.obj.shake = self
end

function M:activate(UI)
  self.obj:addEventListener("accelerometer", self.shakeHandler)

end
--
function M:deactivate(UI)
  self.obj:removeEventListener( "accelerometer",self.shakeHandler)
end
--
function M.createShakeEmulator(target, callback)
  local emulator = {}
  emulator.target = target
  emulator.callback = callback

  local touch1 = nil
  local touch2 = nil
  local initialDistance = nil

  local function handleTouch(event)
    if event.phase == "began" then
      print("event began", event.id ~= (touch1 and touch1.id) )
    elseif event.phase == "moved" then
      print("event moved")
    elseif event.phase == "ended" or event.phase == "cancelled" then
      print("event ended")
      emulator.callback({isShake = true})  -- Call the callback with the scale factor
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
--
M.set = function(model)
  return setmetatable( model, {__index=M})
end
--
return M