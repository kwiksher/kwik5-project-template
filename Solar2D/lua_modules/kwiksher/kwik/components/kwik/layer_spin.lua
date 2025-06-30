local M = {}
--
local app = require "controller.Application"
local MultiTouch = require("dmc_multitouch")
--

M.spinHandler = function(event)
  local target = event.target
  local props = target.spin
  local UI = props.UI
  event.UI = UI
  if event.direction == "clockwise" then
    if props.actions.onClokwise then
          UI.scene:dispatchEvent({name=props.actions.onClokwise, event=event  })
    end
  elseif event.direction == "counter_clockwise" then
    if props.actions.onCounterClockwise then
          UI.scene:dispatchEvent({name=props.actions.onCounterClockwise , event=event  })
    end
  end

  if props.actions.onEnded and event.phase == "ended" then
    UI.scene:dispatchEvent({name=props.actions.onEnded , event=event  })
      -- props.actions.onShapeHandler(event)
  end
  return true
end

function M:setSpin(UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  self.obj        = sceneGroup[layerName]
  if self.isPage then
    self.obj = sceneGroup
  end
  self.obj.spin = self
  self.UI = UI
end
---
function M:activate(UI)
  local obj = self.obj
  if obj == nil then return end
  --- as same as drag except activate with rotate
  local options = {}
  local props = self.properties
  if props.constrainAngle then
    options.constrainAngle=props.constrainAngle
  end
  --
  if props.minAngle > 0 or props.maxAngle > 0  then
    MultiTouch.activate( obj, "rotate", "single",   { minAngle =props.minAgnle, maxAngle = props.maxAngle } )
  else
    MultiTouch.activate( obj, "rotate", "single" )
  end
  obj:addEventListener( MultiTouch.MULTITOUCH_EVENT,self.spinHandler)
end
--
function M:deactivate(UI)
  local obj = self.obj
  obj:removeEventListener( MultiTouch.MULTITOUCH_EVENT,self.spinHandler)
  MultiTouch.deactivate( obj, "rotate", "single", options)
end
--
M.set = function(model)
  return setmetatable( model, {__index=M})
end
--
return M