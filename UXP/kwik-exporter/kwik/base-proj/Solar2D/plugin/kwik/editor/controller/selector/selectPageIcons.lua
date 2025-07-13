local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require(kwikGlobal.ROOT.."controller.Application")
--
local useJson = false
local propsButtons = require(kwikGlobal.ROOT.."editor.parts.propsButtons")
local settingsTable = require(kwikGlobal.ROOT.."editor.parts.settingsTable")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")

--
local command = function (params)
	local UI    = params.UI
  local book, page = UI.book, UI.page

  local path = system.pathForFile( "App/"..UI.editor.currentBook.."/models/settings.json", system.ResourceDirectory)
  print("selectPageIcons", params.icon, params.isNew, params.isDelete, path)
  local src = "App/" .. book .. "/index.lua"
  local picker = require(kwikGlobal.ROOT.."editor.picker.name")
  local confirmation = require(kwikGlobal.ROOT.."editor.picker.confirmation")


  local rootGroup = UI.editor.rootGroup
  if params.icon == "newPage-icon" then --params.isNew == true
    print("new page")
    local listener = function(_page)
      if _page and _page:len() > 0 then
        scripts.backupFiles(src)
        scripts.createPage(book, nil, _page) -- _dst == Solar2D
      else
        print("user cancel")
      end
      picker:destroy()
    end
    picker:create(listener, "Please input a page name")
  elseif params.isDelete then
    print("delete page", page)
    local listener = function(message, props)
      if message == "Continue" then
        scripts.backupFiles(src)
        scripts.removePages(book, {props.page})
      else
        print("user cancel")
      end
      picker:destroy()
      confirmation:destroy()
    end
    confirmation:create(listener, "Press Continue to delete "..page, {page=page})
  elseif params.show~=nil and rootGroup.settingsTable then
    if settingsTable.isVisible then
      settingsTable:hide()
    else
      settingsTable:show()
    end
  else
    UI.editor.editPropsLabel = "Settings"
    local decoded, pos, msg = json.decodeFile( path )
    if not decoded then
      print( "Decode failed at "..tostring(pos)..": "..tostring(msg), path )
    elseif (params.class =="animation") then
      print( "animation is decoded!" )
      --UI.editor.propsStore:set(decoded)
    else
      print( "props is decoded!" )
      settingsTable:didHide(UI)
      settingsTable:destroy(UI)
      settingsTable:init(UI)
      --
      settingsTable:setValue(decoded)
      settingsTable:create(UI)
      settingsTable:didShow(UI)
      settingsTable:show()
      --
      propsButtons:show()
      UI.useClassEditorProps = settingsTable.useClassEditorProps
    end
    --
    --
    UI.editor.rootGroup:dispatchEvent{name="labelStore",
      currentBook= UI.editor.currentBook,
      currentPage= "Settings",
      currentLayer = ""}
  end
--
end
--
local instance = AC.new(command)
return instance
