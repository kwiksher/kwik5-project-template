-- Centralized Key Event Manager
-- Handles multiple key event listeners in a single Runtime:addEventListener
--
-- Usage:
--   local keyEventManager = require("editor.keyEventManager")
--
--   -- Register a handler
--   keyEventManager.register("myHandler", function(event)
--     if event.phase == "up" and event.keyName == "escape" then
--       print("Escape pressed!")
--       return true -- handled
--     end
--     return false -- not handled
--   end, 1) -- priority 1
--
--   -- Unregister when done
--   keyEventManager.unregister("myHandler")
--
-- Higher priority handlers are called first and can prevent lower priority handlers
-- from receiving the event by returning true.

local M = {}

-- Stack to maintain order of key event handlers
local keyHandlers = {}
local isListening = false

-- The single key event handler that dispatches to all registered handlers
local function onKeyEvent(event)
  -- Process handlers in reverse order (most recently added first)
  for i = #keyHandlers, 1, -1 do
    local handler = keyHandlers[i]
    if handler.isActive and handler.onKeyEvent then
      local handled = handler.onKeyEvent(event)
      if handled then
        return true -- Stop propagation if handler claims to have handled the event
      end
    end
  end
  return false -- Allow default system handling
end

-- Start listening for key events if not already listening
local function startListening()
  if not isListening then
    --Runtime:addEventListener("key", onKeyEvent)
    isListening = true
  end
end

-- Stop listening for key events if no active handlers
local function stopListening()
  local hasActiveHandlers = false
  for i = 1, #keyHandlers do
    if keyHandlers[i].isActive then
      hasActiveHandlers = true
      break
    end
  end

  if not hasActiveHandlers and isListening then
    Runtime:removeEventListener("key", onKeyEvent)
    isListening = false
  end
end

-- Register a key event handler
-- @param id: unique identifier for this handler
-- @param onKeyEventFunc: function to handle key events
-- @param priority: optional priority (higher numbers = higher priority, default = 0)
function M.register(id, onKeyEventFunc, priority)
  priority = priority or 0

  -- Remove existing handler with same id if exists
  M.unregister(id)

  -- Insert handler in correct position based on priority
  local handler = {
    id = id,
    onKeyEvent = onKeyEventFunc,
    priority = priority,
    isActive = true
  }

  local inserted = false
  for i = 1, #keyHandlers do
    if keyHandlers[i].priority < priority then
      table.insert(keyHandlers, i, handler)
      inserted = true
      break
    end
  end

  if not inserted then
    table.insert(keyHandlers, handler)
  end

  startListening()
end

-- Unregister a key event handler
-- @param id: unique identifier for the handler to remove
function M.unregister(id)
  for i = #keyHandlers, 1, -1 do
    if keyHandlers[i].id == id then
      table.remove(keyHandlers, i)
      break
    end
  end

  stopListening()
end

-- Activate a registered handler
-- @param id: unique identifier for the handler to activate
function M.activate(id)
  for i = 1, #keyHandlers do
    if keyHandlers[i].id == id then
      keyHandlers[i].isActive = true
      startListening()
      break
    end
  end
end

-- Deactivate a registered handler (but keep it registered)
-- @param id: unique identifier for the handler to deactivate
function M.deactivate(id)
  for i = 1, #keyHandlers do
    if keyHandlers[i].id == id then
      keyHandlers[i].isActive = false
      break
    end
  end

  stopListening()
end

-- Get current handler count (for debugging)
function M.getHandlerCount()
  return #keyHandlers
end

-- Get active handler count (for debugging)
function M.getActiveHandlerCount()
  local count = 0
  for i = 1, #keyHandlers do
    if keyHandlers[i].isActive then
      count = count + 1
    end
  end
  return count
end

return M
