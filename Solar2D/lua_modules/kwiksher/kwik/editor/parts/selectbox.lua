local M = require(kwikGlobal.ROOT.."editor.parts.baseBox").new()
local shapes = require("shapes")
local widget = require( "widget" )

---------------------------
M.name = "class"
M.selectedTextLabel =  "" -- class
--
-- I/F
function M:setValue(decoded, index)
  ---
  self.decoded = decoded
  --
  -- print("### setValue", self.name, decoded, index)
  if decoded == nil then return end
  self.model = {}
  for k, v in pairs(decoded) do
    self.model[#self.model+1] = {name=v.name, class=v.class}
  end
  ---
  local name = decoded[index].name
  -- print("selectbox",name)
  self.selectedIndex = index
end

function M:updateValue(value)
  -- print("### updateValue", self.name, value, self.selectedText.isVisible)
  if self.selectedObj then
    self.selectedObj.text = value
    self.selectedText.text =value
  end
end


function M:setTemplate(template)
  -- print("### setTemplate", #self.model)
  local last = self.model[#self.model]
  local suffix
  if last and last.isTemplate then
    suffix = #self.model
    if suffix == 1 then
      suffix = ""
    end
    self.model[#self.model] = {name=template.name ..suffix, class=template.class, isTemplate = true}
  else
    suffix = #self.model + 1
    if suffix == 1 then
      suffix = ""
    end
    self.model[#self.model+1] = {name=template.name..suffix, class=template.class, isTemplate = true}
  end
  self.selectedIndex = #self.model
  self.selectedTextLabel = template.class
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

function M:init(UI, x, y, w, h)
  self.UI = UI
  self.x = x or self.x
  self.y = y or self.y
  self.width = w or self.width
  self.height = h or self.height
  self.model = self.model or {}
end
--
function M:create(UI)
  --print(debug.traceback())
  --  print("### create", #self.model)
  self.group = display.newGroup()
  self.triangle = self:createTriangle( self.x,self.y+5, 10 )
  self.triangle.alpha = 0
  self.group:insert(self.triangle)
  if #self.model > 2 then
    -- print("selctbox #", #self.model )
    -- local scrollView = widget.newScrollView
    -- {
    --   top                      = self.triangle.contentBounds.yMax,
    --   left                     = self.triangle.contentBounds.xMin,
    --   width                    = self.width,
    --   height                   = #self.model*self.height,
    --   scrollHeight             = #self.model*self.height,
    --   verticalScrollDisabled   = false,
    --   horizontalScrollDisabled = true,
    --   friction                 = 2,
    -- }
    -- UI.editor.rootGroup:insert(self.group)
    --scrollView.isVisible = false
    -- this creatTable in baseBox set self.name to the text field next the triangle icon

    self:createTable({scrollView = scrollView, isRect = true}) -- isRect
  end
end
--
function M:textListener(event )
  if ( event.phase == "began" ) then
      -- User begins editor "defaultField"

  elseif ( event.phase == "ended" or event.phase == "submitted" ) then
      -- Output resulting text from "defaultField"
      self.selectedObj.text = self.selectedObj.field.text
      self.selectedObj.field.isVisible = false
      -- print(self.model[self.selectedObj.index].name)
      self.model[self.selectedObj.index].name = self.selectedObj.text

  elseif ( event.phase == "editor" ) then
      -- print( event.newCharacters )
      -- print( event.oldText )
      -- print( event.startPosition )
      -- print( event.text )
  end
end

function M:commandHandler(event)
  if event.numTaps == 2 then
    -- print("------double tap --------")
    event.target.field.isVisible = true
  else
    -- print("-----single tap------")
    if self.selectedObj ~= obj then
      if self.selectedObj then
        if self.selectedObj.rect then
          self.selectedObj.rect:setFillColor(0.8)
        end
        -- update modified props. save the values to the self.model(decoded)
        --
        local props = self.useClassEditorProps()
        self.model[self.selectedObj.index] = props
        --
      end
      self.selectedObj = event.target
      self.selectedText.text =event.target.text
      self.selectedIndex = event.target.index
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
--
-- function M:didHide(UI)
--   for i=1, #self.objs do
--     local obj = self.objs[i]
--     obj:removeEventListener("tap", obj)
--     if obj.field then
--       obj.field:removeEventListener( "userInput", textListener )
--     end
--   end
--   if self.triangle then
--     self.triangle:removeEventListener("tap", self.triangle)
--     self.triangle:removeEventListener("mouse", self.triangle)
--   end
-- end

return M