-- https://forums.solar2d.com/t/draw-with-finger-and-calculate-an-ellipse-from-the-points/351387/3
local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"


M = {}

local json = require("json")

-- local transition = require("transition2")

function M:init()
end

function M:create()
end

function M:didShow()
end

function M:didHide()
end

function M:destroy()
end

function M:hide()
  if self.removeEventListener then
    self.removeEventListener()
    self.removeEventListener = nil
  end
end

function M:show()
end

local function countShapes(shape, objs)
  local count = 0
  for i, obj in next, objs do
    if obj.name:find(shape) then
      count = count +1
    end
  end
  return count
end


local function getProps(obj, index)
  local _props = json.decode(obj._properties)
  _props.isNew = true -- recreate it for moving
  _props.isMove = true -- recreate it for moving
  _props.shapedWith = obj.shapedWith or "new_image"
  _props.name = obj.name or "layer"..index
  _props.kind = obj.kind
  _props.type = obj.type
  _props.align = obj.align
  _props.layerAsBg = obj.layerAsBg or "nil"
  _props.isSharedAsset = obj.isSharedAsset or "nil"
  _props.randXStart = obj.randXStart or "nil"
  _props.randYStart = obj.randYStart or "nil"
  _props.randXEnd = obj.randXEnd or "nil"
  _props.randYEnd = obj.randYEnd or "nil"
  return _props
end


function M.drawRect(UI, listener)
  local onCreate = listener
  local tempShape, onKeyEvent, touchListener
  --
  local function _drawRect( xStart, yStart, x, y, isFinal )
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

    if M.shiftDown then
      width = maxDistance
      height = maxDistance
    end

    local xScale = width/maxDistance
    local yScale = height/maxDistance

    if xScale ~= 0 and yScale ~= 0 then
      local rectangle = display.newRect( xStart, yStart, width, height)
      rectangle.anchorX, rectangle.anchorY = anchorX, anchorY
      -- print(rectangle.anchorX, rectangle.anchorY)
      -- rectangle.xScale, rectangle.yScale = xScale, yScale
      rectangle:setFillColor(0.8)

      if isFinal then -- phase == "ended"
        print("anchor", rectangle.anchorX, rectangle.anchorY)
        print("scale", rectangle.scaleX, rectangle.scahleY)

        local deltaX, deltaY = rectangle.width * 0.5, rectangle.height * 0.5
        if anchorX == 1 then
          deltaX = -1*deltaX
        end
        if anchorY == 1 then
          deltaY = -1*deltaY
        end
        -- rectangle.width = rectangle.width/xScale
        -- rectangle.height = rectangle.height/yScale
        -- rectangle.xScale, rectangle.yScale = 1,1

        rectangle.anchorX, rectangle.anchorY = 0.5, 0.5
        rectangle:translate(deltaX, deltaY)
        ---
        local _props = json.decode(rectangle._properties)
        _props.isNew = true
        _props.shapedWith = "new_rectangle"
        _props.name = "rect_"..countShapes("rect_", UI.layers)
        _props.x, _props.y = UI.sceneGroup:contentToLocal(_props.x, _props.y)

        UI.scene.app:dispatchEvent {
          name = "editor.classEditor.save",
          UI = UI,
          decoded = nil, --selectbox.decoded,
          props = _props
        }

        Runtime:removeEventListener( "touch", touchListener )
        Runtime:removeEventListener("key", onKeyEvent)
        if onCreate then
          onCreate("ended", _props)
        end
      else
        tempShape = rectangle
      end
    end
  end

  touchListener = function( event )
    local phase = event.phase
    if phase == "moved" or phase == "ended" then
     local props = _drawRect( event.xStart, event.yStart, event.x, event.y, phase == "ended" )
    end
    return true
  end

  onKeyEvent= function(event)
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print(M.name, message)
    -- for k, v in pairs(event) do print(k, v) end
    M.altDown = false
    M.controlDown = false
    M.shiftDown = false
    if isWindows then
      if event.phase == "down" then
        -- print("shape", message)
        M.altDown = event.isCtrlDown and event.isShiftDown
      elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
        M.controlDown = true
      elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
        M.shiftDown = true
      end
    else
      if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
        print("shape", message)
        M.altDown = true
      elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
        M.controlDown = true
      elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
        M.shiftDown = true
      end
    end
    -- print("controlDown", M.controlDown)
  end
  ---
  Runtime:addEventListener( "touch", touchListener )
  Runtime:addEventListener("key", onKeyEvent)
  M.removeEventListener = function()
    Runtime:removeEventListener( "touch", touchListener )
    Runtime:removeEventListener("key", onKeyEvent)
  end
