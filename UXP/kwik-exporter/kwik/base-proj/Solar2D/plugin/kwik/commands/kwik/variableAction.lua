local M = {}
--
local Var = require(kwikGlobal.ROOT.."components.kwik.vars")
--
function M:restartTrackVars(params)
	Var:zeroesKwikVars()
end
--
function M:editVar(UI, name, _value)
  local value = UI:getVariable(name)
  if value then
    if type(_value) == "function" then
      value = _value(value)
    else
      value = _value
    end
    local objs = UI.dynamictexts[name] or {}
    for i, obj in next, objs do
      obj.text = value
    end
    UI:setVariable(name, value)
    print(name, value)
  else
    local app = require("contoller.Application").get()
    value = app:getVariable(name)
    if value then
      if type(_value) == "function" then
        value = _value(value)
      else
        value = _value
      end
    end
    local objs = UI.dynamictexts[name] or {}
    for i, obj in next, objs do
      obj.text = value
    end
    app:setVariable(name, value)
  end
end
return M
