local parent,root, M = newModule(...)
--
local app = require("controller.Application").get()
--
local function _require(mod)
  if app.name then
      return require("App."..app.name.."."..mod)
  else
      return require(mod)
  end
end

function M:init(UI)
  local sceneGroup  = UI.sceneGroup
  {{#extCodeTop}}
  {{ccode}}
  {{arqCode}}
  {{/extCodeTop}}
end
--
function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  {{#extCodeMid}}
  {{ccode}}
  {{arqCode}}
  {{/extCodeMid}}
end
--
function M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
    {{#extCodeBtm}}
    {{ccode}}
    {{arqCode}}
    {{/extCodeBtm}}
end
--
function M:destroy(UI)
  local sceneGroup  = UI.sceneGroup
  {{#extCodeDsp}}
  {{ccode}}
  {{arqCode}}
  {{/extCodeDsp}}
end
--
return M