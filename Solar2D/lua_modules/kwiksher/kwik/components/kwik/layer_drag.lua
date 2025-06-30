local M = {}
local MultiTouch = require("dmc_multitouch")

--
local flipSet = {
  right = {
    axis = "x",
    from = "right",
    to = "left",
    scaleStart = 1,
    scaleEnd = -1
  },
  left = {
    axis = "x",
    from = "right",
    to = "left",
    scaleStart = -1,
    scaleEnd = 1
  },
  bottom = {
    axis = "y",
    from = "bottom",
    to = "top",
    scaleStart = 1,
    scaleEnd = -1
  },
  top = {
    axis = "y",
    from = "bottom",
    to = "top",
    scaleStart = -1,
    scaleEnd = 1
  }
}

M.dragHandler = function(self, event)
  local props = self.properties or {}
  local UI = self.UI
  local target = event.target
  local dropArea = target.dropArea
  local flip = flipSet[props.flipInitialDirection]

  local function isHit()
    local boundsA =  dropArea.contentBounds
    local boundsB =  target.contentBounds
    return boundsA.xMin <= boundsB.xMin and
    boundsA.xMax >= boundsB.xMax and
    boundsA.yMin <= boundsB.yMin and
    boundsA.yMax >= boundsB.yMax
  end
  -- print(hitX, hitY)
  -- print(dropArea.contentBounds.xMin,dropArea.contentBounds.xMax,dropArea.contentBounds.yMin,dropArea.contentBounds.yMax)

  -- print(xMin, yMin, xMax, yMax)
  if self.actions.onShapeHandler then
    self.actions.onShapeHandler(event)
  end
  if event.phase == "began" then
    -- self.layer = nil
    -- self.dropArea = nil
    if not target.isFocus then
      local parent = target.parent
      parent:insert(target)
      display.getCurrentStage():setFocus(target)
      target.isFocus = true
    end
    target.oriBodyType = target.bodyType
    target.bodyType = "kinematic"
  elseif event.phase == "moved" then
    if self.isFlip then
      if (target[flip.axis] < self.flipValue) then
        if target.flipInitialDirection == flip.from then
          target.flipScale = flip.scaleStart
          target.flipInitialDirection = flip.to
        end
      elseif (target[flip.axis] > self.flipValue) then
        if target.flipInitialDirection == flip.to then
          target.flipScale = flip.scaleEnd
          target.flipInitialDirection = flip.from
        end
      end
      self.flipValue = target[flip.axis]
    end
    ---
    if props.isDrop then
        if isHit() then
          target.x = dropArea.x
          target.y = dropArea.y
          target.lock = 1
        else
          target.lock = 0
        end
    end
    if self.actions.onMoved then
      --  self.layer = target
      UI.scene:dispatchEvent({name = self.actions.onMoved, event = {UI = UI}})
    end
  elseif event.phase == "ended" or event.phase == "cancelled" then
    target.bodyType = target.oriBodyType
    if props.isDrop then
      if target.lock == 1 and isHit() then
        target.x = target.dropArea.x
        target.y = target.dropArea.y
        if self.actions.onDropped then
          -- self.layer = target
          -- self.dropArea = target.dropArea
          UI.scene:dispatchEvent({name = self.actions.onDropped, event = {UI = UI}})
        end
      elseif props.backToOrigin then
        -- printKeys(target)
        target.x = target.oriX
        target.y = target.oriY
      end
    end

    if target.lock == nil or target.lock == 0 then
      -- self.layer = target
      if UI then
        UI.scene:dispatchEvent({name = self.actions.onReleased, event = {UI = UI}})
      end
    end

    if target.isFocus then
      display.getCurrentStage():setFocus(nil)
      target.isFocus = false
    end
  end
  return true
end

--
function M:activate(obj)
  if obj == nil then
    return
  end
  local props = self.properties or {boundaries = {}}
  ---
  local options = {}
  if type(props.constrainAngle) == "number" then
    options.constrainAngle = props.constrainAngle
  end
  if props.boundaries.xMin then
    options.xBounds = {props.boundaries.xMin, props.boundaries.xMax}
  end
  if props.boundaries.yMin then
    options.yBounds = {props.boundaries.yMin, props.boundaries.yMax}
  end
  --
  MultiTouch.activate(obj, "move", "single", options)
  --
  if self.isDrop then
    obj.lock = 0
    -- obj.posX = 0
    -- obj.posY = 0
  end
  --
  if self.isFlip then
    obj.flipInitialDirection = props.flipInitialDirection
    local axis = flipSet[props.flipInitialDirection].axis
    self.flipValue = obj[axis]
  end
  --
  -- obj.dragHandler = self.dragHandler
  -- self.obj = obj
  self.listener = function(event)
    -- print("event")
    -- self has the all the props of layer_drag, obj does not have them
    --   see setmetatable is used for the model not to object
    self:dragHandler(event)
  end
  -- print(MultiTouch.MULTITOUCH_EVENT)
  obj:addEventListener( MultiTouch.MULTITOUCH_EVENT, self.listener)
end

function M:deactivate(obj)
  -- obj:removeEventListener( MultiTouch.MULTITOUCH_EVENT, self.listener)
  MultiTouch.deactivate(obj, "move", "single")
end

M.set = function(model)
  return setmetatable(model, {__index = M})
end
--
return M
