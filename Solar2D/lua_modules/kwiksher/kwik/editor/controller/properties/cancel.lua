local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require(kwikGlobal.ROOT.."controller.Application")

local propsButtons = require(kwikGlobal.ROOT.."editor.parts.propsButtons")
local propsTable = require(kwikGlobal.ROOT.."editor.parts.propsTable")
--
--
local command = function (params)
	local UI    = params.UI
  print("props.cancel")

  propsButtons:hide()
  propsTable:hide()
  UI.editor.currentTool = nil
--
end
--
local instance = AC.new(command)
return instance
