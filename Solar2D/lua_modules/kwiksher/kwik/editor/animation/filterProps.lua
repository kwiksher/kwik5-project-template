local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new({width = 50})
M.name = "filterProps"
M.marginFieldX = -10

local util = require(kwikGlobal.ROOT.."lib.util")
local basePropsControl = require(kwikGlobal.ROOT.."editor.parts.basePropsControl")

local yaml = require("server.yaml")
local stringSet = table:mySet {"_effect", "_type", "paint1", "paint2", "folder"}
local colorSet =
  table:mySet {"color", "darkColor", "lightColor", "color1", "color2", " dirLightColor", " pointLightColor"}
--
local header = display.newText("transition.to", 0, 0, native.systemFont, 10)
header:addEventListener(
  "tap",
  function()
    if M.group.isVisible then
      M:hide(header)
    else
      M:show(header)
    end
    header.isVisible = true
  end
)

local json = require("json")
local path =
  system.pathForFile(kwikGlobal.PATH.."template/components/pageX/animation/defaults/filters.json", system.ResourceDirectory)
local file, errorString = io.open(path, "r")
local contents = file:read("*a")
io.close(file)
--
local data = json.decode(contents)
--

function M:setActiveProp(layer, class)
  -- print(layer, class)
  if layer == nil then return end
  for i, obj in next, self.objs do
    if obj.text == self.activeProp then
      obj.field.text = layer..".png"
      break
    end
  end
end

function M.getFilterParams(name)
  for i, v in next, data do
    if v.name == name then
      -- for k, v in pairs(v.params) do print(k, v) end
      return v.params
    end
  end
end

local option, newText, newTextField = M.option, M.newText, M.newTextField

