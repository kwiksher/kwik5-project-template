-- $weight={{weight}}
--
local app = require "controller.Application"
local M = require("components.kwik.layer_image").new()
local infinity = require("components.kwik.layer_image_infinity")

local layerProps = {
  blendMode = "{{blendMode}}",
  height    =  {{bounds.bottom}} - {{bounds.top}},
  width     = {{bounds.right}} - {{bounds.left}} ,
  kind      = {{kind}},
  name      = "{{parent}}{{name}}",
  type      = "png",
  x         = {{bounds.right}} + ({{bounds.left}} -{{bounds.right}})/2,
  y         = {{bounds.top}} + ({{bounds.bottom}} - {{bounds.top}})/2,
  alpha     = {{opacity}}/100,
  infinity = {
    {{#infinity}}
    enabled = false,
    speed = {{speed}},
    distance = {{distance}},
    direction = "{{direction}}",
    {{/infinity}}
  },
  -- text properties
  contents =  "{{contents}}",
  font =  "{{font}}",
  fontSize =  {{fontSize}},
  alignment =  "{{alignment}}",
  {{#color}}
  color    =  { {{red}}, {{green}}, {{blue}}, 1 },
  {{/color}}
  orientation = "{{orientation}}",
}

M.align       = "{{align}}"
M.randXStart  = {{randXStart}}
M.randXEnd    = {{randXEnd}}
M.randYStart  = {{randYStart}}
M.randYEnd    = {{randYEnd}}
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
  --local sceneGroup = UI.scene.view
	if not self.isSharedAsset then
    self.imagePath = UI.page ..self.imageName
  end
end
--
function M:create(UI)
	if not self.isSharedAsset then
    self.imagePath = UI.page ..self.imageName
  end
  local obj = self:createImage(UI)
  UI.layers[#UI.layers] = obj
  self.obj = obj

  if self.infinity and self.infinity.enabled then
    infinity.createInfinityImage(UI, self.obj, self.infinity)
  end
end
--
function M:didShow(UI)
  if self.infinity and self.infinity.enabled then
    infinity.addEventListener(self.obj)
  end
end
--
function M:didHide(UI)
  if self.infinity and self.infinity.enabled then
    infinity.removeEventListener(self.obj)
  end
end
--
function  M:destroy(UI)
end
--
return M