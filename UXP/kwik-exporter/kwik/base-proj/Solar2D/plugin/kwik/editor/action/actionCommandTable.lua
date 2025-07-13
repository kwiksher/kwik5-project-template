local name = ...
local parent, root, M = newModule(name)
-- attach drag-item scrollview to widget library
local dragItemScrollView         = require("dragitemscrollview")
local actionCommandTableListener = require(parent.."actionCommandTableListener")
local buttonContext              = require(parent.."buttonCommandContext")
local util                       = require(kwikGlobal.ROOT.."lib.util")
local widget                     = require("widget")
local keyEventManager            = require(kwikGlobal.ROOT .. "editor.keyEventManager")

M.top = display.contentCenterY-- 22
M.left = nil
M.width = 136
M.height = 240
M.dragtime = 100
M.angle = 20
M.radius = 20
M.touchthreshold = 0   -- touchthreshold or display.actualContentWidth * .1
M.groupName = "rootGroup"
M.selections = {}

local option, newText = util.newTextFactory {
    x = 0,
    y = 0,
    width = nil,
    height = 20,
  }

function M:createTable (foo, fooValue)
  local UI = self.UI
  local objs = {}
  local group = display.newGroup()
  --
  -- self.left = UI.editor.viewStore.commandView.contentBounds.xMax
  if UI.editor.rootGroup.actionTable then
    self.left = UI.editor.rootGroup.actionTable.contentBounds.xMax
  else
    local actionTable = require(kwikGlobal.ROOT.."editor.action.actionTable")
    self.left = actionTable.x
  end
  -- print("@@@@@@@ actionCommandTable", self.left)
  --
  option.parent = self.group
   -- create drag-item scrollview
  local scrollView = dragItemScrollView.new{
    backgroundColor = {1.0},
    left=self.left,
    top=self.top,
    -- top=(display.actualContentHeight-1280/4 )/2,
    width=self.width, --display.actualContentWidth - UI.editor.viewStore.commandView.contentBounds.xMax,
    height=self.height,
    hideBackground         = false,
    -- isBounceEnabled        = false,
    -- verticalScrollDisabled = false,
    backgroundColor        = {1.0},

  }
  --scrollView.x = display.contentCenterX
  -- scrollView.y = 0

  -- scrollView.isVisible = false

  local last_x, last_y = 0, 0

  for i, action in pairs(fooValue.actions) do
    local target, params = "", ""
    for k, v in pairs(action.params) do
      if k ~= "target" then
        params = params ..k ..":" .. tostring(v) .." "
      else
        target = tostring(v)
      end
    end

    option.text = action.command .." "..target or ""
    local obj = newText(option)
    obj.anchorX = 0
    --print("@@@@", option.text)

    scrollView:attachListener(obj,
      function(item, touchevent )
         item:addEventListener( "mouse", self.mouseHandler)
         self:listener(item, touchevent)
      end,
      self.dragtime, self.angle, self.radius) -- item, listener, dragtime, angle, radius, touchthreshold
    --
    obj.x, obj.y = last_x, last_y + 20
    last_x, last_y = obj.x, obj.y
    obj.action = action
    obj.params = params
    obj.target = target
    obj.index = i

    local rect = display.newRect(obj.x, obj.y, obj.width, obj.height)
    rect:setFillColor(1.0)
    rect.anchorX = 0
    obj.rect = rect

    group:insert(rect)
    group:insert(obj)
    scrollView:insert(group)
    objs[#objs+1] = obj

  end

  self.scrollView = scrollView
  self.group:insert(scrollView)

  self.objs = objs
  -- print("@@@@@@@", #objs)
  self.actions = fooValue.actions
end

function M:init(UI)
  buttonContext:init(UI)
end

function M.mouseHandler(event)
  -- print(event.isSecondaryButtonDown,event.target.isSelected )
  if event.isSecondaryButtonDown and event.target.isSelected then
    -- print("@@@@selected")
    buttonContext:showContextMenu(event.x + 20, event.y,  event.target, "actionCommand")
    --self.target = event.target
  else
    -- print("@@@@not selected")
  end
  return true
end

--
function M:create(UI)
  self.UI = UI
  self.group = display.newGroup()
  --self.group = UI.editor.actionEditor.group
  -- self.group = UI.editor[self.groupName]

  UI.editor.viewStore.actionCommandTable = self
  UI.editor.actionCommandStore:listen(function(foo, fooValue)
    self.readonly = fooValue.readonly
    self:createTable(foo, fooValue)
    self:show()
  end)
end

function M:didShow(UI)
  keyEventManager.register("actionCommandTable", function(event) return M:onKeyEvent(event) end, 1)
end
--
function M:didHide(UI)
  keyEventManager.unregister("actionCommandTable")
end

function M:hide()
  self.group.isVisible = false
end
function M:show()
  self.group.isVisible = true
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
  end
end

return setmetatable(M, {__index=actionCommandTableListener})

  -- create item to add to the scroll view (this will be dragged off the scrollview)
  -- local text1 = newText(option, "Animation-play title")
  -- local text2 = newText(option, "Audio-play bgm")
  -- local text3 = newText(option )


  -- add the drag-item to the scrollview
  --[[
    Params:
      item: Item to add to the scrollview
      listener: Listener function to call when a drag-off is detected
      Dragtime: Milliseconds that a hold will begin a drag-off
      Angle: Angle at which a touch-motion will begin a drag-off event
      Radius: Radius around the angle within which the drag-off will begin, outside this will not
      Touch-threshold: Distance a touch must travel to begin a drag-off (default is .1 of screen width)

    Description:
      This example will cause the white circle to be dragged off the scrollview only if the
      touch begins and does not move further than the touch-threshold within 450 milliseconds
      OR if the touch moves further than .1 of the screen width within 450 millisecond
      BUT ONLY if the touch moves within 90 degrees of immediately east (right) of the initial touch.

      The Dragtime determines how long a touch-and-hold will cause a drag to fire. Leave nil to
      have only touch with distance begin a drag-off.

      Angle and Radius define a range of direction which will fire a drag-off event. Outside of that
      will result in the scrollview being scrolled. Leave nil to have only touch-and-hold to fire a
      drag-off event.

      The Touch-threshold can be used to define the distance that a touch-and-move will fire a
      drag-off event. The default is .1 of the screen width.
  ]]--

  -- scrollView:attachListener( text1, listen, 100, 20, 20 )
  -- scrollView:attachListener( text2, listen, 100, 20, 20 )
  -- scrollView:attachListener( text3, listen, 100, 20, 20 )


  -- position the drag item in the scrollview
  -- text1.x, text1.y = 2, text1.height/2
  -- text2.x, text2.y = text1.x, text1.y + 20 --scrollView.x, scrollView.y + 20
  -- text3.x, text3.y = text2.x, text2.y + 20


  -- local function render (models, xIndex, yIndex)
  --   local count = 0
  --   for i = 1, #models do
  --     local model = models[i]
  --     model.name, model.class, model.children = parse(model)
  --     option.text = model.name
  --     option.x = UI.editor.viewStore.selectLayer.x + UI.editor.viewStore.selectLayer.width/2 + xIndex *5
  --     option.y = UI.editor.viewStore.selectLayer.contentBounds.yMax + 10 + option.height * count
  --     option.width = 100
  --     local obj = newText(option)
  --     obj.layer = model.name
  --     obj.class = ""
  --     obj.tap = commandHandler
  --     obj:addEventListener("tap", obj)
  --     count = count + 1
  --     -- class
  --     if model.class then
  --       local last_x = 10
  --       for k=1, #model.class do
  --         option.text = model.class[k]:sub(1, 5)
  --         option.x = UI.editor.viewStore.selectLayer.x + UI.editor.viewStore.selectLayer.width/2 + last_x
  --         option.y = UI.editor.viewStore.selectLayer.contentBounds.yMax + 10 + option.height * (count-1)
  --         option.width = nil
  --         local obj = newText(option)
  --         --obj.width = 50
  --         obj.layer = model.name
  --         obj.class = "_"..model.class[k]
  --         obj.tap = commandHandler
  --         obj:addEventListener("tap", obj)
  --         last_x = obj.width + 2
  --       end
  --     end
  --     -- children
  --     if #model.children then
  --       count = count + render(model.children, xIndex + 1, count )
  --     end
  --   end
  --   return count
  -- end

  -- UI.actionStore:listen(
  --   function(foo, fooValue)
  --     render(fooValue,0,0)
  --   end
  -- )

