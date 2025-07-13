local AC = require("commands.kwik.actionCommand")
--
local actionCommandTable = require(kwikGlobal.ROOT.."editor.action.actionCommandTable")

local command = function (params)
	local UI    = params.UI
  print("actionCommand.delete")
  local actions = actionCommandTable.actions

  local updated = {name = UI.editor.currentAction.name , actions = {}}
  for i,v in next, actions do
    if i ~= UI.editor.currentActionCommandIndex then
      updated.actions[i] = v
    end
  end

  UI.editor.actionCommandStore:set(updated)
  UI.editor.actionEditor:hideCommandPropsTable(true)
  UI.editor.actionEditor:show()

  -- if UI.editor.selections then
  --   for i, obj in next, UI.editor.selections do
  --     print("", obj.index, obj.command)
  --   end
  -- end

--
end
--
local instance = AC.new(command)
return instance
