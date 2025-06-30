local name = ...
local parent, root = newModule(name)
local Animation = require(kwikGlobal.ROOT.."components.kwik.layer_animation")
local Filter = require(kwikGlobal.ROOT.."components.kwik.layer_filter")
local json   = require("json")

local animPropSet = table:mySet{"x", "y", "rotation", "xScale", "yScale", "alpha"}

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    print(name, params.props.layer, params.class)
    local props = params.props
    --print(props.class)
    if props.to.color1 then
      for k, v in pairs(props.to.color1) do
        print("", k, v)
      end
    end

    for k, v in pairs(props.to) do
      if animPropSet[k] then
        props.to[k] = tonumber(v)
      end
    end

    for k, v in pairs(props.from) do
      if animPropSet[k] then
        props.from[k] = tonumber(v)
      end
    end

    if params.tool == "animation" then
      props.class = params.class
      local player = Animation.set(props)
      --
      local function onEndHandler(UI)
        if props.actions.onComplete then
          UI.scene.app:dispatchEvent {
            name = props.actions.onComplete,
            event = {UI = UI},
            UI = UI
          }
        -- Runtime:dispatchEvent({name = UI.page .. props.actions.onComplete, event = {}, UI = UI})
        end
      end
      --
      if params.class == "filter" then
        -- printKeys(props)
        props.properties.autoPlay = true
        props.properties.animation = true
        local player = Filter.set(props)
        player:create(UI)
        player:didShow(UI)
      else -- path
        printKeys(props)
        local sceneGroup = UI.sceneGroup
        if player:initAnimation(UI, sceneGroup[props.layer], onEndHandler) then
          player.tween = player:buildAnim(UI)
        -- player.tween:pause()
          player:_init()
          if player.tween.from then
            player.tween.from:play()
          else
            player.tween.to:play()
          end
        end
      end
    end
  end
)
--
return instance
