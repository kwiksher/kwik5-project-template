-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local ActionCommand = {}
----------------------------
-----------------------------
function HideCommand:new()
	local command = {}
	--
	function command:execute(params)
		local UI         = params.UI
		local sceneGroup = UI.sceneGroup
		local layers      = UI.layers
		local phase     = params.event.phase
		local obj       = params.obj

		if phase == "create" and obj.type == "native" then
			obj.alpha = 0
		else if phase == "didShow" and obj.type == "display" then
			obj.alpha = 0
		end
	end
	return command
end
--
return HideCommand