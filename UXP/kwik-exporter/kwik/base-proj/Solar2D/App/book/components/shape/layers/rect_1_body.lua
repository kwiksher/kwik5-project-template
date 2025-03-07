local M = {
  name = "rect_1",
  class="body",
  dataPath = NIL, -- physicsEdtior(CodeAndWeb)
  dataShape ={}
}
function M:create(UI)
  local rect_1 = UI.sceneGroup["rect_1"]
  self.properties = {
      bounce = 1,
      density = 1,
      friction = 1,
      gravityScale = 1,
      isSensor = false,
      radius = 0, -- NIL means use object width/2
      shape   ="rectangle", -- "circle", -- rectangle,  path
      type = "dynamic", -- kinematic, static, dynamic
  }
  self:_create(UI)
end
return require("components.kwik.layer_physicsBody").set(M)
