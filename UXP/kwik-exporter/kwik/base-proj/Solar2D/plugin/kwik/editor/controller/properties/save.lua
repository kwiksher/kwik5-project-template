local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require("Application")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local util = require(kwikGlobal.ROOT.."editor.util")
local yaml = require("server.yaml")

--
local useJson = false
--
local command = function (params)
	local UI    = params.UI

  print("parts.save", UI.editor.currentTool.name)
  local _props = UI.editor.currentTool:getValue()
  local props = {
    randXStart  = "NIL",
    randXEnd    = "NIL",
    randYStart  = "NIL",
    randYEnd    = "NIL",
    --,
    xScale     = "NIL",
    yScale     = "NIL",
    rotation   = "NIL",
    --,
    layerAsBg     = "NIL",
    isSharedAsset = "NIL",
  }
  print(json.prettify(_props))

  for k, v in pairs(_props) do
    print("", v.name, v.value)
    if v.name == "color" then
      if type(v.value) == "table" then
        -- printKeys(v.value)
        props.fill = {r= tonumber(v.value[1])/255, g=tonumber(v.value[2])/255, b=tonumber(v.value[3])/255, a=(tonumber(v.value[4]) or 1)}
      elseif type(v.value) =="string" then
        local nums = util.split(v.value, ',')
        props.fill = {r= tonumber(nums[1])/255, g=tonumber(nums[2])/255, b=tonumber(nums[3])/255, a=(tonumber(nums[4]) or 1)}
      end
    elseif v.name == "infinity" then
      props[v.name] = yaml.evalTable(v.value)
    elseif v.name == "_height" then
      props.height =v.value
    elseif v.name == "_width" then
      props.width =v.value
    else
      props[v.name] = v.value
    end

  end

  print(json.prettify(props))

  local updatedModel = util.createIndexModel(UI.scene.model)
  local controller = require(kwikGlobal.ROOT.."editor.controller.index")

  if props.shapedWith then
    scripts.publish(UI, {
      book=UI.editor.currentBook, page=UI.editor.currentPage or UI.page,
      updatedModel = updatedModel,
      layer = props.name,
      class = props.shapedWith or "properties", -- rectangle,text, image, ellipse
      props = props},
      controller)
  else
    scripts.publishForSelections(UI, {
        book=UI.editor.currentBook, page=UI.editor.currentPage or UI.page,
        updatedModel = updatedModel,
        layer = props.name,
        class = props.shapedWith or "properties", -- rectangle,text, image, ellipse
        props = {properties = props}
      },
      controller, {})
  end

  UI.editor.currentTool = nil
--
end
--
local instance = AC.new(command)
return instance
