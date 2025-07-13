local physics = require("physics")
local app    = require "controller.Application"

local M = {
  name = NIL,
  properties = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    type = "", --pistoin, distance, pulle, + defaultSet
  },
  pivot = {
    isMotorEnabled=false,
    maxMotorTorque = nil,
    motorForce = nil,
    motorSpeed = nil,
    isLimitEnabled = true,
    rotationX = 0,
    rotationY = 0
  },
  piston = {
    anchor_x = 0,
    anchor_y = 0,
    isMotorEnabled=false,
    maxMotorTorque = nil,
    motorForce = nil,
    motorSpeed = nil,
    axisX = 0,
    axisY = 0,
  },
  wheel = {
    anchor_x = 0,
    anchor_y = 0,
    axisX = 0,
    axisY = 0,
  },
  distance = {
    anchorA_x = 0,
    anchorA_y = 0,
    anchorB_x=0,
    anchorB_y=0
  },
  pulley = {statA_x=0, statA_y=0, statB_x=0, statB_y=0, bodyA_x=0, bodyA_y=0, bodyB_x=0, bodyB_y=0, ratio=1.0},
  rope = {offsetA_x=0, offsetA_y=0, offsetB_x=0, offsetB_y=0},
  gear = {joint1="", joint2="", ratio=1},
}


