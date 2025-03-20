local parent,root, M = newModule(...)
--
-- TODO extlib table in kwik editor and template/uiHandler.lua
--
M.libs = {
}

-- enable the line belor for kwik5-sample-books/App/keyvoard. See https://kwiksher.github.io/kwik5docs/tutorial/keyboard/index.html
local keyboardPath = system.pathForFile("keyboard", system.ResourceDirectory)
if keyboardPath then
  local attr = lfs.attributes(keyboardPath)
  if attr and attr.mode == "directory" then
    table.insert(M.libs, {name="mycode", value = "keyboard.mycode"})
    print("Keyboard module found and enabled")
  end
end


function M:init(UI)
  for i, v in next, self.libs do
    UI[v.name] = require(parent..v.value)
  end
end

function M:create(UI)
  -- print(UI.props.appName, UI.props.gotoPage)
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