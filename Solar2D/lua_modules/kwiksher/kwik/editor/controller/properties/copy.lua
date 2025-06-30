local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require(kwikGlobal.ROOT.."controller.Application")
--
local useJson = false
--
local command = function (params)
	local UI    = params.UI
  print("anim.copy")
--
end
--
local instance = AC.new(command)
return instance
