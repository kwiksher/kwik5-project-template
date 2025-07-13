local M = require(kwikGlobal.ROOT.."editor.parts.baseBox").new{}

M.name = "Page Name Picker"

-- Initialization: set position and dimensions
function M:init(UI)
  local App = require(kwikGlobal.ROOT.."controller.Application")
  local app = App.get()
  self.model = {
    {name="PREVIOUS"},
    {name="NEXT"}
  }
  for i, scene in ipairs(app.props.scenes) do
    table.insert(self.model, {name = scene})
  end
  self.x = display.contentCenterX + 480/2
  self.y = display.contentCenterY
  self.height = 20
  self.width = 120
  self.fontSize = 10
  self.top = self.y - (#self.model * self.height / 2)
  self.left = self.x + self.width/4
end

-- Add inheritance from gotoSceneEffect for all methods except init
local baseSelector = require(kwikGlobal.ROOT.."editor.picker.baseSelector")
setmetatable(M, {__index = baseSelector})

return M
