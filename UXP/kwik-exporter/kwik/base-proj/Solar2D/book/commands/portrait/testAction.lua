local ActionCommand = {}
local AC           = require("commands.kwik.actionCommand")
--
-----------------------------
-----------------------------
function ActionCommand:new()
  local command = {}
  --
  function command:execute(params)
    local UI         = params.UI
    local sceneGroup = UI.sceneGroup
    local layers      = UI.layers
    local event      = params.event
    local obj        = event.target
    --printKeys(event.target)
    -- local conditions = require("App." .. UI.book..".common.conditions")
    -- local expressions = require("App." .. UI.book.."common.expressions")
    --
    -- target layer :sceneGroup[layerName]
    -- target animation : layer.animations[index]
    --
    obj = UI.animations["GroupA/SubA/Triangle_linear"]
    AC.Animation:play(obj) --
  end
  return setmetatable( command, {__index=AC})
end
--
ActionCommand.model = [[
{"name":"testAction","actions":[{"command":"animation.play","params":{"target":"GroupA/SubA/Triangle_linear"}}]}
]]
--
return ActionCommand
