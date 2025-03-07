-- $weight={{weight}}
--
local parent,root, M = newModule(...)

local _layerProps = {
  blendMode = "{{blendMode}}",
  height    = {{height}},
  width     = {{width}} ,
  kind      = "{{kind}}",
  name      = "{{name}}",
  type      = "{{type}}",
  x         = {{x}},
  y         = {{y}},
  alpha     = {{alpha}},
  --
  align       = "{{align}}",
  randXStart  = {{randXStart}},
  randXEnd    = {{randXEnd}},
  randYStart  = {{randYStart}},
  randYEnd    = {{randYEnd}},
  --,
  xScale     = {{xScale}},
  yScale     = {{yScale}},
  rotation   = {{rotation}},
  --,
  layerAsBg     = {{layerAsBg}},
  isSharedAsset = {{isSharedAsset}},
  ---
  {{#color}}
  color    = { {{r}}, {{g}}, {{b}}, {{a}} },
  {{/color}}
  {{#text}}
  text = {{text}},
  font = {{font}},
  fontSize = {{fontSize}},
  {{/text}}
  ---
  infinity = {{infinity}},
  infinitySpeed = {{infinitySpeed}},
  infinityDistance = {{infinityDistance}},
  ---
  {{#imagePath}}
  imagePath   = {{imagePath}},
  imageHeight = {{imageHeight}},
  imageWidth  = {{imageWidth}}
  {{/imagePath}}
}
--
function M:init(UI)
  --local sceneGroup = UI.sceneGroup
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
function M:new(props)
  return self:newInstance(props, _layerProps)
end
--
return M