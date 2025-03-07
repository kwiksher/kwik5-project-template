local parent, root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name = "{{name}}",
  properties = {
    {{#properties}}
    target          = "{{target}}",
    mapType         = "{{mapType}}",
    latituite       = "{{latituite}}",
    longtitude      = "{{longtitude}}",
    isScrollEnabled = {{isScrollEnabled}},
    isZoomEnabled   = {{isZoomEnabled}},
    marker = {
      enabled    = {{marker.enabled}},
      latituite  = "{{marker.latituite}}",
      longtitude = "{{marker.longtitude}}",
      title      = "{{marker.title}}",
      subtitle   = "{{marker.subtitle}}",
    },
    {{/properties}}
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_map").set(M)