end

function M.drawEllipse(UI)
  local tempShape
  --
  local function drawEllipse( xStart, yStart, x, y, isFinal )
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
    local xScale = width/maxDistance
    local yScale = height/maxDistance

    if M.controlDown then
       if xScale > yScale then
         yScale = xScale
       else
        xScale = yScale
       end
    end

    if xScale ~= 0 and yScale ~= 0 then
      local ellipse = display.newCircle( xStart, yStart, maxDistance*0.5 )
      ellipse:setFillColor(0.8)
      ellipse.anchorX, ellipse.anchorY = anchorX, anchorY
      ellipse.xScale, ellipse.yScale = xScale, yScale

      if isFinal then

        local cB = ellipse.contentBounds
        -- local deltaX, deltaY = ellipse.width * 0.5, ellipse.height * 0.5
        local deltaX, deltaY = (cB.xMax- cB.xMin) * 0.5, (cB.yMax-cB.yMin) * 0.5
        if anchorX == 1 then
          deltaX = -1*deltaX
        end
        if anchorY == 1 then
          deltaY = -1*deltaY
        end
        --ellipse:translate(deltaX, deltaY)
        -- print(ellipse.anchorX, ellipse.anchorY, ellipse.x, ellipse.y)
        -- print(ellipse.anchorX, ellipse.anchorY, ellipse.x, ellipse.y)
        ellipse.anchorX, ellipse.anchorY = 0.5, 0.5
        ellipse:translate(deltaX, deltaY)

        local _props = json.decode(ellipse._properties)
        _props.isNew = true
        _props.shapedWith = "new_ellipse"
        _props.name = "ellipse_"..countShapes("ellipse_", UI.layers)
        _props.x, _props.y = UI.sceneGroup:contentToLocal(_props.x, _props.y)

        UI.scene.app:dispatchEvent {
          name = "editor.classEditor.save",
          UI = UI,
          decoded = nil, --selectbox.decoded,
          props = _props
        }

        Runtime:removeEventListener( "touch", touchListener )
        Runtime:removeEventListener("key", onKeyEvent)
        if onCreate then
          onCreate("ended", _props)
        end
      else
        tempShape = ellipse
      end
    end
  end

  local function touchListener( event )
    local phase = event.phase
    if phase == "moved" or phase == "ended" then
      drawEllipse( event.xStart, event.yStart, event.x, event.y, phase == "ended" )
    end
    return true
  end

  Runtime:addEventListener( "touch", touchListener )
end

