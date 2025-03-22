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
  friction = "properties",
  weld = "properties",
  touch = {
    body="", anchor_x = 0, anchor_y =0
  },
  pivot = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    isMotorEnabled=false,
    maxMotorTorque = NIL,
    motorForce = NIL,
    motorSpeed = NIL,
    isLimitEnabled = true,
    rotationX = 0,
    rotationY = 0
  },
  piston = {
    anchor_x = 0,
    anchor_y = 0,
    bodyA = "",
    bodyB = "",
    isMotorEnabled=false,
    maxMotorTorque = NIL,
    motorForce = NIL,
    motorSpeed = NIL,
    axisX = 0,
    axisY = -1,
  },
  wheel = {
    bodyA = "",
    bodyB = "",
    anchor_x = 0,
    anchor_y = 0,
    axisX = 0,
    axisY = 0,
  },
  distance = {
    bodyA = "",
    bodyB = "",
    anchorA_x = 0,
    anchorA_y = 0,
    anchorB_x=0,
    anchorB_y=0
  },
  pulley = {
    bodyA = "",
    bodyB = "",
    statA_x=0, statA_y=0, statB_x=0, statB_y=0, bodyA_x=0, bodyA_y=0, bodyB_x=0, bodyB_y=0, ratio=1.0},
  rope = {
    bodyA = "",
    bodyB = "",
    offsetA_x=0, offsetA_y=0, offsetB_x=0, offsetB_y=0},
  gear = {
    bodyA = "",
    bodyB = "",
    joint1="", joint2="", ratio=1},

}

return M