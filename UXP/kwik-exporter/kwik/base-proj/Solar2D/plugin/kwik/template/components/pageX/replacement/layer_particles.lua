local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name ="{{name}}",
  class = "{{class}}", -- spritesheet
  -- sheet = {{name}}_sheet,
  properties = {
    {{#properties}}
    target = "{{target}}",
    filename = "{{filename}}", -- kaboom_393.json
    autoPlay = {{autoPlay}},
    {{/properties}}
  }
}
--
M.x = layerProps.x
M.y = layerProps.y
--

return require("components.kwik.layer_particles").new(M)
