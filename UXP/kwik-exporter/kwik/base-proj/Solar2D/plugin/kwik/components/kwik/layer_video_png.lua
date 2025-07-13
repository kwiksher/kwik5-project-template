local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
local player = require "movieclip_player"

function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layeName    = UI.properties.target
  local props = self.properties --
  local png_prefix = UI.props.videoDir .. props.url.."/"..props.prefix  -- "img/test_HTML5 Canvas" --test_HTML5 Canvas0001.png,

  self.group = display.newGroup()
  self.group.player = player
  player:init(png_prefix, props.startIndex,  props.numOfImages, layerProps.mX, layerProps.mY, layerProps.imageWidth, layerProps.imageHeight, self.group ) -- group

  sceneGroup:insert(self.group)
  sceneGroup[layerName] = self.group
  UI.videos[layerName] = self.group
end
--
function M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
  --
    if self.actions.onComplete then
         self.group.videoListener = function(event)
        if event.phase == "ended" then
          if self.actions.onComplete then
             UI.scene:dispatchEvent({name=self.actions.onComplete, layer=self.group })
          end
         end
      end
    end

    if props.autoPlay then
        local _loop = 0
       if props.loop == nil then
            _loop = -1
       end
      self.group.loop = _loop
      player:play({loop=_loop, onComplete = function()
          print("completed")
          player:stop()
          if self.actions.onComplete then
            self.group.videoListener({phase ="ended"})
          end
        end
      })
    end
end
--
M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end
--
return M