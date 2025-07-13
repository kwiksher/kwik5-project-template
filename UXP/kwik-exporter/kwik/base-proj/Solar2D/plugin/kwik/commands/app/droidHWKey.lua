-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _Command = {}
-----------------------------
-----------------------------
function _Command:new()
	local command = {}
	--
	function command:execute(params)
		local event         = params.event
		if event=="init" then
			-- Handles physical buttons on Android devices
			local function onKeyEvent( event )
			   local phase = event.phase
			   local keyName = event.keyName
			   local alert = nil
			   if ( "back" == keyName and phase == "up" ) then
			      local function onComplete( event )
			         if "clicked" == event.action then
			            local i = event.index
			            if 1 == i then
			               if alert~= nil then
			                 native.cancelAlert( alert )
			               end
			            elseif 2 == i then
			               native.requestExit()
			            end
			         end
			      end
			      alert = native.showAlert( "EXIT", "ARE YOU SURE?", { "NO", "YES" }, onComplete )
			      return true
			   end
			   return false
			end
			Runtime:addEventListener( "key", onKeyEvent )
		end
	end
	return command
end
--
return _Command