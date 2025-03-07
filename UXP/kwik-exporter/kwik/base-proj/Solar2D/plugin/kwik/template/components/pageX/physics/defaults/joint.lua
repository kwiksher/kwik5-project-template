local M = {
  name = "",
  class ="joint",
  properties = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    type = "", --pistoin, distance, pulle, + defaultSet
  },
  friction = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    maxForce = 0.22,
    maxTorque = 0.028
  },
  weld = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    frequency = 0.8,
    dampingRatio = 0.2
  },
  touch = {
    body="", anchor_x = 0, anchor_y =0,
    maxForce = 1000,
    frequency = 0.8,
    dampingRatio = 0.2
  },
  pivot = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    isMotorEnabled=true,
    maxMotorTorque = 1000,
    motorForce = 1,
    motorSpeed = 10,
    isLimitEnabled = true,
    rotationX = 0,
    rotationY = 0
  },
  piston = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    isMotorEnabled=true,
    isLimitEnabled = true,
    --maxMotorForce = 1000,
    maxMotorTorque = 1000,
    motorForce = 10,
    motorSpeed = -30,
    axisX = 0,
    axisY = 1,
    isMotorEnabled=true,
    limitX = -100,
    limitY = 0
  },
  wheel = {
    bodyA = "",
    bodyB = "",
    anchor_x = 0,
    anchor_y = 0,
    axisX = 0,
    axisY = 0,
    springFrequency = 30,
    springDampingRatio = 1.0
  },
  distance = {
    bodyA = "",
    bodyB = "",
    anchorA_x = 0,
    anchorA_y = 0,
    anchorB_x=0,
    anchorB_y=0,
    frequency = 0.8,
    dampingRatio = 0.8,
    length = nil
  },
  pulley = {
    bodyA = "",
    bodyB = "",
    statA_x=0, statA_y=0, statB_x=0, statB_y=0, bodyA_x=0, bodyA_y=0, bodyB_x=0, bodyB_y=0,
    ratio=1.0},
  rope = {
    bodyA = "",
    bodyB = "",
    offsetA_x=0, offsetA_y=0, offsetB_x=0, offsetB_y=0,
    maxLength = 200
  },
  gear = {
    bodyA = "",
    bodyB = "",
    joint1="", joint2="",
    ratio=1
  },

}

return M