function M.drawText(UI, listener)
  local onCreate = listener
  local tempShape, _drawRectForText, textListener
  --
  local options = {
    parent   = nil,
    text     = "",
    x        = 0,
    y        = 0,
    width    = 80,
    height   = 16,
    font     = native.systemFont,
    fontSize = 10,
    align    = "center"
  }
  --
  local function touchListener( event )
    local phase = event.phase
    if phase == "moved" or phase == "ended" then
      local obj = _drawRectForText( event.xStart, event.yStart, event.x, event.y, phase == "ended" )
      if obj then -- this means ended
        obj.field.userInput = function(event)
          textListener(obj, event)
        end
        native.setKeyboardFocus( obj.field )
        obj.field:setReturnKey( "done" )
        obj.field:addEventListener( "userInput", obj.field.userInput )

        -- obj.tap = function(event)
        --   print("tap")
        -- end
        -- --
        -- obj:addEventListener("tap",obj)
        if onCreate then
          onCreate("editor", obj)
        end

      end
    end
    return true
  end
  --
  -- this obj is retuned by _drawRectForText
  textListener = function(obj, event )
    for k, v in pairs(event) do print(k, v) end
		if ( event.phase == "began" ) then
 		-- User begins editor "defaultField"
		elseif ( event.phase == "ended" or event.phase == "submitted" ) then
			-- Output resulting text from "defaultField"
			print( event.target.text, event.newCharacters )
      obj.text = obj.text .. (event.newCharacters or "")
      event.target:removeEventListener( "userInput", event.target )
      event.target.isVisible = false

      print(obj.x, obj.y, obj.width, obj.height)
      print(obj.rect.x, obj.rect.y, obj.rect.width, obj.rect.height, obj.rect.anchorX, obj.rect.anchorY)
      Runtime:removeEventListener("touch", touchListener )
      --
      local _props = json.decode(obj._properties)
      _props.isNew = true
      _props.shapedWith = "new_text"
      _props.name = "text_"..countShapes("text_", UI.layers)
      _props.font = "native.systemFont"
      _props.fontSize= _props.size
      _props.text = obj.text
      _props.align = "center"
      _props.fill = {r=0, g=0, b=0, a=1}

      UI.scene.app:dispatchEvent {
        name = "editor.classEditor.save",
        UI = UI,
        decoded = nil, --selectbox.decoded,
        props = _props
      }

      if onCreate then
        onCreate("ended", _props)
      end

      obj.field:removeSelf()
      obj.rect:removeSelf()
      obj:removeSelf()

      Runtime:removeEventListener( "touch", touchListener )
      Runtime:removeEventListener("key", onKeyEvent)
		elseif ( event.phase == "editor" ) then
			print( event.newCharacters )
			print( event.oldText )
			print( event.startPosition )
			print( event.text )
      obj.text = obj.text ..event.newCharacters

		end
	end
  --
  _drawRectForText = function( xStart, yStart, x, y, isFinal )
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

    if M.shiftDown then
      width = maxDistance
      height = maxDistance
    end

    local xScale = width/maxDistance
    local yScale = height/maxDistance

    if xScale ~= 0 and yScale ~= 0 then
      local rectangle = display.newRect( xStart, yStart, width, height)
      rectangle.anchorX, rectangle.anchorY = anchorX, anchorY
      rectangle.xScale, rectangle.yScale = xScale, yScale
      rectangle:setFillColor(0.8)
      rectangle.strokeWidth = 1
      rectangle:setStrokeColor(0, 1, 0, 0.8)

      if isFinal then
        --
        local deltaX, deltaY = rectangle.width * 0.5, rectangle.height * 0.5
        if anchorX == 1 then
          deltaX = -1*deltaX
        end
        if anchorY == 1 then
          deltaY = -1*deltaY
        end
        rectangle:translate(deltaX, deltaY)
        rectangle.anchorX, rectangle.anchorY = 0.5, 0.5

        ---
        options.x = rectangle.x
        options.y = rectangle.y
        options.width = rectangle.width
        options.height = rectangle.height

        --
        local obj = display.newText(options)
        obj.anchorX = rectangle.anchorX
        obj.anchorY = rectangle.anchorY


        -- local obj = display.newText(options.text, rectangle.x, rectangle.y, options.font, options.fontSize )
                -- local obj = display.newText(options.text, rectangle.x+rectangle.width/2, rectangle.y + rectangle.height*0.25, options.font, options.fontSize )
        -- obj.x, obj.y = rectangle.x + rectangle.width/2, rectangle.y + rectangle.height*0.25
        obj.rect = rectangle

        local field = native.newTextField( obj.x, obj.y, obj.width, obj.height/2 )
        field.font = native.newFont( options.font, 8 )
        -- field:resizeFontToFitHeight()
        --field.placeholder = "Enter text"
        field.text = options.text
        field.anchorX = obj.anchorX
        field.anchorY = obj.anchorY

        obj.field = field
        return obj
        --
        -- rectangle:removeSelf()
        --

      else
        tempShape = rectangle
      end
    end
  end


  local function onKeyEvent(event)
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print(M.name, message)
    -- for k, v in pairs(event) do print(k, v) end
    M.altDown = false
    M.controlDown = false
    M.shiftDown = false
    if isWindows then
      if event.phase == "down" then
        -- printKeys(event)
        M.altDown = event.isCtrlDown and event.isShiftDown
      elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
        M.controlDown = true
      elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
        M.shiftDown = true
      end
    else
      if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
        -- print(message)
        M.altDown = true
      elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
        M.controlDown = true
      elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
        M.shiftDown = true
      end
    end
    -- print("controlDown", M.controlDown)
  end
  ---
  Runtime:addEventListener( "touch", touchListener )
  Runtime:addEventListener("key", onKeyEvent)
  M.removeEventListener = function()
    Runtime:removeEventListener( "touch", touchListener )
    Runtime:removeEventListener("key", onKeyEvent)
    end
