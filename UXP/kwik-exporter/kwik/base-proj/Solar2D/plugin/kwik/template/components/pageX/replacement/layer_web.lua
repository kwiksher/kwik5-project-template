local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  properties = {
    {{#properties}}
    target   = "{{target}}",
    isLocal  = "{{isLocal}}",
    url      = "{{url}}",
    width    = {{width}},
    height   = {{height}}
    {{/properties}}
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_web").set(M)
