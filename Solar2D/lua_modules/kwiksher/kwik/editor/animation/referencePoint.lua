local M= require(kwikGlobal.ROOT.."editor.parts.baseProps").new({width=50})
M.name = "referencePoint"
--
local header = display.newText("Reference Point", 0, 0, native.systemFont, 10)
--
header:addEventListener("tap", function()
  if M.group.isVisible then
    M:hide(header)
  else
    M:show(header)
  end
  header.isVisible = true
end)

function M:setActiveProp(layer)
  print("activeProp", self.class, class, self.activeProp, layer)
  local name = self.activeProp
  local value = layer
  local UI = self.UI
  --
  if self.activeProp == "referencePoint" then
    local obj = self:getObj(name)
    obj.field.text = value
    self.value = value
    return true
  end
end

-- function M:getValue()
--   local ret = {}
--   return ret
-- end

function M:create(UI)
  -- print("@@create", self.name)
  -- if self.group == nil then
    self.UI = UI
    if UI.editor.currentLayer then
      self.targetObject = UI.sceneGroup[UI.editor.currentLayer]
    end
    --
    self.group = display.newGroup()
    UI.editor.viewStore.propsTable = self.group
    --
    header.x, header.y = self.x, self.y
    header.anchorX = 0.5
    header.anchorY = 0.3

    header.isVisible = true
    -- self.group:insert(header)
  --
  if self.props then
    self:createTable(self.props)
  else
    -- print("no props")
    header.isVisible = false
  end
end

function M:show(skip)
  -- print("show", self.name)
  if self.objs == nil or #self.objs == 0 then
    header.isVisible = true
    return
  end
  for i=1, #self.objs do
    self.objs[i].isVisible = true
    if self.objs[i].rect then
      self.objs[i].rect.isVisible = true
    end
    if self.objs[i].field then
      self.objs[i].field.isVisible = true
    end
    if self.objs[i].actionbox then
      self.objs[i].actionbox:show()
    end
  end
  self.group.isVisible = true
  self.isVisible = true
  header.isVisible = true

  if skip == nil then
    -- self:hide(true)
  end

end

function M:hide(skip)
  -- print("hide", self.name)
  -- print(debug.traceback())
  if self.objs == nil then return end
  for i=1, #self.objs do
    self.objs[i].isVisible = false
    if self.objs[i].rect then
      self.objs[i].rect.isVisible = false
    end
    if self.objs[i].field then
      self.objs[i].field.isVisible = false
    end
    if self.objs[i].actionbox then
      self.objs[i].actionbox:hide()
    end
  end
  self.group.isVisible = false
  self.isVisible = false
  if skip == nil then
    header.isVisible = false
  end
end

return M