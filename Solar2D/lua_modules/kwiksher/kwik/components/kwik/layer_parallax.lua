
local M = {}
---------------------
M.accelerometerHandler = function(event)
    local obj = event.target
    local props = obj.parallax
    -- printKeys(props)
    local UI = props.UI
    if props.properties.dampX then
        obj.x = props.X + (props.X * event.yGravity * props.properties.dpx);
    end
    if props.properties.dampY then
        obj.y = props.Y + (props.Y * event.yGravity * props.properties.dpy);
    end
    if event.zGravity > 0 then
       if props.actions.onBack then
          UI.scene:dispatchEvent({name=props.actions.onBack, event=event })
       end
    else
      if props.actions.onForward then
          UI.scene:dispatchEvent({name=props.actions.onForward, event=event })
      end
    end
end

function M:setParallax(UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  local obj        = sceneGroup[layerName]
  if self.properties.target == "page" then
    obj = sceneGroup
  end
  obj.parallax = self
  obj.parallax.UI = UI
  obj.parallax.X = obj.x
  obj.parallax.Y = obj.y
  self.obj = obj
end

--
function M:activate(UI)
  if self.properties.isActive then
    self.obj:addEventListener("accelerometer", self.accelerometerHandler)
  end
  ---
end

function M:deactivate(UI)
  if self.properties.isActive then
    self.obj:removeEventListener("accelerometer", self.accelerometerHandler)
  end
end

M.set = function(model)
  return setmetatable(model, {__index = M})
end
--

local function _createDummyAccelerometerDispatcher(interval, _initialDirection)
  local dispatcher = {}
  local directions = {"left", "right", "up", "down"}
  local currentDirection = _initialDirection or directions[math.random(1, #directions)]
  local targetXGravity = 0
  local targetYGravity = 0
  local currentXGravity = 0
  local currentYGravity = 0
  local smoothFactor = 0.1 -- Adjust this value for smoothness (lower = smoother, higher = faster changes)


  local timer = timer.performWithDelay(interval, function()
    local event = {
      name = "accelerometer",
      xGravity =  math.random(0, 1) * smoothFactor,
      yGravity =  math.random(0, 1) * smoothFactor,
      zGravity = 0, -- zGravity can often be ignored for 2D games
      target = nil
    }

    -- Determine target gravity based on currentDirection
    if _initialDirection then -- If an initial direction is provided, stick to it
        currentDirection = _initialDirection
    else
        local newDirection = directions[math.random(1, #directions)]
        if newDirection ~= currentDirection then
            currentDirection = newDirection
        end
    end

    if currentDirection == "left" then
      event.xGravity = -1*event.xGravity
    elseif currentDirection == "right" then
    elseif currentDirection == "up" then
    elseif currentDirection == "down" then
      event.yGravity = -1*event.yGravity
    end

    if dispatcher.targets then
      for i, v in next, dispatcher.targets do
        -- printKeys(v)
        event.target = v
        M.accelerometerHandler(event)
        -- accelerometerUpdate(event) -- Assuming this function is defined elsewhere
      end
    end
  end, 0)

  dispatcher.timer = timer
  return dispatcher
end


---------------------
M._accelerometerHandler = function(event)
    local obj = event.target
    local props = obj.parallax
    local UI = props.UI
    if props.properties.dampX then
        obj.x = props.X + (props.X * event.yGravity * props.properties.dpx)
    end
    if props.properties.dampY then
        obj.y = props.Y + (props.Y * event.yGravity * props.properties.dpy)
    end
    if event.zGravity > 0 then
       if props.actions.onBack then
          UI.scene:dispatchEvent({name=props.actions.onBack, event=event })
       end
    else
      if props.actions.onForward then
          UI.scene:dispatchEvent({name=props.actions.onForward, event=event })
      end
    end
end

-- Rest of your existing module code remains the same --

-- Enhanced Dummy Accelerometer Dispatcher with Smooth Physics
local function createDummyAccelerometerDispatcher(params)
    local dispatcher = {}
    local directions = {"left", "right", "up", "down", "random"}

    -- Physics parameters
    local currentX = 0
    local currentY = 0
    local targetX = 0
    local targetY = 0
    local velocityX = 0
    local velocityY = 0
    local smoothing = params.smoothingFactor or 0.1
    local maxSpeed = params.maxSpeed or 0.5
    local damping = params.damping or 0.95

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local _timer = timer.performWithDelay(params.interval or 50, function()
        -- Update physics
        velocityX = lerp(velocityX, (targetX - currentX) * maxSpeed, smoothing)
        velocityY = lerp(velocityY, (targetY - currentY) * maxSpeed, smoothing)

        -- Apply damping
        velocityX = velocityX * damping
        velocityY = velocityY * damping

        -- Update current position
        currentX = currentX + velocityX
        currentY = currentY + velocityY


        -- Generate event
        local event = {
            name = "accelerometer",
            xGravity = currentX,
            yGravity = currentY,
            zGravity = math.random() * 2 - 1,  -- Keep random but smoothable
            --target = dispatcher.target
        }

        if dispatcher.targets then
          for i, v in next, dispatcher.targets do
            -- printKeys(v)
            event.target = v
            M.accelerometerHandler(event)
            -- accelerometerUpdate(event) -- Assuming this function is defined elsewhere
          end
        end
        -- if dispatcher.target and dispatcher.target.parallax then
        --     M.accelerometerHandler(event)
        -- end
    end, 0)

    -- Function to change direction smoothly
    function dispatcher:setDirection(direction)
        if direction == "random" or direction == nil then
            direction = directions[math.random(1, 4)]
        end

        if direction == "left" then
            targetX = -1
            targetY = 0
        elseif direction == "right" then
            targetX = 1
            targetY = 0
        elseif direction == "up" then
            targetX = 0
            targetY = -1
        elseif direction == "down" then
            targetX = 0
            targetY = 1
        else  -- Gentle random movement
            targetX = math.random() * 2 - 1
            targetY = math.random() * 2 - 1
        end

        -- Add some randomness to make movement more organic
        targetX = targetX + (math.random() * 0.2 - 0.1)
        targetY = targetY + (math.random() * 0.2 - 0.1)
    end

    -- Auto-direction changer
    if params.autoChange then
        timer.performWithDelay(params.directionChangeInterval or 3000, function()
            dispatcher:setDirection(params.direction or "random")
        end, 0)
    else
        dispatcher:setDirection(params.direction or "random")
    end
    dispatcher.timer = _timer

    return dispatcher
end

-- -- Example usage with smooth physics
-- local parallaxModule = M.set({
--     properties = {
--         target = "page",
--         dampX = true,
--         dampY = true,
--         dpx = 0.1,
--         dpy = 0.1
--     },
--     actions = {
--         onBack = "onBackEvent",
--         onForward = "onForwardEvent"
--     }
-- })

-- local UI = {
--     sceneGroup = display.newGroup(),
--     scene = {
--         dispatchEvent = function(event)
--             print("Dispatched event:", event.name)
--         end
--     }
-- }

-- parallaxModule:setParallax(UI)
-- parallaxModule:activate(UI)

-- Create smooth dispatcher
-- local dummyDispatcher = createDummyAccelerometerDispatcher({
--     interval = 50,             -- Update every 50ms for smooth animation
--     smoothingFactor = 0.08,    -- Lower = smoother, slower movements
--     maxSpeed = 0.3,            -- Maximum tilt intensity
--     damping = 0.92,            -- Higher = less oscillation
--     autoChange = true,         -- Automatically change directions
--     directionChangeInterval = 4000,  -- Change direction every 4 seconds
--     direction = "random"       -- Initial direction
-- })

-- dummyDispatcher.target = UI.sceneGroup

-- Create a dummy accelerometer dispatcher with a specific direction
M.dummyDispatcher = function(targets, interval, direction)
  local dispatcher = createDummyAccelerometerDispatcher(
    {
      interval = interval,             -- Update every 50ms for smooth animation
      smoothingFactor = 0.08,    -- Lower = smoother, slower movements
      maxSpeed = 0.3,            -- Maximum tilt intensity
      damping = 0.42,            -- Higher = less oscillation
      autoChange = true,         -- Automatically change directions
      directionChangeInterval = 1000,  -- Change direction every 4 seconds
      direction = "random"       -- Initial direction
  })

  -- interval, direction)  -- Dispatch every 1000ms (1 second) with "left" direction
  dispatcher.targets = targets
  return dispatcher
end

return M
