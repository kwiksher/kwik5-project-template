local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local layerName = self.properties.target
  local props = self.properties
  local layerProps = self.layerProps
  local obj
  local options = {}
  if layerProps.shapedWith then
    options.x = layerProps.x + (props.paddingX or 0)
    options.y = layerProps.y + (props.paddingY or 0)
    options.width = layerProps.width
    options.height = layerProps.height
  else
    options.x = layerProps.mX + (props.paddingX or 0)
    options.y = layerProps.mY + (props.paddingY or 0)
    options.width = layerProps.imageWidth
    options.height = layerProps.imageHeight
  end
  --
  if props.type == "rectangle" then
    obj = display.newRect(options.x, options.y, options.width, options.height)
  elseif props.type == "circle" then
    obj = display.newCircle(options.x, options.y, options.width / 2)
  else
    print("Error", "invalid type for vector replacement")
  end
  --
  --
  obj:setFillColor(unpack(props.color))
  --
  self:setLayerProps(obj)
  --
  obj.layerProps = layerProps
  --
  if props.isBackground then
    sceneGroup:insert(1, obj)
  else
    sceneGroup:insert(obj)
  end
  if sceneGroup[layerName] and sceneGroup[layerName].removeSelf then
    sceneGroup[layerName]:removeSelf()
  end
  sceneGroup[layerName] = obj
  self.obj = obj
end
--
M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end

return M
