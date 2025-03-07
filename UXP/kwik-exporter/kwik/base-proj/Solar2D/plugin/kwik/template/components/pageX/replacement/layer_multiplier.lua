local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name = "{{name}}",
  properties = {
    {{#properties}}
    target         = "{{target}}",
    alphaMax       = {{alphaMax}},
    alphaMin       = {{alphaMin}},
    autoPlay       = {{autoPlay}},
    enabledWind    = {{enabledWind}},
    enablePhysics  = {{enablePhysics}},
    enableSeonsor  = {{enableSeonsor}},
    fixedDistance  = {{fixedDistance}},
    fixedScaleMax   = {{fixedScaleMax}},
    fixedScaleMin   = {{fixedScaleMin}},
    gravityY        = {{gravityY}},
    interval       = {{interval}},
    numOfCopies    = {{numOfCopies}},
    playForever    = {{playForever}},
    rotationMax    = {{rotationMax}},
    rotationMin    = {{rotationMin}},
    physicsShape   = "{{physicsShape}}",
    weightMax      = {{weightMax}},
    weightMin      = {{weightMin}},
    windSpeed      = {{windSpeed}},
    xEnd           = {{xEnd}},
    xSaleMax       = {{xSaleMax}},
    xScaleMin      = {{xScaleMin}},
    xStart         = {{xStart}},
    yEnd           = {{yEnd}},
    ySaleMax       = {{ySaleMax}},
    yScaleMin      = {{yScaleMin}},
    yStart         = {{yStart}},
    {{/properties}}
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_multiplier").set(M)
