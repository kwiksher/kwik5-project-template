local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local layerName = self.properties.target
  local props = self.properties
  local layerProps = self.layerProps
    --
    local target = sceneGroup[layerName]
    local group = display.newGroup()
    group:insert(target)

    local path = UI.props.imgDir..UI.page .."/"..props.mask ..".png"

    if ( display.imageSuffix == "@4x" ) then
      path = UI.props.imgDir..UI.page .."/"..props.mask .."@4x.png"
    elseif ( display.imageSuffix == "@2x" ) then
      path = UI.props.imgDir..UI.page .."/"..props.mask .."@2x.png"
    end

    local mask = graphics.newMask(path, UI.props.systemDir)
    if mask then
      group:setMask(mask)
      group.maskScaleX = layerProps.scaleX
      group.maskScaleY = layerProps.scaleY
      group.maskX = layerProps.mX
      group.maskY = layerProps.mY
      --
      if ( display.imageSuffix == "@4x" ) then
        group.maskScaleX = 0.25 * layerProps.scaleX
        group.maskScaleY = 0.25 * layerProps.scaleY
      elseif ( display.imageSuffix == "@2x" ) then
        group.maskScaleX = 0.5 * layerProps.scaleX
        group.maskScaleY = 0.5 * layerProps.scaleY
      end
      target.group = group
      -- target.isMasked = true
      -- group.isMasked = true
      sceneGroup:insert(group)
    end

end
--
M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end
return M
