local current = ...
local parent,  root = newModule(current)
--
local json = require("json")

local M = require(kwikGlobal.ROOT.."editor.controller.index").new("replacement")
local previewPanel = require(root.."previewPanel")

local util = require(kwikGlobal.ROOT.."lib.util")
local yaml = require("server.yaml")


function M:init(viewGroup)
  self.viewGroup = viewGroup
  --
  self.selectbox      = viewGroup.selectbox
  self.classProps    = viewGroup.classProps
  self.actionbox = viewGroup.actionbox
  self.buttons       = viewGroup.buttons
  -- for sprite.sequenceData, sync.line
  self.listbox        = viewGroup.listbox
  self.listPropsTable = viewGroup.listPropsTable
  self.listButtons = viewGroup.listButtons

  self.audioProps = viewGroup.audioProps
  self.textProps  = viewGroup.textProps

  self.listButtons:init()
  --print(debug.traceback())
  --
  self.buttons.useClassEditorProps = function() return self:useClassEditorProps() end
  self.selectbox.useClassEditorProps = function() self:useClassEditorProps() end
  --
  self.selectbox.classEditorHandler = function(decoded, index)
    self:reset()
    self:setValue(decoded, index)
    self:redraw()
  end
end
-------
-- I/F
------
function M:show()
  -- don't show listbox, listPropsTavle, listButtons
  local viewGroup = {
    self.selectbox,
    self.classProps,
    self.actionbox,
    self.buttons,
    self.listbox,
    self.textProps,
    self.audioProps
  }
  for k, v in pairs(viewGroup) do
    v:show()
  end
  self.view.group.isVisible = true

end

function M:hide()
  for k, v in pairs(self.viewGroup) do
    v:hide()
  end
  if self.view.group then
    self.view.group.isVisible = false
  end
  --
  self.listbox:hide()
  self.listPropsTable:hide()
  self.listButtons:hide()
  previewPanel:hide()
  --
end

function M:getClassEditorProps(UI)
  -- print("useClassEditorProps")
  local props = {
    index = self.selectbox.selectedIndex,
    name = UI.editor.currentLayer, -- self.selectbox.selectedObj.text,
    class= UI.editor.currentClass, -- self.selectbox.selectedText.text,
    properties = {},
  }
  --
  local properties = self.classProps:getValue()
  for i=1, #properties do
    -- print("", properties[i].name, type(properties[i].value))
    props.properties[properties[i].name] = properties[i].value
  end
  props.book = UI.book

  -- onComplete
  if self.actionbox.isActive then
    props.actionName =self.actionbox.value
  end
  --
  -- TBI? listbox
  --
  return props
end

