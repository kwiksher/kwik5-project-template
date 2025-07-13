local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new()
local widget = require("widget")
local json = require("json")
---------------------------
M.name = "classProps"
local option = M.option
local newText = M.newText
local newTextField = M.newTextField

function M:getValue()
  -- print("@@@@@@@@@")
  local ret = {}
  for i=1, #self.objs do
    -- if self.objs[i] == nil then break end
    -- print(self.props[i].name, self.objs[i].text )
    local name = self.objs[i].text
    local value
    if name == 'value' then
      if  self.valueType == "string" then
        value = "'" ..self.objs[i].field.text.."'"
      else
        value = self.objs[i].field.text
      end
    elseif type(self.props[i].value) == 'boolean' then
      value = tostring( self.objs[i].field.text )
    elseif type(self.props[i].value) == 'number' then
      value = tonumber( self.objs[i].field.text )
    elseif self.objs[i] and  self.objs[i].field then
      value = self.objs[i].field.text
    end
    ret[#ret +1] = {name=name, value=value}
  end
  ret[#ret+1] = {name="type", value = self.valueType or "string"}
  print ("", json.encode(ret))
  return ret
end

function M:createTable(props)
  local objs = {}
  for i=1, #props do
    local prop = props[i]
    local count = #objs + 1
    if (prop.name =="_type") then
      self.valueType = prop.value
    else
      option.text = prop.name
      option.x = self.x
      option.y = count*option.height + self.y
      option.text = prop.name
      -- print(self.group, option.x, option.y, option.width, option.height)
      local rect = display.newRect(self.group, option.x, option.y, option.width, option.height)
      rect:setFillColor(1)

      local obj = newText(option)
      obj.rect = rect
      objs[#objs + 1] = obj
      -- Edit
      option.x =rect.x + rect.width/2
      option.y = rect.y
      if type(prop.value) == "boolean" then
        option.text = tostring(prop.value)
      else
        option.text = prop.value
      end
      --
      local objField = newTextField(option)
      obj.field = objField
      self.group:insert(objField)
        -- obj.page = props.name
        -- obj.tap = commandHandler
        -- obj:addEventListener("tap", obj)
      if prop.name == 'value' then
        obj.radioGroup = self:createRadioGroup(objField, self.valueType)
        self.group:insert(obj.radioGroup)
      end

      self.group:insert(obj.rect)
      self.group:insert(obj)
    end
  end
  -- backRect.x = posX
  -- backRect.height = #props * option.height
  -- backRect.isVisible = true
  -- objs[#objs + 1] = backRect
  self.objs = objs
end


function M:createRadioGroup(obj, value)
  local top = obj.contentBounds.yMin
  local left = obj.contentBounds.xMax
  -- Handle press events for the buttons
  local function onSwitchPress( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    --
    self.valueType = switch.id
   --
  end
  -- Create a group for the radio button set
  local radioGroup = display.newGroup()
  radioGroup.model = {"string", "number", "boolean", "table","function"}
  -- Create two associated radio buttons (inserted into the same display group)
  local entry
  for i=1, #radioGroup.model do
    local entry = widget.newSwitch(
      {
          left = left ,
          top = top + (i-1) * 20 -5,
          style = "radio",
          id = radioGroup.model[i],
          initialSwitchState = (value == radioGroup.model[i]),
          onPress = onSwitchPress
      }
    )
    entry:scale(0.5, 0.5)
    radioGroup:insert( entry )

    option.text   =  radioGroup.model[i]
    option.x = entry.contentBounds.xMax + 60
    option.y = entry.y + 5

    local obj = newText(option)
    obj:setFillColor(0,1,0)
    radioGroup:insert(obj)
  end
  --
  radioGroup.alpha = 1
  return radioGroup
end

--
return M