local M = {}
--
function M:pause(obj)
	transition.pause(obj.proxy)
end
--
function M:resume(obj)
	transition.resume(obj.proxy)
end
--
function M:play(obj)
	obj:dispatchEvent( {name="playFilterAnim" })
end
--
function M:cancel(obj)
	transition.cancel(obj.proxy)
end
return M