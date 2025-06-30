local name = ...
local parent,root, M = newModule(name)

function M:setValue(UI, command, model, selected)

  self:destroy()
  --
  self.command           = command -- animation
  self.model             = model
  self.selectedText.text = command -- audio, animation, image ...
  -- print("action command", command)
  -- self.selectedTextValue = nil
  self.selectedIndex     = nil
  self.selectedObj       = nil
  self.objs           = {}
  ---
  if model then
    self:createTable(UI, selected)
  end
end

--
function M:toggle()
  -- self.triangle.tap()
  -- self.triangle.isVisible = self.scrollView.isVisible
  self.selectedText.isVisible  = self.scrollView.isVisible
end

function M:show()
  -- print("show")
  -- self.triangle.isVisible = true
  self.selectedText.isVisible  = true
  --
  if self.scrollView == nil  then return end
  self.scrollView.isVisible = true
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj.isVisible = true
    obj.rect.isVisible = true
  end
  -- print("", "show end")
end

function M:hide()
  -- print("hide")
  -- self.triangle.isVisible = false
  self.selectedText.isVisible  = false
  --
  if self.scrollView == nil  then return end
  self.scrollView.isVisible = false
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj.isVisible = false
    obj.rect.isVisible = false
  end
  -- print("", "hide end")
end

M.attachListener = function(instance)
	return setmetatable(instance, {__index=M})
end

function M:tap(obj, e)
  -- print(e.target.name)
  if e.numTaps == 2 then
    -- print("------double tap --------")
  else
    -- print("-----single tap------")
    if self.selectedObj ~= obj then
      if self.selectedObj then
        self.selectedObj.rect:setFillColor(0.8)
      end
      -- print("#####", self.text)
      self.selectedObj = obj
      -- self.selectedText.text =self.text
      self.selectedIndex = obj.index
      self.selectedObj.rect:setFillColor(0, 1, 0)
      --
      -- for k, v in pairs(self.params) do print("", k, v) end
      self.UI.scene.app:dispatchEvent {
        name = "editor.action.selectActionCommand",
        UI = self.UI,
        commandClass = self.command,
        index = obj.index,
        isNew = true
      }
    end
  end
  return true
end

--
return M