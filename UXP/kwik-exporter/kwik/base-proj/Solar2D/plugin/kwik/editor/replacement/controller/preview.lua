local name = ...
local parent, root = newModule(name)
local listPropsTable = require(root.."listPropsTable")
local listbox = require(root.."listbox")
local listButtons = require(root.."listButtons")
local previewPanel = require(root.."previewPanel")
local buttons       = require(kwikGlobal.ROOT.."editor.parts.buttons")
local controller = require(root.."controller.index")
local json = require("json")
--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local type = listPropsTable.model.type
    if type == "sequenceData" then
      print(name, params.index)
      local ret = listPropsTable:getValue()
      print (type, json.encode(ret))
      print(name)
      print ("@@", json.encode(listbox.value[params.index]))
      --
      local props = controller:getClassEditorProps(UI)
      print ("----- classProps ---- /n", json.encode(props))

      props.sequenceData = {ret}
      previewPanel:show(UI, props)
    else
      print("not supported", type)
    end
  end
)
--
return instance

-- {"loopDirection":"forward","pause":"","count":4,"time":600,"start":5,"frames":"","name":"tile_02"}
-- {"properties":{"_filename":"sprites/SpriteTiles/sprites.png","numFrames":64,"_width":50,"_height":50,"sheetContentWidth":800,"sheetContentHeight":200,"sheetInfo":""}