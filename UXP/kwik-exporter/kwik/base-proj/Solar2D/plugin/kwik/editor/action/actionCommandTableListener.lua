local M = {}
M.name = ...

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or 
                 archInfo == "IA64" or archInfo == "ARM"                 

local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")

function M:onKeyEvent(event)
  -- Print which key was pressed down/up
  -- local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
  -- for k, v in pairs(event) do print(k, v) end
  self.altDown = false
  self.controlDown = false
  if isWindows then
    if event.phase == "down" then
      -- printKeys(event)
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

function M:singleClickEvent(obj)
  -- print("------- singleClickEvent ----- ")
  local target = obj
  local UI = self.UI
  layerTableCommands.clearSelections(self, "actionCommand")
  if self.controlDown then
    -- print("controlDown")
    layerTableCommands.multiSelections(self, target)
    UI.editor.selections = self.selections
    -- print("%%%%", #self.selections)
  else
    self.lastTarget = target
    self.UI.scene.app:dispatchEvent {
      name = "editor.action.selectActionCommand",
      UI = self.UI,
      index = obj.index,
      commandClass = self.actions[obj.index]
    }

    if self.selection and self.selection ~= obj then
      self.selection.rect:setFillColor(1)
    end
    self.selection = obj
    self.selection.rect:setFillColor(0,1,0)

    if self.altDown then
      -- if layerTableCommands.singleSelection(self, target) then
      --   actionbox:setActiveProp(target.action) -- nil == activeProp
      -- end
   end
  end




end

    -- create a listener to handle drag-item commands
function M:listener( item, touchevent )
  -- print("@@@@@@ actionCommandTableListener UI", self.UI)
  if touchevent.phase  == "ended" then
    -- print("single click event")
    -- this opens a commond editor table
    self:singleClickEvent(item)
  else
    display.currentStage:insert( item )
    item.x, item.y = touchevent.x, touchevent.y
    -- print(item.x, item.y)
    --
    local function touch(e)
      --print("touch", e.phase, e.target.hasFocus)
      if (e.phase == "began") then
        display.currentStage:setFocus( e.target, e.id )
        e.target.hasFocus = true
        return true
      elseif (e.target.hasFocus) then
        e.target.x, e.target.y = e.x, e.y
        -- print("", e.target.x, e.target.y)
        if (e.phase == "moved") then
        elseif (e.phase == "ended") then
          -- print(e.phase, e.target.x, e.target.y)
          display.currentStage:setFocus( e.target, nil )
          e.target.hasFocus = nil
          local localX, localY = self.scrollView:contentToLocal(  e.target.x,  e.target.y )
          e.target.x = localX + self.scrollView.width/2
          e.target.y = localY + self.scrollView.height/2
          -- print("", e.target.x, e.target.y)
          -- print("--------")

          local function compare(a,b)
            return a.y < b.y
          end
          --
          table.sort(self.objs,compare)
          local actions = {}
          for i=1, #self.objs do
            print(i, self.objs[i].index, self.objs[i].action.command)
            actions[i] = self.objs[i].action
          end
          self:destroy()
          self:createTable(nil, {actions = actions})
          --
          --self.scrollView:attachListener(e.target, listener, 100, 20, 20)
        end
        return true
      end
      return false
    end
    --
    item.hasFocus = true
    display.currentStage:setFocus( item, touchevent.id )
    -- print("add")
    item:addEventListener( "touch", touch )
  end
end

--
return M