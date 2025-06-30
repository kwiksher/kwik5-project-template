local current = ...
local parent,  root = newModule(current)

local M = {
  x = display.contentCenterX - 480/2 + 10, --10, -- display.contentCenterX/2,
  y = display.contentCenterY + 320/2+5,
  width = 480 -20,
  height = 240/2 -40,
  rowWidth = 60,
  rowHeight = 20
}
-- attach drag-item scrollview to widget library
require("dragitemscrollview")
-- load widget library
local widget = require("widget")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")

local textProps = require(parent.."textProps")
--I/F

local headers = {}
-- for sync
headers.line = {"name", "start", "out", "dur", "file", "action"}
-- for spritesheet
headers.sequenceData = {"name", "start", "count", "frames", "loopCount", "loopDirection", "time", "pause"}

M.headers = headers

-- name   start   out   dur file action
--  A   1.00   2.00         a.mp3
--  B   2.00   4.00         b.mp3
--
function M:getValue()
  local ret = {}
  for i, obj in next, self.objs do
    if obj.index > 0 then
      local entry = ret[obj.index]
      if entry == nil then
        entry = {}
        ret[#ret + 1] = entry
      end
      entry[obj.name] = obj.text
      if ( obj.name == "start" or obj.name == "count" ) and obj.text =="" then
        entry[obj.name] = NIL
      end
      if obj.name == "frames" then
        local len =  obj.text:len()
        entry[obj.name] = obj.text:sub(2, len-1)
      end
      if obj.name == "dur" and obj.text == "" then
        entry.dur = 0
      end
    end
  end
  -- print(json.encode(ret))
  return ret
end

function M:setValue(fooValue, type)
  -- self:destroy()
  self.type = type or self.type
  self.value = fooValue or self.value
  -- print("####", self.type, #self.value)
  -- print(json.prettify(self.value))
  self:createTable()
end

--
function M:create(UI)
  self.rootGroup = UI.editor.rootGroup
  self.rootGroup.listPropsTable = display.newGroup()
  --
  self.singleClickEvent = function(obj)
    -- print("@@@", obj.index)
    UI.scene.app:dispatchEvent {
      name = "editor.replacement.list.select",
      UI = UI,
      index = obj.index,
      value = obj.value,
      type = obj.type
    }
    if self.selection and self.selection ~= obj and self.selection.rect.setFillColor then
      self.selection.rect:setFillColor(1)
    end
    self.selection = obj
    self.selection.rect:setFillColor(0,1,0)

    textProps:hide()
  end
  --
  self.addEvent = function(obj)
    UI.scene.app:dispatchEvent {
      name = "editor.replacement.list.add",
      UI = UI,
      index = #self.value,
      value = nil,
      type = self.type
    }
  end
end


    -- create a listener to handle drag-item commands
function M:listener( item, touchevent )
  -- print("@@@@")
  if touchevent.phase  == "ended" then
    -- print("single click event")
    -- this opens a commond editor table
    self.singleClickEvent(item)
  else
    display.currentStage:insert( item )
    item.x, item.y = touchevent.x, touchevent.y
    -- print(item.x, item.y)
    --
    local function touch(e)
      --print("touch", e.phase, e.target.hasFocus)
      if (e.phase == "began") then
        display.currentStage:setFocus( e.target, e.id )
        e.target.hasFocus = true
        return true
      elseif (e.target.hasFocus) then
        e.target.x, e.target.y = e.x, e.y
        -- print("", e.target.x, e.target.y)
        if (e.phase == "moved") then
        elseif (e.phase == "ended") then
          -- print(e.phase, e.target.x, e.target.y)
          display.currentStage:setFocus( e.target, nil )
          e.target.hasFocus = nil
          local localX, localY = self.scrollView:contentToLocal(  e.target.x,  e.target.y )
          --[[

            e.target.x = localX + self.scrollView.width/2
            e.target.y = localY + self.scrollView.height/2
            -- print("", e.target.x, e.target.y)
            -- print("--------")
            local function compare(a,b)
              return a.y < b.y
            end
            --
            table.sort(self.objs,compare)
            local objs = {}
            for i=1, #self.objs do
              print(i, self.objs[i].index, self.objs[i].entry.command)
              [i] = self.objs[i].entry
            end
            self:destroy()
            self:createTable(self.type,  objs)
            --]]
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

local option, newText = util.newTextFactory{
  width = nil,
  height = 20,
}

function M:createTable()
  self.objs = {}
  option.parent = self.rootGroup
  option.text = self.name or ""
  option.x = self.x
  option.y = self.y
  option.align="center"

  -- printKeys(option)
  -- print(debug.traceback())

  local labelText = newText(option)

   -- create drag-item scrollview
  local index = 0
  local function createRow(row)
    for i=1, #row do
      local group = display.newGroup()
      --
      local type = type(row[i])
      if type == 'table' then
        row[i] =  json.encode(row[i])
      end
      option.text    = row[i]
      local obj      = newText(option)
      obj.x, obj.y   = i*self.rowWidth -40, index*self.rowHeight + 4 + 4
      obj.value      = row
      obj.index      = index
      obj.type       = self.type
      obj.name       = headers[self.type][i]
      --
      local rect = display.newRect(obj.x, obj.y, obj.width, obj.height)
      rect:setFillColor(1)
      -- rect.anchorX = 0
      obj.rect = rect
      ---
      group:insert(rect)
      group:insert(obj)
      self.scrollView:insert(group)
      self.scrollView:attachListener(obj,
        function(item, touchevent )
          self:listener(item, touchevent)
        end, 100, 20, 20)
      --
      self.objs[#self.objs+1] = obj
    end
    index = index + 1
  end

  -- local headers = {"_name"}
  -- local headerMap = {}
  -- for i, entry in pairs(fooValue) do
  --   for k, v in pairs(entry) do
  --     if k~="name" and headerMap[k] == nil then
  --       headerMap[k] = k
  --       headers[#headers+1] = k
  --       print(k)
  --     end
  --   end
  -- end
  -- local function compare(a, b) return a < b end
  -- --
  -- table.sort(headers, compare)
  -- --

  self.scrollView = widget.newDragItemsScrollView{
    backgroundColor = {1.0},
    left = self.x,
    top = self.y ,
    -- top=(display.actualContentHeight-1280/4 )/2,
    width= self.width, --display.contentWidth -20,
    -- width= self.width * #headers[self.type],
    height=self.height
  }
  --
  createRow(headers[self.type])
  --  --
  for i, entry in next, self.value do
    -- print(i, entry)
    local row = {}
    for k, header in next ,headers[self.type] do
      -- if headers[i] == "_name" then
      --   row[i] = entry["name"]
      -- else
      -- print("", header)
      row[k] = entry[header] or ""
      -- end
    end
    -- print(i, json.encode(row))
    createRow(row)
  end

  self.rootGroup:insert(self.scrollView)

  --
  option.text = "Add"
  option.x = self.scrollView.contentBounds.xMax - 10
  option.y = self.scrollView.contentBounds.yMin - 5
  option.width = 40
  option.height = 20

  local canvas = display.newContainer(option.width, option.height)
  canvas.x = option.x
  canvas.y = option.y

  -- Create the rectangle first
  local rect = display.newRoundedRect(0, 0, option.width, option.height, 4)
  rect:setFillColor(0, 0, 1)
  canvas:insert(rect)

  -- Position the text at 0,0 (center of the container)
  option.x = 0
  option.y = 0
  -- Make sure anchor point is center and align is center
  option.align = "center"
  self.addButton = newText(option)
  self.addButton:setFillColor(1, 1, 1)
  -- Set anchor point if not already set by newText
  self.addButton.anchorX = 0.5
  self.addButton.anchorY = 0.25
  canvas:insert(self.addButton)

  -- Move container to front
  canvas:toFront()

  -- Add event listener to the rect
  rect:addEventListener("tap", self.addEvent)
  self.addButton.rect = rect
end


function M:didShow(UI) end
--
function M:didHide(UI) end

function M:hide()
  if self.scrollView then
    self.scrollView.isVisible = false
    self.addButton.isVisible = false
    self.addButton.rect.isVisible = false
  end
end

function M:show()
  if self.scrollView then
    self.scrollView.isVisible = true
    self.addButton.isVisible = true
    self.addButton.rect.isVisible = true
  end
end

--
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
    self.addButton.rect:removeSelf()
    self.addButton:removeSelf()
  end
end


return M