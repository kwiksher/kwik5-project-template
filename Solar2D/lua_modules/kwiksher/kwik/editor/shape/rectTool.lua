local current = ...
local parent,  root, M = newModule(current)
local popup  = require(parent.."popup")
local tools = require ("com.gieson.Tools")
local json = require("json")
local editorUtil = require(kwikGlobal.ROOT.."editor.util")

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"

function M:setActiveEntry(obj)
  self.activeEntry = obj
  local value = editorUtil.split(obj.text, ",") -- 0, 1920, 0, 1280
  self.xMin = value[1] or 0
  self.xMax = value[2] or 0
  self.yMin = value[3] or 0
  self.yMax = value[4] or 0
end

function M:drawRect()
  if self.onDraw then return end
  self.onDraw = true
  popup:create(self)
  --
  local tempShape, onKeyEvent, touchListener
  self.altDown = false
  self.controlDown = false
  self.shiftDown = false

  --
  local function _drawRect( xStart, yStart, x, y, phase )
    local width = xStart-x
    local height = yStart-y
    display.remove( tempShape )
    tempShape = nil

    local anchorX, anchorY = 1, 1
    if width < 0 then
      anchorX = 0
      width = -width
    end
    if height < 0 then
      anchorY = 0
      height = -height
    end

    local maxDistance = math.max( width, height )

    if self.shiftDown then
      width = maxDistance
      height = maxDistance
    end

    local xScale = width/maxDistance
    local yScale = height/maxDistance

    if xScale ~= 0 and yScale ~= 0 then
      local rectangle = display.newRect( xStart, yStart, width, height)
      rectangle.alpha = 0.5
      rectangle.anchorX, rectangle.anchorY = anchorX, anchorY
      rectangle.xScale, rectangle.yScale = xScale, yScale
      if  phase == "ended" or phase == "cancelled" then
        ---
        local w, h = rectangle.width, rectangle.height
        rectangle.xScale, rectangle.yScale = 1
        rectangle.width = rectangle.width*xScale
        rectangle.height = rectangle.height*yScale

        self.obj = rectangle
        Runtime:removeEventListener( "touch", touchListener )
        Runtime:removeEventListener("key", onKeyEvent)
        self.onDraw = false
      else
        -- popup:pos(x, y)
        popup:text(string.format("xMin: %d xMax: %d \n yMin: %d yMax: %d",
        tools:round(rectangle.contentBounds.xMin, 2),
        tools:round(rectangle.contentBounds.xMax, 2),
        tools:round(rectangle.contentBounds.yMin, 2),
        tools:round(rectangle.contentBounds.yMax, 2)))
        tempShape = rectangle
      end
    end
  end

  touchListener = function( event )
    local phase = event.phase
    if phase ~= "began" then
     local props = _drawRect( event.xStart, event.yStart, event.x, event.y, phase )
    end
    return true
  end

  onKeyEvent= function(event)
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print(M.name, message)
    -- for k, v in pairs(event) do print(k, v) end
    self.altDown = false
    self.controlDown = false
    self.shiftDown = false
    if isWindows then
      if event.phase == "down" then
        -- printKeys(event)
        self.altDown = event.isCtrlDown and event.isShiftDown
      elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
        self.controlDown = true
      elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
        self.shiftDown = true
      end
    else
      if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
        print("shape", message)
        self.altDown = true
      elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
        self.controlDown = true
      elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
        self.shiftDown = true
      end
    end
    -- print("controlDown", self.controlDown)
  end
  ---
  if self.xMin + self.xMax + self.yMin + self.yMax ~= 0 then
    self.obj = display.newRect(
      (self.xMin+self.xMax)/2*0.25 + display.contentWidth/4,
      (self.yMin + self.yMax)/2*0.25+display.contentHeight/4,
      (self.xMax - self.xMin)*0.25,
      (self.yMax-self.yMin)*0.25)
  else
    local margin = 50
    self.obj = display.newRect( display.contentCenterX, display.contentCenterY, 480-margin, 320-margin)
    -- Runtime:addEventListener( "touch", touchListener )
    -- Runtime:addEventListener("key", onKeyEvent)
  end
  popup:pos(display.contentCenterX, display.contentCenterY-400/2)
  self.obj.alpha = 0.5
  -- popup:pos(rectangle.x, rectange.y)
  popup:text(string.format("xMin: %d xMax: %d \n yMin: %d yMax: %d",
    tools:round(self.obj.contentBounds.xMin, 2),
    tools:round(self.obj.contentBounds.xMax, 2),
    tools:round(self.obj.contentBounds.yMin, 2),
    tools:round(self.obj.contentBounds.yMax, 2)))
end

