local M = {}
local current = ...
local parent,  root = newModule(current)

--
local App = require("Application")

local Props = {
  name = "asset",
  commandClass = "asset",
  anchorName = "selectAsset",
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
    local eventName =  "editor."..self.commandClass.."." .. entry.name
    if app.context.commands[eventName] == nil then
      app.context:mapCommand(
        eventName,
        "editor.asset.controller." .. entry.name
      )
    end
  end
end

function M:create(UI)
  M:_create(UI)
  --UI.editor.audioEditor:insert(self.group)
  self.group:toFront()
  self:hide()
end

return M
