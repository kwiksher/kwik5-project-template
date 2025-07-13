local name = ...
local parent,           root, M = newModule(name)
local baseProps        = require(kwikGlobal.ROOT.."editor.parts.baseProps")
local basePropsControl = require(kwikGlobal.ROOT.."editor.parts.basePropsControl")
local commandbox       = require(parent.."commandbox")
local util             = require(kwikGlobal.ROOT.."lib.util")
local json             = require("json")


M.groupName = "rootGroup"
-- M.x =  display.contentCenterX + 28 -- UI.editor.viewStore.actionCommandTable.left + UI.editor.viewStore.actionCommandTable.width -- commandbox.x + option.width/2
-- M.x = display.contentCenterX + 480/2
M.x = display.actualContentWidth -180
M.y =  22
M.width = 100
      -- commandbox.y  -- (display.actualContentHeight - display.contentHeight + option.height)/2

local option, newText = util.newTextFactory{
  x = 0,
  y = 100,
  width = M.width,
  height = 20
}


--
--- I/F ---
--

--[[
  local function _getValue(name, fieldText, currentValue)
    local _type = type(currentValue)
    local value = fieldText
    -- if name == "_target" then
    --   value = self.objs[i].linkbox.value
    -- end
    -- print("@", type(self.model.properties[i].value))
    if _type == 'boolean' then
      if value == nil or value == "" then
        value = currentValue
      end
      value = tostring(value)
    elseif  _type == 'number' then
      value = tonumber( value )
    end
    return value
  end
--]]

function M:getValue()
  -- print(json.encode(self.model))
  -- for k, v in pairs(linkbox) do print(k, v) end
  for i=1, #self.model.properties do
    if self.objs[i] == nil then break end
    -- print(self.model[i], self.objs[i].text, self.objs[i].field.text )
    self.model.properties[i].value = baseProps._getValue(self.model.properties[i].name, self.objs[i].field.text, self.model.properties[i].value)
  end
  if commandbox.selectedObj then -- create
    return self.model, commandbox.selectedObj.text
  else
    return self.model, commandbox.command
  end
end
--
function M:init(UI)
  -- self.linkbox = linkbox
end

