local M = {}
local current = ...
local parent = current:match("(.-)[^%.]+$")

M.name = current
M.weight = 1

local App = require("Application")

--
-- local button = require("com.gieson.Button")
-- local tools = require("com.gieson.Tools")
---
M.commands = {"selectAction", "selectActionCommand"}

---
function M:init(UI, toggleHandler)
    local app = App.get()
    for i = 1, #self.commands do
      local eventName = "editor.action." ..self.commands[i]
      if app.context.commands[eventName] == nil then
        app.context:mapCommand(
          eventName,
          "editor.action.controller." .. self.commands[i]
        )
      end
    end
    self.togglePanel = toggleHandler
end
--
function M:create(UI)
end
--
function M:didShow(UI)
end
--
function M:didHide(UI)
end
--
function M:destroy()
end

function M:toggle()
end

function M:show()
end

function M:hide()
end

--
return M
