local M = {}
function M:create(UI)
  local rect_0 = UI.sceneGroup["rect_0"]
  local rect_1 = UI.sceneGroup["rect_1"]
  self.name = "rect_0_rect_1_pivot"
  self.class ="joint"
  self.properties = {
    bodyA = "rect_0",
    bodyB = "rect_1",
    type = "pivot", --pistoin, distance, pulle, + defaultSet
    anchor_x = rect_0.x + rect_0.width/2,
    anchor_y = rect_0.y + rect_0.height/2,
    isMotorEnabled= true,
    maxMotorTorque = 1000,
    motorForce = 1,
    motorSpeed = 10,
    isLimitEnabled = false,
    rotationX = rect_0.x,
    rotationY = rect_0.y
  }

  self:_create(UI)

  local circle = display.newCircle(self.properties.anchor_x, self.properties.anchor_y, 10)
  circle:setFillColor(1, 0, 0)
  UI.sceneGroup:insert(circle)
end


return require("components.kwik.page_physicsJoint").set(M)