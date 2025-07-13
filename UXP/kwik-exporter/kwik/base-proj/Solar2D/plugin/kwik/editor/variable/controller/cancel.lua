local name = ...
local controller   = require(kwikGlobal.ROOT.."editor.variable.index").controller
--
local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI    = params.UI
    print(name)
    controller:hide()
    local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")
    toolbar:hideToolMap()
    toolbar.selection = nil
    UI.editor.currentTool = nil

  end
)
--
return instance