--
function M:create(UI)
  -- if viewStore.actionCommandPropsTable then return end
  -- print("create", self.name)
  self.group = display.newGroup()
  UI.editor.viewStore.actionCommandPropsTable = self

  option.parent = self.group


    -- Create invisible background element for hiding the keyboard (when applicable)


  local newTextField = util.newTextField

  local function render(foo, props)
    M:didHide(UI)
    M:destroy()
    -- print("------- actionCommandPropsStore --------")
    local alphaObj = nil


    local posX = self.x
    -- print("#### commandbox.x", commandbox.x)
    -- local posY  = display.contentCenterY + 1280/4 * 0.5  +  (option.height)/2
    local posY  = self.y
    -- print("", debug.traceback())
    --
    for i=1, #props.properties do
      if props.properties[i].name == "target" then
        props.properties[i].name = "_target"
      end
    end
    --
    util.sortProps(props.properties)
    ---
    local objs = {}
    for i=1, #props.properties do
      local entry = props.properties[i]
      option.text = entry.name
      option.x = posX
      option.y = i*option.height + posY
      option.text = entry.name
      local rect = display.newRect(option.parent, option.x, option.y, option.width*1.2, option.height)
      rect:setFillColor(1)
      --
      local obj
      obj = newText(option)
      obj.rect = rect
      obj.anchorY = 0.25
      objs[#objs + 1] = obj

      -- Edit
      --[[
        if entry.name == "_target" then
          linkbox:load(UI, props.type, obj.x + obj.width, obj.y - obj.height/4, entry.value)
          obj.linkbox = linkbox
        else
          option.x = posX + option.width
          option.text = entry.value
          --
          obj.field = newTextField(option)
        end
      --]]
      if entry.name == "_target" then
        M.activeProp = entry.name
        -- print("commandbox.command", commandbox.command)
        if basePropsControl.CommandForTapSet[commandbox.command] then
          obj:addEventListener("tap", function(event) basePropsControl.handler[commandbox.command](event) end)
        else -- layer
          obj:addEventListener("tap", function(event) basePropsControl.handler.layer(event) end)
        end
      elseif entry.name == "pageName" then -- this is gotoScene, command: "page.pageName"
        -- M.activeProp = entry.name
        print("commandbox.command", commandbox.command)
        obj:addEventListener("tap", function(event)
          M.activeProp = event.target.text
          basePropsControl.handler["pageName"](event)
        end)
      elseif entry.name == "effect" then -- this is gotoScene, command: "page.effect"
        -- M.activeProp = entry.name
        print("commandbox.command", commandbox.command)
        obj:addEventListener("tap", function(event)
          M.activeProp = event.target.text
          basePropsControl.handler["pageEffect"](event)
        end)
      elseif entry.name == "alpha" then
        alphaObj = obj
      elseif entry.name == "color" then
        if alphaObj then
          obj.fieldAlpha = alphaObj.field
        end
        obj:addEventListener("tap", function(event) basePropsControl.handler.color(event) end)
      end
      option.x = posX + option.width
      local value = entry.value
      if type(value) == "boolean" then value = tostring(value) end
      option.text = basePropsControl._yamlValue(entry.name, value)
      obj.field = newTextField(option)
      ---

      -- objs[#objs + 1] = obj
      -- obj.page = props.name
      -- obj.tap = commandHandler
      -- obj:addEventListener("tap", obj)
      --
      -- TBI set value to obj.field for some special cases
      --   animation.playAll
      --     read all animations, xxx_linear, yyy_bounce ...

    end
    self.objs = objs
    self.model = props

    self.group:toFront()
  end
    --
    --
    --------
    -- save
    --[[

    local map = {}
    local objs = tableHelper:getTextFields()
    for i=1, #objs do
      print(" "..i..":", objs[i].text)
      models[i].value = objs[i].text
      map[models[i].name] = objs[i].text -- TODO tonumber?
    end
    local tmplt = UI.appFolder.."/../../templates/components/layer_props"
    local path = UI.currentPage.path .."/"..UI.currentLayer.name.."_props"
    util.renderer(tmplt, path, map)
  --]]
  --
  UI.editor.actionCommandPropsStore:listen(render)
  -- viewStore.actionCommandPropsTable.group:translate(-100, 0)

  if system.orientation == "portrait" then
    -- local delta_x = 400
    -- self.group:translate(delta_x, 0)
    -- if self.group.propsTable then
    --   self.group.propsTable:translate(delta_x, 0)
    -- end
  else
   -- self.group:translate(-130, 0)
  end

end
--
--
--
local Animation = table:mySet{"linear", "blink", "bounce", "pulse", "rotaion", "tremble"}
local Layer     = table:mySet{"image", "layer", "audio", "variable", "physics"}
local Layer_Class = table:mySet{ "button", "countdown", "filter", "multiplier", "particles", "sprite", "readme", "video", "web"}

--
function M:setActiveProp(layer, class, suffix)
  -- print("setActiveProp", self.activeProp, layer, class)
  local value = layer
  if class and class:len() > 0  then
    value = layer.."_"..class
    if suffix then
      value = layer.."_"..class..suffix
    end
  end
  --
  -- check
  --
  local activeCommandName = commandbox.selectedText.text
  --
  -- commandbox.model is nil for modification, see setValue in commandbox
  --
  if commandbox.model == nil then
    -- print(json.prettify(self.model))
    activeCommandName = commandbox.selectedText.text:split(".")[1]
  end

  -- print("@@@@", activeCommandName)
  -- animation.play, animation.pause, animation.resume
  local isValid = function(class)
    if activeCommandName == "page" and self.activeProp == "effect"  or self.activeProp == "pageName" then
      return true
    elseif activeCommandName == "animation"  then
      return Animation[class]
    elseif Layer_Class[activeCommandName] then
      return activeCommandName == class
    elseif Layer[activeCommandName] then
      return class == nil or class:len() == 0
    end
  end
  ---
  if isValid(class) then
    ---
    for i,v in next, self.objs do
      -- print(v.text)
      if v.text == self.activeProp then
        v.field.text = value
        return true
      end
    end
  else
    -- TBI show popup
  end
end
--
function M:didShow(UI)
  self:show()
  -- linkbox:didShow(UI)
end
--
function M:didHide(UI)
  self:hide()
  -- linkbox:didHide(UI)
end
--
function M:destroy()
  if self.objs then
    for i=1, #self.objs do
      if self.objs[i].rect then
        self.objs[i].rect:removeSelf()
      end
      if self.objs[i].field then
        self.objs[i].field:removeSelf()
      end
      self.objs[i]:removeSelf()
    end
    self.objs = nil
  end
end
--
function M:hide()
  -- linkbox:hide()
  self.isVisible = false
  if self.objs == nil then return end
  for i=1, #self.objs do
    self.objs[i].isVisible = false
    if self.objs[i].rect then
      self.objs[i].rect.isVisible = false
    end
    if self.objs[i].field then
      self.objs[i].field.isVisible = false
    end
    -- if self.objs[i].linkbox then
    --   self.objs[i].linkbox.isVisible = false
    -- end
  end
end

function M:show()
  -- print("show")
  -- linkbox:show()
  self.isVisible = true
  if self.objs == nil then return end
  for i=1, #self.objs do
    self.objs[i].isVisible = true
    if self.objs[i].rect then
      self.objs[i].rect.isVisible = true
    end
    if self.objs[i].field then
      self.objs[i].field.isVisible = true
    end
    -- if self.objs[i].linkbox then
    --   self.objs[i].linkbox.isVisible = true
    -- end
    self.group:toFront()
  end
end
--
return M
