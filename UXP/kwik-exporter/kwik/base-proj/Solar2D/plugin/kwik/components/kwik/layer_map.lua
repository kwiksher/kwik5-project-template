local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local layerName = self.properties.target
  local props = self.properties
  local layerProps = self.layerProps
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
  -- printKeys(options)
  local archInfo = system.getInfo("architectureInfo")
  local isWindows = archInfo == "x86" or archInfo == "x64" or 
                   archInfo == "IA64" or archInfo == "ARM"                 
  
  if ( ( system.getInfo("environment") == "simulator"
    or system.getInfo("platform") == "macos"
    or isWindows ) ) then

    options.text = "MapView is not supported. Use Android or iPhone/iPad"
    local obj = display.newText(options)
    sceneGroup[layerName] = obj

  else
    local obj = native.newMapView(options.x, options.y, options.width, options.height)
    obj.mapType = props.mapType
    obj:setCenter(props.latituite, props.longtitude)
    obj.isScrollEnabled = props.isScrollEnabled
    obj.isZoomEnabled = props.isZoomEnabled

    if props.marker.enabled then
      obj:addMarker(
        props.marker.latituite,
        props.marker.longtitude,
        {title = props.marker.title, subtitle = props.marker.subtitle}
      )
    end

    self:setLayerProps(obj)
    --
    obj.layerProps = layerProps
    local original = sceneGroup[layerName]
    if original then
      original:removeSelf()
    end
    sceneGroup[layerName] = obj
    self.obj = obj

  end
end
--
M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end

return M
