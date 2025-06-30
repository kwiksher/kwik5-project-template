
local ApplicationMediator = {}
--
--  viewInstance is an instance of Application
--
function ApplicationMediator:new()
	local mediator = {}
	mediator.session = nil
	--
	function mediator:onRegister()
		Runtime:addEventListener("onTrigger", self)
    if self.viewInstance.useTrigger then
			self.viewInstance:trigger(self.viewInstance.startSceneName, {})
		elseif self.viewInstance.showView then
			-- only app context has showView when app(book) is loaded
			-- 1) this onRegister is called by app:init
			--
			-- 2) scene:create of composer.gotoScene() also fires this onTrigger
			-- because onRobotloegsViewCreate create meditor for the composer scene
			--
			self.viewInstance:showView(self.viewInstance.startSceneName, {})
		end
	end
	--
	function mediator:onTrigger(event)
		self.viewInstance:trigger(event.url)
	end
	--
	return mediator
end
--
return ApplicationMediator