local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require("Application")
--
local useJson = false
local useStore = false
--
local command = function (params)
	local UI    = params.UI
  UI.editor.currentPage = params.page
  -- print("selectPage")
  -- print("", App.get().name, UI.editor.currentPage, UI.page)
  UI.editor:setCurrnetSelection("")

  if params.page and params.page:len() > 0 and UI.page ~= params.page then
    local app = UI.scene.app -- App.get()
    app.fromEditor = true
    app:showView("components." .. params.page .. ".index", {effect = "slideDown"})
  else
    -- print("UI.page equals to", params.page)
  end

  -- showView loads
  --   UI.scene.model.components.layers
  --   UI.scene.model.components.audios  etc
  --
  -- and then selectors.lua onClick event to set them to the table with nanostore

end
--
local instance = AC.new(command)
return instance
