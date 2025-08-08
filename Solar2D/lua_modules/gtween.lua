--[[
gtween.lua
Copyright (c) 2011 Josh Tynjala
Licensed under the MIT license.

Based on GTween for ActionScript 3
http://gskinner.com/libraries/gtween/
Copyright (c) 2009 Grant Skinner
Released under the MIT license.

Easing functions adapted from Robert Penner's AS3 tweening equations.
]] --
-- version 2 by Kwiksher
-- version 2.1 by Kwiksher - breadcrumbs
-- version 2.2 03/20/13 - do not dispose dots if not requested
-- version 2.3 03/20/13 - remove target from crumbGoup (otherwise change order of animations)
-- version 2.4 03/22/13 - target:toFront() only executes in animations with breadcrumbs
-- version 2.5 08/22/13 - xSwipe parameter
-- version 2.6 03/31/14 - Breadcrumb color for Graphics 2.0
-- version 2.7 06/23/14 - 3.3 Flip X and Y

module(..., package.seeall)

local savedTweens = {}
local savedTime = 0

local crumbs = {}

local function indexOf(t, value, start)
  if start == nil then
    start = 1
  end
  for i, v in ipairs(t) do
    if i >= start and v == value then
      return i
    end
  end
  return nil
end

local function copyTableTo(t1, t2)
  for k, v in pairs(t1) do
    t2[k] = v
  end
  return t2
end

local function copyTable(t)
  local t2 = {}
  return copyTableTo(t, t2)
end

local function updateTweens(event)
  local t = savedTime
  savedTime = event.time / 1000
  if pauseAll then
    print("pauseAll")
    return
  end
  local offset = savedTime - t
  local savedTweensCopy = copyTable(savedTweens)
  for i = 1, #savedTweensCopy do
    local tween = savedTweensCopy[i]
    if (tween.position ~= nil and offset ~= nil) then
      tween:setPosition(tween.position + offset)
    end
  end
end

local function registerTween(tween)
  table.insert(savedTweens, tween)
  if #savedTweens == 1 then
    savedTime = system.getTimer() / 1000
    Runtime:addEventListener("enterFrame", updateTweens)
  end
end

local function unregisterTween(tween)
  table.remove(savedTweens, indexOf(savedTweens, tween))
  if #savedTweens == 0 then
    Runtime:removeEventListener("enterFrame", updateTweens)
  end
end

local function invalidate(tween)
  tween.inited = false
  if tween.position > 0 or tween.position == nil then
    tween.position = 0
  end
  if tween.autoPlay then
    tween:play()
  end
end

pauseAll = false

local function setValues(tween, newValues)
  copyTableTo(newValues, tween.values)
  invalidate(tween)
end

local function resetValues(tween, newValues)
  tween.values = {}
  setValues(tween, newValues)
end

local function init(tween)
  tween.inited = true
  tween.initValues = {}
  tween.rangeValues = {}
  for i, v in pairs(tween.values) do
    if tween.values[i] ~= nil then
      tween.initValues[i] = tween.target[i]

      if (tween.values[i] ~= nil and tween.initValues[i] ~= nil) then
        tween.rangeValues[i] = tween.values[i] - tween.initValues[i]
      end
    end
  end
  if not tween.suppressEvents then
    if tween.onInit then
      tween.onInit(tween)
    end
  end
end

local transitionEasing = easing

local backS = 1.70158
easing = {}
easing.inBack = function(ratio)
  return ratio * ratio * ((backS + 1) * ratio - backS)
end
easing.outBack = function(ratio)
  ratio = ratio - 1
  return ratio * ratio * ((backS + 1) * ratio + backS) + 1
end
easing.inOutBack = function(ratio)
  ratio = ratio * 2
  if ratio < 1 then
    return 0.5 * (ratio * ratio * ((backS * 1.525 + 1) * ratio - backS * 1.525))
  else
    ratio = ratio - 2
    return 0.5 * (ratio * ratio * ((backS * 1.525 + 1) * ratio + backS * 1.525) + 2)
  end
end
easing.inBounce = function(ratio)
  return 1 - easing.outBounce(1 - ratio, 0, 0, 0)
end
easing.outBounce = function(ratio)
  if ratio < 1 / 2.75 then
    return 7.5625 * ratio * ratio
  elseif ratio < 2 / 2.75 then
    ratio = ratio - 1.5 / 2.75
    return 7.5625 * ratio * ratio + 0.75
  elseif ratio < 2.5 / 2.75 then
    ratio = ratio - 2.25 / 2.75
    return 7.5625 * ratio * ratio + 0.9375
  else
    ratio = ratio - 2.625 / 2.75
    return 7.5625 * ratio * ratio + 0.984375
  end
