local M = {}
local widget = require("widget")

local function angleOf(ax, ay, bx, by, adjust, positive)
  local angle = math.atan2(by - ay, bx - ax) * 180 / math.pi

  if (adjust) then
    if (type(adjust) ~= "number") then
      adjust = -90
    end
    angle = angle - adjust
    if (angle < -180) then
      angle = angle + 360
    end
    if (angle > 180) then
      angle = angle - 360
    end
  end

  if (positive) then
    if (angle < 0) then
      angle = angle + 360
    elseif (angle > 360) then
      angle = angle - 360
    end
  end

  return angle
end

local function lengthOf(ax, ay, bx, by)
  local width, height = bx - ax, by - ay
  return (width * width + height * height) ^ 0.5 -- math.sqrt(width*width + height*height)
end

function widget.newDragItemsScrollView(params)
  local scrollview = widget.newScrollView(params)

  function scrollview:attachListener(item, listener, dragtime, angle, radius, touchthreshold)
    scrollview:insert(item)

    local dragtimer = nil
    local touchevent = nil
    local touch = nil

    touchthreshold = touchthreshold or display.actualContentWidth * .1

    local function isWithinRadius(e)
      local angle = angleOf(e.xStart, e.yStart, e.x, e.y, angle - 90, false)
      return (angle > -radius / 2 and angle < radius / 2)
    end

    local function cancelDragTimer()
      if (dragtimer) then
        timer.cancel(dragtimer)
        dragtimer = nil
      end
    end

    local function startDragByHold()
      print("start by hold")
      item:removeEventListener("touch", touch)
      listener(item, touchevent)
      item, touchevent = nil, nil
    end

    local function startDragByTouch()
      print("start by drag")
      cancelDragTimer()
      item:removeEventListener("touch", touch)
      listener(item, touchevent)
      item, touchevent = nil, nil
    end

    touch = function(event)
      -- print(event.phase, event.target.hasFocus)
      touchevent = event
      if (event.phase == "began") then
        display.currentStage:setFocus(event.target, event.id)
        event.target.hasFocus = true
        if (dragtime) then
          dragtimer = timer.performWithDelay(dragtime, startDragByHold, 1)
        end
        return true
      elseif (event.target.hasFocus) then
        if (event.phase == "moved") then
          if (lengthOf(event.xStart, event.yStart, event.x, event.y) > touchthreshold) then
            cancelDragTimer()
            if (angle and radius and isWithinRadius(event)) then
              startDragByTouch()
            else
              print("takefocus")
              scrollview:takeFocus(event)
              return false
            end
          end
        else
          -- display.currentStage:setFocus( event.target, nil )
          -- event.target.hasFocus = nil
          -- timer.performWithDelay( dragtime+100, function()
          --   print("  add again")
          --   event.target:addEventListener( "touch", function() print("$$$$$$$") end )
          -- end )
          -- event.phase is ended
          print("---ended--- ")
          cancelDragTimer()
          listener(item, touchevent)
        end
        return true
      elseif (event.phase == "ended") then
        print("---ended--- ")
        cancelDragTimer()
        listener(item, touchevent)
      end
      return false
    end

    item:addEventListener("touch", touch)
  end

  return scrollview
end

M.new = widget.newDragItemsScrollView
return M