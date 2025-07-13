local current = ...
local parent,  root, M = newModule(current)
--

local actionEditor = require(kwikGlobal.ROOT.."editor.action.index")
local actionTable = require(kwikGlobal.ROOT.."editor.action.actionTable")
--local actoinbox = require(parent.."actionbox")

local listbox = require(parent .. "listbox")
-- local linkbox = require(root .. "parts.linkbox").new({width = 55})

---
local util = require(kwikGlobal.ROOT.."lib.util")
local json = require("json")

M.x = display.contentCenterX + 480 / 2 + 120 -- listbox.scrollView.x - option.width
M.y = display.contentCenterY + 40 --listbox.y + 70  -- (display.actualContentHeight - display.contentHeight + option.height)/2

function M:init(UI)
end

local function tapListenerAction(event)
  print("action tap listener")
  M.activeProp = event.target.text
  actionEditor:showActionTable(M)
end

function M:setActiveProp(value)

  actionTable:hide()
  print("activeProp", value)

  local name =self.activeProp or ""
  for i,v in next, self.objs or {} do
    if v.text == name then
      v.field.text = value
      print("###", self.activeProp, value, #self.objs, self)
      return
    end
  end
  print("Warning activeProp name is not found for", self.activeProp)
end


local option, newText =
  util.newTextFactory {
  x = 0,
  y = 100,
  width = 60,
  height = 20
}

local newTextField = util.newTextField

function M:render(props)
  -- print("", debug.traceback())
  local function compare(a, b)
    return a.name < b.name
  end
  --
  local headers = listbox.headers[props.type]
  ---
  local objs = {}
  for i = 1, #headers do
    -- print("", props[i].name)
    local header = headers[i]
    local value = props.value[i]
    -- print(props.index, header, value)
    --
    option.text = header
    option.x = self.x
    option.y = i * option.height + self.y
    --
    local rect = display.newRect(option.parent, option.x, option.y, option.width * 2, option.height)
    rect:setFillColor(1)
    --
    option.x = option.x - option.width / 2 + 5
    local obj = newText(option)
    obj.rect = rect

    -- Edit
    if header == "action" then
      -- linkbox:load(self.UI, "action", obj.x + obj.width / 2, obj.y - obj.height / 4, value)
      -- obj.linkbox = linkbox
      obj:addEventListener("tap", tapListenerAction)
    end

    option.x = self.x + option.width / 2
    option.text = value
    --
    obj.field = newTextField(option)
    objs[#objs + 1] = obj

    -- objs[#objs + 1] = obj
    -- obj.page = props.name
    -- obj.tap = commandHandler
    -- obj:addEventListener("tap", obj)
  end
  self.objs = objs
  self.model = props
end

--
--- I/F ---
--
function M:getValue()
  --for k, v in pairs(self.model) do print(k, v) end
  local ret = {}
  for i = 1, #self.objs do
    if self.objs[i] == nil then
      break
    end
    -- print(self.model[i], self.objs[i].text, self.objs[i].field.text )
    local key = self.objs[i].text
    local value
    if self.objs[i].field then
      value = self.objs[i].field.text
      print("@", type(self.objs[i].text), key, value)
      if type(self.model.value[i]) == "boolean" then
        if value == nil or value == "" then
          value = self.model.value[i]
        end
        value = tostring(value)
      elseif type(self.model.value[i]) == "number" then
        value = tonumber(value)
      end
    else -- action
      -- value = self.objs[i].linkbox.value
    end
    --
    -- print(key,value)
    ret[key] = value
  end
  return ret
end

--
function M:setValue(props)
  self:didHide(self.UI)
  self:destroy()
  print("------- listPropsTable --------")
  self:render(props)
  -- linkbox.callbackTriagnle = function(isOn)
  --   if isOn then
  --     for i = 1, #self.objs do
  --       if self.objs[i].field then
  --         self.objs[i].field.alpha = 1
  --       end
  --     end
  --   else
  --     for i = 1, #self.objs do
  --       if self.objs[i].field then
  --         self.objs[i].field.alpha = 0.1
  --       end
  --     end
  --   end
  -- end
  -- --
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
end

--
--
function M:create(UI)
  local rootGroup = UI.editor.rootGroup
  if rootGroup.listPropsTable then
    return
  end
  -- print("create", self.name)
  option.parent = rootGroup
  rootGroup.listPropsTable = self
  self.UI = UI
end
--
function M:didShow(UI)
  self:show()
  -- linkbox:didShow()
end
--
function M:didHide(UI)
  self:hide()
  -- linkbox:didHide()
end
--
function M:destroy()
  if self.objs then
    for i = 1, #self.objs do
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
  self.isVisible = false
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
  end
  -- linkbox:hide()
end

function M:show()
  self.isVisible = true
  if self.objs == nil then
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
  end
  -- linkbox:show()
end
--
return M
