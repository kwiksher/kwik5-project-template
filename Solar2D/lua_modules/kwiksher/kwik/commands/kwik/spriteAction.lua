local M = {}
--
function M:play(obj, seq)
		obj:setSequence(seq)
		obj:play()
end
--
function M:pause(obj)
  	obj:pause()
end
--
return M