function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layer       = UI.layer
  local bodyA         = sceneGroup[self.properties.bodyA]
  local bodyB       = sceneGroup[self.properties.bodyB]
  local body

  if self.properties.body then
    body = sceneGroup[self.properties.body] -- for touch
  end

  if (bodyA == nil or bodyB== nil) and body==nil then
    print("Error no body")
    return
  end


  local function getPosition(x, y)
    -- local x, y = app.getPosition(x, y)
    --local x, y = x or 0, y or 0

    -- local x = x and (x  - 480 * 0.5) or 0
    -- local y = y and (y  - 320 * 0.5) or 0

    -- if UI.props.editor  then
    --   print("getPosition", x, y, UI.sceneGroup.x/2, UI.sceneGroup.y/2)
    --   x = x + UI.sceneGroup.x/2
    --   y = y + UI.sceneGroup.y/2
    -- end
    return x, y
  end
  --
  local obj
  -- local props = self[props.type] or self.properties
  local props = self.properties
  local anchor_x, anchor_y= getPosition(props.anchor_x, props.anchor_y)
  --
  if props.type == "friction" then
    local axisX, axisY = getPosition(props.axisX, props.axisY)
    obj = physics.newJoint(props.type, bodyA, bodyB, anchor_x, anchor_y)
    obj.maxForce = props.maxForce
    obj.maxTorque = props.maxTorque
  elseif props.type == "weld" then
    local axisX, axisY = getPosition(props.axisX, props.axisY)
    obj = physics.newJoint(props.type, bodyB, bodyA, anchor_x, anchor_y)
    obj.frequency = props.frequency
    obj.dampingRatio = props.dampingRatio
  elseif props.type == "piston" then
    -- local axisX, axisY = getPosition(props.axisX, props.axisY)
    obj = physics.newJoint(props.type, bodyA, bodyB, anchor_x, anchor_y, props.axisX, props.axisY)

    -- obj.isLimitEnabled = true
    -- obj:setLimits( -140, 0 )
    -- obj.isMotorEnabled = true
    -- obj.motorSpeed = -30
    -- obj.maxMotorForce = 1000

    if props.isMotorEnabled then
      -- print("#### piston #### ",  anchor_x, anchor_y, props.axisX, props.axisY)
      obj.isMotorEnabled = props.isMotorEnabled
      obj.motorSpeed = props.motorSpeed
      obj.maxMotorForce = props.maxMotorForce
    end
    if props.isLimitEnabled then
      obj.isLimitEnabled = true
      obj:setLimits(props.limitX, props.limitY)
    end
  elseif props.type == "wheel" then
    -- local axisX, axisY = getPosition(props.axisX, props.axisY)
    -- print("@@@@@ wheel")
    obj = physics.newJoint(props.type, bodyA, bodyB, anchor_x, anchor_y, props.axisX, props.axisY)
    obj.springDampingRatio = props.springDampingRatio
    obj.springFrequency    = props.springFrequency
  elseif props.type == "distance" then
    -- print("bodyA shapedWith class",bodyA.shapedWith, bodyA.class)
    -- print("bodyA anchor",bodyA.anchorX, bodyA.anchorY)
    local anchorA_x, anchorA_y= getPosition(props.anchorA_x, props.anchorA_y)
    local anchorB_x, anchorB_y= getPosition(props.anchorB_x, props.anchorB_y)
    obj = physics.newJoint(props.type, bodyA, bodyB, anchorA_x, anchorA_y, anchorB_x, anchorB_y)
  elseif props.type == "pulley" then
    local statA_x, statA_y = getPosition(props.statA_x, props.statA_y)
    local statB_x, statB_y = getPosition(props.statB_x, props.statB_y)
    local bodyA_x, bodyA_y = getPosition(props.bodyA_x, props.bodyA_y)
    local bodyB_x, bodyB_y = getPosition(props.bodyB_x, props.bodyB_y)
    -- print("@@@@ pulley",      statA_x, statA_y,
    --   statB_x, statB_y,
    --   bodyA_x, bodyA_y,
    --   bodyB_x, bodyB_y,
    --   props.ratio)

    -- obj = physics.newJoint(props.type, bodyA, bodyB,
    --   bodyA.x, bodyA.y-100,
    --   bodyB.x, bodyB.y-140,
    --   bodyA.x, bodyA.y,
    --   bodyB.x, bodyB.y,
    --   1.0)

      obj = physics.newJoint(props.type, bodyA, bodyB,
      statA_x, statA_y,
      statB_x, statB_y,
      bodyA_x, bodyA_y,
      bodyB_x, bodyB_y,
      props.ratio)

  elseif props.type == "rope" then
    local offsetA_x, offsetA_y = getPosition(props.offsetA_x, props.offsetA_y)
    local offsetB_x, offsetB_y = getPosition(props.offsetB_x, props.offsetB_y)
    obj = physics.newJoint( "rope", bodyA, bodyB, offsetA_x, offsetA_y, offsetB_x, offsetB_y )
  elseif props.type == "gear" then
    local joint1 = UI.joints[props.joint1]
    local joint2 = UI.joints[props.joint2]
    -- printKeys(UI.joints)
    obj = physics.newJoint( "gear", bodyA, bodyB, joint1, joint2, props.ratio )
    if obj then print("Gear is created!!") end
  elseif props.type == "touch" then
    obj = physics.newJoint(props.type, body, anchor_x, anchor_y)
    obj.maxForce = props.maxForce
    obj.frequency = props.frequency
    obj.dampingRatio = props.dampingRatio
  else -- pivot
    -- print(props.type, bodyA, bodyB, anchor_x, anchor_y)
    obj = physics.newJoint(props.type, bodyA, bodyB, anchor_x, anchor_y)
    if props.rotationX or props.rotationY then
      local rotX, rotY =getPosition( props.rotationX, props.rotationY)
      if props.isMotorEnabled then
        obj:setRotationLimits(rotX, rotY)
        obj.isMotorEnabled = props.isMotorEnabled
        obj.motorSpeed = props.motorSpeed
        obj.motorForce = props.motorForce
        obj.maxMotorTorque = props.maxMotorTorque
      end
    end
  end

  if obj == nil then
    print("## Error creating a joint")
    return
  end
  self.joint = obj
  UI.joints[self.name] = obj
end

M._create = M.create

--
function M:didShow(UI)
end

M.set = function(instance)
  return setmetatable(instance, {__index=M})
end
--
return M