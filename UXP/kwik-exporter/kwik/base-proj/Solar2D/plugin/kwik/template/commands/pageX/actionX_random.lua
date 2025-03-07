-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local command = {}
--
local ran = nil
function command:playRandom(params)
	local UI         = params.UI
	local sceneGroup = UI.sceneGroup
	local layers      = UI.layers
	local phase      = params.event.phase
	local ran        = nil
	{{#playRand}}
		ran = math.random(1,{{triggersLen}}})
	{{/playRand}}
	{{^playRand}}
		if (ran == nil) then
			ran = 0
		end
		ran = ran + 1
		if (ran> {{triggersLen}}}) then
			ran = 1
		end
	{{/playRand}}
	{{#randArr}}
		if (ran == {{ca}}}) then
			{{play}}()
		end
	{{/randArr}}
end
--
return command