end
easing.inOutBounce = function(ratio)
  ratio = ratio * 2
  if ratio < 1 then
    return 0.5 * easing.inBounce(ratio, 0, 0, 0)
  else
    return 0.5 * easing.outBounce(ratio - 1, 0, 0, 0) + 0.5
  end
end
easing.inCircular = function(ratio)
  return -(math.sqrt(1 - ratio * ratio) - 1)
end
easing.outCircular = function(ratio)
  return math.sqrt(1 - (ratio - 1) * (ratio - 1))
end
easing.inOutCircular = function(ratio)
  ratio = ratio * 2
  if ratio < 1 then
    return -0.5 * (math.sqrt(1 - ratio * ratio) - 1)
  else
    ratio = ratio - 2
    return 0.5 * (math.sqrt(1 - ratio * ratio) + 1)
  end
end
easing.inCubic = function(ratio)
  return ratio * ratio * ratio
end
easing.outCubic = function(ratio)
  ratio = ratio - 1
  return ratio * ratio * ratio + 1
end
easing.inOutCubic = function(ratio)
  if ratio < 0.5 then
    return 4 * ratio * ratio * ratio
  else
    ratio = ratio - 1
    return 4 * ratio * ratio * ratio + 1
  end
end
local elasticA = 1
local elasticP = 0.3
local elasticS = elasticP / 4
easing.inElastic = function(ratio)
  if ratio == 0 or ratio == 1 then
    return ratio
  end
  ratio = ratio - 1
  return -(elasticA * math.pow(2, 10 * ratio) * math.sin((ratio - elasticS) * (2 * math.pi) / elasticP))
end
easing.outElastic = function(ratio)
  if ratio == 0 or ratio == 1 then
    return ratio
  end
  return elasticA * math.pow(2, -10 * ratio) * math.sin((ratio - elasticS) * (2 * math.pi) / elasticP) + 1
end
easing.inOutElastic = function(ratio)
  if ratio == 0 or ratio == 1 then
    return ratio
  end
  ratio = ratio * 2 - 1
  if ratio < 0 then
    return -0.5 *
      (elasticA * math.pow(2, 10 * ratio) * math.sin((ratio - elasticS * 1.5) * (2 * math.pi) / (elasticP * 1.5)))
  end
  return 0.5 * elasticA * math.pow(2, -10 * ratio) *
    math.sin((ratio - elasticS * 1.5) * (2 * math.pi) / (elasticP * 1.5)) +
    1
end
easing.inExponential = function(ratio)
  if ratio == 0 then
    return 0
  end
  return math.pow(2, 10 * (ratio - 1))
end
easing.outExponential = function(ratio)
  if ratio == 1 then
    return 1
  end
  return 1 - math.pow(2, -10 * ratio)
end
easing.inOutExponential = function(ratio)
  if ratio == 0 or ratio == 1 then
    return ratio
  end
  ratio = ratio * 2 - 1
  if 0 > ratio then
    return 0.5 * math.pow(2, 10 * ratio)
  end
  return 1 - 0.5 * math.pow(2, -10 * ratio)
end
easing.noneLinear = function(ratio)
  return ratio
end
easing.inQuadratic = function(ratio)
  return ratio * ratio
end
easing.outQuadratic = function(ratio)
  return -ratio * (ratio - 2)
end
easing.inOutQuadratic = function(ratio)
  if ratio < 0.5 then
    return 2 * ratio * ratio
  end
  return -2 * ratio * (ratio - 2) - 1
end
easing.inQuartic = function(ratio)
  return ratio * ratio * ratio * ratio
end
easing.outQuartic = function(ratio)
  ratio = ratio - 1
  return 1 - ratio * ratio * ratio * ratio
end
easing.inOutQuartic = function(ratio)
  if ratio < 0.5 then
    return 8 * ratio * ratio * ratio * ratio
  end
  ratio = ratio - 1
  return -8 * ratio * ratio * ratio * ratio + 1
end
easing.inQuintic = function(ratio)
  return ratio * ratio * ratio * ratio * ratio
end
easing.outQuintic = function(ratio)
  ratio = ratio - 1
  return 1 + ratio * ratio * ratio * ratio * ratio
