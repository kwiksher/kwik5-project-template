local parent,root, M = newModule(...)
local util = require(kwikGlobal.ROOT.."lib.util")
--
local _layerProps = {
  name = M.name,
}
--
function M:init(UI)
end
--
function M:create(UI)
  local layerProps = self.layerProps or _layerProps
  self.obj = util.getLayer(UI, layerProps.name)
  -- local classOption = self.classOption or "to"
  -- print("", self.name, self.classOption)
end
--
function M:didShow(UI)
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
