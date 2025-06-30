local current = ...
local parent,root = newModule(current)
local util = require(kwikGlobal.ROOT.."editor.util")

--
local model = {
  id ="audio",
  props = {
    {name="autoPlay", value=true},
    {name="channel", value = ""},
    {name="delay", value=0},
    {name="filenme", value = ""},
    {name="folder", value=""},
    {name="loops", value = ""},
    {name="name", value = ""},
    {name="type", value = ""},
  }
}

local selectbox      = require(parent .. "audioTable")
local classProps    = require(parent.."classProps")
local actionbox = require(root..".parts.actionbox")

-- this set editor.audio.save, cacnel
local buttons       = require(parent.."buttons")
local controller = require(kwikGlobal.ROOT.."editor.controller.index").new("audio")
--
local M = require(root.."parts.baseClassEditor").new(model, controller)

M.x				= display.contentCenterX + 480/2
M.y				= 20
-- M.y				= (display.actualContentHeight-1280/4 )/2
M.width = 80
M.height = 16

function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  -- UI.editor.viewStore = self.group
  -- --
  -- selectbox     : init(UI, self.x + self.width/2, self.y, self.width*0.74, self.height)
  -- classProps   : init(UI, self.x + self.width*1.5 + 2, self.y,  self.width, self.height)

  selectbox:init()
  classProps:init(UI, self.x + self.width, self.y,  self.width, self.height)
  classProps.model = model.props
  classProps.type  = current

  classProps.UI = UI
  --
  actionbox:init(UI, self.x+self.width, display.contentCenterY)
  actionbox.props = {
    {name="onComplete", value=""}
  }

  buttons:init(UI)
  -- --
  controller:init{
    selectbox      = selectbox,
    classProps    = classProps,
    actionbox = actionbox,
    buttons       = buttons
  }
  controller.view = self
  --
  UI.useClassEditorProps = function() return controller:useClassEditorProps() end
  --
end

function controller:render(book, page, class, name, model)
  local dst = "App/"..book.."/components/"..page .."/audios/"..class.."/"..name ..".lua"
  local tmplt =  kwikGlobal.PATH.."template/components/pageX/audio/audio.lua"
  util.mkdir("App", book, "components",page, "audios", class)
  util.saveLua(tmplt, dst, model)
  return dst
end

function controller:save(book, page, class, name, model)
  local dst = "App/"..book.."/models/"..page .."/audios/"..class.."/"..name..".json"
  util.mkdir("App", book, "models", page, "audios", class)
  util.saveJson(dst, model)
  return dst
end

return M
