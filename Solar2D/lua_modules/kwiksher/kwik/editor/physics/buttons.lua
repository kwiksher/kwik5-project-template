local M = require(kwikGlobal.ROOT.."editor.parts.buttons").new("physics")
local App = require("Application")

function M:init(UI, toggleHandler)
  -- singleton ---
  self.objs = {}
  ---
    local app = App.get()
    for i, command in next, self.commands do
      if command == "save" then

      -- print("@@@@@@@@@@@ ppppp", self.id, #self.commands, self.contextInit)
        local eventName = "editor.classEditor.physics." .. self.commands[i]
        if app.context.commands[eventName] == nil then
          app.context:mapCommand(
            eventName,
            "editor.physics.controller." .. self.commands[i]
          )
        end
      else
        -- app.context:mapCommand(
        --   "editor.classEditor." .. self.commands[i],
        --   "editor.controller." .. self.commands[i]
        -- )
      end
    end
  self.togglePanel = toggleHandler
end

function M:didShow(UI)
  self.UI = UI
  local obj = self.objs.save
  obj.eventName = "physics.save"
  obj.rect.eventName = "physics.save"
end


return M

