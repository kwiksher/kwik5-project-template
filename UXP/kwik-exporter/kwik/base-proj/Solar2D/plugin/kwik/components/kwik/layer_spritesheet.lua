local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
M.objs = {}

--
function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layer       = UI.layer
  if self.properties.target == nil then
    print("self.properties.target is nil")
    return
  end

  local target      = sceneGroup[self.properties.target] or self.properties.target
  if self.sheet == nil then
    print("Error sheet is emptry")
    return
  end
  --
  self.layerProps = self.layerProps or {}
  -- for k, v in pairs( self.sequenceData) do print("", k, v) end
  --
  local obj = display.newSprite(self.sheet, self.sequenceData ) -- ff_seq is to be used in future
  if obj == nil then
    print("Error newSprite")
    return
  end
  obj.x        = target.x or display.contentCenterX
  obj.y        = target.y or  display.contentCenterY


  if self.layerProps.imageWidth then
    obj:scale(self.layerProps.imageWidth/obj.width, self.layerProps.imageHeight/obj.height)
  end

  -- self:setLayerProps(obj)

  obj.name = self.layerProps.name or "_preview"
  obj.type = "sprite"

  if #self.sequenceData > 0 and self.sequenceData[1].pause and not obj.name=="_preview" then
      obj:pause()
  else
    obj:play()
  end
  if obj.name ~="_preview" then
    -- sceneGroup:remove(target)
    target.alpha = 0
  end

  -- printKeys(obj)

  sceneGroup[obj.name.."_sprite"] = obj
  sceneGroup:insert( obj)
  self.objs[#self.objs+1] = obj
  -- obj:toFront()

end
--
function M:didShow()
end
--
function M:destroy()
  for i, v in next, self.objs do
    display.remove( v )
  end
  self.objs = {}
end

---------------------------
M.set = function(instance)
	return setmetatable(instance, {__index=M})
end
--
return M