local AC = require("commands.kwik.actionCommand")
--
local command = function (params)
	local UI    = params.UI
  print("actionCommand.cancel")
  UI.editor.actionEditor:hideCommandPropsTable(true)
  UI.editor.actionEditor:show()
--
end
--
local instance = AC.new(command)
return instance
