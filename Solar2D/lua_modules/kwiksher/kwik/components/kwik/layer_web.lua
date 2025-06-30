local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
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

  if props.width > 0 then
    options.width = props.width
  end
  if props.height > 0 then
    options.height = props.height
  end

  printKeys(options)
  local obj = native.newWebView( options.x, options.y, options.width, options.height )

    if props.isLocal then
      -- Loads web pages
      print("@@@@", props.url, UI.props.wwwDir )
      obj:request( UI.props.wwwDir ..props.url,  UI.props.systemDir )
    else
      -- Loads web pages
      obj:request( props.url )
    end

    if sceneGroup[layerName] and sceneGroup[layerName].removeSelf then
      sceneGroup[layerName]:removeSelf()
    end
    sceneGroup:insert( obj )
    sceneGroup[layerName] = obj
    self.obj = obj

end
--
function M:didShow(UI)
  if self.obj then
    self.obj.isVisible = true
  end
end

function M:didHide(UI)
  if self.obj then
    self.obj.isVisible = false
  end
end
--
function M:destroy(UI)
  if self.obj then
    self.obj:removeSelf()
    self.obj = nil
  end
end
--
M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end
--
return M