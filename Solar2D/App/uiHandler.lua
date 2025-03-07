local parent,root, M = newModule(...)
--
-- TODO extlib table in kwik editor and template/uiHandler.lua
--
M.libs = {
  {name="mycode", value = "keyboard.mycode"}
}

function M:init(UI)
  for i, v in next, self.libs do
    UI[v.name] = require(parent..v.value)
  end
end

function M:create(UI)
  print(UI.props.appName, UI.props.goPage)
  -- UI.mycode:createDica(UI)
end

function M:willShow(UI)
end

function M:didShow(UI)
end

function M:willHide(UI)
end

function M:didHide(UI)
end

function M:destroy(UI)
end

function M:resume(UI)
end

return M