end
easing.inOutQuintic = function(ratio)
  if ratio < 0.5 then
    return 16 * ratio * ratio * ratio * ratio * ratio
  end
  ratio = ratio - 1
  return 16 * ratio * ratio * ratio * ratio * ratio + 1
end
easing.inSine = function(ratio)
  return 1 - math.cos(ratio * (math.pi / 2))
end
easing.outSine = function(ratio)
  return math.sin(ratio * (math.pi / 2))
end
easing.inOutSine = function(ratio)
  return -0.5 * (math.cos(ratio * math.pi) - 1)
end

function new(target, duration, values, props)
  local tween = {}
  tween.inited = false
  tween.isPlaying = false
  tween.ratio = nil
  tween.calculatedPosition = nil
  tween.positionOld = nil
  tween.ratioOld = nil
  tween.calculatedPositionOld = nil
  tween.values = nil
  tween.initValues = nil
  tween.rangeValues = nil
  tween.lastPercent = 0  -- Initialize lastPercent to 0

  tween.autoPlay = true
  tween.delay = 0
  tween.duration = 1
  tween.transitionEase = transitionEasing.linear
  tween.nextTween = nil
  tween.onInit = nil
  tween.onChange = nil
  tween.onComplete = nil
  tween.position = 0
  tween.repeatCount = 1
  tween.reflect = false
  tween.supressEvents = false
  tween.target = nil

  -- New in 2.3, ability to draw breadcrumb in the animations)
  --tween.breadcrumb = nil
  --tween.breadAnchor = nil
  local numCrumbs = 0
  local crumbGroup = display.newGroup()

  --crumbGroup:insert(target)

  --print(tween.breadAnchor)

  function tween:play()
    if self.isPlaying then
      return
    end
    self.isPlaying = true
    for i = 1, #crumbs do
      -- crumbs[i].alpha = 1
    end
    if self.position == nil or self.repeatCount ~= 0 and self.position >= self.repeatCount * self.duration then
      print("reached the end, reset.")
      self.inited = false
      self.positionOld = 0
      self.calculatedPosition = 0
      self.calculatedPositionOld = 0
      self.ratio = 0
      self.ratioOld = 0
      self.position = -self.delay
    else
      -- print("not reached", self.position, self.repeatCount, self.duration)
    end
    registerTween(self)
  end
  function tween:pause()
    if not self.isPlaying then
      return
    end
    for i = 1, #crumbs do
      if crumbs[i] then
        crumbs[i].alpha = 0
      end
    end
    self.isPlaying = false
    unregisterTween(self)
  end

  function tween:toBeginning()
    self:setPosition(0)
    if self.delay ~= 0 then
      self.position = -self.delay
    end
    self:pause()
  end

  function tween:toEnd()
    if self.repeatCount > 0 then
      self:setPosition(self.repeatCount * self.duration)
    else
      self:setPosition(self.duration)
    end
  end

  function tween:forceValue(k, v)
    if self.initValues and self.initValues[k] then
      self.initValues[k] = v
    end
    if self.target then
      self.target[k] = v
    end
  end

  local useShortDuration = false
  function tween:setPosition(value)
    if useShortDuration then
      -- Calculate the percentage complete (0-1) and ensure at least 10 steps
      local percent = value / self.duration
      local stepSize = 1/10  -- Ensure at least 10 visible steps

      -- If the jump is too large, break it into smaller steps
      if (percent - self.lastPercent > stepSize) and percent < 3 then
          -- Use intermediate steps
          value = self.lastPercent * self.duration + stepSize * self.duration
          self.lastPercent = self.lastPercent + stepSize
      else
          self.lastPercent = percent
      end

      -- Continue with existing code...
      if self.duration == 0 then
          self.ratio = 1
          self.calculatedPosition = self.duration
          if not self.inited then
              init(self)
          end
          for key, v in pairs(self.values) do
              local initVal = self.initValues[key]
              local rangeVal = self.rangeValues[key]
              if initVal ~= nil and rangeVal ~= nil then
                  local val = initVal + rangeVal * self.ratio
                  self.target[key] = val
              end
          end
          if not self.suppressEvents then
              if self.onChange then
                  self.onChange(self)
              end
          end
          self:pause()
          if self.onComplete then
              self.onComplete(self)
          end
          return
      end

      -- Handle very short durations
      if value >= self.duration then
          value = self.duration
      end
    end

    self.positionOld = self.position
    self.ratioOld = self.ratio
    self.calculatedPositionOld = self.calculatedPosition

    local maxPosition = self.repeatCount * self.duration
    if self.reflect then
      maxPosition = maxPosition * 2
    end
    -- print(type(value), type(maxPosition), self.repeatCount)
    local hasEnded = value >= maxPosition and self.repeatCount > 0
    if hasEnded then
      -- print("hasEnded", value,maxPosition, self.repeatCount )
      if self.calculatedPositionOld == maxPosition then
      -- print("self.calculatedPositionOld == maxPosition")
      end
      self.position = maxPosition
      if self.reflect and (self.repeatCount % 2 == 0) then
        print("self.reflect and self.repeatCount % 2 == 0")
        self.calculatedPosition = 0
      else
        self.calculatedPosition = self.duration
      end

      self:pause()

      if self.nextTween then
        self.nextTween:play()
      else
        -- print("no nextTween")
      end
      if not self.suppressEvents then
        if self.onComplete ~= nil then
          self.onComplete(self)
        end
      end
    else
      self.position = value
      if self.position < 0 then
        self.calculatedPosition = 0
      else
        self.calculatedPosition = self.position % self.duration
      end

      if self.reflect and math.floor(self.position / self.duration) % 2 ~= 0 then
        -- print("not ended, self.reflect and self.repeatCount % 2 == 0")
        self.calculatedPosition = self.duration - self.calculatedPosition
      end

      -- Flip
      local _scaleX = self.values.xScale or 1.0
      local _scaleY = self.values.YScale or 1.0
      if not self.pathAnim then
        if self.reflect and self.xSwipe and math.floor(self.position / self.duration) % 2 ~= 0 then
          self:forceValue("xScale", -_scaleX)
        elseif self.reflect and self.xSwipe then
          self:forceValue("xScale", _scaleX)
        end
        if self.reflect and self.ySwipe and math.floor(self.position / self.duration) % 2 ~= 0 then
          self:forceValue("yScale", -_scaleY)
        elseif self.reflect and self.ySwipe then
          self:forceValue("yScale", _scaleY)
        end
      else
        if
          self.reflect and self.xSwipe and math.floor(self.position / self.duration) % 2 ~= 0 and
            self.values.rotation == 0
         then
          self:forceValue("xScale", -_scaleX)
        elseif self.reflect and self.xSwipe then
          self:forceValue("xScale", _scaleX)
        end
        if
          self.reflect and self.ySwipe and math.floor(self.position / self.duration) % 2 ~= 0 and
            self.values.rotation == 0
         then
          self:forceValue("yScale", -_scaleY)
        elseif self.reflect and self.ySwipe then
          self:forceValue("yScale", _scaleY)
        end
      end
      --
      -- Ratio
      if self.duration == 0 and self.position >= 0 then
        self.ratio = 1
      else
        if self.ease ~= nil then
          self.ratio = self.ease(self.calculatedPosition / self.duration, 0, 1, 1)
        elseif self.transitionEase ~= nil then
          self.ratio = self.transitionEase(self.calculatedPosition, self.duration, 0, 1)
        end
      end

      if  self.target and (self.position >= 0 or self.positionOld >= 0) and self.calculatedPosition ~= self.calculatedPositionOld then
        if not self.inited then
          init(self)
        end

        for key, v in pairs(values) do
          local initVal = self.initValues[key]
          local rangeVal = self.rangeValues[key]
          if (initVal ~= nil and rangeVal ~= nil and self.ratio ~= nil) then
            local val = initVal + rangeVal * self.ratio
            self.target[key] = val
            -- print(self.target.name, key, val)
            --
            -- 2.3 breadcrumbs
            if self.breadcrumb and value > 0 and value < maxPosition - 1 then
              numCrumbs = numCrumbs + 1
              self:playBreadCrumbs(target, value, maxPosition, numCrumbs)
            end
          --self.target[i] = val
          --target:toFront()
          end
        end
      end

      if not self.suppressEvents then
        if self.onChange ~= nil then
          self.onChange(self)
        end
      end
    end
  end -- end of setPosition()

  function tween:playBreadCrumbs(target, value, maxPosition, numCrumbs)
    local xPos, yPos
    local c1, c2, c3
    local alpha = self.breadColor[4]
    local bW = self.breadW or 10
    local bH = self.breadH or 10
    local bI = self.breadInterval or 50
    local btime = self.breadTimer or nil
    if btime ~= nil then
      btime = btime * 1000
    end

    --Sets the anchor point for the crumb
    if self.breadAnchor == 1 then -- top, left
      xPos = target.x - (target.width / 2)
      yPos = target.y - (target.height / 2)
    elseif self.breadAnchor == 2 then -- top, center
      xPos = target.x
      yPos = target.y - (target.height / 2)
    elseif self.breadAnchor == 3 then -- top, right
      xPos = target.x + (target.width / 2)
      yPos = target.y - (target.height / 2)
    elseif self.breadAnchor == 4 then -- center, left
      xPos = target.x - (target.width / 2)
      yPos = target.y
    elseif self.breadAnchor == 5 then -- center, center
      xPos = target.x
      yPos = target.y
    elseif self.breadAnchor == 6 then -- center, right
      xPos = target.x + (target.width / 2)
      yPos = target.y
    elseif self.breadAnchor == 7 then -- bottom, left
      xPos = target.x - (target.width / 2)
      yPos = target.y + (target.height / 2)
    elseif self.breadAnchor == 8 then -- bottom, center
      xPos = target.x
      yPos = target.y + (target.height / 2)
    elseif self.breadAnchor == 9 then -- bottom, right
      xPos = target.x + (target.width / 2)
      yPos = target.y + (target.height / 2)
    end

    if application.content.scale == "adaptive" then -- this means config is letterbox
        local editorWidth, editorHeight = (display.contentWidth - 480)/2, (display.contentHeight-320)/2
        -- xPos = xPos - editorWidth
        -- yPos = yPos - editorHeight
    end

    --Set color
    if (self.breadColor[1] == "rand") then
      c1 = math.random(255) / 255
      c2 = math.random(255) / 255
      c3 = math.random(255) / 255
    else
      c1 = self.breadColor[1]
      c2 = self.breadColor[2]
      c3 = self.breadColor[3]
    end

    local obj
    if (numCrumbs == 1) then
      --[[
      if (self.breadShape == "circle") then
        obj = display.newCircle(target.x, target.y, bW)
      else
        obj = display.newRect(target.x, target.y, bW, bH)
      end
        obj:setFillColor(c1, c2, c3)
        obj.alpha = alpha
        -- obj.x = xPos + display.contentCenterX
        -- obj.y = yPos + display.contentCenterY
        obj.x = xPos
        obj.y = yPos
        obj.xScale = target.xScale
        obj.yScale = target.yScale
        crumbGroup:insert(obj)
        crumbs[numCrumbs] = obj

        -- fade after x seconds
        local function dispCrumb(obj)
          obj:removeSelf()
        end
        if (btime ~= nil) then
          transition.to(obj, {time = btime, alpha = 0, onComplete = dispCrumb})
        end
        --]]
    elseif ((numCrumbs) % bI == 0) then -- this is the INTERVAL
      if (display.contentWidth >= xPos and display.contentHeight >= yPos) then
        if (self.breadShape == "circle") then
          obj = display.newCircle(target.x, target.y, bW)
        else
          obj = display.newRect(target.x, target.y, bW, bH)
        end
        obj:setFillColor(c1, c2, c3)
        obj.alpha = alpha
        -- obj.x = xPos + display.contentCenterX
        -- obj.y = yPos + display.contentCenterY
        obj.x = xPos
        obj.y = yPos
        obj.xScale = target.xScale
        obj.yScale = target.yScale

        crumbGroup:insert(obj)
        crumbs[numCrumbs] = obj

        -- fade after x seconds
        local function dispCrumb(obj)
          obj:removeSelf()
        end
        if (btime ~= nil) then
          transition.to(obj, {time = btime, alpha = 0, onComplete = dispCrumb})
        end
      end
    end
    --search for group position
    target:toFront()
  end
  ---
  tween.target = target
  if duration == nil then
    tween.duration = 1
  else
    tween.duration = duration
  end
  if props then
    -- for k, v in pairs(props) do
    --   -- if props[k] and type(v) ~= type(props[k]) then
    --   --   print(k)
    --   -- end
    --   print("", k, type(v), v)
    -- end
    copyTableTo(props, tween)
  end
  if values == nil then
    values = {}
  end
  if tween.delay ~= 0 then
    tween.position = -tween.delay
  end
  --
  resetValues(tween, values)
  --
  if tween.duration == 0 and tween.delay == 0 and tween.autoPlay then
    tween:setPosition(0)
  end
  --
  return tween
end
