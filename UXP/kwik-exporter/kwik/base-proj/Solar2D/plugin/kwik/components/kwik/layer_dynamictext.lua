local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()

local App = require(kwikGlobal.ROOT.."controller.Application")
local util = require(kwikGlobal.ROOT.."lib.util")

function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layerProps = self.layerProps
  local props = self.properties

  local mVar = UI:getVariable(props.variable) or ""
  if props.type == "global" then
    local app = App.get()
    myVar = app:getVariable(props.variable) or ""
  end
  ---

  local _font = native.systemFont
  if type(props.font)=="string" and props.font:len() > 0 then
    if props.font == "native.systemFont" then
      options.font = native.systemFont
    else
      _font = props.font
    end
  end
  --
  local options = {
    text = mVar,
    fontSize = props.fontSize/2,
    font = _font,
    -- width = layerProps.width/4,
    -- height = layerProps.height/4,
    -- align = props.align
   }

    if layerProps.shapedWith then
      options.x = layerProps.x + (props.paddingX or 0)
      options.y = layerProps.y + (props.paddingY or 0)
    else
      options.x = layerProps.mX + (props.paddingX or 0)
      options.y = layerProps.mY + (props.paddingY or 0)
    end

  -- printKeys(options)

  local obj = display.newText(options)
  if obj == nil then return end
  -- print("#####")
  -- printKeys(props.color)

  obj:setFillColor( unpack(props.color) )
  obj.anchorX = 0.5
  obj.anchorY = 0.25
  util.repositionAnchor(obj,0.5,0)

  self:setLayerProps(obj)
  obj.layerProps = layerProps

--   obj.alpha     = layerProps.oriAlpha
--   obj.oldAlpha  = layerProps.oriAlpha
--   obj.blendMode = layerProps.blendMode
--   --
--   obj.layerAsBg = layerProps.layerAsBg
--   obj.isSharedAsset = layerProps.isSharedAsset
--   ---
--   obj.shapedWith  = layerProps.shapedWith
--   obj.randXStart  = layerProps.randXStart
--   obj.randXEnd    = layerProps.randXEnd
--   obj.randYStart  = layerProps.randYStart
--   obj.randYEnd    = layerProps.randYEnd
--   obj.type        = layerProps.type
--   obj.kind        = layerProps.kind

--  if layerProps.randXStart and layerProps.randXStart > 0 then
--   obj.x = math.random( layerProps.randXStart, layerProps.randXEnd)
--  end
--  if layerProps.randYStart and layerProps.randYStart > 0  then
--     obj.y = math.random( layerProps.randYStart, layerProps.randYEnd)
--  end
--  if layerProps.xScale then
--    obj.xScale = layerProps.xScale
--  end
--  if layerProps.yScale then
--    obj.yScale = layerProps.yScale
--  end
--  if layerProps.rotation then
--    obj:rotate( layerProps.rotation )
--  end

--   obj.oriX     = obj.x
--   obj.oriY     = obj.y
--   obj.oriXs    = obj.xScale
--   obj.oriYs    = obj.yScale
--   obj.alpha    = layerProps.oriAlpha or 1
--   obj.oldAlpha = layerProps.oriAlpha or 1

  local targetObj = sceneGroup[self.name]
  sceneGroup:remove(targetObj)
  ---
  sceneGroup:insert( obj)
  sceneGroup[self.name] = obj
  self.obj = obj
  self.UI = UI

  --- we need the link information for setVar to update dynamictext
  local tbl = UI.dynamictexts[props.variable] or {}
  tbl[#tbl+1] = self.obj
  UI.dynamictexts[props.variable]  = tbl
  -- for k, entry in next, UI.dynamictexts do
  --   print(k, #entry)
  -- end

end

function M:update(value)
  local UI = self.UI
  local name = self.properties.variable
  local mVar = UI:getVariable(name) or ""
  if self.properties.type == "global" then
    local app = App.get()
    myVar = app:getVariable(name) or ""
    if value then
      app:setVariable(name, value)
    end
  else
    if value then
      -- print("@@@", self.name, name, value)
      UI:setVariable(name, value)
    end
  end
  self.obj.text = value or myVar
end
---------------------------
M.new = function(instance)
	return setmetatable(instance, {__index=M})
end

return M
