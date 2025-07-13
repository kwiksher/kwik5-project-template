local M = {}

M.new = function(mediatorName)

    local Class = {}
	print(mediatorName)
    Class.name = mediatorName:gsub("mediators.", ""):gsub("Mediator", "")
    --
    local scene = require("scenes." .. Class.name)
    Class.commands = scene:getCommands()
    --
    function Class:new()
        local mediator = {}
        mediator.commands = self.commands
        mediator.name = self.name
        --
        function mediator:onRegister()
            local scene = self.viewInstance
            for k, eventName in pairs(self.commands) do
                scene:addEventListener(eventName, self)
            end
        end
        --
        function mediator:onRemove()
            local scene = self.viewInstance
            for k, eventName in pairs(self.commands) do
                scene:removeEventListener(eventName, self)
            end
        end
        --
        print("mediator")
        for k, eventName in pairs(self.commands) do
			print("", self.name, eventName)
            mediator[eventName] = function(self, event)
                local myself = self
                Runtime:dispatchEvent({
                    name = myself.name .. "." .. eventName,
                    event = event,
                    UI = myself.viewInstance.pageUI
                })
            end
        end
        --
        return mediator
    end
    --
    return Class
end

return M