function M:createTable(props, propsTo)
  local UI = self.UI
  local objs = {}
  local alphaObj, imageObj

  option.parent = self.group

  for i = 1, #props do
    local prop = props[i] or {}
    option.text = prop.name or ""
    --print("@@ parts.baseProps",i, prop.name, prop.value)
    option.x = self.x
    option.y = i * (self.height or option.height) + self.y
    -- print(self.group, option.x, option.y, option.width, option.height)
    local rect =
      display.newRect(self.group, option.x, option.y, self.width or option.width, (self.height or option.height))
    rect:setFillColor(1)

    option.x = self.x + 2
    option.height = (self.height or option.height)
    option.width = self.width or option.width
    local obj = newText(option)
    obj.rect = rect
    objs[#objs + 1] = obj
    -- show asset table
    -- print("", prop.name)
    if prop.name == "_effect" then
      obj:addEventListener(
        "tap",
        function(event)
          self:tapListener(event, "filters")
        end
      )
    elseif prop.name == "color" or prop.name:find("color")  then -- or prop.name == "imageFile"
      -- obj.fieldAlpha = alphaObj.field
      imageObj = obj
      obj.targetObject = self.targetObject
      obj.page = "*" .. UI.page .. "*"
      obj:addEventListener(
        "tap",
        function(event)
          self:tapListener(event, "color")
        end
      )
    elseif prop.name == "paint1" or prop.name == "paint2" then
      local layerTable = require(kwikGlobal.ROOT.."editor.parts.layerTable")
      layerTable.classProps = M
      obj:addEventListener("tap", function(event)
        self.activeProp = event.target.text
        self:tapListener(event, 'layer')
      end)
    end
    -- Edit
    option.x = rect.x + rect.width / 2
    option.y = rect.y
    if type(prop.value) == "boolean" then
      option.text = tostring(prop.value)
    else
      option.text = prop.value
    end
    --
    local objField = newTextField(option)
    obj.field = objField
    --
    if propsTo and #propsTo >= i   then
      if type(prop.value) == "boolean" then
        option.text = tostring(propsTo[i].value)
      else
        option.text = propsTo[i].value
      end
    end
    -- TO
    if  not stringSet[prop.name] then
      obj.field.width = obj.field.width/2
      option.x = rect.x + rect.width / 2 + option.width/2
      local objFieldTo = newTextField(option)
      obj.fieldTo = objFieldTo
      objFieldTo.width = obj.field.width
      self.group:insert(objFieldTo)
    end

    self.group:insert(objField)
    self.group:insert(obj.rect)
    self.group:insert(obj)
  end

  -- set alpha obj to color.fieldAlpha
  for i, obj in next, objs do
    -- print(obj.text)
    if obj.text == "color" then
      if alphaObj then
        obj.fieldAlpha = alphaObj.field
      end
    end
    if obj.text == "imageFolder" then
      if imageObj then
        imageObj.imageFolder = obj
      end
    end
  end

  self.objs = objs
end

function M:create(UI)
  -- print("@@create", self.name)
  -- if self.group == nil then
  self.UI = UI
  if UI.editor.currentLayer then
    self.targetObject = UI.sceneGroup[UI.editor.currentLayer]
  end
  --
  self.group = display.newGroup()
  UI.editor.viewStore.propsTable = self.group
  --
  header.x, header.y = self.x + 100, self.y
  header.anchorX = 0
  header.anchorY = 0.3

  header.isVisible = true
  -- self.group:insert(header)
  --
  if self.props then
    local addSetValue
    local setValue = function(obj, value)
      obj.field.text = value
      local params = M.getFilterParams(value)
      local entries = util.split(value, ".")
      if entries[1] == "composite" then
        M:setValue({params = params, effect = entries[2], type = entries[1], paint1 = NIL, paint2 = NIL, folder = NIL})
      else
        M:setValue({params = params, effect = entries[2], type = entries[1]})
      end
      M:destroy()
      M:createTable(M.props)
      addSetValue()
    end

    addSetValue = function()
      for i, obj in next, M.objs do
        if obj.text == "_effect" then
          obj.setValue = setValue
          break
        end
      end
    end
    self:createTable(self.props, self.propsTo)
    addSetValue()
  else
    -- print("no props")
    header.isVisible = false
  end
end

function M:getValue()
  local props = {}
  local propsTo = {}
  if self.objs == nil then return end
  for i, obj in next, self.objs do
    local value = obj.field.text
    local valueTo
    local key = obj.text
    if colorSet[key] then -- from
      value = yaml.eval("[ " .. value .. " ]")
      value = {value[1] / 255, value[2] / 255, value[3] / 255, value[4]}
      --
      valueTo =  obj.fieldTo.text
      valueTo = yaml.eval("[ " .. valueTo .. " ]")
      valueTo = {valueTo[1] / 255, valueTo[2] / 255, valueTo[3] / 255, valueTo[4]}
    elseif value:find(",") then
      value = yaml.eval("[ " .. value .. " ]")
      --
      valueTo =  obj.fieldTo.text
      valueTo = yaml.eval("[ " .. valueTo .. " ]")
    elseif not stringSet[key] then
      value = tonumber(value)
      --
      valueTo =  obj.fieldTo.text
      valueTo = tonumber(valueTo)
    end
    props[#props + 1] = {name = obj.text, value = value}
    if valueTo then
      propsTo[#propsTo + 1] = {name = obj.text, value = valueTo}
    end
  end
  return props, propsTo
end

-- "levels", "blur.vertical","blur.horixaontal" "add"
-- "vertical", "horizontal"

local function getFlatten(name, value, fooValue)
  local _name = name:sub(2)
  if colorSet[_name] then
    return {name = _name, value = basePropsControl._yamlValue("color", value)}
  else
    return  {name = _name, value = basePropsControl._yamlValue(_name, value, fooValue)}
  end
end

function M:setValue(fooValue)
  local props, propsTo = {}, {}
  local _fooValue = fooValue or {}
  -- local properties = _fooValue.properties or _fooValue
    -- printKeys(properties)
  --
  for k, v in pairs(_fooValue) do
    -- print(k, json.encode(v))
    --
    if not basePropsControl.filter(k) then
      local prop
      if k == "params" then
        local entries = util.flattenKeys(nil, v)
        for name, value in pairs(entries) do
          -- print("", name:sub(2), value)
          -- print("","", prop.value)
          prop = getFlatten(name, value, _fooValue)
          props[#props + 1] = prop
          propsTo[#propsTo + 1] = prop
        end
      elseif k == "from" then
        local entries = util.flattenKeys(nil, v)
        for name, value in pairs(entries) do
          prop = getFlatten(name, value, _fooValue)
          props[#props + 1] = prop
        end
      elseif k == "to" then
        local entries = util.flattenKeys(nil, v)
        for name, value in pairs(entries) do
          prop = getFlatten(name, value, _fooValue)
          propsTo[#propsTo + 1] = prop
        end
      elseif k == "effect" then
        prop = {name = "_effect", value = basePropsControl._yamlValue(k, v, _fooValue)}
        props[#props + 1] = prop
        propsTo[#propsTo + 1] = prop
      elseif k == "type" then
        prop = {name = "_type", value = basePropsControl._yamlValue(k, v, _fooValue)}
        props[#props + 1] = prop
        propsTo[#propsTo + 1] = prop
      elseif k == "paint1" then
        local UI = M.UI
        prop = {name = k, value = UI.editor.currentLayer..".png"}
        props[#props + 1] = prop
      elseif k == "folder" then
        local UI = M.UI
        prop = {name = k, value = "images/"..UI.page}
        props[#props + 1] = prop
      else
        prop = {name = k, value = basePropsControl._yamlValue(k, v, _fooValue)}
        props[#props + 1] = prop
      end
    end
  end
  --
  --
  util.sortProps(props)
  ---
  self.props = props
  ---
  if propsTo and #propsTo > 0 then
    util.sortProps(propsTo)
  end
  self.propsTo = propsTo
  --
  -- print(json.prettify(self.props))
  -- print(json.prettify(self.propsTo))

end

function M:show(skip)
  -- print("show", self.name)
  if self.objs == nil or #self.objs == 0 then
    header.isVisible = false
    return
  end
  for i = 1, #self.objs do
    self.objs[i].isVisible = true
    if self.objs[i].rect then
      self.objs[i].rect.isVisible = true
    end
    if self.objs[i].field then
      self.objs[i].field.isVisible = true
    end
    if self.objs[i].fieldTo then
        self.objs[i].fieldTo.isVisible = true
    end
    if self.objs[i].actionbox then
      self.objs[i].actionbox:show()
    end
  end
  self.group.isVisible = true
  self.isVisible = true
  header.isVisible = true

  -- if skip == nil then
  --   self:hide(true)
  -- end
end

function M:hide(skip)
  -- print("hide", self.name)
  -- print(debug.traceback())
  if self.objs == nil then
    return
  end
  for i = 1, #self.objs do
    self.objs[i].isVisible = false
    if self.objs[i].rect then
      self.objs[i].rect.isVisible = false
    end
    if self.objs[i].field then
      self.objs[i].field.isVisible = false
    end
    if self.objs[i].fieldTo then
        self.objs[i].fieldTo.isVisible = false
    end
    if self.objs[i].actionbox then
      self.objs[i].actionbox:hide()
    end
  end
  self.group.isVisible = false
  self.isVisible = false
  if skip == nil then
    header.isVisible = false
  end
end

function M:destroy()
  if self.objs then
    for i=1, #self.objs do
      if self.objs[i].rect then
        self.objs[i].rect:removeSelf()
      end
      if self.objs[i].field then
        self.objs[i].field:removeSelf()
      end
      if self.objs[i].fieldTo then
        self.objs[i].fieldTo:removeSelf()
      end

      if self.objs[i].actionbox then
        self.objs[i].actionbox:destroy()
      end
      if self.objs[i].radioGroup then
        self.objs[i].radioGroup:removeSelf()
      end
      self.objs[i]:removeSelf()
    end
    self.objs = nil
  end

end

return M
