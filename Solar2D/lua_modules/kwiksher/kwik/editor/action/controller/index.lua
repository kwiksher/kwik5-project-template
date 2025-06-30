local name = ...
local parent,  root, M = newModule(name)
local util = require(kwikGlobal.ROOT.."editor.util")
--
local json = require("json")
local lustache = require("lustache")
local actionTable = require(kwikGlobal.ROOT.."editor.action.actionTable")
local picker = require(kwikGlobal.ROOT.."editor.picker.name")

function M:init(UI, commandMap, selectbox)
  self.commandMap = commandMap
  self.selectbox = selectbox
  self.UI = UI
end
-------
-- I/F
--
M.commandGroupHandler = function(event)
  local UI = M.UI
  -- print(event.target.muiOptions.name)
  -- local len = string.len("editor.action.actionEditor-")
  local name = event.target.muiOptions.name
  local obj = M.commandMap[name]
  --
  -- TBI
  --   dispatchEvent selectXXX for linking target and xxx componetns
  --

  if obj == nil then
    print("Error name not found:", name)
    for k,v in pairs(M.commandMap) do print(k, v) end
  end

  if obj.model.commandClass then
    UI.scene.app:dispatchEvent {
      name = "editor.action.selectActionCommand",
      UI = UI,
      commandClass = obj.model.commandClass,
      isNew = true
    }
  else
    -- toggle hide/show the children
    -- print("@@@@", name)
    UI.editor.actionEditor:commandViewHandler(name, UI.editor.rootGroup.selectLayer)
  end
end

M.commandHandler = function(event)
  local UI = M.UI
  -- TBI
  --   dispatchEvent selectXXX for linking target and xxx componetns
  --
  -- print(event.name)
  UI.scene.app:dispatchEvent {
    name = "editor.action.selectActionCommand",
    UI = UI,
    commandClass = event.model.commandClass,
    isNew = true
  }
end

function M:useActionEditorProps()
end

function M:setValue(decoded, index, template)
end

function M:toggle()
end

function M:show(editor)
  local UI = self.UI
  self.selectbox:show()
  --
  if editor then
  local scrollView = UI.editor.viewStore.commandView
  if scrollView then
    for k, v in pairs(self.commandMap) do
      v.alpha = 1
    end
    scrollView.isVisible = true
  end
  end
  --
  -- if UI.editor.viewStore.actionButtons then
  --   UI.editor.viewStore.actionButtons:show()
  -- end

  if UI.editor.viewStore.actionCommandTable then
    UI.editor.viewStore.actionCommandTable.isVisible = true
    if UI.editor.viewStore.actionCommandButtons.lastVisible then
        UI.editor.viewStore.commandbox:show()
        UI.editor.viewStore.actionCommandPropsTable:show()
        UI.editor.viewStore.actionCommandButtons:show()
    else
        --UI.editor.viewStore.actionCommandButtons:show()
    end
  end
--
  if actionTable.newButton then
    actionTable.newButton.alpha = 1
    actionTable.editButton.alpha = 1
    -- actionTable.attachButton.alpha = 1
  end

  -- picker:show()

end

function M:hide(cancel)
  local UI = self.UI
  self.selectbox:hide()
  --
  local scrollView = UI.editor.viewStore.commandView or {}
  if self.commandMap then
    for k, v in pairs(self.commandMap) do
      v.alpha = 0
    end
  end
  scrollView.isVisible = false

  if UI.editor.viewStore.actionButtons then
    UI.editor.viewStore.actionButtons:hide()
  end
  --
  if UI.editor.viewStore.actionCommandTable then
    UI.editor.viewStore.actionCommandTable:hide()
    UI.editor.viewStore.commandbox:hide()
    UI.editor.viewStore.actionCommandPropsTable:hide()
    if cancel then
      UI.editor.viewStore.actionCommandButtons.lastVisible = false
    else
      UI.editor.viewStore.actionCommandButtons.lastVisible = UI.editor.viewStore.actionCommandButtons.isVisible
    end
    UI.editor.viewStore.actionCommandButtons:hide()
  end
  if actionTable.newButton and not cancel then
    -- print(debug.traceback())
    actionTable.newButton.alpha = 0
    actionTable.editButton.alpha = 0
    -- actionTable.attachButton.alpha = 0]
  else
    actionTable:hide()
  end

  picker:hide()

end

function M:reset()
end

function M:redraw()
end

--
-- [{"command":"animation.play","params":{"target":""}}]
--
function M:render(book, page, command, actions)
  local dst = "App/"..book.."/commands/"..page .."/"..command..".lua"
  --local dst = layer.."_"..class ..".lua"
  local tmplt =  kwikGlobal.PATH.."template/commands/pageX/actionX.lua"
  util.mkdir("App", book, "commands", page)
  -- util.saveLua(tmplt, dst, {actions = {
  --   {animation = {play = {target="layerOne", sec=1}}},
  --   {animation = {pause = {target="layerTwo", sec=2}}},
  -- }})
  local model ={}
  -- print(json.encode(actions))
  for i=1, #actions do
    local entry = {}
    local out = util.split(actions[i].command, '.')
    -- print(unpack(out))
    entry[out[1]] = {}
    local name = out[2]
    if name == "_end" or name == "_else" then
      entry[out[1]][name] = true
    else
      entry[out[1]][name]  = actions[i].params
    end
    model[i] = entry
  end
  -- print("###", json.encode(model))
  util.saveLua(tmplt, dst, { actions = model, encoded = json.encode({name=command, actions=actions})})
  return dst
end

function M:save(book, page, command, model)
  local dst = "App/"..book.."/models/"..page .."/commands/"..command..".json"
  --local dst = layer.."_"..tool..".json"
  util.mkdir("App", book, "models", page, "commands")
  -- local decoded = util.copyTable(model)
  -- table.insert(decoded, entry)
  util.saveJson(dst,model)
  return dst
end

return M