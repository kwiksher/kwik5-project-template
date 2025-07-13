local name = ...
local parent, root = newModule(name)
local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI    = params.UI
    UI.editor.currentTool:hide()
    local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")
    toolbar:hideToolMap()
    --
  end
)
--
return instance
