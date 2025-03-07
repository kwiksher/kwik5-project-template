local parent,root, M = newModule(...)

local M = {
  name ="star",
  class = "particles", -- spritesheet
  -- sheet = star_sheet,
  properties = {
    target = "star",
    url = "particleTest2.json", -- kaboom_393.json
    autoPlay = true,
  }
}
--
local layerProps = require(parent.."star")
--
M.x = layerProps.x
M.y = layerProps.y
--

return require("components.kwik.layer_particles").new(M)
