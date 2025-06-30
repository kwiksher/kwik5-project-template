local M = {}

local model= {
  {name="animation"},
  {name="audio"},
  {name="button"},
  {name="canvas"},
  {name="countdown"},
  {name="drag"},
  {name="dynamic text"},
  {name="group"},
  {name="mask"},
  {name="multiplier"},
  {name="parallax"},
  {name="particles"},
  {name="physics body"},
  {name="physics collision"},
  {name="physics env"},
  {name="physics force"},
  {name="physics joint"},
  {name="pinch"},
  {name="scroll"},
  {name="set lang"},
  {name="shake"},
  {name="spin"},
  {name="sprite"},
  {name="swipe"},
  {name="sync audio text"},
  {name="text"},
  {name="text input"},
  {name="timer"},
  {name="transition"},
  {name="variable"},
  {name="video"},
}

local shapes = require("shapes")
local widget = require( "widget" )
local util = require(kwikGlobal.ROOT.."lib.util")

local numberOfRows=#model
local halfW = display.contentCenterX
local halfH = display.contentCenterY

---------------------------
M.name = "class"
M.selectedText = nil
M.objs = {}
--

local option, newText = util.newTextFactory{
    width    = 0,
    height   = 16,
}
--
local function createTable(triangle, rootGroup)
  -- print("@@@@ createTable")
  local labelText = display.newText{
      parent = rootGroup,
      text = M.name,
      x = triangle.x+18,
      y = triangle.y,
    fontSize = 10,
  }
  labelText.alpha = 0
  labelText:setFillColor( 0 )
  M.labelText = labelText

  local selectedText = display.newText{
    parent = rootGroup,
    text = "ALL",
    x = triangle.contentBounds.xMax + 2,
    y = triangle.y,
    fontSize = 10,
  }
  selectedText:setFillColor( 0 )
  selectedText.anchorX = 0
  M.selectedText = selectedText

  --
  local scrollView = widget.newScrollView
  {
    top                      = triangle.contentBounds.yMax,
    left                     = triangle.contentBounds.xMax,
    width                    = 64,
    height                   = #model*12,
    scrollHeight             = #model*12,
    hideBackground           = false,
    backgroundColor          = {0.8},
    verticalScrollDisabled   = false,
    horizontalScrollDisabled = true,
    friction                 = 2,
  }
  --scrollView.x=labelText.x
  ---[[

  local index = 0
  local function createRow(entry)
    -- print("createRow")
    local group = display.newGroup()
    -- name
    option.parent = group
    option.text   =  entry.name
    option.x = option.width/2 + 2 -- scrollView.x  --labelText.contentBounds.xMin - 100
    option.y = index * option.height + 12
    -- print(option.x, option.y)
    --
    local obj = newText(option)
    obj.name = entry.name
    obj.anchorX = 0
    -- print(obj.x, obj.y)
    -- local test = display.newRect(obj.x, obj.y, obj.width, obj.height)
    -- test:setFillColor(1,0,0,0.5)
    -- --
    scrollView:insert(obj)
    index = index + 1
    M.objs[index] = obj
  end
  --
  for k, entry in pairs(model) do
    createRow(entry)
  end
  --
  --scrollView.isVisible = false
  rootGroup:insert(scrollView)
  M.scrollView = scrollView
  --scrollView.anchorY = 0
--]]

end
--
--
function M:init(UI)
end
--
function M:create(UI, x, y)
  -- if self.rootGroup then return end
  self.rootGroup = UI.editor.rootGroup
  self.triangle = shapes.triangle.equi( x, y, 10 )
  self.triangle:rotate(180)
  self.triangle.tap = function(event)
    -- print("triangle tap")
    self.scrollView.isVisible = not self.scrollView.isVisible
    for i=1, #self.objs do
      local obj = self.objs[i]
      obj.isVisible = self.scrollView.isVisible
    end
    M.scrollView:toFront()

    if self.scrollView.isVisible then
      for i=1, #self.rootGroup.layerTable do
        self.rootGroup.layerTable[i]:translate(M.scrollView.width, 0)
        self.rootGroup.layerTable[i].rect:translate(M.scrollView.width, 0)

      end
    else
      for i=1, #self.rootGroup.layerTable do
        self.rootGroup.layerTable[i]:translate(-M.scrollView.width, 0)
        self.rootGroup.layerTable[i].rect:translate(-M.scrollView.width, 0)

      end
    end
    return true
  end
  ---
  self.triangle.mouse = function(event )
    --print(event.name, event.type, event.y)
    --for k, v in pairs(event) do print(k, v) end
    -- if event.type == "down" then
    --     if event.isPrimaryButtonDown then
    --         print( "Left mouse button clicked." )
    --     elseif event.isSecondaryButtonDown then
    --         print( "Right mouse button clicked." )
    --     end
    -- end
    if M.labelText.alpha == 0 then
      M.labelText.alpha = 1
      self.rootGroup.layerTable:translate(M.scrollView.width, 0)
      timer.performWithDelay( 1000, function()
        M.labelText.alpha = 0
        self.rootGroup.layerTable:translate(-M.scrollView.width, 0)
      end)
    end
  end
  --
  self.rootGroup:insert(self.triangle)
  createTable(self.triangle, self.rootGroup)
  return self.scrollView
end
--
function M:didShow(UI)
  local rootGroup = self.rootGroup
  self.scrollView.isVisible = false
  -- print("objs", #self.objs)
  for i=1, #self.objs do
    local obj = self.objs[i]
    function obj:tap(e)
      -- print(e.target.name)
      M.selectedText.text = e.target.name
      return true
    end
    obj:addEventListener("tap",obj)
  end
  self.triangle:addEventListener("tap", self.triangle)
  --self.triangle:addEventListener( "mouse", self.triangle )

end
--
function M:didHide(UI)
  -- print("didHide")
  for i=1, #self.objs do
    local obj = self.objs[i]
    obj:removeEventListener("tap", obj)
  end
  self.triangle:removeEventListener("tap", self.triangle)
  --self.triangle:removeEventListener("mouse", self.triangle)

end
--
function M:hide()
  -- print("hide")
  self.triangle.isVisible = false
  self.scrollView.isVisible = false
  self.selectedText.isVisible = false
end
--
function M:show ()
  -- print("show")
  self.triangle.isVisible = true
  self.scrollView.isVisible = false
  self.selectedText.isVisible = true
end
--
function  M:destroy(UI)
  -- print("destroy")
  for i=1, #self.objs do
    self.objs[i]:removeSelf()
  end
  self.objs = {}
end
--
return M