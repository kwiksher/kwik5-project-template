local Align = require("extlib.align")
local M = {}

local function slice (t, first, last)
  local ret = {}
  for key, value in pairs({table.unpack({1, 2, 3, 4, 5}, 2, 4)}) do
    ret[#ret+1] = value
  end
  return ret
end

function M:init(UI)
end
--
function M:create(UI)
end
--
function M:didShow(UI)
  -- local rect = {width = 480, height = 320, x = display.contentCenterX, y = display.contentCenterY}
  -- local mainRef = Align.newReference(rect, {padding=20})
  local mainRef = Align.newReference(display.currentStage, {padding=0})
  local option = {
    -- local dialog = Align.newContainer(mainRef, {
      width=mainRef.insideWidth,
      height=mainRef.insideHeight/2,
      nil, -- bg="bg.jpg",
      padding=0}

  -- print(display.contentHeight)
  -- x = display.contentCenterX,
  option.y = display.contentCenterY/2

  local dialog = Align.newContainer(display.currentStage, option)
  option.x = display.contentWidth*0.25
  local dialog1 = Align.newContainer(display.currentStage, option)
  option.x = display.contentWidth*0.75
  local dialog2 = Align.newContainer(display.currentStage, option)
  -- print("onInit", #UI.layers )

  local patterns = {}
  patterns[1] = function()
  end
  patterns[2] = function()
    Align.spaceVertically(dialog, unpack(UI.layers))
  end
  patterns[3] = function()
   Align.spaceHorizontally(dialog, unpack(UI.layers))
  end
  patterns[4] = function()
    Align.bottom(dialog, UI.layers[1])
    Align.top(dialog,  UI.layers[2])
    Align.left(dialog, UI.layers[3])
    Align.right(dialog, UI.layers[4])
  end
  patterns[5] = function()
    Align.bottom(dialog, UI.layers[1])
    Align.top(dialog,  UI.layers[2])
    Align.left(dialog, UI.layers[3])
    Align.right(dialog, UI.layers[4])
  end
  patterns[6] = function()
    Align.spaceVertically(dialog1, slice(UI.layers, 1, 3))
    Align.spaceVertically(dialog2, slice(UI.layers, 4, 6))
  end
  patterns[7] = function()
    Align.spaceVertically(dialog1, slice(UI.layers, 1, 3))
    Align.spaceVertically(dialog2, slice(UI.layers, 4, 6))
  end
  patterns[8] = function()
    Align.spaceVertically(dialog1, slice(UI.layers, 1, 3))
    Align.spaceVertically(dialog2, slice(UI.layers, 4, 6))
    Align.spaceVertically(dialog, slice(UI.layers, 7, 8))
  end
  patterns[9] = function()
    Align.spaceHorizontally(dialog1, slice(UI.layers, 1, 3))
    Align.spaceHorizontally(dialog2, slice(UI.layers, 4, 6))
    Align.spaceHorizontally(dialog, slice(UI.layers, 7, 9))
  end
  patterns[10] = function()
  end

  -- print("##########", #UI.layers)
  patterns[#UI.layers]()
  -- for k, v in pairs(UI.  sceneGroup) do print(k, v) end
  -- for i=1, #UI.layers do
  --   print(UI.layers[i].name)
  -- end
-- Align.spaceHorizontally(dialog, unpack(UI.layers))
  --Align.spaceVertically(dialog, unpack(UI.layers))




    -- Align.insideRight(dialog, UI.layers[1])
end
--
function M:didHide(UI)
end
--
function M:destroy(UI)
end
--
return M
