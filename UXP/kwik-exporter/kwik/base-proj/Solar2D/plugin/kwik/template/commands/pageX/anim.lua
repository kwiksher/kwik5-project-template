-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local AnimationCommand = {}
local _K = require("Application")
-----------------------------
-----------------------------
function AnimationCommand:new()
	local command = {}
	--
	function command:execute(params)
		local UI    = params.event.UI
		local phase = params.event.phase
		local obj   = params.obj

		if phase == "didShow" then
			obj:repoHeader(UI)
			obj:buildAnim(UI)
		elseif phase=="dispose" then
			obj:toDispose()
		elseif phase=="play" then
			obj:play()
		end
	end
	return command
end
--
return AnimationCommand