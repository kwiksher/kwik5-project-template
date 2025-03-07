-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
local _K = require "Application"
local player = require "extlib.movieclip_player"
--
--
{{#ultimate}}
local imageWidth = {{elW}}/4
local imageHeight = {{elH}}/4
local mX, mY = _K.ultimatePosition({{mX}}, {{mY}}, "{{align}}")
{{#randX}}
local randXStart = _K.ultimatePosition({{randXStart}})
local randXEnd = _K.ultimatePosition({{randXEnd}})
{{/randX}}
{{#randY}}
local dummy, randYStart = _K.ultimatePosition(0, {{randYStart}})
local dummy, randYEnd     = _K.ultimatePosition(0, {{randYEnd}})
{{/randY}}
{{/ultimate}}
{{^ultimate}}
local imageWidth = {{elW}}
local imageHeight = {{elH}}
local mX, mY                 = _K.ultimatePosition({{mX}}, {{mY}}, "{{align}}")
{{#randX}}
local randXStart = {{randXStart}}
local randXEnd = {{randXEnd}}
{{/randX}}
{{#randY}}
local randYStart = {{randYStart}}
local randYEnd = {{randYEnd}}
{{/randY}}
{{/ultimate}}
local oriAlpha = {{oriAlpha}}

local png_prefix = _K.videoDir .. "{{elURL}}/{{prefix}}" -- "img/test_HTML5 Canvas" --test_HTML5 Canvas0001.png
local prefix_num = "{{preNum}}"
local num_of_pngs = {{numOfPngs}}

function _M:localVars(UI)
end

function _M:localPos(UI)
  local sceneGroup  = UI.scene.view
  local layer       = UI.layer

  layer.{{myLName}} = display.newGroup()
  layer.{{myLName}}.player = player
  player:init(png_prefix, prefix_num,  num_of_pngs, mX, mY, imageWidth, imageHeight, layer.{{myLName}} ) -- group

  sceneGroup:insert(layer.{{myLName}})
  sceneGroup.{{myLName}} = layer.{{myLName}}
end
--
function _M:didShow(UI)
  local sceneGroup  = UI.scene.view
  local layer       = UI.layer

  --
    {{#randX}}
      layer.{{myLName}}.x = math.random( randXStart,randXEnd)
    {{/randX}}
    {{#randY}}
      layer.{{myLName}}.y = math.random( randYStart, {{randYEnd}})
    {{/randY}}
    {{#scaleW}}
      layer.{{myLName}}.xScale = {{scaleW}}
    {{/scaleW}}
    {{#scaleH}}
      layer.{{myLName}}.yScale = {{scaleH}}
    {{/scaleH}}
    {{#rotate}}
      layer.{{myLName}}:rotate( {{rotate)}})
    {{/rotate}}
    layer.{{myLName}}.oriX = layer.{{myLName}}.x
    layer.{{myLName}}.oriY = layer.{{myLName}}.y
    layer.{{myLName}}.oriXs = layer.{{myLName}}.xScale
    layer.{{myLName}}.oriYs = layer.{{myLName}}.yScale

    layer.{{myLName}}.alpha = oriAlpha
    layer.{{myLName}}.oldAlpha = oriAlpha

    {{#elTriggerElLoop}}
         layer.{{myLName}}.videoListener = function(event)
        if event.phase == "ended" then
          {{#elRewind}}
          {{/elRewind}}
          {{#elTrigger}}
           UI.scene:dispatchEvent({name="action_{{elTrigger}}", layer=layer.{{myLName}} })
          {{/elTrigger}}
         end
      end
    {{/elTriggerElLoop}}

    {{#elPlay}}
        local _loop = 0
       {{#elLoop}}
            _loop = -1
      {{/elLoop}}
      layer.{{myLName}}.loop = _loop
      player:play({loop=_loop, onComplete = function()
          print("completed")
          player:stop()
        {{#elTriggerElLoop}}
          layer.{{myLName}}.videoListener({phase ="ended"})
        {{/elTriggerElLoop}}
        end
      })
    {{/elPlay}}
    layer.{{myLName}}.name = "{{myLName}}"
end
--
function _M:toDispose(UI)
  local sceneGroup  = UI.scene.view
  local layer       = UI.layer
  {{#elTriggerElLoop}}
  if layer.{{myLName}} then
      layer.{{myLName}}.videoListener = nil
  end
  {{/elTriggerElLoop}}
end
--
function _M:localVars()
end

function _M:toDestroy(UI)
  local sceneGroup  = UI.scene.view
  local layer       = UI.layer
end

--
return _M