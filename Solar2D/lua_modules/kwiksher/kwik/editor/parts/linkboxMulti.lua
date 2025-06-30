local name = ...
local parent = name:match("(.-)[^%.]+$")
local util = require(kwikGlobal.ROOT.."editor.util")
local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local keyEventManager = require("editor.keyEventManager")

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"

local M = {
  model = {},
  selections = {}
}

local function onKeyEvent(event)
  -- Print which key was pressed down/up
  local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
  --for k, v in pairs(event) do print(k, v) end
  if isWindows then
    if event.phase == "down" then
      -- print("shape", message)
      M.altDown = event.isCtrlDown and event.isShiftDown
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      M.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      M.shiftDown = true
    end
  else
    if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
      -- print("linkboxMulti", message)
      M.altDown = true
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      M.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      M.shiftDown = true
    end
  end
end

function M:didShow(UI)
  keyEventManager.register("linkboxMulti", onKeyEvent, 1)
  self:_didShow(UI)
end
--
function M:getValue()
  return self.objs
end
--
function M:getSelections()
  return self.selections
end

--
function M:didHide(UI)
  keyEventManager.unregister("linkboxMulti")
  self:_didHide(UI)
end

function M:commandHandler(eventObj, event)
  -- print(event.phase)
  if event.phase == "began" or event.phase == "moved" then
    return
  end

  util.setSelection(self, eventObj)
  layerTableCommands.showFocus(self)
  -- local target = eventObj -- or event.target
  -- --
  -- if not self.controlDown then
  --   self.selection = target
  --   for i = 1, #self.selections do
  --     if self.selections[i].rect then
  --       self.selections[i].rect:setFillColor(0.8)
  --     end
  --   end
  --   self.selections = {target}
  --   target.isSelected = true
  --   target.rect:setFillColor(0,1,0)
  -- else -- mutli selections
  --   if not target.isSelected then
  --     self.selections[#self.selections + 1] = target
  --     target.isSelected = true
  --   end
  --   --target:setFillColor(1)
  --   target.rect:setFillColor(0, 1, 0)
  -- end

  return true

end

return M