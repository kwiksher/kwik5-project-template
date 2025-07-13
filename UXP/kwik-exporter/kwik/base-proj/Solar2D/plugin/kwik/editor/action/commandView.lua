local name = ...
local parent,root, M = newModule(name)
M.width  = 136
M.height = 240
M.top    = nil
M.left   = nil -- display.contentCenterX --  - 480*0.5 - M.width
M.groupName = "rootGroup"
---
local muiIcon = require(kwikGlobal.ROOT.."components.mui.icon").new()
local mui     = require("materialui.mui")
local muiData = require("materialui.mui-data")
local widget  = require("widget")
---
local controller     = require(parent.."controller.index")
local util = require(kwikGlobal.ROOT.."lib.util")

local option, newText = util.newTextFactory{
  width    = M.width,
  fontSize = 11,
  height   = 16,
}

function M:createTable(parent)
  local UI = self.UI
  --
  -- self.left = UI.editor[self.groupName].selectAction.rect.contentBounds.xMin
  self.top  = self.y or display.contentCenterY
  -- UI.editor[self.groupName].selectAction.y + 100

  self.left = self.x or UI.editor.viewStore.actionCommandTable.left
  -- + UI.editor.viewStore.actionCommandTable.width
  -- print("@@@@", UI.editor.viewStore.actionCommandTable.left, UI.editor.viewStore.actionCommandTable.width)

  --
  local scrollListener  = function(e) end
  local  scrollView = widget.newScrollView{
       top                    = self.top,
       left                   = self.left, --display.contentCenterX-200,
       width                  = self.width,
       height                 = 240,
    -- height                 = #models*18,
       scrollWidth            = display.contentWidth*0.5,
       scrollHeight           = display.contentHeight*0.8,
       hideBackground         = false,
       isBounceEnabled        = false,
       verticalScrollDisabled = false,
       backgroundColor        = {1.0},
       listener               = scrollListener
  }

  option.parent   = parent
  option.y        = self.y

  local count = 0
  for k, v in pairs(self.models or {}) do
    --print("actionEditor", self.name .. "-" .. v.name, v.icon)
    local obj = muiIcon:createImage {
      icon      = v.icon,
      text      = v.name,
      name      = self.name .. "-" .. v.name,
      x         = 60,
      y         = count*18,
      width     = 110,
      height    = 22,
      fontSize  = 10,
      iconSize  = 20,
      listener  = controller.commandGroupHandler,
      fillColor = {1.0}
    }
    -- print(obj.name)
    --
    -- option.text = v.name
    -- option.x = 60
    -- option.y = option.height * count
    -- local obj = newText(option)
    -- obj.name = v.name
    -- obj.tap = commandHandler
    -- obj:addEventListener("tap", obj)
    --
    obj.model = v
    obj.children = v.children or {}
    --print("", obj.name)
    self.commandMap[obj.name] = obj
    scrollView:insert(obj)
    count = count + 1
    --
    if self.activeEntry ==  self.name .. "-" .. v.name then
      for i=1, #obj.children do
        local entry = v.children[i]
        -- local obj = muiIcon:createImage {
        --   icon = entry.icon,
        --   text = entry.name,
        --   name = self.name .. "-" .. v.name.. "-"..entry.name,
        --   x = 70,
        --   y = count*18,
        --   width = 120,
        --   height = 18,
        --   fontSize =12,
        --   listener = commandHandler
        -- }
        --
        option.text = entry.name
        option.x = 120
        option.y = option.height * count + 30
        --
        local obj = newText(option)
        obj.name = entry.name
        obj.tap = controller.commandHandler
        obj:addEventListener("tap", obj)
        obj.model = entry
        --
        self.commandMap[obj.name] = obj
        scrollView:insert(obj)
        count = count + 1
      end
    end
  end
  -- print("###", scrollView.x, scrollView.y, scrollView.contentBounds.xMin, scrollView.contentBounds.xMax, scrollView.contentBounds.yMin, scrollView.contentBounds.yMax)
  return scrollView
end

function M:set(models, commandMap)
  self.models = models
  self.commandMap = commandMap
end

function M:init(UI,x ,y, models, commandMap)
  self.x = x
  self.y = y
  self.models = models
  self.commandMap = commandMap
end

function M:createCommandview()
  local group = self.UI.editor[self.groupName]
  local scrollView = self:createTable(group)
  group:insert(scrollView)
  group.commandView = scrollView
  self.UI.editor.viewStore.commandView = scrollView
end


function M:create(UI)
  -- if UI.editor.viewStore.actionCommandTabe then
    -- local group = UI.editor.actionEditor.group
    self.UI = UI
    ---
    UI.editor.actionCommandStore:listen(function(foo, fooValue)
      if  UI.editor.viewStore.commandView == nil then
        self:createCommandview()
      end
    end)
   -- end
end
--
function M:didShow(UI)
end
--
function M:didHide(UI)
end
--
function M:destroy()
end

function M:toggle()
end

function M:show()
end

function M:hide()
end


--
return M
