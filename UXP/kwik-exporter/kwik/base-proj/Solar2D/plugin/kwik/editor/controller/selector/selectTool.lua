local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
--local models = require(kwikGlobal.ROOT.."editor.model").layerTools

local propsButtons = require(kwikGlobal.ROOT.."editor.parts.propsButtons")
local propsTable = require(kwikGlobal.ROOT.."editor.parts.propsTable")

--
-- see index.lua
--   self.editorTools['editor.parts.toolbar-'..layerTools[i].icon] = module
--   self.editorTools['editor.parts.baseTable-'..v.id] = module
--
-- local classMap = {
--      animation = "animation",
--      linear    = "animation",
--      blink     = "animation",
--      bounce    = "animation",
--      pulse     = "animation",
--      rotation  = "animation",
--      tremble    = "animation",
--      switch    = "animation",
--   -- filter    = "animation",
--   -- path      = "animation",
--   --
--     button     = "interaction",
--     drag       = "interaction",
--     canvas     = "interaction",
--   --
--     spritesheet   = "replacement",
--     particles     = "replacement",
--     syncTextAudio = "replacement",
--     video         = "replacement"
-- }
--
local lastTool
--
local command = function (params)
	local UI    = params.UI
 	-- print("selectTool", UI.editor.currentLayer, params.class, params.isNew )
  if params.asset then
    -- links is an array of layer names
    -- for k, v in pairs(params.asset) do print("", k, v) end
  end

  -- print(debug.traceback())

  local tool = (params.class) and UI.editor:getClassModule(params.class) or nil
   if params.class == "addcode" then
    local command = require(kwikGlobal.ROOT.."editor.scripts.commands")
    command.openEditorByPath("App/uiHandler.lua")
   elseif tool then
    -- print("### tool", params.class, tool.id)
    if lastTool then
      -- print("### lastTool", lastTool.name)
      lastTool.controller:hide()
    end
    lastTool= tool
    --
    if params.hide then
      tool.controller:hide()
      return
    elseif params.toogle then
      tool.controller:toggle()
      tool.group:toFront()
    elseif params.class == "new_rectangle" or params.class == "new_ellipse" or params.class == "new_text" then
      UI.scene.app:dispatchEvent{name="editor.classEditor.shape."..params.class,
        UI = UI}
    elseif params.class == "new_image" then
      native.showAlert("not implemented yet", "You can create a new rect and then click imageFile for browsing images")
      return
    else
      propsButtons:hide()
      propsTable:hide()

      -- read json
      tool:show()
      UI.editor.currentTool = tool
      UI.editor:setCurrnetSelection(UI.editor.currentLayer, params.class, UI.editor.currentType, params.suffix) -- inherits currentLayer and currentType here

      if params.class then -- this measn user clicks one of class, anim, button, drag ...
        if UI.editor.currentLayer == params.layer then
          print("not changed", UI.editor.currentLayer, params.layer)
          --print(debug.traceback())
        end
      end
      -- should we use name of UI.editor.editor.currentClass?
      -- timer.performWithDelay( 1000, function()
      if params.isUpdatingAsset then
        -- print("isUpdatingAsset")
        tool.controller:updateAsset(params.classField, params.asset)
      else
        -- params.asset is merged in this load()
        tool.controller:load(UI.editor.currentBook, UI.page, UI.editor.currentLayer, params.class, params.isNew, params.asset, UI.editor.currentType, UI.editor.currentClassSuffix)
        UI.editor.rootGroup:dispatchEvent{name="labelStore",
        currentBook= UI.editor.currentBook,
        currentPage= UI.page,
        currentLayer = UI.editor.currentLayer,
        currentClass = UI.editor.currentClass}

      end
      -- end)
    end
  else
    print("tool is not found for", params.class)
    -- let's use a generic one, should getClassModule return a generic tool?
    --
  end

  -- if params.class then
  --     -- for Animations, Interactions, Replacements ...
  --     for i=1, #models do
  --       local model = models[i]
  --       if "editor.view.toolbar-"..model.icon == params.class then
  --         UI.editor.currentToolbar = params.class
  --         --toolbar:toogleToolMap()
  --         break
  --       end
  --     end
  --     print("", "currentToolbar", UI.editor.currentToolbar)
  -- end

  --
    --
    --[[
    if UI.editor.currentTool =="Animations" then
        UI.currentPanel = UI.animationPanel
        UI.animationStore:set(fooValue)
        UI.actionEditor:hide()
        UI.actionPanel:destroy()
        UI.layerInstancePanel:destroy()
      else
        --local buttons = require(parent.."buttons")
      end
    --]]


--[[
		local path = UI.currentPage.path .."/commands/"..UI.currentAction.name..".json"
		print(path)

		UI.editPropsLabel = UI.currentAction.name
		local decoded, pos, msg = json.decodeFile( path )
		if not decoded then
			print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
		else
			print( "File successfully decoded!" )
			UI.actionCommandStore:set(decoded)
			UI.actionEditor:show()
		end
	--]]
  --
  --

end
--
local instance = AC.new(command)
return instance
