local name = ...
local parent,root = newModule(name)
local basePropsControl = require(kwikGlobal.ROOT.."editor.parts.basePropsControl")
local json = require("json")
local util = require(kwikGlobal.ROOT.."editor.util")

local function getModel(params)
  return util.copyTable(params, true)
  --[[
  local model = {}
  for k, v in pairs(params) do
    if not basePropsControl.filter(k) then
      if k== "properties" then
        model[k] = util.copyTable(v)
        -- for key, value in pairs(v) do
        --   --print(key, value, type(value),  #value)
        --   if type(value) == "table" and #value == 0 then
        --     model[k][key] = "NIL"
        --   else
        --     model[k][key] = value
        --   end
        -- end
      else
        model[k] = v
      end
    end
  end
  return model
  --]]
end

local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI    = params.UI
    local props = params.props

    local layer= UI.editor.currentLayer
    local selections = UI.editor.selections or {layer}
    local class= props.class
    print(layer, #selections, class)
    --
    local clipboard = UI.editor.clipboard
    local data, components = {}, {}
    --- these are tables in index.lua
    components.layers = {} -- if a class is copied, this layers table holds the class properties
    components.audios = {}
    components.groups = {} -- if a class of group is copied, this groups table holds the class properties
    components.timers = {}
    components.variables = {}
    components.joints = {}
    components.page = {}
    data.components = components
    data.book = UI.book
    data.page = UI.page
    data.class = props.class -- if not nil, components.layers have a class's model.

    for i, v in next, selections do
      local params, model
      if props.class =="audio" then
        params = require("App."..UI.book..".components."..UI.page..".audios."..v.subclass.."."..v.audio)
        model = getModel(params)
        table.insert(components.audios, model)
      elseif UI.editor.currentType =="group" then
        -- printKeys(v)
        data.type = "group"
        if props.class:len() > 0  then
          -- print("group class", v.class)
          params = require("App."..UI.book..".components."..UI.page..".groups."..v.layer.."_"..v.class)
        else
          params = require("App."..UI.book..".components."..UI.page..".groups."..v.layer)
        end
        model = getModel(params)
        -- print(json.prettify(model))
        table.insert(components.groups, model)
      elseif props.class =="timer" then
        params = require("App."..UI.book..".components."..UI.page..".timers."..v.timer)
        model = getModel(params)
        table.insert(components.timers, model)
      elseif props.class =="variable" then
        params = require("App."..UI.book..".components."..UI.page..".variables."..v.variable)
        model = getModel(params)
        table.insert(components.variables, model)
      elseif props.class =="joint" then
        params = require("App."..UI.book..".components."..UI.page..".joints."..v.joint)
        model = getModel(params)
        table.insert(components.joint, model)
      elseif props.class =="page" then
        table.insert(components.page, v.page)
      elseif props.class and props.class:len()>0 then -- layer's class like linear, button, sprite ..
        print("App."..UI.book..".components."..UI.page..".layers."..v.layer.."_"..v.class)
        params = require("App."..UI.book..".components."..UI.page..".layers."..v.layer.."_"..v.class)
        model = getModel(params)
        table.insert(components.layers, model)
      elseif v.layer then -- class == nil
        params = require("App."..UI.book..".components."..UI.page..".layers."..v.layer)
        model = getModel(params)
        table.insert(components.layers, model)
      end
    end
    UI.editor.clipboard:save(data)
  end)
--
return instance