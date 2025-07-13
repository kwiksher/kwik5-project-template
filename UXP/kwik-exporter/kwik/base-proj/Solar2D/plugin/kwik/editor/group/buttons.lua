local current = ...
local parent,  root, M = newModule(current)
--
local App = require("Application")

local Props = {
  name = "group",
  commandClass = "group",
  anchorName = "selectGroup",
  model = {
      {name="add",   label="->"},
      {name="remove",   label="<-"},
      {name="save",   label="Save"},
      {name="cancel", label="Cancel"}}
}

local M = require(root.."parts.baseButtons").new(Props)

function M:init(UI, x, y)
  self.objs = {}
  self.x = x
  self.y = y
  local app = App.get()
  for i = 1, #self.model do
    local entry = self.model[i]
    app.context:mapCommand(
      "editor."..self.commandClass.."." .. entry.name,
      "editor.group.controller." .. entry.name
    )
  end
end

function M:create(UI)
  M:_create(UI)
  self.model[1].obj.x = self.x -220
  self.model[1].obj.y = self.y + 30
  self.model[1].obj.rect.x = self.x + -220
  self.model[1].obj.rect.y = self.y+ 30
  self.model[2].obj.x = self.x + 220
  self.model[2].obj.y = self.y + 30 -- self.model[1].obj.height
  self.model[2].obj.rect.x = self.x + 220
  self.model[2].obj.rect.y = self.y+ 30
  self.group:toFront()
  self:hide()
end

return M
