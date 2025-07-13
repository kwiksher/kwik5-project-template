local M = {}
--
local util = require "lib.util"
--
-- Infinity background animation
--
local function infinityBackHandler(self, event)
  local props = self.infinityProps

  if (props.direction == "left") then -- horizontal loop
    if self.x < display.contentCenterX - self.width / 2 - self.width then
      self.x = display.contentCenterX + self.width / 2
    else
      self.x = self.x - props.speed
    end
  elseif (props.direction == "right") then -- horizontal loop
    if self.x > display.contentCenterX + self.width / 2 then
      self.x = display.contentCenterX - self.width - self.width / 2
    else
      self.x = self.x + props.speed
    end
  elseif (props.direction == "up") then -- vertical loop
    if self.y < display.contentCenterY - self.height / 2 - self.height then
      self.y = display.contentCenterY + self.height / 2
    else
      self.y = self.y - props.speed
    end
  elseif (props.direction == "down") then -- vertical loop
    if self.y > display.contentCenterY + self.height / 2 then
      self.y = display.contentCenterY - self.height - self.height / 2
    else
      self.y = self.y + props.speed
    end
  end
end

function M.createInfinityImage(UI, layer_1, props)
  print(props)
  props.width = layer_1.width
  local sceneGroup = UI.sceneGroup
  local layer_2 =
     display.newImageRect(UI.props.imgDir .. layer_1.imagePath, UI.props.systemDir, layer_1.width, layer_1.height)
  layer_1.infinityProps = props
  layer_2.infinityProps = props
  if layer_2 == nil then
    return
  end
  layer_2.blendMode = layer_1.blendMode
  sceneGroup:insert(layer_2)
  sceneGroup[layer_1.name .. "_2"] = layer_2

  local marginX = display.contentCenterX - layer_1.width / 2
  local marginY = layer_1.height / 2

  layer_1.anchorX = 0
  layer_1.anchorY = 0
  util.repositionAnchor(layer_1, 0, 0)
  layer_2.anchorX = 0
  layer_2.anchorY = 0
  util.repositionAnchor(layer_2, 0, 0)

  if props.direction == "up" then
    layer_2.yScale = 1.1
    layer_1.x = layer_1.oriX
    layer_1.y = marginY
    layer_2.x = layer_1.oriX
    layer_2.y = layer_1.y + layer_1.height
    layer_2.oriY = layer_1.y
  elseif props.direction == "down" then
    layer_2.yScale = 1.1
    layer_1.x = layer_1.oriX
    layer_1.y = - marginY
    layer_2.x = layer_1.oriX
    layer_2.y = layer_1.y - layer_1.height
    layer_2.oriY = layer_1.y
  elseif props.direction == "right" then
    layer_2.xScale = 1.1
    layer_1.x =  marginX
    layer_1.y = layer_1.oriY
    layer_1.oriX = layer_1.x
    layer_2.x = layer_1.x - layer_1.width
    layer_2.y = layer_1.oriY
    layer_2.oriX = layer_1.x
  elseif props.direction == "left" then
    layer_2.xScale = 1.1
    layer_1.x =  - marginX
    layer_1.y = layer_1.oriY
    layer_1.oriX = layer_1.x
    layer_2.x = layer_1.x + layer_1.width
    layer_2.y = layer_1.oriY
    layer_2.oriX = layer_1.x
  end

  layer_1.infinityLayer = layer_2
  layer_1.enterFrame = infinityBackHandler
  layer_2.enterFrame = infinityBackHandler
end

function M.addEventListener(layer_1)
   Runtime:addEventListener("enterFrame", layer_1)
   Runtime:addEventListener("enterFrame", layer_1.infinityLayer)
end

function M.removeEventListener(layer_1)
  Runtime:removeEventListener("enterFrame", layer_1)
  Runtime:removeEventListener("enterFrame", layer_1.infinityLayer)
end

return M