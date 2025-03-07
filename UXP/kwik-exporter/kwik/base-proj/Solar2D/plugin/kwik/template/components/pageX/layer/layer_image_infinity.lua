-- $weight={{weight}}
--
local _K = require "controller.Application"
local _M = require("components.kwik.layer_image").new()

parseValue = function(value, newValue)
	if newValue then
		if value then
			return newValue
		else
			return nil
		end
	else
		return value
	end
end

local Props = {
  blendMode = "{{blendMode}}",
  height    =  {{bounds.bottom}} - {{bounds.top}},
  width     = {{bounds.right}} - {{bounds.left}} ,
  kind      = {{kind}},
  name      = "{{parent}}{{name}}",
  type      = "png",
  x         = {{bounds.right}} + ({{bounds.left}} -{{bounds.right}})/2,
  y         = {{bounds.top}} + ({{bounds.bottom}} - {{bounds.top}})/2,
  alpha     = {{opacity}}/100,
}

_M.infinity = parseValue({{infinity}})
_M.infinitySpeed = parseValue({{infinitySpeed}})
--
--
_M.imageWidth  = Props.width/4
_M.imageHeight = Props.height/4
_M.mX, _M.mY   = _K.getPosition(Props.x, Props.y, "{{align}}")
_M.randXStart  = _K.getPosition({{randXStart}})
_M.randXEnd    = _K.getPosition({{randXEnd}})
_M.dummy, _M.randYStart = _K.getPosition(0, 0)
_M.dummy, _M.randYEnd   = _K.getPosition(0, 0)
_M.infinityDistance = (parseValue({{idist}}) or 0)/4
--
_M.layerName     = Props.name
_M.oriAlpha = Props.alpha
_M.isSharedAsset = parseValue({{kwk}})
_M.imagePath = Props.name.."." .. Props.type
_M.imageName = "/"..Props.name.."." ..Props.type
_M.langGroupName = "{{dois}}"
_M.langTableName = "tab{{um}}"
_M.xScale     = parseValue({{scaleW}})
_M.yScale     = parseValue({{scaleH}})
_M.rotation   = parseValue({{rotation}})
_M.blendMode     = Props.blendMode
_M.layerAsBg     = parseValue({{layerAsBg}})
--
function _M:init(UI)
	if not self.isSharedAsset then
    self.imagePath = UI.page ..self.imageName
  end
  if self.multLayers then
    UI[self.langTableName][self.langGroupName] = {self.imagePath, self.imageWidth, self.imageHeight, self.mX, self.mY, self.oriAlpha}
  end
end
--
function _M:create(UI)
	if not self.isSharedAsset then
    self.imagePath = UI.page ..self.imageName
  end
  local layer = self:myNewImage(UI)
  UI.layers[#UI.layers+1] = layer
end
--
function _M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  if not self.multLayers then
    if self.infinity then
       -- Infinity background
       if sceneGroup[self.layerName] == nil  or sceneGroup[self.kayerName.."_2"] == nil then return end
       Runtime:addEventListener("enterFrame", sceneGroup[self.layerName])
       Runtime:addEventListener("enterFrame", sceneGroup[self.kayerName.."_2"])
    end
  end
end
--
function _M:didHide(UI)
  local sceneGroup = UI.sceneGroup
  if self.infinity then
    if sceneGroup[self.layerName] == nil  or sceneGroup[self.kayerName.."_2"] == nil then return end
      Runtime:removeEventListener("enterFrame", sceneGroup[self.layerName])
      Runtime:removeEventListener("enterFrame", sceneGroup[self.kayerName.."_2"])
  end
end
--
function  _M:destroy()
end
--
return _M