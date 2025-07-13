-- the following props are from gtween
-- local model = {
--     {name="restart", value = false},
--     {name="easing", value = ""},
--     {name="reverse", value = false},
--     {name="delay", value = 1000},
--     {name="loop", value = 1},
--     {name="angle", value = 45},
--     {name="xSwipe", value = 0},
--     {name="ySwipe", value = 0},
--     {name="anchor", value = "CenterReferencePoint"}
--   }

local M = require(kwikGlobal.ROOT.."editor.parts.baseBox").new()

-- these props are converted to the props of gtween in kwik/lauer_animation.lua
M.model = {
  {name="autoPlay", value=true},
  {name="delay", value=0},
  {name="duration", value=3000},
  {name="loop", value=1},
  {name="reverse", value=false},
  {name="resetAtEnd", value=false},
  {name="easing", value=nil},
  {name="xSwipe", value=nil},
  {name="ySwipe", value=nil},
}
--
---------------------------
M.name = "settings"
M.selectedTextLabel =  "autoPlay"
--
return M