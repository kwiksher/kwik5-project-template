local M = {}
--		obj:showHide("objB", false)
local App = require("controller.Application")
--
function M:edit(obj, x, y, width, height, xScale, yScale, rotation)
   local mX, mY  = App.getPosition(x, y)
   if x then
        obj.x = x/4
   end
   if y then
        obj.y = y/4
   end
   if width then
        obj.width = width/4
   end
   if height then
       obj.height = height/4
   end
   if xScale then
       obj.xScale = xScale
   end
   if yScale then
       obj.yScale = yScale
   end
   if rotation then
       obj.rotation = rotation
   end
end
--
return M