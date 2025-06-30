local M = {}
local current = ...
local parent,  root = newModule(current)
--

local Props = {
  name = "Settings",
  anchorName = "Settings",
  x = display.contentCenterX+480/2,
  y = 10

}

local M = require(parent.."baseProps").new(Props)
--
-- I/F
--
M.useClassEditorProps = function()
  return M:getValue()
end

return M
