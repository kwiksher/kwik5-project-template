local Command = {}
local composer = require("composer")
local App = require("controller.Application")
-----------------------------
local removeOff = true
-----------------------------
function Command:new()
	local command = {}
	--
	function command:execute(params)
		local event         = params.event
    local app           = App.get()
    local page1index = "App."..app.props.appName..".components."..app.props.scenes[1]..".index"
    --
		if event=="init" then
			local function onSystemEvent(event)
			    local quitOnDeviceOnly = true
			    if quitOnDeviceOnly and system.getInfo("environment")=="device" then
			       if (event.type == "applicationSuspend")  then
			          if (system.getInfo( "platform" ) == "Android")  then
			              native.requestExit()
			          elseif removeOff then
			              if nil~= composer.getScene(page1index) then
                      --print("kwik", "=== suspend remove  === ")
			              --  composer.removeScene(page1index, true)
			              end
			              --print("kwik","==== suspend =====")
    			          -- composer.gotoScene(page1index)
			          end
			       end
			    end
			end
			Runtime:addEventListener("system", onSystemEvent)
		end
	end
	return command
end
--
return Command