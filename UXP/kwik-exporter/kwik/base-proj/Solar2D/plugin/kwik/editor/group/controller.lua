local current = ...
local parent,  root = newModule(current)
--
local json = require("json")

local M = require(kwikGlobal.ROOT.."editor.controller.index").new("group")

-------
-- I/F
--
function M:useClassEditorProps()
  print("useClassEditorProps")
  local props = {}

  local selectbox = self.viewGroup.selectbox
  local classProps = self.viewGroup.classProps or {}
  local buttons = self.viewGroup.buttons
  --
  local layersbox = self.viewGroup.layersbox
  local layersTable = self.viewGroup.layersTable

  props.properties = classProps:getValue() or {} -- name or ""
  --
  props.layersTableSelections = layersTable:getSelections()
  props.layersboxSelections = layersbox:getSelections()
  --
  props.layersbox = layersbox:getValue()
  props.layersTable = layersTable:getValue()

  return props
end


-- this handler should be called from selectbox to set one of components user selected
function M:setValue(decoded, index, template)
  print("ERROR don't use group setValue")
  --
  -- see selectGoup.lua menu.controller.seletGroup calls
  --    controller.selectGroup.command()
  --    because editor.controller.index.command() only works for
  --      conrolbox, onCompletebo and buttons. It does not have specfific layersbox and layersTable of Group!
end

return M