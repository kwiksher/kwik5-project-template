local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require("Application")
local Animation = require(kwikGlobal.ROOT.."components.kwik.layer_animation")
--
local useJson = false
--
local command = function (params)
	local UI    = params.UI

  if params.tool == "animation" then
    print("anim.preview")

    local props = params.props
    --print(props.class)
    for k, v in pairs(props.to) do print("", k, v) end

    local player = Animation.new(props, params.class)
    --
    local function onEndHandler (UI)
      if props.actionName:len() > 0  then
        Runtime:dispatchEvent({name=UI.page..props.actionName, event={}, UI=UI})
      end
    end
    --
    local rootGroup = UI.rootGroup
    player:initAnimation(UI, rootGroup[props.name], onEndHandler)
    player.tween = player:buildAnim(UI)
    player.tween:play()

  end

--
end
--
local instance = AC.new(command)
return instance
