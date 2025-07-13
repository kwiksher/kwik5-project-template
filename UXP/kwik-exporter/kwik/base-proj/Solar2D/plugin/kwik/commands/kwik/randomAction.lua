-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
local _K            = require "controller.Application"

function _M:playRandom(id, actions, playRand, params)
		local trigger
		-- print("randomAction")
		if actions and #actions > 0 then
			if playRand then
		    local ran = math.random(1,#actions)
				trigger = actions[ran]
		  else
				if  _K.randomAction[id] == nil then
				  _K.randomAction[id] = 0
				end
				_K.randomAction[id] = _K.randomAction[id] + 1
				if _K.randomAction[id] > #actions then
					_K.randomAction[id] = 1
				end
				trigger = actions[_K.randomAction[id]]
			end
			params.event.UI = params.UI
	    Runtime:dispatchEvent({name=trigger, event=params.event, UI=params.UI})
	  end
end
--
function _M:playRandomAnimation(id, actions, playOnce, params)
		-- trigger()
		-- print("randomAnimation")
		if  _K.randomAnim[id] == nil then
			 _K.randomAnim[id] = {}
			 for i=1, #actions do
			 	_K.randomAnim[id][i] =  {actions[i], false}
			 end
		end
		if #_K.randomAnim[id] > 0 then
	    local ran = math.random(1,#_K.randomAnim[id])
			local trigger = _K.randomAnim[id][ran][1]
			table.remove(_K.randomAnim[id], ran)
			-- print(trigger)
			params.event.phase = "play"
			params.event.UI = params.UI
	    Runtime:dispatchEvent({name=trigger, event=params.event})
	  end
end
--
return _M