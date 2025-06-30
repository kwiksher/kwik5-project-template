local M = {}
M.name = ...
-- attach drag-item scrollview to widget library
require("dragitemscrollview")

local utileditor = require(kwikGlobal.ROOT.."editor.util")
local util = require(kwikGlobal.ROOT.."lib.util")

-- local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"


local option, newText = util.newTextFactory{
  height = 20,
  -- fontSize = 10,
  anchorX = 0
}

-- load widget library
local widget = require("widget")

function M:getValue()
  -- for i, v in next, self.members do
  --   print("", v)
  -- end
  return self.members or {}
end

function M:getLayers()
  return self.members
end

function M:getSelections()
 return self.selections
end

local function onKeyEvent(event)
  -- Print which key was pressed down/up
  -- print("onKeyEvent")
  --
  local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase

  if isWindows then
    -- Set altDown to true if both Ctrl and Shift are pressed
    if event.phase == "down" then
      M.altDown = event.isCtrlDown and event.isShiftDown
    else
      M.altDown = false
    end
  else
    -- Original Alt key handling for non-Windows platforms
    if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
      M.altDown = true
    elseif (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "up" then
      M.altDown = false
    end
  end
end

function M:init(UI, x, y, width, height)
  self.x = x
  self.y = y
  self.width= width or 80*2
  self.height=height or 200
  self.selections = {}

end
--

function M:showFocus()
  local UI = self.UI
  if UI.editor.focusGroup then
    UI.editor.focusGroup:removeSelf()
  end
  local group = display.newGroup()
  UI.sceneGroup:insert(group)
  UI.editor.focusGroup = group
  --
  for i, v in next, self.selections do
    print(i, v.obj.text)
    local obj = UI.sceneGroup[v.obj.text]
    if obj then
      -- print("@", v.text, obj.x, obj.y)
      local posX, posY = obj.x, obj.y
      local rect = display.newRect(UI.editor.focusGroup, posX, posY, obj.width, obj.height)
      rect:setFillColor(1, 0, 0, 0)
      rect:setStrokeColor(0, 1, 0)
      rect.strokeWidth = 1
      rect.xScale = obj.xScale
      rect.yScale = obj.yScale
      rect.anchorX = obj.anchorX
      rect.anchorY = obj.anchorY
      rect.rotation = obj.rotation
      transition.from(rect, {time=100, xScale=3, yScale=3})
    end
  end
end

function M:create(UI)
  self.UI = UI
  -- if self.group then return end
  self.group = display.newGroup()
  --UI.editor.viewStore:insert(self.group)

  option.parent = self.group
  option.width = self.width

  self.singleClickEvent = function(obj)
    utileditor.setSelection(self, obj)
  end


  -- create a listener to handle drag-item commands
  local function listener( item, touchevent )
    print(touchevent.id)
    -- if touchevent.pahse == "began" then
    --   item.markX = item.x
    --   item.markY = item.y

    if touchevent.phase  == "ended" then
      -- print("single click event")
      -- this opens a commond editor table
      self.singleClickEvent(item)
      --for k, v in pairs (self.selections[1]) do print(k, v) end
      self:showFocus()
    else

      local function touch(e)
        local target = e.target
        --print("@@touch", e.phase, e.target.hasFocus)
        if (e.phase == "began" or target.markX == nil) then
         target.markX, target.markY = target.x, target.y
          --
          -- display.currentStage:insert( target )
          --
          display.currentStage:setFocus( target, e.id )
          target.hasFocus = true

          target.x = e.x - e.xStart + target.markX
          target.y = e.y - e.yStart + target.markY

          return true
        elseif (target.hasFocus) then
          -- print("", target.x, target.y)
          if (e.phase == "moved") then
            target.x = e.x - e.xStart + target.markX
            target.y = e.y - e.yStart + target.markY
          else
            -- print(e.phase, target.x, target.y)
            display.currentStage:setFocus( target, nil )
            target.hasFocus = nil
            self.scrollView:attachListener(target, listener, 100, 20, 20) -- dragtime, angle, radius,(touchthreshold)
            --
            local function compare(a,b)
              return  a.y < b.y
            end

            target.obj.y = target.obj.y + target.y
            table.sort(self.objs,compare)
            local _layers = {}
            for i, v in next, self.objs do
              -- print(i, v.text, v.y)
              _layers[i] = v.text
            end
            -- reset
            UI.editor.groupLayersStore:set{members=_layers} -- layersTable
            --
          end
          return true
        end
        return false
      end
      --
      item.hasFocus = true
      display.currentStage:setFocus( item, touchevent.id )
      -- print("add")
      item:addEventListener( "touch", touch )
    end
  end

  self.listener = listener


  UI.editor.groupLayersStore:listen(
      function(foo, fooValue)
        if fooValue == nil then return end
        -- local json = require("json")
      --  print(json.prettify(fooValue))

        local objs = {}
         -- create drag-item scrollview
        local scrollView = widget.newDragItemsScrollView{
          backgroundColor = {1.0},
          left=self.x, -- M.rootGroup.layerbox.contentBounds.xMax,
          top= self.y, -- 22,
          -- top=(display.actualContentHeight-1280/4 )/2,
          width=self.width, -- display.actualContentWidth - M.rootGroup.layerbox.contentBounds.xMax,
          height=self.height -- 240
        }
        --scrollView.x = display.contentCenterX
        -- scrollView.y = 0

        self.scrollView = scrollView
        self.group:insert(scrollView)
        -- scrollView.isVisible = false

        local last_x, last_y = 2, 0 -- scrollView.x , scrollView.y

        self.members = fooValue.members or {}
        -- print(#self.members)
        for i=1, #self.members do
          local _group = display.newGroup()

          local name = fooValue.members[i]
          option.text = name
          -- print(name)
          local obj = newText(option)

          scrollView:attachListener(_group, listener, 100, 20, 20) -- dragtime, angle, radius,(touchthreshold)
          obj.x, obj.y = last_x, last_y + 20
          last_x, last_y = obj.x, obj.y
          obj.index = i

          local rect = display.newRect(obj.x, obj.y, obj.width, obj.height)
          rect:setFillColor(1)
          rect.anchorX = 0
          obj.rect = rect

          _group:insert(rect)
          _group:insert(obj)
          _group.obj = obj
          _group.rect = rect
          obj.parent = _group
          scrollView:insert(_group)
          objs[#objs+1] = obj

        end
        -- print("num of objs", #objs)
        self.objs = objs
      end
    )
end


function M:didShow(UI)
  -- print("didShow")
  Runtime:addEventListener("key", onKeyEvent)
end
--
function M:didHide(UI)
  -- print("didHide")
  Runtime:removeEventListener("key", onKeyEvent)
end
--
function M:hide(UI)
  if self.objs then
    for i=1, #self.objs do
      self.objs[i].isVisible = false
      if self.objs[i].rect then
        self.objs[i].rect.isVisible = false
      end
    end
  end
  if self.scrollView then
    self.group.isVisible = false
    self.scrollView.isVisible = false
  end
end
--
function M:show(UI)
  if self.objs then
    for i=1, #self.objs do
      self.objs[i].isVisible = true
      if self.objs[i].rect then
        self.objs[i].rect.isVisible = true
      end
    end
  end
  if self.scrollView then
    self.group.isVisible = true
    self.scrollView.isVisible = true
  end
end

function M:destroy()
  if self.objs then
    for i=1, #self.objs do
      if self.objs[i].rect then
        self.objs[i].rect:removeSelf()
      end
      self.objs[i]:removeSelf()
    end
    self.objs = nil
  end

  if self.scrollView then
    self.scrollView:removeSelf()
    self.scrollView = nil
  end
end

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


return M