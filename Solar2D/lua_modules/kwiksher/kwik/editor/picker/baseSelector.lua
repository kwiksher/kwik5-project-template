local name = ...
local model = {}

local M = require(kwikGlobal.ROOT.."editor.parts.baseBox").new(model)
M.originalCreate =  M.create
--
local shapes = require("shapes")
local util   = require(kwikGlobal.ROOT.."lib.util")
local widget = require( "widget" )

M.name = name
---------------------------
--
function M:init(UI)
  self.x = display.contentCenterX + 480/2
  self.y = display.contentCenterY
  self.height = 16
  self.width = 160
  self.fontSize = 10
  self.top = self.y - #self.model*self.height/2
  self.left =self.x + M.width/4
end

function M:commandHandler(event)
  self.selectedText.text = event.target.name
  self.callback(event.target.name)
  self:hide()
  return true
end


function M:createRow(index, entry)
  -- print("createRow", index, entry.name)
  local params = self.params
  local option = self.option
  option.x = self.width/2 +2
  option.width = self.width

  local group = display.newGroup()
  -- name
  option.parent = group
  option.text   =  entry.name or ""
  -- Modified line: position rows relative to scrollView's content origin
  option.y = index * option.height -2
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
  -- print("createTable")
  local labelText = display.newText{
      parent = self.group,
      text = self.name,
      x = self.x,
      y = self.y,
      fontSize = self.fontSize,
  }
  labelText.alpha = 0
  labelText:setFillColor( 1 )
  self.labelText = labelText

  local obj = display.newText{
    parent = self.group,
    text = self.selectedTextLabel or "",
    x = self.x,
    y = self.y,
    fontSize = self.fontSize,
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
      top                      = self.top,
      left                     = self.left,
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
  self.option.parent = self.group

  self.params = params
  -- self.option = option
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


function M:create(callback, message)
  -- print(debug.traceback())
  self.callback = callback
  --
  self.obj = {}
  self:init()
  self:originalCreate(UI)
  self:show()
  self:didShow()
end


return M