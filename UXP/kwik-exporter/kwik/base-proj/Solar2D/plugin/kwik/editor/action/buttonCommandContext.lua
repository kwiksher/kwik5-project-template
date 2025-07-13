local name = ...
local parent,        root = newModule(name)
local buttonContext = require(kwikGlobal.ROOT.."editor.parts.buttonContext")
local util          = require(kwikGlobal.ROOT.."lib.util")
local widget        = require("widget")
--
-- local buttonsContextListener = require(parent.."buttonsContextListener")
-- local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")

local model = {"Copy", "Paste", "Delete"}

local M = buttonContext.new{model=model}
M.class ="actionCommand"
--
M._init = M.init
M.handler = {}
---
function M:init(UI)
  self.UI = UI
  self:_init(UI, function(eventName, target, class)
    print(eventName)
    self.handler[eventName](self.UI, target, UI.editor.selections, class)
  end)
end

function M.handler.Copy(UI, target, selections, class)
    UI.scene.app:dispatchEvent {
      name = "editor.action.copy",
      action = target.action,
      selections = selections,
      class = class,
      UI = UI
    }
end

function M.handler.Paste(UI, target, selections, class)
    UI.scene.app:dispatchEvent {
      name = "editor.action.paste",
      action = target.action,
      selections = selections,
      class = class,
      UI = UI
    }
end

function M.handler.Delete(UI, target, selections, class)
    UI.scene.app:dispatchEvent {
      name = "editor.action.delete",
      action = target.action,
      selections = selections,
      class = class,
      UI = UI
    }
end

return M