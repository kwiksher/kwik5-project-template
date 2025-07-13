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
			if ( system.getInfo("environment") =="simulator" ) then
			   local function monitorMem()
			       collectgarbage()
			       print( "MemUsage: " .. collectgarbage("count") )
			       local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
			       print( "TexMem:   " .. textMem )
			   end
			   Runtime:addEventListener("enterFrame", monitorMem)
			end
		end
	end
	return command
end
--
return _Command