local M = {}

function M:create(UI)
  local group = display.newGroup()

  -- Calculate center point and dimensions of the 360x480 area
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

  group:insert(topGuideLine)
  group:insert(bottomGuideLine)
  group:insert(leftGuideLine)
  group:insert(rightGuideLine)
  self.group = group
end

function M:hide()
  self.group.isVisible = false
end

function M:show()
  self.group.isVisible = true
end

function M:destroy()
  self.group:removeSelf()
end

return M