local numParams = table:mySet{"_height", "_width", "numFrames", "sheetContentWidth", "sheetContentHeight"}
--
-- local Prefix_Layers = require(kwikGlobal.ROOT.."editor.parts.baseProps").Prefix_Layers
--
function M:useClassEditorProps(UI)
  -- print("useClassEditorProps")
  local props = {
    book  = UI.book,
    index = self.selectbox.selectedIndex,
    layer = UI.editor.currentLayer, -- self.selectbox.selectedObj.text,
    class= UI.editor.currentClass, -- self.selectbox.selectedText.text,
    properties = {},
  }
  --
  local properties = self.classProps:getValue()
  local sheetType = "uniform-sized"
  for i=1, #properties do
    -- print("", properties[i].name, type(properties[i].value))
    -- props.properties[properties[i].name] = properties[i].value
    local name, value = properties[i].name, properties[i].value
    -- print(name, value)
    if numParams[name] and value == "" then
      value = 0
    end
    if name =="_height" then
      name = "height"
    elseif name == "_width" then
      name = "width"
    elseif name == "_filename" then
      name = "filename"
    elseif name == "sheetInfo" then
      if value:find(".lua") then
        sheetType = "TexturePacker"
      elseif value:find(".json") then
        sheetType = "Animate"
      end
    elseif name == "sheetType" and (value == NIL or value == "") then
      value = sheetType
    elseif name  == "color" then
      if type(value) == "table" then
        value = {r= tonumber(value[1])/255, g=tonumber(value[2])/255, b=tonumber(value[3])/255, a=(tonumber(value[4]) or 1)}
      else
        local nums = util.split(value, ',')
        value = {r= tonumber(nums[1])/255, g=tonumber(nums[2])/255, b=tonumber(nums[3])/255, a=(tonumber(nums[4]) or 1)}
      end
    elseif name == "marker" then
      value = yaml.evalTable(value)
    end

    props.properties[#props.properties+ 1] = {name = name, value = value}
  end

  if self.listbox.type == "sequenceData" then
    props.sequenceData = self.listbox:getValue()
    -- printKeys(props.sequenceData)
    for i, v in next, props.sequenceData do
      for key,value in pairs(v) do
        -- print(key, value, type(value))
        if ( key == "count" or key=="start" )  then
          props.sequenceData[i][key] = tonumber(value)
        end
      end
    end
  elseif self.listbox.type =="line" then -- this means sync (class == sync)
    props.line = self.listbox:getValue()
    props.textProps = self.textProps:getValue()
    props.audioProps = self.audioProps:getValue()
    props.onComplete =self.actionbox:getValue("onComplete")
  end
  return props
end

-- this handler should be called from self.selectbox to set one of animtations user selected
function M:setValue(decoded, index, template)
  if decoded == nil then print("## Error setValue ##") return end
  if not template then
    -- print("@", decoded[index].class)
    -- print(json.encode(decoded[index]))
    for k, v in pairs(decoded[index]) do print(k, v) end
    self.selectbox:setValue(decoded, index)  -- "linear 1", "rotation 1" ...
    self.classProps:setValue(decoded[index].properties)
    self.classProps.class = decoded[index].class
    if decoded[index].actionName then
      self.actionbox:setValue({name ="onCompplete", value = decoded[index].actionName})
      self.actionbox.isActive = true
    end
    -- for sprite.sequenceData, sync.line
    if decoded[index].sequenceData or decoded[index].line then
      local type = (decoded[index].sequenceData) and "sequenceData" or  "line"
      self.listbox:setValue(decoded[index].sequenceData or  decoded[index].line, type)
      self.listbox.isActive = true
    end

    if decoded[index].audioProps then
      self.audioProps:setValue(decoded[index].audioProps)
    end
    if decoded[index].textProps then
      self.textProps:setValue(decoded[index].textProps)
    end

    if decoded[index].class == "sprite" then
      local value = decoded[index].properties.filename
      self.classProps:showThumnail("sprites", value, "sprites")
      self.classProps.didShow = function(self, UI)
        self.activeProp = "sheetInfo"
        self:setActiveProp(value, "sprite")
      end
    end

  else
    self.selectbox:setTemplate(decoded)  -- "linear 1", "rotation 1" ...
    self.classProps:setValue(decoded.properties)
    self.classProps.class = decoded.class
    if decoded.actionName then
       self.actionbox:setValue({name = "onComplete", value=decoded.actionName})
        self.actionbox.isActive = true
    end
    if decoded.sequenceData or decoded.line then
      local type = (decoded.sequenceData) and "sequenceData" or  "line"
      self.listbox:setValue(decoded.sequenceData or  decoded.line, type)
      self.listbox.isActive = true
    end
    --
    if decoded.audioProps then
      self.audioProps:setValue(decoded.audioProps)
    end
    if decoded.textProps then
      self.textProps:setValue(decoded.textProps)
    end

    if decoded.class == "sprite" then
      local value = decoded.properties.filename
      self.classProps:showThumnail("sprites", value, "sprites")
      self.classProps.didShow = function(self, UI)
        self.activeProp = "sheetInfo"
        self:setActiveProp(value, "sprite")

      end
    end

  end
end

function M:mergeAsset(model, asset)
  -- print("mergreAsset", asset.path, asset.name, #asset.links)
  if model.class == "sprite" then
    model.properties.filename = "sprites/"..asset.name
  end
  -- for k, v in pairs(model.properties) do print("", k,v) end
  return model
end

return M