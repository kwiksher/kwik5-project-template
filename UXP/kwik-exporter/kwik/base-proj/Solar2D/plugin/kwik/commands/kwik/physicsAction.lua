local M = {}
--
function M:applyForce(obj, xForce, yForce)
   obj:applyForce(xForce, yForce, obj.x, obj.y)
end
--
function M:setBodyType(obj, type)
    obj.bodyType = type
end
--
function M:gravity(gx, gy)
  physics.setGravity( gx, gy )
end
--
return M