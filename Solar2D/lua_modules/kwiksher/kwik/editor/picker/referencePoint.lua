local M = require(kwikGlobal.ROOT.."editor.parts.baseBox").new{}

M.name = "Page Name Picker"
M.model = {
  {name= "Center"},
  {name= "TopLeft"},
  {name= "TopCenter"},
  {name= "TopRight"},
  {name= "CenterLeft"},
  {name= "CenterRight"},
  {name= "BottomLeft"},
  {name= "BottomCenter"},
  {name= "BottomRight"},
}

-- Initialization: set position and dimensions
function M:init(UI)
  self.x = display.contentCenterX + 480/2-40
  self.y = display.contentCenterY
  self.height = 20
  self.width = 80
  self.fontSize = 10
  self.top = self.y - (#self.model * self.height / 2)
  self.left = self.x + self.width/4
end

-- Add inheritance from gotoSceneEffect for all methods except init
local baseSelector = require(kwikGlobal.ROOT.."editor.picker.baseSelector")
setmetatable(M, {__index = baseSelector})

return M
