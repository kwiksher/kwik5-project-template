local M = {
  name = "rect_0",
  class="body",
  dataPath = NIL, -- physicsEdtior(CodeAndWeb)
  dataShape ={}
}
function M:create(UI)
  local rect_0 = UI.sceneGroup["rect_0"]
  self.properties = {
    bounce = 1,
    density = 1,
    friction = 1,
    gravityScale = 1,
    isSensor = true,
    radius = NIL, -- NIL means use object width/2
    shape   ="rectangle", -- "circle", -- rectangle,  path
    type = "static", -- kinematic, static, dynamic
  }
  self:_create(UI)

end
return require("components.kwik.layer_physicsBody").set(M)
