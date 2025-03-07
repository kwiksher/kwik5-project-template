-- $weight=-1
--
local _M = {}
local App = require("controller.Application")
--
local off = true

function _M:init(UI)
end

-- local pressedKeys = {}

local function onKeyEvent(event)
  -- if event.phase == "down" then
  --   pressedKeys[event.keyName] = true
  -- else
  --   pressedKeys[event.keyName] = false
  -- end
  -- Print which key was pressed down/up

  local picker = require("editor.picker.name")
  if picker.isOn then
    return
  end

  local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
  local app = App.get()
  local scenes = app.props.scenes
  -- for k, v in pairs(scenes) do print(k, v) end
  if event.phase == "up" then
    -- print("onKeyEvent", message, app.currentViewName )
    if event.keyName == "a" or event.keyName == "left" then
      -- print("onKeyEvent", app.currentViewName, #scenes)
      local getPrevious = function()
        for i = 1, #scenes do
          local sceneName = "components." .. scenes[i] .. ".index"
          if sceneName == app.currentViewName then
            if i == 1 then
              return "components." .. scenes[#scenes] .. ".index"
            end
            return "components." .. scenes[i - 1] .. ".index"
          end
        end
        return app.currentViewName
      end
      app:showView(getPrevious(), {effect = "slideRight"})
    elseif event.keyName == "d" or event.keyName == "right" then
      local getNext = function()
        for i = 1, #scenes do
          local sceneName = "components." .. scenes[i] .. ".index"
          if sceneName == app.currentViewName then
            if i == #scenes then
              return "components." .. scenes[1] .. ".index"
            end
            return "components." .. scenes[i + 1] .. ".index"
          end
        end
        return app.currentViewName
      end
      app:showView(getNext(), {effect = "slideLeft"})
    elseif event.keyName == "w" or event.keyName == "up" then
      local getNext = function()
        for i = 1, #scenes do
          local sceneName = "components." .. scenes[i] .. ".index"
          if sceneName == app.currentViewName then
            if i == #scenes then
              return "components." .. scenes[1] .. ".index"
            end
            return "components." .. scenes[i + 1] .. ".index"
          end
        end
        return app.currentViewName
      end
      app:showView(getNext(), {effect = "slideUp"})
    elseif event.keyName == "s" or event.keyName == "down" then
      local getNext = function()
        for i = 1, #scenes do
          local sceneName = "components." .. scenes[i] .. ".index"
          if sceneName == app.currentViewName then
            if i == #scenes then
              return "components." .. scenes[1] .. ".index"
            end
            return "components." .. scenes[i + 1] .. ".index"
          end
        end
        return app.currentViewName
      end
      app:showView(getNext(), {effect = "slideDown"})
    end
  end

  -- If the "back" key was pressed on Android, prevent it from backing out of the app
  if (event.keyName == "back") then
    if (system.getInfo("platform") == "android") then
      return true
    end
  end

  -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
  -- This lets the operating system execute its default handling of the key
  return false
end
--
--
local swipeLength = 100
--
local function onSwipe(event)
  --print(event.direction)
  if event.phase == "ended" and event.direction ~= nil then
    if event.direction == "left" then
      onKeyEvent {keyName = "d", phase = "up"}
    elseif event.direction == "right" then
      onKeyEvent {keyName = "a", phase = "up"}
    elseif event.direction == "up" then
      onKeyEvent {keyName = "w", phase = "up"}
    elseif event.direction == "down" then
      onKeyEvent {keyName = "s", phase = "up"}
    end
  end
end
--
local function onTap(event)
  print("bg is tapped")
end

--
function _M:create(UI)
  local sceneGroup = UI.sceneGroup
end

function _M:addEventListener()
--  print("addEventListener")
 if off == false then
  Runtime:addEventListener("key", onKeyEvent)
 end
end

function _M:removeEventListener(UI)
  -- print("removeEventListener")
  if off == false then
    Runtime:removeEventListener("key", onKeyEvent)
  end

  local sceneGroup = UI.sceneGroup
  local app = App.get()
  --
  -- local bg = UI.layers[#UI.layers+1]
  -- if bg == nil then return end
  -- app.props.Gesture.deactivate(bg)
  -- bg:removeEventListener(app.props.Gesture.SWIPE_EVENT, onSwipe)
  -- bg:removeEventListener("tap", onTap)
end

--
function _M:didShow(UI)
end
--
function _M:didHide(UI)
  self:removeEventListener(UI)
end
--
function _M:destroy()
end
--
return _M
