-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
local _K = require "Application"
--
local particleDesigner = require("extlib.particleDesigner")
--
function _M:didShow()
end
--
function _M:toDispose()
end
--
{{#ultimate}}
local imageWidth = {{elW}}/4
local imageHeight = {{elH}}/4
local mX, mY = _K.ultimatePosition({{mX}}, {{mY}})

{{/ultimate}}
{{^ultimate}}
local imageWidth = {{elW}}
local imageHeight = {{elH}}
local mX = {{mX}}
local mY = {{mY}}
{{/ultimate}}
--
function _M:localPos (UI)
  local sceneGroup  = UI.sceneGroup
  local layer       = UI.layer
  {{^multLayers}}
    layer.{{myLName}} = particleDesigner.newEmitter( _K.particleDir.. "{{elURL}}", _K.systemDir)
    if layer.{{myLName}} == nil then return end
    {{^elPlay}}
        layer.{{myLName}}:pause();
    {{/elPlay}}
    layer.{{myLName}}.x = mX
    layer.{{myLName}}.y = mY;
    layer.{{myLName}}.oriX = layer.{{myLName}}.x
    layer.{{myLName}}.oriY = layer.{{myLName}}.y
    layer.{{myLName}}.oriXs = layer.{{myLName}}.xScale
    layer.{{myLName}}.oriYs = layer.{{myLName}}.yScale
    layer.{{myLName}}.oldAlpha = layer.{{myLName}}.alpha
    layer.{{myLName}}.type = "particles"
    sceneGroup:insert( layer.{{myLName}})
    sceneGroup.{{myLName}} = layer.{{myLName}}
  {{/multLayers}}
end
--
function _M:localVars(UI)
  {{#multLayers}}
    UI.tab{{um}}["{{dois}}"] = {"", imageWidth, imageHeight, mX, mY, _K.particleDir.. "{{elURL}}", _K.particleDir.. "{{elPNG}}" }
  {{/multLayers}}
end
--
return _M