local AC = require("commands.kwik.actionCommand")
--
local actionTable        = require(kwikGlobal.ROOT.."editor.action.actionTable")

local command = function (params)
	local UI    = params.UI
  print("action.cancel")
  UI.editor.actionEditor:hide(true)

  if actionTable.actionbox then
    --
    local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")
    local classProps    = require(kwikGlobal.ROOT.."editor.parts.classProps")
    buttons:show()
    classProps:show()
  end
--
end
--
local instance = AC.new(command)
return instance
