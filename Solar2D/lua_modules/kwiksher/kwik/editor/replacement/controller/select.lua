local name = ...
local parent, root = newModule(name)

local listPropsTable = require(root.."listPropsTable")
local listButtons = require(root.."listButtons")
local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    print(name, params.index)
    listPropsTable:setValue(params)
    listButtons.index = params.index
    listButtons:show()
    buttons:hide()
  end
)
--
return instance
