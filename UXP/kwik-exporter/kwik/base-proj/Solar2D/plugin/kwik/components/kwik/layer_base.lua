local M = {}
--
local setProps = require(kwikGlobal.ROOT.."components.kwik.layer_image").setProps
--
function M:setProps(layerPros)
  setProps(self, layerPros)
end

function M:setLayerProps(obj)
  -- obj.x         = self.mX
  -- obj.y         = self.mY
  -- obj.alpha     = self.oriAlpha
  -- obj.oldAlpha  = self.oriAlpha
  -- obj.blendMode = self.blendMode
  --
  if self.randXStart and self.randXStart > 0 then
    obj.x = math.random( self.randXStart, self.randXEnd)
  end
  if self.randYStart and self.randYStart > 0 then
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
end
--
function M.new()
  local instance = {}
  return setmetatable(instance, {__index = M})
end
--
return M