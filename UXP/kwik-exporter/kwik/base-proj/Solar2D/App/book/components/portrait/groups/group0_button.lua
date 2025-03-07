local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps
local M = {
  name ="group0_button",
  properties = {
    target = "group0",
    type  = "group",
    eventType = "tap",  -- tap, touch
    over = "NIL",
    btaps = 1,
    mask = "NIL",
  },
  actions={
    onTap = ""
  },
  -- buyProductHide =
  -- product       =
  -- TV =
  layerProps = layerProps
}
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local obj =  self:createButton(UI)
  UI.layers[self.properties.target] = obj
  sceneGroup[self.properties.target] = obj
  sceneGroup:insert(obj)
  self.obj = obj
end
function M:didShow(UI)

  function self.obj:tap(event)
    print("tap")
  end
  self:addEventListener(UI)
end
function M:didHide(UI)
  self:removeEventListener(UI)
end
return require("components.kwik.layer_button").set(M)
