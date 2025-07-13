local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
--
function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layerName  = self.properties.target
  local props      = self.properties
  local layerProps = self.layerProps

  --
  self.Min = math.floor(props.countValue / 60)
  self.Sec = props.countValue % 60
  self.countValue = props.countValue
  ---
  if (self.Sec < 10) then
     self.Sec = "0"..self.Sec
  end
  if (self.Min < 10) then
     self.Min = "0"..self.Min
  end
  self.Txt = self.Min..":"..self.Sec
  --

  local options = {
    text = props.countValue,
    fontSize = props.fontSize/2,
    font = props.font,
    --align = props.alignment,
    x = layerProps.mX + (props.paddingX or 0),
    y = layerProps.mY + (props.paddingY or 0),
    width = layerProps.width/4,
    height = layerProps.height/4,
  }

  if options.width < options.fontSize*5 then
    options.width = options.fontSize*5
  end

  if layerProps.shapedWith and layerProps.shapedWith:len() > 0 then
    options.x = layerProps.x + options.width/4 + (props.paddingX or 0)
    options.y = layerProps.y + (props.paddingY or 0)
  end

  if props.font == "native.systemFont" then
    options.font = native.systemFont
  end
  --
  local obj = display.newText( options )
  obj.originalH = obj.height
  obj.originalW = obj.width
  obj:setFillColor (unpack(props.color))
  -- obj.x = obj.x + options.width/2 + (props.paddingX or 0)
  -- --
  -- obj.y = obj.y + (props.paddingY or 0)
  -- --
  obj.anchorX = 0.5
  obj.anchorY = 0.5

  self:setLayerProps(obj)
  obj.layerProps = layerProps

  sceneGroup:insert( obj )
  sceneGroup[layerName]= obj
  self.obj = obj
end
--
function M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
  local props      = self.properties
  --
  local function upTimeHandler()
    self.Min = math.floor(self.countValue / 60)
    self.Sec = self.countValue % 60
    if (self.Sec < 10) then
      self.Sec = "0"..self.Sec
    end
    -- print(self.Min, self.Sec)
    local countText =  self.Min..":"..self.Sec
    if self.Min > 0 and (self.Min < 10) then
      countText = "0"..self.Min
    end
    -- print(countText)
    self.obj.text = countText
    self.countValue = props.countValue - 1
    ---
    if self.actions.onComplete and self.actions.onComplete:len() > 0 then
      if (self.countValue == -1) then
         UI.scene:dispatchEvent({name=self.actions.onComplete, layer = self.obj })
       end
    end
  end
  --
  upTimeHandler()

  self.timer = timer.performWithDelay( 1000, upTimeHandler, self.countValue + 1 )
  if not self.properties.autoPlay then
    -- print("@@@@ Pause")
    timer.pause( self.timer )
  end
  UI.timers[props.target.."_counter"]  = self.timer
end

M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end
--
return M
