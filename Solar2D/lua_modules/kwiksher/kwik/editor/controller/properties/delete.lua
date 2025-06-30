local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require("Application")
--
local useJson = false
--
local command = function (params)
	local UI    = params.UI
  print("anim.delete")

  local props = UI.useClassEditorProps()
  for k, v in pairs(props) do print("", k, v) end
--
end
--
local instance = AC.new(command)
return instance
