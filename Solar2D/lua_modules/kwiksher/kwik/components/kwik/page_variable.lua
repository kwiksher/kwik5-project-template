local M = {}
local Var = require(kwikGlobal.ROOT.."components.kwik.vars")
local App   = require("Application")

function M:init(UI)
  local props = self.properties
  if not props.isAfter then
    if not props.isLocal then
      if props.type == "table" then
        App.variables[self.name] = { props.value }
      else
        App.variables[self.name] = props.value
      end
      --
      if props.isSave then
        -- Check if variable has a pre-saved content
        if Var:kwkVarCheck(self.name) ~= nil then
          App.variables[self.name] = Var:kwkVarCheck(self.name)
        end
      end
    else
      if self.type == "table" then
        UI.variables[self.name] = { props.value }
      else
        UI.variables[self.name] = props.value
      end
      if props.isSave then
        -- Check if variable has a pre-saved content
        if Var:kwkVarCheck(self.name) ~= nil then
          UI.variables[self.name] = Var:kwkVarCheck(self.name)
        end
      end
    end
  end
end

function M:create(UI)
  local sceneGroup  = UI.sceneGroup
end
--
function M:didShow(UI)
  if self.isAfter then
    if not self.isLocal then
      if self.type == "table" then
        App.variables[self.name] = { props.value }
      else
        App.variables[self.name] = props.value
      end
    else
      if self.type == "table" then
        UI.variables[self.name] = { props.value }
      else
        UI.variables[self.name] = props.value
      end
    end
  end
end
--
function M:destroy(UI)
end
--
M.set = function(instance)
	return setmetatable(instance, {__index=M})
end

return M