-- $weight={{weight}}
--
local app = require "controller.Application"
local M = require("components.kwik.layer_image").new()

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
M:setProps(Props)
--
function M:init(UI)
end
--
function M:create(UI)
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