end

--
-- kwik/layer_drag and template/components/pageX/interaction/layer_drag.lua
--
function M.move(UI, obj, listener)
  local onMove = listener
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
    isFlip = false,
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
        for k, v in pairs(event) do print(k, v) end
        --
        if event.phase == "ended" then
          local obj = event.target
          print("@@@@@", obj.name, obj.shapedWith)
          local _props = getProps(obj, #UI.layers)
          print(json.prettify( _props ))
          UI.scene.app:dispatchEvent {
            name = "editor.classEditor.save",
            UI = UI,
            decoded = nil, --selectbox.decoded,
            props = _props
          }
          if onMove then
            onMove("ended", _props)
          end
        end
      end
    },
    --
    layerProps = layerProps
  }

  local self = require(kwikGlobal.ROOT.."components.kwik.layer_drag").set(props)
  --
  self:activate(obj)
  M.removeEventListener = function()
    self:deactivate( obj )
  end
end

-- kwik/layer_spin
function M.spin(obj)
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
    name="",
    --
    constrainAngle = 360,
    bounds = {xStart=nil, xEnd=nil, yStart=nil, yEnd=nil},
    isActive = "",
    --
    actions={
      onClokwise = nil,
      onCounterClockwise = nil,
      onReleased =nil,
      -- onMoved="{{}}"
      onShapeHandler = function(event)
        for k, v in pairs(event) do print(k, v) end
      end
    },
    --
    layerProps = layerProps
  }

  local self = require(kwikGlobal.ROOT.."components.kwik.layer_spin").set(props)
  self:activate(obj)
  M.removeEventListener = function()
    self:deactivate( obj )
  end
end


-- kwik/layer_swipe
function M.swipe(obj)
end

-- kwik/layer_pinch
function M.pinch(obj)
end


-- https://forums.solar2d.com/t/zoom-to-a-certain-area-of-screen/348415/10

-- bezier
-- https://forums.solar2d.com/t/draw-curved-lines/318409/5

function M.bezierCubicCurve(obj)

  local bezierCubicCurve = function (t, p1, tg1, tg2, p2)
    local x = (1 - t) * (1 - t) * (1 - t) * p1.x + 3 * (1 - t) * (1 - t) * t * tg1.x + 3 * (1 - t) * t * t * tg2.x + t * t * t * p2.x
    local y = (1 - t) * (1 - t) * (1 - t) * p1.y + 3 * (1 - t) * (1 - t) * t * tg1.y + 3 * (1 - t) * t * t * tg2.y + t * t * t * p2.y
    return ({x = x, y = y})
  end

  local tPoint = {
    {x = 20, y = 80},
    {x = 180, y = 10},
    {x = 280, y = 250},
    {x = 110, y = 420}
  }

  for p = 1, #tPoint do
    local circle = display.newCircle(tPoint[p].x, tPoint[p].y, 3)
  end

  local startPoint = tPoint[1]
  for t = 0, 100 do
    local workPoint = bezierCubicCurve(t / 100, tPoint[1], tPoint[2], tPoint[3], tPoint[4])
    local line = display.newLine(startPoint.x, startPoint.y, workPoint.x, workPoint.y)
    line:setStrokeColor( 1, 0, 0, 1 )
    line.strokeWidth = 1
    startPoint = workPoint
  end
end

-- https://quangnle.wordpress.com/2012/12/30/corona-sdk-curve-fitting-2-implementation-of-p-j-schneider-using-cubic-beizer-curves/
--  CurveFitting

function M.curveFitting()
end

-- https://forums.solar2d.com/t/drag-and-drop-for-multiple-objects-display-group/343144/5

function M.gridDrag()
end

function M.dragIntoOffsetGroup()
end

function M.dollClothes()
end

