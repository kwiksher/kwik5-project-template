local parent,root, M = newModule(...)
--
local transition2 = require("transition2")

local _layerProps = {
  name = M.name,
  text = "hello my class",
}
--
function M:init(UI)
end
--
function M:create(UI)
end
--
function M:didShow(UI)
  local classOption = self.classOption or "to"
  -- print(self.name)
  -- for k, v in pairs(UI.sceneGroup) do print(k, v) end
  self.obj = UI.sceneGroup[self.name]
  for k, v in pairs(UI.layers) do print("", k) end
  if self.obj then
    -- print("@@@@@", self.obj.x, self.obj.y)
    transition2[classOption](self.obj, self.params or {x=10})
  end

end
--
function M:didHide(UI)
end
--
function M:destroy(UI)
end

function M:new(props)
  return self:newInstance(props, _layerProps)
end
--
return M
