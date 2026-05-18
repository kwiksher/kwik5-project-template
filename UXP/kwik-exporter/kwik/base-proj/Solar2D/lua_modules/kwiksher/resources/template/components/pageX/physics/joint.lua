local M = {}

function M:create(UI)
{{#properties}}
  {{^touch}}
  local {{bodyA}} = UI.sceneGroup["{{bodyA}}"]
  local {{bodyB}} = UI.sceneGroup["{{bodyB}}"]
  {{/touch}}
  {{#touch}}
  local {{body}} = UI.sceneGroup["{{body}}"]
  {{/touch}}
  self.name = "{{name}}"
  self.class ="joint"
  self.properties = {
    bodyA = "{{bodyA}}",
    bodyB = "{{bodyB}}",
    type = "{{type}}", --pistoin, distance, pulle, + defaultSet
    {{#friction}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    maxForce = {{maxForce}},
    maxTorque = {{maxTorque}}
  {{/friction}}
  {{#touch}}
    body     = "{{body}}",
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    frequency = {{frequency}},
    dampingRatio = {{dampingRatio}},
    maxForce = {{maxForce}},
  {{/touch}}
  {{#weld}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    frequency = {{frequency}},
    dampingRatio = {{dampingRatio}}
  {{/weld}}
  {{#pivot}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    isMotorEnabled= {{isMotorEnabled}},
    maxMotorTorque = {{maxMotorTorque}},
    motorForce = {{motorForce}},
    motorSpeed = {{motorSpeed}},
    isLimitEnabled = {{isLimitEnabled}},
    rotationX = {{rotationX}},
    rotationY = {{rotationY}}
  {{/pivot}}
  {{#piston}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    isMotorEnabled= {{isMotorEnabled}},
    maxMotorTorque = {{maxMotorTorque}},
    motorSpeed = {{motorSpeed}},
    axisX = {{axisX}},
    axisY = {{axisY}},
    isLimitEnabled = {{isLimitEnabled}},
    limitX = {{limitX}},
    limitY = {{limitY}},
  {{/piston}}
  {{#wheel}}
    anchor_x = {{anchor_x}},
    anchor_y = {{anchor_y}},
    axisX = {{axisX}},
    axisY = {{axisY}},
    springFrequency = {{springFrequency}},
    springDampingRatio = {{springDampingRatio}}

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
    maxLength = {{maxLength}}
  {{/rope}}
  {{#gear}}
    joint1="{{joint1}}",
    joint2="{{joint2}}",
    ratio  = {{ratio}},
  {{/gear}}
  }
{{/properties}}
  self:_create(UI)

  --[[
    local circleA = display.newCircle(self.properties.anchorA_x, self.properties.anchorA_y, 10)
    circleA:setFillColor(1, 0, 0)
    UI.sceneGroup:insert(circleA)

    local B = display.newCircle(self.properties.anchorB_x, self.properties.anchorB_y, 10)
    B:setFillColor(1, 1, 0)
    UI.sceneGroup:insert(B)

    local circle = display.newCircle(self.properties.anchor_x, self.properties.anchor_y, 10)
    circle:setFillColor(1, 0, 0)
    UI.sceneGroup:insert(circle)

  --]]


end

return require("components.kwik.page_physicsJoint").set(M)