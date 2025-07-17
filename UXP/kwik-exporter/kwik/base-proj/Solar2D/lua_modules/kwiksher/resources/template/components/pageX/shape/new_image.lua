-- $weight={{weight}}
--
local app = require "controller.Application"
local M = require("components.kwik.layer_image").new()

local layerProps = {
  blendMode = "{{blendMode}}",
  height    =  {{height}},
  width     = {{width}} ,
  kind      = "{{kind}}",
  name      = "{{name}}",
  type      = "{{type}}",
  x         = {{x}},
  y         = {{y}},
  alpha     = {{alpha}},
  xScale = {{xScale}},
  yScale = {{yScale}},
  anchorX = {{anchorX}},
  anchorY = {{anchorY}},
  rotation = {{rotation}},
  shapedWith = "{{shapedWith}}",
  randXStart  = {{randXStart}},
  randXEnd    = {{randXEnd}},
  randYStart  = {{randYStart}},
  randYEnd    = {{randYEnd}},
}

M.align       = "{{align}}"
--
M.xScale     = {{xScale}}
M.yScale     = {{yScale}}
M.rotation   = {{rotation}}
--
M.layerAsBg     = {{layerAsBg}}
M.isSharedAsset = {{isSharedAsset}}
--
-- See the layerProps are retrived from obj, so use setPropsFromDisplayObject
--
M:setPropsFromDisplayObject(layerProps)
--
function M:init(UI)
  --local sceneGroup = UI.sceneGroup
	if not self.isSharedAsset then
    self.imagePath = UI.page ..self.imageName
  end
end
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
	if not self.isSharedAsset then
    self.imagePath = UI.page ..self.imageName
  end
  local obj = self:createImage(UI)

  obj.xScale = layerProps.xScale
  obj.yScale = layerProps.yScale
  obj.anchorX = layerProps.anchorX or 0.5
  obj.anchorY = layerProps.anchorY or 0.5
  obj.rotation = layerProps.rotation or 0

  obj.shapedWith = layerProps.shapedWith

  obj.layerIndex = #UI.layers+1
  UI.layers[obj.layerIndex] = obj
  sceneGroup[obj.name] = obj
end
--
function M:didShow(UI)
end
--
function M:didHide(UI)
end
--
function  M:destroy(UI)
end
--
function M.getProps ()
  return layerProps
end
--
return M