local M = {}
local Gesture = require("dmc_gesture")
local util   = require(kwikGlobal.ROOT.."lib.util")
--
M.swipeHandler = function(event)
  local target = event.target or {}
  local props = target.swipe
  local UI = props.UI
  if event.phase == "ended" and event.direction ~= nil then
    -- print(event.phase, event.direction)
    if event.direction == "up" then
      if props.actions.onUp then
        UI.scene:dispatchEvent({name = props.actions.onUp, event = event})
      end
    elseif event.direction == "down" then
      if props.actions.onDown then
        UI.scene:dispatchEvent({name = props.actions.onDown, event = event})
      end
    elseif event.direction == "left" then
      if props.actions.onLeft then
        UI.scene:dispatchEvent({name = props.actions.onLeft, event = event})
      end
    elseif event.direction == "right" then
      if props.actions.onRight then
        UI.scene:dispatchEvent({name = props.actions.onRight, event = event})
      end
    end
  end
  return true
end

function M:setSwipe(UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  self.obj = sceneGroup[layerName]
  if self.isPage then
    self.obj = sceneGroup
  end
  self.UI = UI
  self.obj.swipe = self
end

function M:activate(UI)
  local obj = self.obj
  local props = self.properties
    local dbounds = {
    swipeLength = util.toNumber(props.swipeLength),
    limitAngle =  util.toNumber(props.limitAngle),
    useStrictBounds = util.toBoolean(props.useStrictBounds)
  }
  printKeys(dbounds)
  Gesture.activate(obj, dbounds)
  obj:addEventListener(Gesture.SWIPE_EVENT, self.swipeHandler)
end
--
function M:deactivate(UI)
  local obj = self.obj
  obj:removeEventListener(Gesture.SWIPE_EVENT, self.swipeHandler)
end
--
M.set = function(model)
  return setmetatable( model, {__index=M})
end

return M
