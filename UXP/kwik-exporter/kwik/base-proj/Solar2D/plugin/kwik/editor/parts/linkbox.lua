local Class, M = {}, {}

local current = ...
local parent = current:match("(.-)[^%.]+$")
local root = parent:sub(1, parent:len() - 1):match("(.-)[^%.]+$")

local editorUtil = require(root .. "util")
local shapes = require("shapes")
local widget = require("widget")
local App = require "Application"

local util = require(kwikGlobal.ROOT.."lib.util")

-- linkbox has a rect only not having native.textField. boxbase implements it with native.textField
---------------------------
M.name = ...
--
-- I/F
--
local typeMap = {
  animation = "layers",
  audio = "audios",
  group = "groups",
  action = "commands",
  layer = "layers",
  button = "layers"
}

local nodeMap = {} -- for hiding children

function M:load(UI, type, x, y, selectedValue)
  self:didHide()
  self:destroy()
  self:init(UI, x, y, nil, nil, type)
  self:create(UI)
  self:setValue(selectedValue)
  self:didShow()
  self:show()
end

function M:setValue(selectedValue)
  local UI = self.UI
  local book = UI.editor.currentBook or App.get().name
  local page = UI.editor.currentPage or UI.page
  print("linkbox", book, page, self.type)

  local scene = require("App." .. book .. ".components." .. page .. ".index")

  self.model = editorUtil.updateIndexModel(scene.model)
  local class = typeMap[self.type]

  -- print(debug.traceback())
  -- for k, v in pairs(self.model) do
  --   print(k, #v)
  -- end
  -- -- --
  self.value = selectedValue
  self.selection = nil
  self.objs = {}
  ---
  -- for k, v in pairs(self.model) do print(k, #v) end

  if self.model[class] then
    -- print("@@@ linkbox createTable", selectedValue)
    self:createTable(UI, self.model[class], nil, selectedValue)
    if selectedValue == "" then
      self.scrollView.alpha = 0
    end
  else
    print("error no model:", class, self.type)
  end
end

local option, newText = util.newTextFactory()
M.newText = newText

function M:createTable(UI, rows, selectedIndex, selectedValue)
  -- print("createTable", #rows, selectedValue)
  local json = require("json")
  -- print(json.prettify(rows))
  local option = self.option
  --
  local scrollView =
    widget.newScrollView {
    top = self.triangle.contentBounds.yMin - self.triangle.height / 2,
    left = self.triangle.contentBounds.xMin - self.width,
    width = self.width,
    height = self.height,
    scrollHeight = #rows * self.height,
    verticalScrollDisabled = false,
    horizontalScrollDisabled = true,
    friction = 2
  }

  local index = 0
  local instance = self
  --
  local function createRow(entry, xIndex, parentObj, nLevel)
    -- print("createRow", entry.name)
    local group = display.newGroup()
    -- name
    option.text = entry.name or ""
    option.x = self.width / 2 + xIndex * 5 --labelText.contentBounds.xMin - 100
    option.y = index * option.height + option.height / 2
    --
    local obj = newText(option)
    obj.name = entry.name
    obj.layer = entry.name -- obj.layer is used for audio, action too. necessary to compare it with selectedValue
    obj.params = entry.params
    obj.parentObj = parentObj
    --
    local rect = display.newRect(obj.x, obj.y, obj.width + 10, option.height)

    rect:setFillColor(1)
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
    index = index + 1
    obj.index = index
    --
    if self.commandHandler then
      obj.touch = function(eventObj, event)
        -- print("calls commandHandler")
        self:commandHandler(eventObj, event)
        UI.editor.selections = self.selections
        return true
      end
    else
      -- print("----- create tap ----")
      function obj:tap(e)
        -- print(e.target.name)
        if e.numTaps == 2 then
          -- print("------double tap --------")
        else
          -- print("-----single tap------", instance.value, instance.selection)
          if instance.selection ~= obj then
            if instance.selection then
              instance.selection.rect:setFillColor(0.8)
            end
            instance.selection = self
            instance.value = self.text
            instance.selectedIndex = self.index
            instance.selection.rect:setFillColor(0, 1, 0)
          -- scrollView:scrollToPosition{y=-self.height*(self.index-1)}
          --
          -- for k, v in pairs(self.params) do print("", k, v) end
          -- UI.scene.app:dispatchEvent {
          --   name = "editor.action.selectActionCommand",
          --   UI = UI,
          --   value = M.command,
          --   index = self.index,
          --   isNew = true
          -- }
          -- UI.editor.actionCommandPropsStore:set(self.params)
          end
        end
        return true
      end
    end

    --
    scrollView:insert(group)
    self.objs[index] = obj

    -- children
    local children = entry["layers"..nLevel]
    if children and #children > 0 then
      if nodeMap[entry.name] == nil then
        for i = 1, #children do
          local _obj = createRow(children[i], xIndex + 1, obj, nLevel+1)
        end
      end
      obj.text = "- " .. entry.name
      obj.isExpanded = true
      --
      obj.tap = function(_self, event)
        -- open/close folder
        if nodeMap[entry.name] == nil then
          nodeMap[entry.name] = true
        else
          nodeMap[entry.name] = nil
        end
        print(UI, self.type, self.x, self.y, self.value)
        self:reload()
      end
      obj:addEventListener("tap", obj)
    else
      -- only attach the handler if not a group index
      if obj.tap then
        -- print("###", obj.text)
        obj:addEventListener("tap", obj)
      elseif self.commandHandler then
        obj:addEventListener("touch", obj)
      end
      -- check

      -- local scene = require("App." .. book .. ".components." .. page .. ".index")

      local path = editorUtil.getParent(obj)
      if obj.layer and selectedValue == path .. obj.layer then -- layer is used for audio, action too
        self.selectedIndex = index
        obj.rect:setFillColor(0, 1, 0)
        self.selection = obj
        self.value = obj.text
      end
    end
    return obj
  end
  --
  --
  for k, entry in pairs(rows) do
    createRow(entry, 0, nil, 1)
  end
  --
  if #self.objs > 0 and selectedIndex and selectedIndex > 0 then
    self.objs[selectedIndex].rect:setFillColor(0, 1, 0)
    self.selection = self.objs[selectedIndex]
    self.value = self.objs[selectedIndex].text
    self.selectedIndex = selectedIndex
  end

  if self.selectedIndex then
    scrollView:scrollToPosition {y = -self.height * (self.selectedIndex - 1)}
  end

  self.scrollView = scrollView
end

--
--
function M:init(UI, x, y, w, h, type)
  self:_init(UI, x, y, w, h, type)
end

function M:_init(UI, x, y, w, h, type)
  self.x = x or display.contentCenterX
  self.y = y or display.contentCenterY
  self.UI = UI
  self.type = type
  -- print("@@@@@", type)

  self.height = w or 20
  self.width = h or 72
  -- self.x = self.x + self.width/2
  -- print("linkbox", UI.layers,  UI.page, UI.audios, UI.numberOfPages, UI.appFolder)
  -- for k, v in pairs(UI) do print("", k, v) end
  -- UI.layers
  -- local path =system.pathForFile( "App/"..App.get().name.."/models/"..UI.page.."/commands/"..UI.editor.currentAction..".json", system.ResourceDirectory)
  --

  option.width = self.width
  option.height = self.height
  self.option = option
end

--
function M:_create(UI)
  -- if self.rootGroup then
  --   return
  -- end
  self.rootGroup = UI.editor.rootGroup
  if self.triangle == nil then
    -- print(debug.traceback())
    self.triangle = shapes.triangle.equi(self.x + self.width + 5, self.y, 10)
    self.triangle:rotate(180)
    self.triangle:setFillColor(1, 1, 0)
    self.triangle.tap = function(event)
      print("triangle tap")
      if self.callbackTriagnle then
        self.callbackTriagnle(self.triangle.on)
      end
      self.scrollView.alpha = 1
      self.triangle.on = not self.triangle.on
      if self.triangle.on then
        --self.scrollView:translate(100,0)
        self.scrollView:setSize(self.width, self.height * #self.objs)
        self.scrollView:toFront()
        self.scrollView:scrollToPosition {y = 0}
      else
        -- self.scrollView:translate(-100,0)
        self.scrollView:setSize(self.width, self.height)
        if self.selectedIndex and self.selectedIndex > 0 then
          self.scrollView:scrollToPosition {y = -self.height * (self.selectedIndex - 1)}
        else
          self.scrollView:scrollToPosition {y = -self.height}
        end
      end
      return true
    end

    self.rootGroup:insert(self.triangle)
  else
    self.triangle.x = self.x + self.width / 2
    self.triangle.y = self.y
  end
  --
  ---
  self:hide()
end

function M:create(UI)
  self:_create(UI)
end
--

function M:_didShow(UI)
  local rootGroup = self.rootGroup
  if self.scrollView then
    self.scrollView.isVisible = true
    -- print("objs", #self.objs)
    for i = 1, #self.objs do
      local obj = self.objs[i]
      -- function obj:tap(e)
      --   print(e.target.name)
      --   M.value = e.target.name
      --   return true
      -- end
      obj:addEventListener("tap", obj)
    end
    self.triangle:addEventListener("tap", self.triangle)
  end
  --self.triangle:addEventListener( "mouse", self.triangle )
  if self.radioGroup then
    self.radioGroup.isVisible = true
  end
end
--
function M:_didHide(UI)
  if self.objs then
    for i = 1, #self.objs do
      local obj = self.objs[i]
      -- print("## removed ")
      obj:removeEventListener("tap", obj)
    end
    self.triangle:removeEventListener("tap", self.triangle)
  end
  if self.radioGroup then
    self.radioGroup.isVisible = false
  end
  --self.triangle:removeEventListener("mouse", self.triangle)
end

function M:didShow(UI)
  self:_didShow(UI)
end
--
function M:didHide(UI)
  self:_didHide(UI)
end
--
function M:hide()
  -- print("hide", self.name)
  if self.scrollView then
    self.scrollView.isVisible = false
  end
  if self.triangle then
    self.triangle.isVisible = false
  end
  if self.radioGroup then
    self.radioGroup.isVisible = false
  end
  --self.group.isVisible = false
end
--
function M:show()
  --self.group.isVisible = true
  -- print("show", self.name)
  if self.scrollView then
    self.triangle.isVisible = true
    self.scrollView.isVisible = true
  end
  if self.radioGroup then
    self.radioGroup.isVisible = true
  end
end
--
function M:toggle()
  -- print("toggle")
  if self.scrollView then
    self.triangle.isVisible = not self.triangle.isVisible
    self.scrollView.isVisible = self.triangle.isVisible
  end
end

--
function M:destroy(UI)
  if self.objs then
    for i = 1, #self.objs do
      -- print(i)
      self.objs[i].rect:removeSelf()
      self.objs[i]:removeSelf()
    end
  end
  if self.scrollView then
    self.scrollView:removeSelf()
  end
  if self.radioGroup then
    self.radioGroup:removeSelf()
  end
  self.scrollView = nil
  self.objs = nil
  self.radioGroup = nil
end

function M:removeSelf()
  self:destroy()
end

--
function M:isAltDown()
  return self.altDown
end
--
function M:isControlDown()
  return self.controlDown
end
--
function M:isShiftDown()
  return self.shiftDown
end

function Class.new(t)
  local instance = t or {}
  --instance.model = {layers={{name="bg"}, {name="title"}, {name="buttonA"}}}
  return setmetatable(instance, {__index = M})
end

--
return Class
