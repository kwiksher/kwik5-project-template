local physics = require("physics")

local M = {
  -- name = NIL, -- must be a layer name
  -- properties = {
  --   bounce = 0,
  --   density = 0,
  --   friction = 0,
  --   gravityScale = NIL,
  --   isFixedRotation = false,
  --   isSensor = false,
  --   radius = NIL,
  --   shape   = "rectangle", -- circle -- rectangle,  path
  --   type = "dynamic", -- dynamic, kinematic, static
  -- },
  -- dataPath = "", -- physicsEdtior(CodeAndWeb)
  -- dataShape = {}
}
--

function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layer       = UI.layer
  local curPage = UI.curPage
  local props = self.properties

  local obj = sceneGroup[self.name]
  --
  -- print("@@@@", self.name, props.shape)
  if props.shape == "circle" then
    local radius = props.radius
    if (props.radius == nil or props.radius == 0) then
      radius =  obj.width/2
    end
    physics.addBody(obj, props.type, {density=props.density, friction=props.friction, bounce=props.bounce, radius=radius })
  elseif props.shape == "rectangle" then
    physics.addBody(obj, props.type, {density=props.density, friction=props.friction, bounce=props.bounce })
  elseif props.shape == "path" then
    physics.addBody(obj, props.type, {density=props.density, friction=props.friction, bounce=props.bounce, shape=self.dataShape })
  else -- physicsEditor data
    if self.dataPath ~= NIL then
      local physicsData = require(self.dataPath).physicsData(1.0)
      physics.addBody(obj, physicsData:get(self.name))
    end
  end
  --
  if obj then
    obj.isSensor = props.isSensor
    obj.isFixedRotation = props.isFixedRotation
    --
    if props.gravityScale then
        obj.gravityScale = props.gravityScale
    end
  end
end

M._create = M.create
--
M.set = function(model)
  return setmetatable( model, {__index=M})
end

return M