-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}},
--
local ActionCommand = {}
local _K            = require "Application"
--
function ActionCommand:new()
	local command = {}
	--
	function command:execute(params)
		local UI         = params.UI
		local sceneGroup = UI.sceneGroup
		local layers      = UI.layers
		local phase     = params.event.phase
		local event     = params.event
		{{#vvar}}
			{{vvar}}
		{{/vvar}}
		{{#arqCode}}
			{{arqCode}}
		{{/arqCode}}
	end
	return command
end
--
return ActionCommand
