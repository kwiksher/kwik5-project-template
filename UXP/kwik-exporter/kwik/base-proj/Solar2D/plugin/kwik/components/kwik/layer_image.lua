local M = {}
--
local app = require "controller.Application"
local util = require "lib.util"

function M:setProps(layerProps)
  self.imageWidth  = layerProps.width/4
  self.imageHeight = layerProps.height/4
  local editorWidth, editorHeight = display.contentWidth - 480, display.contentHeight -320
  self.mX, self.mY   = layerProps.x*0.25 + editorWidth/2 , layerProps.y*0.25 + editorHeight/2

  -- Use app.getPosition for consistent positioning
  -- self.mX, self.mY = app.getPosition(layerProps.x, layerProps.y)

  layerProps.mX, layerProps.mY = self.mX, self.mY
  --
  self.randXStart  = app.getPosition(layerProps.randXStart)
  self.randXEnd    = app.getPosition(layerProps.randXEnd)
  self.dummy, self.randYStart = app.getPosition(0, layerProps.randYStart)
  self.dummy, self.randYEnd   = app.getPosition(0, layerProps.randYEnd)
  --
  self.name = layerProps.name
  self.oriAlpha  = layerProps.alpha
  --
  if layerProps.type then
    -- self.imagePath = layerProps.name.."." .. layerProps.type
    self.imageName = "/"..layerProps.name.."." ..layerProps.type
  end
  --
  self.blendMode = layerProps.blendMode
  --
  self.infinity = layerProps.infinity
  --
  self.layerProps = layerProps

end

function M:setPropsFromDisplayObject(layerProps)
  self.imageWidth  = layerProps.width
  self.imageHeight = layerProps.height
  self.mX, self.mY   = layerProps.x, layerProps.y
  layerProps.mX, layerProps.mY = self.mX, self.mY
  --
  self.randXStart  = layerProps.randXStart
  self.randXEnd    = layerProps.randXEnd
  self.randYStart =  layerProps.randYStart
  self.randYEnd   = layerProps.randYEnd
  --
  self.name = layerProps.name
  self.oriAlpha  = layerProps.alpha
  --
  self.imagePath = name.."." .. layerProps.type
  self.imageName = "/"..layerProps.name.."." ..layerProps.type
  --
  self.blendMode = layerProps.blendMode
  self.layerProps = layerProps
end


function M:createImage(UI)
  local sceneGroup = UI.sceneGroup
  local obj = display.newImageRect(
    UI.props.imgDir..self.imagePath,
    UI.props.systemDir,
    self.imageWidth,
    self.imageHeight)
  if obj == nil then return nil end
  --
  obj.imagePath = self.imagePath
  obj.x         = self.mX
  obj.y         = self.mY
  obj.alpha     = self.oriAlpha
  obj.oldAlpha  = self.oriAlpha
  obj.blendMode = self.blendMode
  --
  obj.layerAsBg = self.layerAsBg
  obj.isSharedAsset = self.isSharedAsset
  ---
  obj.shapedWith = self.layerProps.shapedWith
  obj.randXStart  = self.layerProps.randXStart
  obj.randXEnd    = self.layerProps.randXEnd
  obj.randYStart  = self.layerProps.randYStart
  obj.randYEnd    = self.layerProps.randYEnd
  obj.type        = self.layerProps.type
  obj.kind        = self.layerProps.kind

  -- print("Image positioned: " .. self.name .. " at " .. obj.x .. ", " .. obj.y)
  --
  if self.randXStart and self.randXStart > 0 then
     obj.x = math.random( self.randXStart, self.randXEnd)
  end
  if self.randYStart and self.randYStart > 0  then
     obj.y = math.random( self.randYStart, self.randYEnd)
  end
  if self.xScale then
    obj.xScale = self.xScale
  end
  if self.yScale then
    obj.yScale = self.yScale
  end
  if self.rotation then
    obj:rotate( self.rotation )
  end
  --
  obj.oriX = obj.x
  obj.oriY = obj.y
  obj.oriXs = obj.xScale
  obj.oriYs = obj.yScale
  obj.name = self.name
  -- obj.type = "image"
  --
  sceneGroup[self.name] = obj
  -- print("@@@@", self.name, obj)

  --
  if self.layerAsBg then
    sceneGroup:insert( 1, obj)
  else
    sceneGroup:insert( obj)
  end
  --
  return obj
end

function M:createRect(UI)
  local sceneGroup = UI.sceneGroup
  local obj = display.newRect(
    self.mX,
    self.mY,
    self.imageWidth,
    self.imageHeight)
  if obj == nil then return nil end
  --
  obj.imagePath = self.imagePath
  obj.x         = self.mX
  obj.y         = self.mY
  obj.alpha     = self.oriAlpha
  obj.oldAlpha  = self.oriAlpha
  obj.blendMode = self.blendMode
  --
  if self.randXStart > 0 then
    obj.x = math.random( self.randXStart, self.randXEnd)
  end
  if self.randYStart > 0 then
    obj.y = math.random( self.randYStart, self.randYEnd)
  end
  if self.xScale then
    obj.xScale = self.xScale
  end
  if self.yScale then
    obj.yScale = self.yScale
  end
  if self.rotation then
    obj:rotate( self.rotation )
  end
  --
  obj.oriX = obj.x
  obj.oriY = obj.y
  obj.oriXs = obj.xScale
  obj.oriYs = obj.yScale
  obj.name = self.name
  obj.type = "rect"
  --
  sceneGroup[self.name] = obj
  -- print("@@@@", self.name)
  --
  if self.layerAsBg then
    sceneGroup:insert( 1, obj)
  else
    sceneGroup:insert( obj)
  end
  --

  return obj

end

--
M.new = function()
	local instance = {}
	return setmetatable(instance, {__index=M})
end

return M