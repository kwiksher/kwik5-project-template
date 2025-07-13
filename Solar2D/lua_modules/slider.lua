--https://forums.solar2d.com/t/creating-a-material-ui-inspired-slider/356594

M = {}

local function createSlider(options)
  -- Default options
  options = options or {}
  local width = options.width or 200
  local height = options.height or 4
  local thumbRadius = options.thumbRadius or 10
  local capRadius = height / 2
  local minValue = options.minValue or 0
  local maxValue = options.maxValue or 100
  local startValue = options.startValue or 0
  local onChange = options.onChange or function(value) end

  -- Create slider group
  local sliderGroup = display.newGroup()

  -- Create the track
  local track = display.newRect(sliderGroup, 0, 0, width, height)
  track:setFillColor(0.8, 0.8, 0.8)
  track.anchorX = 0
  track.x = -width / 2

  -- Create the filled part of the track
  local filledTrack = display.newRect(sliderGroup, 0, 0, (startValue - minValue) / (maxValue - minValue) * width, height)
  filledTrack:setFillColor(0.3, 0.6, 0.9)
  filledTrack.anchorX = 0
  filledTrack.x = -width / 2

  -- Create the caps
  local leftCap = display.newCircle(sliderGroup, -width / 2, 0, capRadius)
  leftCap:setFillColor(0.3, 0.6, 0.9) -- same color as the filled track
  local rightCap = display.newCircle(sliderGroup, width / 2, 0, capRadius)
  rightCap:setFillColor(0.8, 0.8, 0.8)

  -- Create the thumb
  local thumb = display.newCircle(sliderGroup, 0, 0, thumbRadius * 2)
  thumb.xScale = 0.5
  thumb.yScale = 0.5
  thumb:setFillColor(0.3, 0.6, 0.9)
  thumb.x = (startValue - minValue) / (maxValue - minValue) * width - width / 2

  -- Functions to show and hide the touch overlay
  local showOverlay = function(overlay)
      transition.cancel("moveOverlay")
      transition.to(overlay, {xScale = 0.5, yScale = 0.5, time = 150, tag = "moveOverlay"})
  end

  local hideOverlay = function(overlay)
      transition.cancel("moveOverlay")
      transition.to(overlay, {xScale = 0.1, yScale = 0.1, time = 150, onComplete = function() overlay.isVisible = false end, tag = "moveOverlay"})
  end

  -- Create the touch overlay
  local touchOverlay = display.newCircle(sliderGroup, thumb.x, thumb.y, thumbRadius * 4)
  touchOverlay.xScale = 0.1
  touchOverlay.yScale = 0.1
  touchOverlay:setFillColor(0.3, 0.6, 0.9, 0.3)
  touchOverlay.isVisible = false

  -- Touch event for the thumb
  local function onThumbTouch(event)
      if event.phase == "began" then
          display.getCurrentStage():setFocus(thumb)
          thumb.isFocus = true
          touchOverlay.isVisible = true
          showOverlay(touchOverlay)
      elseif event.phase == "moved" then
          if thumb.isFocus then
              local newX = event.x - sliderGroup.x
              if newX < -width / 2 then
                  newX = -width / 2
              elseif newX > width / 2 then
                  newX = width / 2
              end
              thumb.x = newX
              touchOverlay.x = newX
              filledTrack.width = newX + width / 2
              local value = minValue + (newX + width / 2) / width * (maxValue - minValue)
              onChange(value)
          end
      elseif event.phase == "ended" or event.phase == "cancelled" then
          display.getCurrentStage():setFocus(nil)
          thumb.isFocus = nil
          hideOverlay(touchOverlay)
      end
      return true
  end

  thumb:addEventListener("touch", onThumbTouch)

  return sliderGroup
end

M.createSlider = createSlider
return M