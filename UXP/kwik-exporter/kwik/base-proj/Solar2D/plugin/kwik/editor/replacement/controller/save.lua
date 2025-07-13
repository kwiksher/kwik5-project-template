local name = ...
local parent, root = newModule(name)
local listPropsTable = require(root.."listPropsTable")
local listbox = require(root.."listbox")
local listButtons = require(root.."listButtons")
local previewPanel = require(root.."previewPanel")
local textProps    = require(root.."textProps")

local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")
local json = require("json")
--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local type = listPropsTable.model.type
    print(name, params.index)
    local ret = listPropsTable:getValue()
    print (type, json.encode(ret))
    -- update
    print ("@@", json.encode(listbox.value[params.index]))
    listbox.value[params.index] = ret
    listbox:destroy()
    listbox:setValue()
    listButtons:hide()
    listPropsTable:hide()
    buttons:show()

    previewPanel:hide()
    textProps:show()

  end
)
--
return instance
