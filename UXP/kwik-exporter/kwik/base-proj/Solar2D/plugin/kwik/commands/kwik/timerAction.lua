local M = {}
--
--
function M:create(UI, name, delay, loop, autoPlay, onComplete)
  local _UI = UI
	local timerObj = timer.performWithDelay(delay*1000,
		function()
      UI.scene:dispatchEvent{name = onComplete }
		end , loop )
  UI.timers[name] = timerObj
  if not autoPlay then
    timer.pause(timerObj)
  end
end
--
function M:pause(obj)
	timer.pause(obj)
end
--
function M:resume(obj)
	timer.resume(obj)
end
--
function M:cancel(obj)
	timer.cancel(obj)
end
--
return M