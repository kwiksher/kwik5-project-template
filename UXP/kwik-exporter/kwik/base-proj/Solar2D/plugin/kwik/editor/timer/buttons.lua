local M = {}
local current = ...
local parent,root = newModule(current)
local actionEditor = require(kwikGlobal.ROOT.."editor.action.index")
--
local App = require("Application")

local Props = {
  name = "timer",
  commandClass = "timer",
  anchorName = "selectTimer",
  model = {
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
      "editor.timer.controller." .. entry.name
    )
  end
end

function M:create(UI)
  M:_create(UI)
  --UI.editor.groupEditor:insert(self.group)
  self.group:toFront()
  self:hide()
  --
  actionEditor:addToogleButton(self)
end

return M
