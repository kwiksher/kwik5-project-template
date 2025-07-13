local current = ...
local parent,  root = newModule(current)
--
local M    = require(root.."parts.baseProps").new()

local assetbox   = require(root.."parts.assetbox")
local util = require(kwikGlobal.ROOT.."editor.util")

local option = M.option
local newText = M.newText
local newTextField = M.newTextField

function M:createTable(props)
  local objs = {}

  for i=1, #props do
    local prop = props[i]
    option.text = prop.name
    option.x = self.x
    option.y = i*option.height + self.y
    option.text = prop.name
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
    if prop.name == '_file' or props.name == 'file' then
      obj.text = "_filename"
      local class = "audio"..(prop.type or "short") -- audioshort or audiolong
      assetbox:load(self.UI, class, obj.x + obj.width*2.75 -6, obj.y - obj.height/4, prop.value)
      obj.assetbox = assetbox
      self.group:insert(obj.assetbox.scrollView)
    else
      local field = newTextField(option)
      field.width = 100
      obj.field = field
      self.group:insert(field)
      ---
      if prop.name == '_type' then
        function obj:switch(event)
          --for k, v in pairs(event) do print(k, v) end
          self.field.text = event.id:gsub("audio", "")
        end
        obj:addEventListener("switch", obj)
        assetbox.switchDispatcher = obj
      elseif prop.name == "name" then
        function obj:assetName(event)
          self.field.text = util.getFileName(event.value)
        end
        obj:addEventListener("assetName", obj)
        assetbox.assetNameDispatcher = obj
      end
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
  self.rootGroup.propsTable = self.group
  self.objs = objs
  -- assetbox.scrollView:toFront()
end

function M:didShow(UI)
  assetbox:didShow(UI)
  self.group.isVisible = true
end
--
function M:didHide(UI)
  self.group.isVisible = false
  assetbox:didHide(UI)
end


return M