-- $weight={{weight}}
--
local app = require "controller.Application"
local M = require("components.common.{{className}}").new()

function M:setProps(layerProps)
  self.imageWidth  = layerProps.width/4
  self.imageHeight = layerProps.height/4
  self.mX, self.mY   = app.getPosition(layerProps.x, layerProps.y, self.align)
  --
  self.randXStart  = app.getPosition(self.randXStart)
  self.randXEnd    = app.getPosition(self.randXEnd)
  self.dummy, self.randYStart = app.getPosition(0, self.randYStart)
  self.dummy, self.randYEnd   = app.getPosition(0, self.randYEnd)
  --
  self.layerName = layerProps.name
  self.oriAlpha  = layerProps.alpha
  --
  self.imagePath = layerProps.name.."." .. layerProps.type
  self.imageName = "/"..layerProps.name.."." ..layerProps.type
  --
  self.blendMode = layerProps.blendMode
end

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
M:setProps(layerProps)
--
return M