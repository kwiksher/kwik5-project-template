local current = ...
local parent, root = newModule(current)
local util = require(kwikGlobal.ROOT.."editor.util")
--
local model = {
  id = "timer",
  props = {
    {name = "actionName", value = ""},
    {name = "delay",      value = 0},
    {name = "iterations", value = 1},
    {name = "name",       value = ""}
  }
}

local selectbox = require(parent .. "timerTable")
local classProps = require(root .. "parts.classProps")
local actionbox = require(root .. ".parts.actionbox")
-- this set editor.timer.save, cacnel
local buttons = require(parent .. "buttons")
local picker = require(kwikGlobal.ROOT.."editor.picker.name")

local controller = require(kwikGlobal.ROOT.."editor.controller.index").new("timer")
local M = require(root .. "parts.baseClassEditor").new(model, controller)
--
M.x = display.contentCenterX + display.actualContentWidth/8


function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group

  selectbox:init()
  -- print("@@@@", self.x, self.y)
  classProps:init(UI, self.x + self.width * 1.5, self.y, self.width, self.height)
  classProps.model = model.props
  classProps.type  = current

  --
  actionbox:init(UI)
  buttons:init(UI)
  -- --
  controller:init {
    selectbox = selectbox,
    classProps = classProps,
    actionbox = actionbox,
    buttons = buttons,
    picker        = picker
  }
  --
  controller.view = self
  --
  UI.useClassEditorProps = function()
    return controller:useClassEditorProps()
  end
  --
end

function controller:render(book, page, class, name, model)
  local dst = "App/" .. book .. "/components/".. page .. "/timers/" .. name .. ".lua"
  local tmplt = kwikGlobal.PATH.."template/components/pageX/timer/timer.lua"
  util.mkdir("App", book, "components", page, "timers")
  print(dst, tmplt)
  util.saveLua(tmplt, dst, model)
  return dst
end

function controller:save(book, page, class, name, model)
  local dst = "App/" .. book .. "/models/" .. page .. "/timers/ " .. name .. ".json"
  util.mkdir("App", book, "models", page, "timers")
  util.saveJson(dst, model)
  return dst
end

return M
