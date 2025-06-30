local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require(kwikGlobal.ROOT.."controller.Application")
local composer = require("composer")
--
--
local command = function (params)
  -- print("----------- initBook -----------")
	local UI    = params.UI
  local bookName = params.book or App.get().name
  UI.editor.currentBook = bookName


  if UI.book ~= bookName then
    -- print("@@@@", UI.book, bookName)

    UI.editor:didHide(UI)
    UI.editor:destroy(UI)

    local scenes = require("App."..bookName..".index")
    Runtime:dispatchEvent{name="changeThisMug", appName=bookName, gotoPage=scenes[1], editor = true }
    --- set pages ----
   --local currScene = composer.getSceneName( "current" )
   --print(currScene)
  --  loadPage(UI)

  --  timer.performWithDelay( 2000, function()
  --   local UI = require(currScene).UI
  --   loadPage(UI)
  --  end)
  else
    -- print("selectBook same book")
    -- App.loadPage(UI)
  end

  --
  --UI.editor.labelStore:set{currentBook= UI.editor.currentBook, currentPage= UI.page, currentLayer = UI.editor.currentayer}
  --
--

end
--
local instance = AC.new(command)
return instance
