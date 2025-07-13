local M={}
local bt = require('btree')
local tree = require("selectorsTree")
--
-- each action comes from tree:onActionActivation()
--  if active && RUNNING
--
local actions = {
  {name = "load book", command=function(status)

    -- selectApp
    -- selectBook
    --
    UI.scene.app:dispatchEvent{
      name = "editor.selector." .. "selectBook",
      UI = self.UI, -- beaware UI is belonged to a page
      show = not event.isVisible
    }

    return bt.SUCCESS end},
  {name = "load page", command = function(status)
    return bt.SUCCESS end},
  {name = "load layer", command = function(status)
    return bt.SUCCESS end},
  {name = "editor props", command = function(status)
    return bt.SUCCESS end},
  {name = "editor component", command = function(status)
    return bt.SUCCESS end},
  {name = "copy", command = function(status)
    return bt.RUNNING end},
  {name = "paste", command = function(status)
      return bt.RUNNING end},
  {name = "hide", command = function(status)
    return bt.RUNNING end},
  {name = "preview", command = function(status)
    return bt.RUNNING end},
  {name = "save", command = function(status)
    return bt.RUNNING end},
  {name = "cancel", command = function(status)
    return bt.RUNNING end},
}

M.map = {}
--
for i=1, #actions do
  M.map[actions[i].name] = actions[i].command
end

M.handler = function(name, status)
  print(name,  bt.getFriendlyStatus( nil,status ))
  if M.map[name] == nil then print("ERROR: selectorsCommand can find ", name) end
  return M.map[name](status)
end

return M.handler