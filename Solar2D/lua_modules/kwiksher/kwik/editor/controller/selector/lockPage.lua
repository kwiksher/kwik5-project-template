local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require(kwikGlobal.ROOT.."controller.Application")
local AC = require("commands.kwik.actionCommand")
local pageTable = require(kwikGlobal.ROOT.."editor.parts.pageTable")
--
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
--
local command = function (params)
	local UI    = params.UI
  local book, page = UI.book, UI.page

  print("lockPage", book, page)

  if UI.editor.lastSelection.book == book and UI.editor.lastSelection.page == page then
    pageTable:setLock()
    scripts.saveSelection()
    UI.editor.lastSelection.book = nil
    UI.editor.lastSelection.page = nil
  else
    UI.editor.lastSelection.book = book
    UI.editor.lastSelection.page = page
    scripts.saveSelection(book, page)
    pageTable:setLock(page)
  end
end
--
local instance = AC.new(command)
return instance
