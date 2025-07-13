local name = ...
local parent, root = newModule(name)

local listPropsTable = require(root.."listPropsTable")
local listButtons = require(root.."listButtons")
local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")
local previewPanel = require(root.."previewPanel")
local textProps    = require(root.."textProps")


local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    print(name)
    listButtons:hide()
    listPropsTable:hide()
    buttons:show()
    previewPanel:hide()
    textProps:show()
  end
)
--
return instance
