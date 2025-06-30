local M = {}
--
function M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  local layer = UI.layer
  local props = self.properties
  local layerName = props.body
  ---
  local obj = sceneGroup[layerName]
  --printKeys(obj)

  local function getOthers()
    if props.others and props.others:len() > 0 then
      local mod = require("App." .. UI.book .. ".components." .. UI.page .. ".groups." .. props.others)
      return mod.members
    end
    return {}
  end
  local others = getOthers()
  print("---------")
  for i, other in next, others do
    print("others", i, other)
  end
  print("---------")

  if obj == nil  or type(obj) == "string" then
    print("Error missing", layerName)
    return
  end


  local function onCollision(self, event)
    for i, other in next, others do
      local otherObj = sceneGroup[other]
      if event.phase == "began" and event.other.name == other then
        -- print("onCollision", event.other.name )
        if self.actions.onCollision then
          -- print("###", self.actions.onCollision)
          self.UI.scene.app:dispatchEvent{name =self.UI.page.."."..self.actions.onCollision, event = {obj = obj, other = otherObj}, UI = UI}
        end
        if props.isRemoveSelf then
          obj:removeSelf()
          sceneGroup[layerName] = nil
        end
        if props.isRemoveOther then
          otherObj:removeSelf()
          sceneGroup[other] = nil
        end
      end
    end
  end
  obj.collision = onCollision
  obj.actions = self.actions
  obj.UI      = UI
  obj:addEventListener("collision")
end
--
M.set = function(model)
  return setmetatable(model, {__index = M})
end

return M
