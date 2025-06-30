
local current = ...
local parent,root = newModule(current)
local util = require(kwikGlobal.ROOT.."editor.util")

--
local model = {
  id ="variable",
  props = {
    {name="name",    value=""},
    {name="isAfter", value=false},
    {name="isLocal", value=true},
    {name="isSave",  value=true},
    {name="class",    value="string"},
    {name="value",   value=""},
  }
}

local selectbox      = require(parent .. "variableTable")
local classProps    = require(parent.."classProps")
--local actionbox = require(root..".parts.actionbox")
-- this set editor.variable.save, cacnel
local buttons       = require(parent.."buttons")
local picker = require(kwikGlobal.ROOT.."editor.picker.name")

local controller = require(kwikGlobal.ROOT.."editor.controller.index").new("variable")
local M = require(root.."parts.baseClassEditor").new(model, controller)
--
M.x = display.contentCenterX + display.actualContentWidth/8

function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group
  --
  selectbox:init()
  -- print("@@@@", self.x, self.y)

  classProps:init(UI, self.x + self.width*1.5, self.y,  self.width, self.height)
  classProps.model = model.props
  classProps.type  = current

  --
  -- actionbox:init(UI)
  buttons:init(UI)
  --
  controller:init{
    selectbox      = selectbox,
    classProps    = classProps,
    actionbox = nil, --actionbox,
    buttons       = buttons,
    picker        = picker
  }
  --
  controller.view = self
  UI.useClassEditorProps = function() return controller:useClassEditorProps() end
  --
end

function controller:render(book, page, class, name, model)
  local dst = "App/"..book.."/"..page .."/components/variables"..name ..".lua"
  local tmplt =  kwikGlobal.PATH.."template/components/pageX/variable/variable.lua"
  util.mkdir("App", book, page, "components", "variables", class)
  --
  model.properties.isAfter = tostring( model.properties.isAfter)
  model.properties.isLocal = tostring( model.properties.isLocal)
  model.properties.isSave = tostring( model.properties.isSave)
  --
  util.saveLua(tmplt, dst, model)
  return dst
end

function controller:save(book, page, class, name, model)
  local dst = "App/"..book.."/models/"..page .."/variable/"..class.."/"..name..".json"
  util.mkdir("App", book, "models", page, "variable", class)
  util.saveJson(dst, model)
  return dst
end

return M
