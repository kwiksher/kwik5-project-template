local name = ...
local parent, root = newModule(name)
local listbox = require(root.."listbox")
local listButtons = require(root.."listButtons")
local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")
local listPropsTable = require(root.."listPropsTable")

--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    print(name, params.index)
    table.remove(listbox.value, params.index)
    listbox:destroy()
    listbox:setValue()
    -- select the last index
    if params.index == 1 then
      listbox.singleClickEvent(listbox.objs[1])
    else
      listbox.singleClickEvent(listbox.objs[params.index -1])
    end

    listPropsTable:hide()
    listButtons:hide()
    buttons:show()

  end
)
--
return instance
