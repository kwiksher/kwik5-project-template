local M = {}

local shapes = require("shapes")
local widget = require( "widget" )
local halfW = display.contentCenterX
local halfH = display.contentCenterY

local option = {
  parent   = nil,
  text     = "",
  x        = 0,
  y        = 0,
  width    = 80,
  height   = 16,
  font     = native.systemFont,
  fontSize = 10,
  align    = "left"
}

M.option = option

function M:init(UI, x, y, width, height)
  self.UI = UI
  self.x  = x
  self.y  = y
  self.width = width
  self.height = height
end

function M:create(UI)
  self.group = display.newGroup()
  local x = self.x + self.width -- selectbox's scrollView
  local y = self.y
  self.triangle = self:createTriangle( x, y, 10 )
  self.triangle.alpha = 0
  self.group:insert(self.triangle)
  self:createTable(self.triangle)
end

function M:createTriangle (x, y)
  local triangle = shapes.triangle.equi( x, y, 10 )
  triangle:rotate(120)
  triangle.alpha = 0
  triangle.tap = function(event)
    -- print("triangle tap")
    for i=1, #self.objs do
      local obj = self.objs[i]
      obj.isVisible = not obj.isVisible
      self.scrollView.isVisible = obj.isVisible
    end
    return true
  end
  ---
  triangle.mouse = function(event )
    --print(event.name, event.type, event.y)
    --for k, v in pairs(event) do print(k, v) end
    -- if event.type == "down" then
    --     if event.isPrimaryButtonDown then
    --         print( "Left mouse button clicked." )
    --     elseif event.isSecondaryButtonDown then
    --         print( "Right mouse button clicked." )
    --     end
    -- end
    if self.labelText.alpha == 0 then
      self.labelText.alpha = 1
      timer.performWithDelay( 1000, function() self.labelText.alpha = 0 end)
    end
  end
  return triangle
end


function M:createRow(index, entry)
  -- print("createRow", index, entry.name)
  local triangle = self.triangle
  local params = self.params

  local group = display.newGroup()
  -- name
  option.parent = group
  option.text   =  entry.name or ""
  option.x = 42   --labelText.contentBounds.xMin - 100
  option.y = triangle.contentBounds.yMax + (index-2) * option.height-5
  --
  local obj = self.newText(option)
  obj.name = entry.name
  obj.class = entry.class
  obj.index = index

  if params and params.isRect then
    local rect = display.newRect(group, obj.x, obj.y, obj.width+10, obj.height)
    rect:setFillColor(0.8)
    obj.rect = rect
    group:insert(obj) -- insert again to make it top

  end
  --
  -- local field = native.newTextField( scrollView.x + 40, obj.y, 40, 16 )
  local field = native.newTextField(obj.x, obj.y ,obj.width, obj.height )
  if type(entry.value) == 'number' then
    field.inputType = "number"
  end
  -- print("createDow", entry.name, entry.value)
  field.text = entry.value
  -- field.isVisible = false
  obj.field = field
  field.isVisible = false1
  group:insert(field)

  ---
  self.scrollView:insert(group)
  self.objs[index] = obj
  if self.selectedIndex == index then
    self.selectedObj = obj
    self.selectedText.text = obj.class
    if obj.rect then
      obj.rect:setFillColor(0,1,0)
    end
  end
end

function M:createTable(params)

  local model = self.model
  local triangle = self.triangle
  -- print("createTable")
  local labelText = display.newText{
      parent = self.group,
      text = self.name,
      x = triangle.x+18,
      y = triangle.y-10,
    fontSize = 10,
  }
  labelText.alpha = 0
  labelText:setFillColor( 1 )
  self.labelText = labelText

  local obj = display.newText{
    parent = self.group,
    text = self.selectedTextLabel or "",
    x = triangle.x + 4 ,
    y = triangle.y,
    fontSize = 10,
  }
  obj:setFillColor( 1 )
  obj.anchorX = 0
  self.selectedText = obj

  --
  if params and params.scrollView then
    self.scrollView = params.scrollView
  else
    self.scrollView = widget.newScrollView
    {
      top                      = triangle.contentBounds.yMax,
      left                     = triangle.contentBounds.xMin,
      width                    = self.width,
      height                   = #model*self.height,
      scrollHeight             = #model*self.height,
      verticalScrollDisabled   = false,
      horizontalScrollDisabled = true,
      friction                 = 2,
    }
  end
  --scrollView.x=labelText.x
  ---[[
  option.parent = self.group

  self.params = params
  self.option = option
  --
  for i=1, #model do
    self:createRow(i, model[i])
  end
  --
  --scrollView.isVisible = false
  if self.group then
    self.group:insert(self.scrollView)
  end
  --scrollView.anchorY = 0
--]]

