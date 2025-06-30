local name = ...
local parent, root = newModule(name)
local util = require(kwikGlobal.ROOT.."editor.util")
local json = require("json")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
--
-- save command performs on one entry.
-- If user switch to another entry without saving, the previous change will be lost.
--
local function printParams(params)
  print("-----decoded-----")
  if params.decoded and type(params.decoded) == 'table' then
    for k, v in next, params.decoded do print(k, json.encode(v)) end
  else
    print(params.decoded)
  end
  print("-----props---------")
  for k, v in pairs(params.props) do
    if k =="properties" then
      print("properties")
      for kk, vv in pairs(v) do print("", kk, vv) end
    else
      print(k, v)
    end
   end
end
-------------------
--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local props = params.props
    if props == nil then print("Error") return end

    local class = params.class
    if class == nill then
      class = UI.editor.currentClass
    end

    local suffix = params.suffix
    if suffix == nill then
      suffix = UI.editor.currentClassSuffix
    end

    local mod = UI.editor:getClassModule(class or "properties") or {controller = require(kwikGlobal.ROOT.."editor.controller.index")}
    local controller = mod.controller -- each tool.contoller can overide render/save. So page tools of audio, group, timer should use own render/save
    if props.shapedWith then
      -- print("new layer")
      local layer = props.name
      local updatedModel = util.createIndexModel(UI.scene.model)
      local index = params.index or #updatedModel.components.layers + 1
      if not props.isMove then
        local newLayer = {name=props.name}
        -- layer = newLayer
        table.insert(updatedModel.components.layers, index, newLayer)
        -- print(json.prettify(updatedModel))
      end
      -- local controller = require(kwikGlobal.ROOT.."editor.controller.index")
      scripts.publish(UI, {
        book=UI.editor.currentBook, page=UI.editor.currentPage or UI.page,
        updatedModel = updatedModel,
        layer = layer,
        class = props.shapedWith or class, -- rectangle,text, image, ellipse
        suffix = suffix,
        props = props},
        controller)
    else
      for k, v in pairs(controller:useClassEditorProps(UI)) do
        -- if type (v) == "table" then
        --   print(k, json.prettify(v))
        -- else
        --   print(k, v)
        -- end
        props[k] = v
      end

      local layer = props.layer or UI.editor.currentLayer
      if layer == nil then
        layer = props.name
        -- print("layer", layer, class)
      else
        -- print("layer", props.name, layer, class)
      end

      if not props.isNew then
        scripts.publishForSelections(UI, {
          book= props.book, page=props.page,
          layer = layer,
          class = class,
          suffix = suffix,
          props = props}, controller, params.decoded or {})
      end

    end
    --  local tmplt = params.UI.page ..
    --  local dst =
    --  util.render(tmplt, props, dst)
  end
)
--
return instance

-- new button
-- App/bookFree/canvas/components/layers/butBlue_button.lua
-- App/bookFree/canvas/models/butBlue_bbutton.json
--
-- new action
-- App/bookFree/canvas/commands/blueBTN.lua
-- App/bookFree/canvas/models/commands/blueBTN.json
-----props---------
--  properties
        --  duration        3000
        --  delay   0
        --  name
--  actionName
--  name    btn_1
--  index   1
--  isNew   true
--  class   button
--  page    canvas
--  layer   butWhite


--[[
  templates
  - pageX/layer/layer_image.lua
  - pageX/interactions/layer_button.lua
  - pageX/animations/layer_animation.lua
--]]

--[[ do multiple interactions work at the same time?
  butBlue_bbutton.json
  [{
    "properties": {
      "delay": 0,
    },
    "class": "button",
    "name": "butBlueB",
    "layerOptions": {
      "referencePoint": "Center",
      "deltaX": 0,
      "deltaY": 0
    }
  },
  {
    "properties": {
      "delay": 0,
    },
    "class": "drag",
    "name": "butBlueD",
    "layerOptions": {
      "referencePoint": "Center",
      "deltaX": 0,
      "deltaY": 0
    }
  }]
--]]