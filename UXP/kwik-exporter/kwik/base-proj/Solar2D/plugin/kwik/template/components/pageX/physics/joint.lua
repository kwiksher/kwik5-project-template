local M = {}

function M:create(UI)
{{#properties}}
  local {{bodyA}} = UI.sceneGroup["{{bodyA}}"]
  local {{bodyB}} = UI.sceneGroup["{{bodyB}}"]
  self.name = "{{name}}"
  self.class ="joint"
  self.properties = {
    bodyA = "{{bodyA}}",
    bodyB = "{{bodyB}}",
    type = "{{type}}", --pistoin, distance, pulle, + defaultSet
  {{#pivot}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    isMotorEnabled= {{isMotorEnabled}},
    maxMotorTorque = {{maxMotorTorque}},
    motorForce = {{motorForce}},
    motorSpeed = {{motorSpeed}},
    isLimitEnabled = {{isLimitEnabled}},
    rotationX = {{rotationX}},
    rotationY = {{rorationY}}
  {{/pivot}}
  {{#piston}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    isMotorEnabled= {{isMotorEnabled}},
    maxMotorTorque = {{maxMotorTorque}},
    motorForce = {{motorForce}},
    motorSpeed = {{motorSpeed}},
    axisX = {{axisX}},
    axisY = {{axisY}},
  {{/piston}}
  {{#wheel}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    axisX = {{axisX}},
    axisY = {{axisY}}
  {{/wheel}}
  {{#distance}}
    anchorA_x = {{anchorA_x}},
    anchorA_y = {{anchorA_y}},
    anchorB_x = {{anchorB_x}},
    anchorB_y = {{anchorB_y}},
  {{/distance}}
  {{#pulley}}
    statA_x= {{statA_x}},
    statA_y= {{statA_y}},
    statB_x= {{statB_x}},
    statB_y= {{statB_y}},
    bodyA_x= {{bodyA_x}},
    bodyA_y= {{bodyA_y}},
    bodyB_x= {{bodyB_x}},
    bodyB_y= {{bodyB_y}},
    ratio  = {{ratio}},
  {{/pulley}}
  {{#rope}}
    offsetA_x= {{offsetA_x}},
    offsetA_y= {{offsetA_y}},
    offsetB_x = {{offsetB_x}},
    offsetB_y = {{offsetB_y}},
  {{/rope}}
  {{#gear}}
    joint1="{{joint1}}",
    joint2="{{joint2}}",
    ratio  = {{ratio}},
  {{/gear}}
  }
{{/properties}}
end

return require("components.kwik.page_physicsJoint").set(M)