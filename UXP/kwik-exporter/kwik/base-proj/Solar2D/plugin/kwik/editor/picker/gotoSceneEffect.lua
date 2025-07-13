local name = ...
local model = {
  {name = "fade"},
  {name = "crossFade"},
  {name = "zoomOutIn"},
  {name = "zoomOutInFade"},
  {name = "zoomInOut"},
  {name = "zoomInOutFade"},
  {name = "flip"},
  {name = "flipFadeOutIn"},
  {name = "zoomOutInRotate"},
  {name = "zoomOutInFadeRotate"},
  {name = "zoomInOutRotate"},
  {name = "zoomInOutFadeRotate"},
  {name = "fromRight"}, -- over current scene
  {name = "fromLeft"}, -- over current scene
  {name = "fromTop"}, -- over current scene
  {name = "fromBottom"}, -- over current scen}e
  {name = "slideLeft"}, -- pushes current scene off
  {name = "slideRight"}, -- pushes current scene off
  {name = "slideDown"}, -- pushes current scene off
  {name = "slideUp"}, -- pushes current scene off
}

local M = require(kwikGlobal.ROOT.."editor.parts.baseBox").new{
}
M.name = "Goto Scene Effect"

-- Initialization: set position and dimensions
function M:init(UI)
  self.x = display.contentCenterX + 480/2
  self.y = display.contentCenterY
  self.height = 16
  self.width = 160
  self.fontSize = 10
  self.top = self.y - #self.model*self.height/2
  self.left =self.x + M.width/4
  self.model = model
end

-- Add inheritance from gotoSceneEffect for all methods except init
local baseSelector = require(kwikGlobal.ROOT.."editor.picker.baseSelector")
setmetatable(M, {__index = baseSelector})

return M

