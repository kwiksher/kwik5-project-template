local name = ...
local parent,        root = newModule(name)
local buttonContext = require(kwikGlobal.ROOT.."editor.parts.buttonContext")
local util          = require(kwikGlobal.ROOT.."lib.util")
local widget        = require("widget")
--
-- local buttonsContextListener = require(parent.."buttonsContextListener")
-- local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")

local model = {"New", "Edit", "In vscode", "Copy", "Paste", "Delete"}

local M = buttonContext.new{name=name, model=model}
M.class ="action"

M._init = M.init
M.handler = {}
---
function M:init(UI)
  self.UI = UI
  self:_init(UI, function(eventName, target, class) -- this is listner to parts.buttonContext
    print(eventName, target.text, class, target.action)
    self:hide()
    self.handler[eventName](self.UI, target, UI.editor.selections, class)

  end)
end

-- edit button
function M.handler.Edit(UI, target, selections, class)
  -- print("editHandler")
  if class=="action" then
    -- print("", self.target.action)
    UI.scene.app:dispatchEvent {
      name = "editor.action.selectAction",
      action = target.action,
      class = class,
      UI = UI
    }
  elseif class =="actionCommand" then
  end
end

--[[
--
--  baseProps's tapListener for action, set actionbox as self.target in parts.buttonContext
--
function M.handler.Attach(self)
  if self.target then
    if layerTableCommands.showLayerProps(self, self.target) then
       print("TODO show action props")
       if layerTableCommands.singleSelection(self, self.target) and self.actionbox then
         self.actionbox:setActiveProp(self.target.action) -- nil == activeProp
         self.actionbox = nil
       end
    end
  end
end
--]]

function M.handler.New(UI, target, selections, class)
  UI.scene.app:dispatchEvent {
    name = "editor.action.selectAction",
    action = {},
    isNew = true,
    class = class,
    UI = UI
  }
end

function M.handler.Copy(UI, target, selections, class)
  if class == "action" then    -- print("", self.target.action)
    UI.scene.app:dispatchEvent {
      name = "editor.action.copy",
      action = target.action,
      selections = selections,
      class = class,
      UI = UI
    }
  elseif class =="actionCommand" then
  end
end

function M.handler.Paste(UI, target, selections, class)
  if class == "action" then
    -- print("", self.target.action)
    UI.scene.app:dispatchEvent {
      name = "editor.action.paste",
      action = target.action,
      selections = selections,
      class = class,
      UI = UI
    }
  elseif class =="actionCommand" then
  end
end

function M.handler.Delete(UI, target, selections, class)
  if class == "action" then
    print("@", target.action)
    UI.scene.app:dispatchEvent {
      name = "editor.action.delete",
      action = target.action,
      selections = selections,
      class = class,
      UI = UI
    }
  elseif class =="actionCommand" then
  end
end

function M.handler.Invscode(UI, target, selections, class)
  if class == "action" then
    -- print("", self.target.action)
    local options = {selections = selections, type="action"}
    if selections == nil or #selections ==0 then
      options.selections = {target}
    end
    --
    UI.scene.app:dispatchEvent {
      name = "editor.classEditor.openEditor",
      props = {options = options},
      UI = UI
    }
  elseif class =="actionCommand" then
  end
end

return M