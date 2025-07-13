local physics = require("physics")

local M = {
  properties = {
    orientation = "landscaleLeft", -- portratiteUpsideDown
    invert = false,
    scale = 1,
    gravityX = 0,
    gravityY = 9.8,
    drawMode = "Hybrid",
    walls = {top=false, bottom=true, left=false, right=false}
  },
}
--

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local areaWidth = 480
local areaHeight = 320

if system.orientation == "portrait" then
  areaWidth = 320
  areaHeight = 480
end
  -- Create horizontal guide lines
  local topGuideLine = display.newLine(centerX- areaWidth / 2, centerY - areaHeight / 2, centerX + areaWidth / 2, centerY - areaHeight / 2)
  topGuideLine.strokeWidth = 2
  topGuideLine:setStrokeColor( 1, 1, 0, 0.5 ) -- Yellow color

  local bottomGuideLine = display.newLine(centerX-areaWidth/2, centerY + areaHeight / 2, centerX + areaWidth / 2, centerY + areaHeight / 2)
  bottomGuideLine.strokeWidth = 2
  bottomGuideLine:setStrokeColor( 1, 1, 0, 0.5 ) -- Yellow color

  -- Create vertical guide lines
  local leftGuideLine = display.newLine(centerX - areaWidth / 2, centerY - areaHeight / 2, centerX - areaWidth / 2, centerY + areaHeight / 2)
  leftGuideLine.strokeWidth = 2
  leftGuideLine:setStrokeColor( 1, 1, 0, 0.5 ) -- Yellow color

  local rightGuideLine = display.newLine(centerX + areaWidth / 2, centerY - areaHeight / 2, centerX + areaWidth / 2, centerY + areaHeight / 2)
  rightGuideLine.strokeWidth = 2
  rightGuideLine:setStrokeColor( 1, 1, 0, 0.5 ) -- Yellow color

function M:init(UI)
  local props       = self.properties
  local  walls = self.properties.walls
  local sceneGroup = UI.sceneGroup
  if walls then
    if walls.top then
      self.wT = display.newRect(centerX,centerY-areaHeight/2,areaWidth,1)
      self.wT:setFillColor(0,0,0)
      sceneGroup:insert(self.wT)
     end
    if walls.bottom then
      self.wB = display.newRect(centerX,centerY+areaHeight/2,areaWidth,1)
      sceneGroup:insert(self.wB)
      self.wB:setFillColor(0,0,0)
    end
    if walls.left then
      self.wL = display.newRect(centerX-areaWidth/2, centerY, 1, areaHeight)
      sceneGroup:insert(self.wL)
      self.wL:setFillColor(0,0,0)
    end
    if walls.right then
      self.wR = display.newRect(centerX+areaWidth/2, centerY,1,areaHeight)
      sceneGroup:insert(self.wR)
      self.wR:setFillColor(0,0,0)
    end
  end
  physics.start()
  physics.setDrawMode(props.drawMode)
  physics.setScale = props.scale
  -- print("physics.start",props.drawMode, props.gravityX, props.gravityY)
  physics.setGravity(props.gravityX, props.gravityY)

end

function M:create(UI)
  local  walls = self.properties.walls
  if walls then
    if walls.top then
      physics.addBody(self.wT, "static")
     end
    if walls.bottom then
      physics.addBody(self.wB, "static")
    end
    if walls.left then
      physics.addBody(self.wL, "static")
    end
    if walls.right then
      physics.addBody(self.wR, "static")
    end
  end
end
--
function M:didShow(UI)
  local sceneGroup  = UI.scene.view
  local layer       = UI.layer
  local props       = self.properties
   -- Physics
  -- Invert gravity on orientation change
  if props.invert then
   local kOrientation, gx, gy = system.orientation, physics.getGravity()
   self.orientationHandler = function(event)
      if (system.orientation == self.orientation and system.orientation ~= kOrientation) then
         physics.setGravity(gx*-1,gy*-1)
      else
         physics.setGravity(gx, gy)
      end
      return true
   end
   Runtime:addEventListener("orientation", self.orientationHandler);
  end
  --
end

function M:didHide()
  if self.orientationHandler then
    Runtime:removeEventListener("orientation", self.orientationHandler);
    self.orientationHandler = nil
  end
  print("didHide")
  physics.stop()
end

--
function M:destroy()
  if self.orientationHandler then
    Runtime:removeEventListener("orientation", self.orientationHandler);
  end
  print("destroy")
  physics.stop()
end
--

M.set = function(instance)
	return setmetatable(instance, {__index=M})
end

return M