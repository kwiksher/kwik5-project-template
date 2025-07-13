local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require("Application")
local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")

--
local useJson = false
--
local command = function (params)
	local UI    = params.UI
  print("anim.create")

  local props = UI.useClassEditorProps()
  for k, v in pairs(props) do print("", k, v) end

  toolbar:toogleToolMap()
--
end
--
local instance = AC.new(command)
return instance