-- Bing scale
function M.scale(UI, obj, listener)
  local onScale = listener

  -- local obj = display.newRect( 100, 100, 50, 50 )
  local startDragX, startDragY
  local startScaleX, startScaleY

  local function scaleShape( event )
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
      elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
          display.getCurrentStage():setFocus( nil )
          event.target.isFocus = false

          if event.phase == "ended" then
            local obj = event.target
            -- print("@@@@@", obj.name, obj.shapedWith)
            local _props = getProps(obj, #UI.layers)

            print(json.prettify( _props ))
            UI.scene.app:dispatchEvent {
              name = "editor.classEditor.save",
              UI = UI,
              decoded = nil, --selectbox.decoded,
              props = _props
            }
            if onScale then
              onScale("ended", _props)
            end
          end
      end
      return true
  end

  obj:addEventListener( "touch", scaleShape )
  M.removeEventListener = function()
    obj:removeEventListener( "touch", scaleShape )
  end
end

---
--- https://forums.solar2d.com/t/how-make-the-object-rotation-be-locked-on-to-the-mouse-position/355912/7
---
--[[
function M.rotateWithMouse(obj)
  local function rotationMove(event)
    local angle = math.atan2(event.y-obj.y,event.x - obj.x);
    obj.rotation = angle * 180/ math.pi
    -- obj.rotation = (angle * (180/ math.pi)+90)
    print(obj.rotation)
  end
  Runtime:addEventListener("mouse", rotationMove)
end
--]]

--- https://forums.solar2d.com/t/zombie-doesnt-rotate-correctly/151299/10

M.rotate = function(UI, obj, listener)
  local onRotate = listener
  -- local obj = display.newRect( 100, 100, 50, 50 )
  local startDragX, startDragY, startAnchorX, startAnchorY
  local startRotation

  local function rotateShape( event )
      -- print("rotate")
      if ( event.phase == "began" ) then
          display.getCurrentStage():setFocus( event.target )
          event.target.isFocus = true
          startDragX = event.x
          startDragY = event.y
          startRotation = event.target.rotation
          startAnchorX = event.target.anchorX
          startAnchorY = event.target.anchorY
      elseif ( event.phase == "moved" ) then
          local dragX = event.x - startDragX
          local dragY = event.y - startDragY
          local angle = math.deg(math.atan2( dragY, dragX ) )
          local rotationAmount = angle - startRotation

          event.target.anchorX = 0.5
          event.target.anchorY = 0.5
          event.target.rotation = startRotation + rotationAmount

          -- event.target.rotation = angle + 90
          -- print(startRotation + rotationAmount)
      elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
          display.getCurrentStage():setFocus( nil )
          event.target.isFocus = false
          if event.phase == "ended" then
            local obj = event.target
            -- print("@@@@@", obj.name, obj.shapedWith)
            local _props = getProps(obj, #UI.layers)
            print(json.prettify( _props ))
            obj.anchorX = startAnchorX
            obj.anchorY = startAnchorY
            UI.scene.app:dispatchEvent {
              name = "editor.classEditor.save",
              UI = UI,
              decoded = nil, --selectbox.decoded,
              props = _props
            }
            if onRotate then
              onRotate("ended", _props)
            end
          end

      end

      return true
  end

  obj:addEventListener( "touch", rotateShape )
  M.removeEventListener = function()
    obj:removeEventListener( "touch", rotateShape )
  end
end

-- transition2
--   z-rotate
--   https://github.com/rannerboy/corona-transition2

function M.z_rotate(obj)
  transition.zRotate(obj, {
    degrees = 360, -- Required. The number of degrees (delta) that the object should rotate, either from its current zRotation angle or from params.startDegrees.
    startDegrees = 180, -- Optional. If specified, the object will always start rotating FROM this angle instead of from its current zRotation angle. Default = 0.
    time = 2000,
    iterations = 0,
    transition = easing.inOutSine,
    reverse = true,
    perspective = 0.25, -- A value between 0-1. Defaults to 0.5.
    horizontal = true, -- Set to true for horizontal rotation (around the y axis). Default is vertical rotation (around the x axis)
    disableStrokeScaling = true, -- Set to true to disable scaling of strokes. Defaults is false, i.e. strokes are scaled.
    shading = true, -- Applies a shading effect as the object rotates away
    shadingDarknessIntensity = 0.75, -- A value between 0-1. Default = 1. Requires shading=true.
    shadingBrightnessIntensity = 0.25, -- A value between 0-1. Default = 0. Requires shading=true.
    static = false, -- Optional, default = false. Set to true to apply final rotation immediately without doing an actual transition. If static=true, params like time, iterations etcetera have no effect.
    hideBackside = true, -- Optional, default = false. Set to true to hide the target object if it appears to be turned away from the display.
  })
end
--
-- https://www.integral-domain.org/lwilliams/tech/corona/events.html#pinch
-- https://github.com/coronalabs/samples-coronasdk/blob/master/Interface/PinchZoomGesture/main.lua
--
function M.pinchZoomGesture(obj)

  local function calculateDelta( previousTouches, event )

    local id, touch = next( previousTouches )
    if ( event.id == id ) then
      id, touch = next( previousTouches, id )
      assert( id ~= event.id )
    end

    local dx = touch.x - event.x
    local dy = touch.y - event.y
    return dx, dy
  end

  -- Create a table listener object for the image
  local function handler(self, event)
    local result = true
    local phase = event.phase
    local previousTouches = self.previousTouches
    local numTotalTouches = 1

    if previousTouches then
      -- Add in total from "previousTouches", subtracting 1 if event is already in the array
      numTotalTouches = numTotalTouches + self.numPreviousTouches
      if previousTouches[event.id] then
        numTotalTouches = numTotalTouches - 1
      end
    end

    if ( "began" == phase ) then
      -- Set touch focus on first "began" event
      if not self.isFocus then
        display.currentStage:setFocus( self )
        self.isFocus = true
        -- Reset "previousTouches"
        previousTouches = {}
        self.previousTouches = previousTouches
        self.numPreviousTouches = 0

      elseif not self.distance then
        local dx, dy
        if previousTouches and ( numTotalTouches ) >= 2 then
          dx, dy = calculateDelta( previousTouches, event )
        end
        -- Initialize the distance between two touches
        if ( dx and dy ) then
          local d = math.sqrt( dx*dx + dy*dy )
          if ( d > 0 ) then
            self.distance = d
            self.xScaleOriginal = self.xScale
            self.yScaleOriginal = self.yScale
            --print( "Distance: " .. self.distance )
          end
        end
      end

      if not previousTouches[event.id] then
        self.numPreviousTouches = self.numPreviousTouches + 1
      end
      previousTouches[event.id] = event

    -- If image is already in touch focus, handle other phases
    elseif self.isFocus then

      -- Handle touch moved phase
      if ( "moved" == phase ) then
        if self.distance then
          local dx, dy
          -- Must be at least 2 touches remaining to pinch/zoom
          if ( previousTouches and numTotalTouches >= 2 ) then
            dx, dy = calculateDelta( previousTouches, event )
          end

          if ( dx and dy ) then
            local newDistance = math.sqrt( dx*dx + dy*dy )
            local scale = newDistance / self.distance
            --print( "newDistance(" ..newDistance .. ") / distance(" .. self.distance .. ") = scale("..  scale ..")" )
            if ( scale > 0 ) then
              self.xScale = self.xScaleOriginal * scale
              self.yScale = self.yScaleOriginal * scale
            end
          end
        end

        if not previousTouches[event.id] then
          self.numPreviousTouches = self.numPreviousTouches + 1
        end
        previousTouches[event.id] = event

      -- Handle touch ended and/or cancelled phases
      elseif ( "ended" == phase or "cancelled" == phase ) then
        if previousTouches[event.id] then
          self.numPreviousTouches = self.numPreviousTouches - 1
          previousTouches[event.id] = nil
        end

        if ( #previousTouches > 0 ) then
          self.distance = nil
        else
          -- Since "previousTouches" is empty, no more fingers are touching the screen
          -- Thus, reset touch focus (remove from image)
          display.currentStage:setFocus( nil )
          self.isFocus = false
          self.distance = nil
          self.xScaleOriginal = nil
          self.yScaleOriginal = nil
          -- Reset array
          self.previousTouches = nil
          self.numPreviousTouches = nil
        end
      end
    end

    return result
  end

  -- Add touch listener to background image
  obj:addEventListener( "touch", function(event) handler(obj, event) end )
end

return M