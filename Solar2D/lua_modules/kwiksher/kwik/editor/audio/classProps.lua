local current = ...
local parent,  root = newModule(current)
--
local M    = require(root.."parts.baseProps").new()
-- local assetbox   = require(root.."parts.assetbox")
local util = require(kwikGlobal.ROOT.."editor.util")
local widget = require( "widget" )

local option = M.option
local newText = M.newText
local newTextField = M.newTextField

function M:createRadioGroup(top, left, width, height)
  local option = self.option
  -- Handle press events for the buttons
  local function onSwitchPress( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    --
    self.switchDispatcher:dispatchEvent({name="switch", id=switch.id})
   --
  end
  self.onSwitchPress = onSwitchPress

  -- Create a group for the radio button set
  local radioGroup = display.newGroup()

  local rect = display.newRect(left+width/2, top+height/2+7,width, height-1)
  rect:setFillColor(1)
  radioGroup:insert(rect)
  -- Create two associated radio buttons (inserted into the same display group)
  local radioButton1 = widget.newSwitch(
    {
        left = left,
        top = top,
        style = "radio",
        id = "audioshort",
        initialSwitchState = (id == "audioshort"),
        onPress = onSwitchPress
    }
  )

  radioButton1:scale(0.5, 0.5)
  radioGroup:insert( radioButton1 )

  option.text   =  "short"
  option.x = radioButton1.contentBounds.xMax+30
  option.y = radioButton1.y + 5
  local obj = newText(option)
  obj:setFillColor(0,1,0)
  radioGroup:insert(obj)

  local radioButton2 = widget.newSwitch(
    {
        left = left + 40,
        top = top,
        style = "radio",
        id = "audiolong",
        initialSwitchState = (id == "audiolong"),
        onPress = onSwitchPress
    }
  )
  radioButton2:scale(0.5, 0.5)
  radioGroup:insert( radioButton2 )

  option.text   =  "long"
  option.x = radioButton2.contentBounds.xMax + 30
  option.y = radioButton2.y + 5
  obj = newText(option)
  obj:setFillColor(0,1, 0)
  radioGroup:insert(obj)
  --
  -- radioGroup.alpha = 0
  return radioGroup
end


function M:createTable(props)
  local objs = {}

  for i=1, #props do
    local prop = props[i]
    option.text = prop.name
    option.x = self.x
    option.y = i*option.height + self.y
    -- print(self.group, option.x, option.y, option.width, option.height)
    local rect = display.newRect(self.group, option.x, option.y, option.width, option.height)
    rect:setFillColor(1 )

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
    self.group:insert(obj.rect)
    --
    if prop.name == '_file' or prop.name == 'file' then
      obj.text = "_filename"
      local class = "audio"..(prop.type or "short") -- audioshort or audiolong
      -- assetbox:load(self.UI, class, obj.x + obj.width*2.75 -6, obj.y - obj.height/4, prop.value)
      -- obj.assetbox = assetbox
      -- self.group:insert(obj.assetbox.scrollView)
      self.activeProp = "_filename" -- prop.name -- this allows selecting a file from assetTable
    end

    ---
    if prop.name == '_type' then
      function obj:switch(event)
        --for k, v in pairs(event) do print(k, v) end
        self.field.text = event.id:gsub("audio", "")
      end
      obj:addEventListener("switch", obj)
      -- assetbox.switchDispatcher = obj
      local radioGroup = self:createRadioGroup(obj.y - obj.height/2-6, obj.rect.x+obj.rect.width/2, 100, option.height)
      self.switchDispatcher = obj
      self.group:insert(radioGroup)
    else
      local field = newTextField(option)
      field.width = 100
      obj.field = field
      self.group:insert(field)
    end

    if prop.name == "name" then
      function obj:assetName(event)
        self.field.text = util.getFileName(event.value)
      end
      obj:addEventListener("assetName", obj)
      -- assetbox.assetNameDispatcher = obj
    end

    -- obj.page = props.name
    -- obj.tap = commandHandler
    -- obj:addEventListener("tap", obj)
    self.group:insert(obj)
  end
  -- backRect.x = posX
  -- backRect.height = #props * option.height
  -- backRect.isVisible = true
  -- objs[#objs + 1] = backRect
  self.group.propsTable = self.group
  self.objs = objs
  -- assetbox.scrollView:toFront()
end

function M:didShow(UI)
  -- assetbox:didShow(UI)
end
--
function M:didHide(UI)
  -- assetbox:didHide(UI)
end


return M