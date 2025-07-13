local M = {}
--
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

function M:reset(UI, target)
  local mod = require("App."..UI.book..".components."..UI.page..".layers,"..target.."_counter")
  mod:destory(UI)
  mod:create(UI)
  mod:didShow(UI)
end
--
return M