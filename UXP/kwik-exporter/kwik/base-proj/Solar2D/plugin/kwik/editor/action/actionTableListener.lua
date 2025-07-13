local name = ...
local parent,root, M = newModule(name)
-- local actionbox = require(root.."parts.actionbox")
--
local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or 
                 archInfo == "IA64" or archInfo == "ARM"                 


local buttons = require(kwikGlobal.ROOT.."editor.parts.buttons")
local buttonContext = require(parent.."buttonContext")
local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")

function M:onKeyEvent(event)
  -- Print which key was pressed down/up
  -- local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
  -- for k, v in pairs(event) do print(k, v) end
  self.altDown = false
  self.controlDown = false
  if isWindows then
    if event.phase == "down" then
      self.altDown = event.isCtrlDown and event.isShiftDown
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      self.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      self.shiftDown = true
    end
  else
    if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
      -- print(message)
      self.altDown = true
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      self.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      self.shiftDown = true
    end
  end
  -- print("controlDown", self.controlDown)
end

local posX = display.contentCenterX*0.75

function M:mouseHandler(event)
  if event.isSecondaryButtonDown and event.target.isSelected then
    -- print("@@@@selected")
    buttons:showContextMenu(posX, event.y,  {class="action", selections=self.selections})
  else
    -- print("@@@@not selected")
  end
  return true
end

function M:selectHandler(target)
  local UI = self.UI
  layerTableCommands.clearSelections(self, "action")
  if self.controlDown then
    -- print("controlDown")
    layerTableCommands.multiSelections(self, target)
    UI.editor.selections = self.selections
    -- print("%%%%", #self.selections)
  elseif self.altDown then
    self.lastTarget = target
    self.UI.scene.app:dispatchEvent {
      name = "editor.action.selectAction",
      action = target.action,
      UI = self.UI
    }
    layerTableCommands.singleSelection(self, target)

  else
    self.lastTarget = target
    -- print("setActiveProp", target.action)
    if layerTableCommands.singleSelection(self, target, true) then -- isNotLayer == true
      if self.actionbox then
        self.actionbox:setActiveProp(target.action) -- nil == activeProp
        self.actionbox = nil
        self:hide()
      end
    else
      print("WARNING: setting activeProp")
      -- self:hide()
    end
  end
  buttonContext:hide()
  -- buttons:hide()
end
-- edit button
function M:editHandler(target)
  -- print("editHandler")
  if self.lastTarget then
    -- print("", self.lastTarget.action)
    self.UI.scene.app:dispatchEvent {
      name = "editor.action.selectAction",
      action = self.lastTarget.action,
      UI = self.UI
    }
  end
end

function M:attachHandler(target)
  if self.lastTarget then
    if layerTableCommands.showLayerProps(self, self.lastTarget) then
       print("TODO show action props")
       if layerTableCommands.singleSelection(self, self.lastTarget) and self.actionbox then
         self.actionbox:setActiveProp(self.lastTarget.action) -- nil == activeProp
         self.actionbox = nil
       end
    end
  end
end

function M:newHandler(target)
  self.UI.scene.app:dispatchEvent {
    name = "editor.action.selectAction",
    action = {},
    isNew = true,
    UI = self.UI
  }
end

return M