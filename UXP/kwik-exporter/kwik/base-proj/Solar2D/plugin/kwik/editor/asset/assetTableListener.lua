local name = ...
local parent,root, M = newModule(name)

local propsTable = require(root .. "parts.propsTable")
local selectors = require(root.."parts.selectors")

local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local contextButtons = require(kwikGlobal.ROOT.."editor.parts.buttons")
local handlerMap  = require(kwikGlobal.ROOT.."editor.asset.model")
local json = require("json")

local posX = display.contentCenterX*0.75

function M.mouseHandler(event)
  if event.isSecondaryButtonDown and event.target.isSelected then
    -- print("@@@@selected")
    contextButtons.openEditorObj.text = "open folder"
    contextButtons:showContextMenu(posX, event.y,  {class="asset", folder=M.class.."s", selections=M.selections})
  else
    -- print("@@@@not selected")
  end
  return true
end

-- target.class will be audio.long or audio.short or audio.sync
-- a sync audio can be multiple

local lastTool, lastClass
---
function M:iconsHandler(event, class, tool)
  if self.group.isVisible == false then
    self:show()
    selectors.assetsSelector:show()
  else

    self:hide()
    -- selectors.assetsSelector:hide()
    -- selectors.componentSelector:show()
    -- selectors.componentSelector:onClick(true,  "layerTable")

    -- should we use BT with "add component"?
    -- for k, v in pairs(event.target.muiOptions) do print(k, v) end
    local name = event.target.muiOptions.name
    --
    -- printTable(self.selection)
    --
    if self.selection then
      if lastTool then
        -- print("#########", lastTool)
        self.UI.scene.app:dispatchEvent {
          name = "editor.selector."..lastTool,
          UI = self.UI,
          class = lastClass,
          hide = true
        }
      end
      lastTool = tool
      lastClass = class
      --
      self.UI.scene.app:dispatchEvent {
        name = "editor.selector."..tool,
        UI = self.UI,
        class = class,
        asset = self.selection.asset,
        isUpdatingAsset = true,
        isNew = (name ~= "trash-icon"),
        isDelete = (name == "trash-icon")
      }
      --
      if  #self.selections > 0 then
        for i = 1, #self.selections do
          if self.selections[i].rect then
            self.selections[i].rect:setFillColor(0.8)
          end
        end
      end
    else
      native.showAlert( "alert", "Please select a file")
    end
  end
end


local function getHandler(assetName)
  -- print(assetName)
  local ret =  handlerMap[assetName]
  if ret then
    return ret.modify
  else
    return {}
  end
end

local function getClass(assetName)
  return handlerMap[assetName].class
end

local function getClassModule(class)
  if class == "particles" then
    return handlerMap[class].tool
  else
    return handlerMap[class.."s"].tool
  end
end

function M:touchHandler(target, event)
  if event.phase == "began" or event.phase == "moved" then  return end
  layerTableCommands.clearSelections(self, "asset")
  -- print(self.controlDown)
  if self:isAltDown() then
    if layerTableCommands.showLayerProps(self, target) then
      print("---- none for assets ------?")
    end
  elseif self:isControlDown() then -- mutli selections
    print("multi", #self.selections)
    layerTableCommands.multiSelections(self, target)
  elseif self.classProps then
    print("target.text", target.text)
    self.classProps:setActiveProp(target.text)
  else
    if layerTableCommands.singleSelection(self, target) then
      -- TBI
      -- dispatchEvent to the class editor
      if target.class then
        -- print(target.class)
        -- printKeys(self.selection.asset)
        self.UI.scene.app:dispatchEvent {
          name = "editor.selector."..getClassModule(target.class),
          UI = self.UI,
          class = target.class,
          asset = self.selection.asset,
          isUpdatingAsset = false,
          isNew = (name ~= "trash-icon"),
          isDelete = (name == "trash-icon")
        }
      end
    end
  end
  return true
end
--
function M:storeListener(foo, fooValue, render)
  -- print("-------------------- storeListener ---------", fooValue.class)
  -- print(debug.traceback())
  --print(json.prettify(fooValue))
  --print("assetStore", #fooValue)
  --
  self:destroy()
  self.selection = nil
  self.selections = {}
  self.objs = {}
  self.commandHandler = getHandler(fooValue.value.class)
  if fooValue.value == nil then
    --render({}, 0, 0)
  else

     if self.lastClass and self.classProps==nil then
      local tool = self.UI.editor:getClassModule(self.lastClass)
       if tool then
          -- print("### lastTool", tool.id)
          tool.controller:hide()
       end
     end

    local asset = handlerMap[fooValue.value.class]
    if asset then
       self.class = asset.class
       self.lastClass= asset.class
      --
      -- local anchor = self.rootGroup[self.anchorName].rect
      render(fooValue.value.decoded or {}, asset.class )
      if asset then
        self:createIcons(asset.icons, asset.class, asset.tool)
      end
    else
      -- fooValue.value.class is missing.
      -- assets/model.lua
      --   audios = {class = "audio",
      --   videos = {class = "video",
      --   sprites = {class = "sprite"
      --   syncs = {class = "sync",
    end
  end
  self:show()
end
--
return M
