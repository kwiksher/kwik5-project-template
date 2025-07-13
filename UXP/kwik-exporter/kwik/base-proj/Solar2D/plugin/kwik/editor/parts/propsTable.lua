local parent,root = newModule(...)
local Props = {
  name = "layer",
  anchorName = "selectLayer"
}

local M = require(parent.."baseProps").new(Props)
return M
