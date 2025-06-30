local current = ...
local parent,  root = newModule(current)

local M = require(parent.."linkbox").new{
  x = display.contentCenterX + 120,
  width=100}
--
M.name = current
local util = require(kwikGlobal.ROOT.."editor.util")
local widget = require( "widget" )

M.newText = newText
local newText = M.newText

--
-- I/F
--
local typeMap = {
  audioshort = "audios.short",
  audiolong  = "audios.long",
  font       = "fonts",
  image      = "images",
  particle   = "particles",
  sprite     = "sprites",
  thumbnail  = "thumbnails",
  video      = "videos",
}

function M:setValue(selectedValue, radioId)
  local UI = self.UI
  local book = UI.editor.currentBook or App.get().name
  local page = UI.editor.currentPage or UI.page
  --
  -- here to read files in assets folder
  --
  if radioId then
    self.type = radioId
  end
  --
  self.model = util.readAssets(book)
  local class = typeMap[self.type]
  --
  self.value             = selectedValue
  self.selectedObj       = nil
  self.objs           = {}
  ---
  -- for k, v in pairs(self.model) do print(k, #v) end

  if self.model[class] then
    print("createTable", class)
    self:createTable(UI, self.model[class], 0, selectedValue)
    self:createRadioGroup(radioId)
  else
    print("error no model:", self.type)
  end
end
--
function M:createRow(entry, indentX)
  -- print("createRow", entry.name)
  local group = display.newGroup()
  local option = self.option
  local instance = self
  local index = entry.index

  -- local entry = {name = row}
  -- name
  option.text   =  entry.name or ""
  option.x = self.width/2 + indentX*5 --labelText.contentBounds.xMin - 100
  option.y = (index-1) * option.height + option.height/2
  --
  local obj = newText(option)
  obj.name = entry.name
    --
  local rect = display.newRect(obj.x, obj.y, obj.width+10,option.height)
  rect:setFillColor(0.8)
  if entry.isFiltered then
    -- print("@@@@ filtered", entry.name)
    obj.alpha = 0.5
    rect.alpha = 0.5
  end
  --
  obj.rect = rect
  group:insert(rect)
  group:insert(obj)
  --
  obj.index = index
  --
  if self.commandHandler then
    obj.touch = function(eventObj, event)
      -- print("calls commandHandler")
      self:commandHandler(obj, event)
      UI.editor.selections = self.selections
      return true
    end
  else
    print("----- create tap ----")
    function obj:tap(e)
      -- print(e.target.name)
      if e.numTaps == 2 then
        -- print("------double tap --------")
      else
        print("-----single tap------", instance.value, instance.selectedObj)
        if instance.selectedObj ~= obj then
          if instance.selectedObj then
            instance.selectedObj.rect:setFillColor(0.8)
          end
          instance.selectedObj = self
          instance.value =self.text
          instance.selectedIndex = index
          instance.selectedObj.rect:setFillColor(0, 1, 0)
          if instance.assetNameDispatcher then
            instance.assetNameDispatcher:dispatchEvent{name="assetName", value=self.text}
          end
        end
      end
      return true
    end
  end

  --
  self.objs[index] = obj
  if obj.tap then
    -- print("###", obj.text)
    obj:addEventListener("tap",obj)
  elseif self.commandHandler then
    obj:addEventListener("touch", obj)
  end
  return group
end

function M:createRadioGroup(id)
  local top = self.triangle.contentBounds.yMin
  local left = self.scrollView.contentBounds.xMax
  local option = self.option
  -- Handle press events for the buttons
  local function onSwitchPress( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    --
    self:didHide()
    self:destroy()
    -- self:init(UI, x, y, type)
    self.selectedIndex = nil
    self:create(self.UI)
    self:setValue(nil, switch.id)
    self:didShow()
    self:show()
    --
    self.switchDispatcher:dispatchEvent({name="switch", id=switch.id})
   --
  end
  M.onSwitchPress = onSwitchPress

  -- Create a group for the radio button set
  local radioGroup = display.newGroup()


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
  option.x = radioButton1.contentBounds.xMax + 60
  option.y = radioButton1.y + 5
  local obj = newText(option)
  obj:setFillColor(0,1,0)
  radioGroup:insert(obj)

  local radioButton2 = widget.newSwitch(
    {
        left = left,
        top = top + 30,
        style = "radio",
        id = "audiolong",
        initialSwitchState = (id == "audiolong"),
        onPress = onSwitchPress
    }
  )
  radioButton2:scale(0.5, 0.5)
  radioGroup:insert( radioButton2 )

  option.text   =  "long"
  option.x = radioButton2.contentBounds.xMax + 60
  option.y = radioButton2.y + 5
  obj = newText(option)
  obj:setFillColor(0,1, 0)
  radioGroup:insert(obj)
  --
  radioGroup.alpha = 0
  self.radioGroup = radioGroup
end
--
function M:_create(UI)
  -- if self.rootGroup then return end
  self.rootGroup = UI.editor.rootGroup
  if self.triangle == nil then
    -- print(debug.traceback())
    self.triangle = shapes.triangle.equi( self.x, self.y, 10 )
    self.triangle:rotate(180)
    self.triangle:setFillColor(1,1,0)
    self.triangle.tap = function(event)
      print("triangle tap")
      self.triangle.on = not self.triangle.on
      if self.triangle.on then
        self.scrollView:setSize(self.width, self.height*#self.objs)
        self.scrollView:toFront()
        self.scrollView:scrollToPosition{y=0}
        self.radioGroup.alpha = 1
       -- self.scrollView:translate(100,0)

      else
        self.scrollView:setSize(self.width, self.height)
        if self.selectedIndex > 0 then
          self.scrollView:scrollToPosition{y=-self.height*(self.selectedIndex-1)}
        else
          --self.scrollView:scrollToPosition{y=-self.height}
        end
        self.radioGroup.alpha = 0
       -- self.scrollView:translate(-100,0)
      end
      return true
    end

    self.rootGroup:insert(self.triangle)
  else
    self.triangle.x = self.x
    self.triangle.y = self.y
  end
  --
  ---
  self:hide()
end

--
function M:createTable(UI, rows, selectedIndex, selectedValue)
  print("createTable", #rows, selectedIndex, selectedValue)
  self.scrollView = widget.newScrollView
  {
    top                      = self.triangle.contentBounds.yMin,
    left                     = self.triangle.contentBounds.xMin - self.width,
    width                    = self.width,
    height                   = self.height,
    scrollHeight             = #rows*self.height,
    verticalScrollDisabled   = false,
    horizontalScrollDisabled = true,
    friction                 = 2,
  }
  self.index = 0
  --
  for i=1,#rows do
    local group = self:createRow({name=rows[i], index = i}, 0)
   self.scrollView:insert(group)
  end

  if #self.objs > 0 and selectedIndex and selectedIndex > 0 then
    self.objs[selectedIndex].rect:setFillColor(0,1,0)
    self.selectedObj = self.objs[selectedIndex]
    self.value = self.objs[selectedIndex].text
    self.selectedIndex = selectedIndex
  end

  self:scrollToPosition()

end

function M:scrollToPosition()
  if self.selectedIndex then
    self.scrollView:scrollToPosition{y=-self.height*(self.selectedIndex-1)}
  else
    self.selectedIndex = 0
  end
end

function M:load(UI, type, x, y, selectedValue)
  self:didHide()
  self:destroy()
  self:init(UI, x, y, type)
  self:create(UI)
  self:setValue(selectedValue, "audioshort")
  -- self:didShow()
  self:show()
end

--
return M