end


function M:getValue()
  for i=1, #self.model do
    local value = self.objs[i].field.text
    if type(self.model[i].value) == 'boolean' then
    elseif type(self.model[i].value) == 'number' then
      value = tonumber( value )
    end
    self.model[i].value = value or self.model[i].value
  end
  return self.model
end

function M:setValue(props)
  -- print("boxBase:setValue")
  for i=1, #self.model do
    local entry = self.model[i]
    -- print("", entry.name, props[entry.name], type(props[entry.name]))
    entry.value = props[entry.name]
  end
end

function M.newText(option)
  local obj=display.newText(option)
  obj:setFillColor( 0 )
  return obj
end

function M:commandHandler(event)
  self.selectedText.text = event.target.name
  return true
end

function M:didShow(UI)
  -- print(debug.traceback())
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj.tap =function(eventObj, event)
      return self:commandHandler(event)
    end

    obj:addEventListener("tap",obj)
    if obj.field then
        obj.field.userInput = function(eventObj, event)
        return self:textListener(event)
      end
      obj.field:addEventListener( "userInput", obj.field )
    end
  end
  if self.triangle then
    self.triangle:addEventListener("tap", self.triangle)
    self.triangle:addEventListener( "mouse", self.triangle )
  end

end
--
function M:didHide(UI)
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj:removeEventListener("tap", obj)
    if obj.field then
      obj.field:removeEventListener( "userInput", obj.field )
    end

  end
  if self.triangle then
    self.triangle:removeEventListener("tap", self.triangle)
    self.triangle:removeEventListener("mouse", self.triangle)
  end
end
--
function  M:destroy(UI)
  self:didHide(UI)
  if self.triangle then
    self.triangle:removeSelf()
    if self.labelTex then
      self.labelText:removeSelf()
    end
    if self.selectedText and self.selectedText.removeSelf then
      self.selectedText:removeSelf()
    end
    if self.scrollView then
      self.scrollView:removeSelf()
    end
  end
  if self.objs then
    for i=1, #self.objs do
      self.objs[i]:removeSelf()
    end
  end
  self.objs = {}
  self.triangle = nil
  self.scrollView = nil
  self.labelText = nil

end
--
function M:toggle()
  self.triangle.tap()
  self.triangle.isVisible = self.scrollView.isVisible
  self.labelText.isVisible = self.scrollView.isVisible
  self.selectedText.isVisible  = self.scrollView.isVisible
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj.isVisible = self.scrollView.isVisible
    if obj.field then
      obj.field.isVisible = self.scrollView.isVisible
    end
  end
end

function M:show()
  if self.scrollView == nil  then return end
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj.isVisible = true

    -- if obj.field then
    --   obj.field.isVisible = true
    -- end
  end
  self.scrollView.isVisible = true
  self.triangle.isVisible = true
  self.labelText.isVisible = true
  self.selectedText.isVisible  = true
end

function M:hide()
  if self.triangle then
    self.triangle.isVisible = false
  end
  if self.labelText then
    self.labelText.isVisible = false
  end
  if self.selectedText then
    self.selectedText.isVisible  = false
  end
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj.isVisible = false
    if obj.field then
      obj.field.isVisible = false
    end
  end
  if self.scrollView then
    self.scrollView.isVisible = false
  end
end

function M:newInstance(model)
  local instance = {
    selectedText = nil,
    selectedTextLabel = nil, -- class
    selectedIndex = 1,
    selectedObj = nil,
    objs = {},
    model = model
  }
  return setmetatable(instance, {__index=self})
end

M.new = function(model)
	local instance = {
    selectedText = nil,
    selectedTextLabel = nil, -- class
    selectedIndex = 1,
    selectedObj = nil,
    objs = {},
    model = model
  }
	return setmetatable(instance, {__index=M})
end


return M