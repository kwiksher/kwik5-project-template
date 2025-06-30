local current = ...
local parent,root, M = newModule(current)
local widget = require( "widget" )
local util = require(kwikGlobal.ROOT.."editor.util")
local libUtil = require(kwikGlobal.ROOT.."lib.util")

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

function M:setValue(decoded, index)
  self.decoded = decoded
  --
  -- print("### setValue", self.name, decoded, index)
  if decoded == nil then return end
  self.model = {}
  for k, v in pairs(decoded) do
    print(k, v)
    self.model[#self.model+1] = {name=v.name, class=v.class}
  end
  --
  libUtil.sortProps(self.model)
  self.selectedIndex = index
end

local function getEntries(_entries, type)
  local entries = util.copyTable(_entries)
  for k, v in pairs(entries) do
    if k=="body" or k=="bodyA" or k=="bodyB" then
      entries["_"..k] = v
      entries[k] = nil
    end
  end
  entries["_type"] = type
  entries.type = nil
  return entries
end

function M:setTemplate(template)
  self.model = {}
  -- print("### setTemplate", #self.model)
  for k, v in pairs(template) do
    if k~="name" and k~="class" and k~="properties" then
      if v=="properties" then
        self.model[#self.model+1] = {name=k, class=template.class, entries = getEntries(template.properties, k), isTemplate = true}
      else
        self.model[#self.model+1] = {name=k, class=template.class, entries = getEntries(v, k), isTemplate = true}
      end
    end
  end

  --
  libUtil.sortProps(self.model)

  self.selectedIndex = 1
  self.selectedTextLabel = self.model[self.selectedIndex].entries["_type"]
  -- local pos = name:find("_new")
  -- if pos and  pos > 0 then
  --   for i=1, #self.model do
  --     local isNew = self.model[i].name:find(")")
  --     if isNew  then
  --       local tmp = "("..name :sub(1, pos) ..#self.model..")"
  --       self.model[i].name = tmp
  --       return
  --     end
  --   end
  --   local tmp = "("..name :sub(1, pos) ..(#self.model+1)..")"
  --   self.model[#self.model+1] = {name=tmp}
  -- end
end

function M:createTable(params)

  local model = self.model
  -- print("createTable")
  local labelText = display.newText{
      parent = self.group,
      text = self.name,
      x = self.x+18,
      y = self.y-10,
    fontSize = 10,
  }
  labelText.alpha = 0
  labelText:setFillColor( 1 )
  self.labelText = labelText

  local obj = display.newText{
    parent = self.group,
    text = self.selectedTextLabel or "",
    x = self.x + 4 ,
    y = self.y,
    fontSize = 10,
  }
  obj:setFillColor( 0.8 )
  obj.anchorX = 0
  self.selectedText = obj

  --
  if params and params.scrollView then
    self.scrollView = params.scrollView
  else
    self.scrollView = widget.newScrollView
    {
      top                      = self.y,
      left                     = self.x,
      width                    = self.width,
      height                   = #model*self.height,
      scrollHeight             = #model*self.height,
      verticalScrollDisabled   = false,
      horizontalScrollDisabled = true,
      friction                 = 2,
      -- backgroundColor = {1,0,1, 0.5},
    }
  end
  --scrollView.x=labelText.x
  ---[[
  option.parent = self.group

  local function createRow(index, entry)
    -- print("createRow", index, entry.name)
    local group = display.newGroup()
    -- name
    option.parent = group
    option.text   =  entry.name or ""
    option.x = 42   --labelText.contentBounds.xMin - 100
    option.y = self.y -self.height/2 + (index-1) * option.height
    --
    local obj = self.newText(option)
    obj.name = entry.name
    obj.class = entry.class
    obj.index = index

    if params and params.isRect then
      local rect = display.newRect(group, obj.x, obj.y, obj.width+10, obj.height)
      rect:setFillColor(1)
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
  --
  for i=1, #model do
    createRow(i, model[i])
  end
  --
  --scrollView.isVisible = false
  if self.group then
    self.group:insert(self.scrollView)
  end
  --scrollView.anchorY = 0
--]]

end

function M:commandHandler(event)
  if event.numTaps == 2 then
    print("------double tap --------")
    event.target.field.isVisible = true
  else
    print("-----single tap------")
    if self.selectedObj ~= obj then
      if self.selectedObj then
        if self.selectedObj.rect then
          self.selectedObj.rect:setFillColor(0.8)
        end
        -- update modified props. save the values to the self.model(decoded)
        --
        -- local props = self.useClassEditorProps()
        -- self.model[self.selectedObj.index] = props
        --
      end
      self.selectedObj = event.target
      self.selectedText.text =event.target.text
      self.selectedIndex = event.target.index
      self.selectedTextLabel = self.model[self.selectedIndex].entries["_type"]
      if self.selectedObj.rect then
        self.selectedObj.rect:setFillColor(0, 1, 0)
      end
      --
      -- this is set by controller.lua
      --   this will redraw with the new index
      self.classEditorHandler(self.decoded, event.target.index)
    end
  end
  return true
end

return setmetatable( M, {__index=require(root.."parts.selectbox")} )