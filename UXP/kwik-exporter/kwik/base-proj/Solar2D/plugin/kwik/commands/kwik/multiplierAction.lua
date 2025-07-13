local M = {}

function M:play(obj)
  if obj then
    timer.resume(obj)
  end
end
--
function M:stop(obj)
  if obj then
    timer.pause(obj)
  end
end
--
return M