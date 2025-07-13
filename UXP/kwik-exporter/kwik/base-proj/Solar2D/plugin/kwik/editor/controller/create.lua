local name = ...
local parent, root = newModule(name)
local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")
local picker = require(kwikGlobal.ROOT.."editor.picker.name")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    print(name)
    if params.props and params.props.book then
      print("create book")
      local listener = function(_book)
        print(_book)
        if _book and _book:len() > 0 then
          --scripts.backupFiles(src)
          scripts.createBook(_book) -- _dst == Solar2D
        else
          print("user cancel")
        end
        picker:destroy()
      end
      picker:create(listener, "Please input a book name")

    else
      if UI.useClassEditorProps then
        local props = UI.useClassEditorProps()
        for k, v in pairs(props) do
          print("", k, v)
        end
      end
      toolbar:toogleToolMap()
    end
    --
  end
)
--
return instance
