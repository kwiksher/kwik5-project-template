-- $weight={{weight}}
--
local app = require "controller.Application"
local M = require("components.kwik.layer_image").new()

local layerProps = {
  blendMode = "{{blendMode}}",
  height    =  {{bounds.bottom}} - {{bounds.top}},
  width     = {{bounds.right}} - {{bounds.left}} ,
  kind      = "{{kind}},
  name      = "{{parent}}{{name}}",
  type      = "png",
  x         = {{bounds.right}} + ({{bounds.left}} -{{bounds.right}})/2,
  y         = {{bounds.top}} + ({{bounds.bottom}} - {{bounds.top}})/2,
  alpha     = {{opacity}}/100,
  shapedWith = "new_image",
  randXStart  = {{randXStart}},
  randXEnd    = {{randXEnd}},
  randYStart  = {{randYStart}},
  randYEnd    = {{randYEnd}},
}

M.align       = "{{align}}"
--
M.xScale     = {{scaleW}}
M.yScale     = {{scaleH}}
M.rotation   = {{rotation}}
--
M.layerAsBg     = {{layerAsBg}}
M.isSharedAsset = {{kwk}}
--
M:setProps(layerProps)
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

  self.obj = self:createImage(UI)
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