--
-- kwik/layer_drag and template/components/pageX/interaction/layer_drag.lua
--
function M:move()
  if self.moveOn then return end
  self.moveOn = true

  local obj = self.obj
  local layerProps = {
    blendMode = "normal",
    height    =  obj.height,
    width     = obj.width,
    kind      = nil,
    name      = obj.name,
    type      = "png",
    x         = obj.x,
    y         = obj.y,
    alpha     = obj.alpha
  }

  local props = {
    commonAsset = "",
    -- buttonProps
    name ="",
    class = "", -- button, drag, canvas ...
    --
    constrainAngle = nil,
    bounds = {xStart=nil, xEnd=nil, yStart=nil, yEnd=nil},
    isActive = "",
    isFocus = true,
    isPage = false,
    --
    isFlip = true,
    flip = "right",  -- flipSet.right
    flipSet  = {
      right = {
        axis = "x",
        from = "right",
        to = "left",
        scaleStart = 1,
        scaleEnd = -1,
      },
      left = {
        axis = "x",
        from = "right",
        to = "left",
        scaleStart = -1,
        scaleEnd = 1,
      },
      bottom={
        axis = "y",
        from = "bottom",
        to = "top",
        scaleStart = 1,
        scaleEnd = -1,
      },
      top = {
        axis = "y",
        from = "bottom",
        to = "top",
        scaleStart = -1,
        scaleEnd = 1,
      },
    },
    --
    isDrop = false,
    dropArea = "",
    dropMargin = 10,
    --
    dropBound = {xStart=0, xEnd=0, yStart = 0, yEnd=0},
    --
    rock = 1, -- 0,
    backToOrigin = false,
    --
    actions={
      onDropped = nil,
      onReleased = nil, -- action
      onMoved= nil, -- action
      onShapeHandler = function(event)
        --
        -- for k, v in pairs(event) do print(k, v) end
        --
        local obj = event.target
        if event.phase == "ended" or event.phase == "cancelled" then
          self:removeEventListener()
          self.moveOn = false
        else
          if obj then
            -- popup:pos(x, y)
            popup:text(string.format("xMin: %d xMax: %d \n yMin: %d yMax: %d",
              tools:round(obj.contentBounds.xMin, 2),
              tools:round(obj.contentBounds.xMax, 2),
              tools:round(obj.contentBounds.yMin, 2),
              tools:round(obj.contentBounds.yMax, 2)))
          end
        end
      end
    },
    --
    layerProps = layerProps
  }

  local  layer_drag = require(kwikGlobal.ROOT.."components.kwik.layer_drag").set(props)
  --
  layer_drag:activate(obj)
  self.removeEventListener = function()
    self.moveOn = false
    layer_drag:deactivate( obj )
  end
end

-- Bing scale
function M:scale()
  if self.scaleOn then return end
  self.scaleOn = true
  local obj = self.obj

  -- local obj = display.newRect( 100, 100, 50, 50 )
  local startDragX, startDragY
  local startScaleX, startScaleY

  local function scaleShape( event )
    local obj = event.target
      if ( event.phase == "began" ) then
          display.getCurrentStage():setFocus( event.target )
          event.target.isFocus = true
          startDragX = event.x
          startDragY = event.y
          startScaleX = event.target.xScale
          startScaleY = event.target.yScale
      elseif ( event.phase == "moved" ) then
          local dragX = event.x - startDragX
          local dragY = event.y - startDragY
          local dragDistance = math.sqrt( dragX^2 + dragY^2 )
          local scaleAmount = dragDistance / 100
          event.target.xScale = startScaleX * scaleAmount
          event.target.yScale = startScaleY * scaleAmount

          -- popup:pos(x, y)
          popup:text(string.format("xMin: %d xMax: %d \n yMin: %d yMax: %d",
            tools:round(obj.contentBounds.xMin, 2),
            tools:round(obj.contentBounds.xMax, 2),
            tools:round(obj.contentBounds.yMin, 2),
            tools:round(obj.contentBounds.yMax, 2)))

      elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
          display.getCurrentStage():setFocus( nil )
          event.target.isFocus = false
          self:removeEventListener()
          self.scaleOn = false

      end
      return true
  end

  obj:addEventListener( "touch", scaleShape )
  self.removeEventListener = function()
    obj:removeEventListener( "touch", scaleShape )
  end
end

function M:save()
  print("save")
  popup:destroy()
  if self.obj then
    self.obj:removeSelf()
    self.obj = nil
  end
  if self.removeEventListener then
    self:removeEventListener()
  end
end

function M:cancel()
  print("cancel")
  popup:destroy()
  if self.obj then
    self.obj:removeSelf()
    self.obj = nil
  end
  if self.removeEventListener then
    self:removeEventListener()
  end
end

return M