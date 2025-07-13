local dir = ...
local parent = dir:match("(.-)[^%.]+$")
local root = parent:sub(1, parent:len() - 1):match("(.-)[^%.]+$")

local M = {}

M.new = function(appDir, name)
  --print("=== mediator ===", mediatorName)
  local Class = {}
  -- Class.name = mediatorName:gsub("mediators.", ""):gsub("Mediator", "")
  Class.name = name -- mediatorName:match("[^.]+$"):gsub("Mediator", "")
  --
  --local appDir = mediatorName:match('(App%.%a+%.)')
  --print(appDir, Class.name)
  local scene = require(appDir .. "components." .. Class.name .. ".index")
  --
  function Class:new()
    local mediator = {}
    mediator.commands = scene:getCommands()
    mediator.name = self.name
    --
    function mediator:onRegister()
      -- print("mediator:onRegister", self.name)
      local scene = self.viewInstance
      for k, eventName in pairs(self.commands) do
        -- print("", eventName)
        scene:addEventListener(eventName, self)
      end
    end
    --
    function mediator:onRemove()
      -- print("mediator:onRemove", self.name)
      local scene = self.viewInstance
      for k, eventName in pairs(self.commands) do
        scene:removeEventListener(eventName, self)
      end
    end
    --
    -- event listeners are here. they are set with onRegister
    --  event in scene is triggered with UI.scene:dispatchEvent
    --    UI.scene:dispatchEvent
    --      name = "bg.clickLayer",
    --        UI = UI
    --      }
    --  then it is redirected to the app:dispatchEvent below
    --
    for k, eventName in pairs(mediator.commands) do
      -- print("", self.name, eventName)
      mediator[eventName] = function(self, event)
        local myself = self
        -- print("", myself.name .. "." .. eventName)
        --
        -- addEventListener is set by context:mapCommand
        --
        if self.viewInstance.isActive then -- ref scene.lua
          local _event = event.event or event
          self.viewInstance.app:dispatchEvent {
            name = myself.name .. "." .. eventName,
            event = _event,
            UI = myself.viewInstance.UI
          }
        end
      end
    end
    --
    return mediator
  end
  --
  return Class
end

return M
