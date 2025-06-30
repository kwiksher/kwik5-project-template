local M = {}
M.name = ...
M.weight = 1
M.x = 11
M.y = 11*7/2 + 26 -- display.contentCenterY -100

---
local muiIcon = require(kwikGlobal.ROOT.."components.mui.icon").new()
local util = require(kwikGlobal.ROOT.."lib.util")
local mui = require("materialui.mui")

 local skipped = {"Shapes"}
---
function M:init(UI)
  self.models = require(kwikGlobal.ROOT.."editor.model").layerTools
end
--
function M:setUI (UI)
  self.UI = UI
end
--
function M:create(UI)
  -- print("create", self.name)
  self.UI = UI

  self.layerToolMap = {}
  self.toolMap = nil
  self.vertical = false

  local toolListener = function(event)
    -- print("@@", self.selection, event.target.muiOptions.name)
    --for k, v in pairs(event.target.muiOptions) do print(k, v) end
    if self.selection == event.target.muiOptions.name then
      self.selection = nil
      self:toogleToolMap()
    else
      for key, obj in pairs(self.toolMap) do
        if key == event.target.muiOptions.name then
          self.selection = key
          -- print("@@@@@@@", UI.editor.currentLayer)
          UI.scene.app:dispatchEvent(
            {
              name = "editor.selector.selectTool",
              UI = self.UI,
              class = obj.class,
              -- toolbar = self,
              isNew = true
            }
          )
        else
          mui.turnOnButtonByName(key)
        end
      end
      -- obj.isVisible = false
    end
    return true
  end

  local findSelectedTool = function (name)
    for k, obj in pairs(self.layerToolMap) do
      if k == name then
        return k, obj
      end
    end
  end

  local lastTool
  --
  -- for Animations, Interactions, Replacements ...
  local layerToolListener = function(event)
    if UI.editor.currentTool then
      print("save or cancel to make it nil", UI.editor.currentTool.model.id)
      return
    end
    local toolbarName, layerTool = findSelectedTool(event.target.muiOptions.name)
    mui.turnOnButtonByName(toolbarName)
    --
    if self.toolMap == nil and #layerTool.tools > 0 then
      self.toolMap = {}
      -- Kwik Component such as linear, pulse, roation ..
      for i = 1, #layerTool.tools do
        local tool = layerTool.tools[i]
        local posX, posY
        if self.vertical then
          posX = 33
          posY =  self.y + event.target.y + 22*i -2
        else
          posX =  22*i + 11
          posY = 20
        end
        local obj =
          muiIcon:createToolImage {
          icon = tool.icon,
          name = layerTool.id .. "-" .. tool.name,
          --text = tool.name,
          class = tool.name,
          hoverText = tool.name,
          -- x = 66+ (i+2 ) * 22 - #obj.tools * 22 * 0.5,
          -- y = (display.actualContentHeight-1280/4 )/2,
          x = posX,
          y =  posY,
          width = 22,
          height = 22,
          listener = toolListener,
          iconSize = 18

        }
        obj.class    = string.lower(tool.name)
        obj.layerTool = layerTool.id
        self.toolMap[layerTool.id .. "-" .. tool.name] = obj
      end
    elseif #layerTool.tools == 0 then -- Trash
        UI.scene.app:dispatchEvent(
          {
            name = "editor.classEditor." ..layerTool.command,
            UI = self.UI,
          }
        )

    else
      for k, v in pairs(self.toolMap) do
        v:removeSelf()
      end
      self.toolMap = nil
    end
    -- print(toolbarName)
    -- UI.editor.currentToolbar = toolbarName

    -- UI.scene.app:dispatchEvent(
    --   {
    --     name = "editor.selector.selectTool",
    --     UI = UI,
    --     selection = toolbarName,
    --     toolbar = self
    --   }
    -- )

    --self:toogleToolMap()

    --
    -- timer.performWithDelay( 6000, function()
    --   for k, v in pairs(self.toolMap) do
    --     v:removeSelf()
    --     self.toolMap = {}
    --   end
    -- end )
    --
    return true
  end
  -- KWIK Components Category W/O text, Properties, Animations, Replacements, Interactions ..
  for k, v in pairs(self.models) do
    --if v.icon:len() > 0 then
      local obj =
        muiIcon:createImage {
        icon = v.icon,
        name = v.name,
        x = self.x,
        y = self.y+ (k) * 22 - (#self.models-#skipped) * 22 * 0.5,
        -- y = (display.actualContentHeight-1280/4 )/2-22,
        width = 22,
        height = 22,
        listener = layerToolListener,
        id = v.id,
        fillColor = {1, 1, 1},
        iconAlign = "center",
        iconSize = 18
      }
      obj.id = v.id
      obj.tools = v.tools
      obj.command = v.command -- for trash
      self.layerToolMap[v.name] = obj
      lastTool = obj
    --end
  end
  self:hide()
  UI.editor.toolbar = self

end

function M:getWidth()
  return (#self.models +1) * 22 -4
end
--
function M:didShow(UI)
end
--
function M:didHide(UI)
end
--
function M:destroy()
end

function M:hide ()
  for k, v in pairs(self.layerToolMap) do
    v.isVisible = false
  end
  self.isVisible = false
end

function M:show ()
  for k, v in pairs(self.layerToolMap) do
    v.isVisible = true
  end
  self.isVisible = true
end

function M:toogleToolMap ()
  if self.toolMap then
    for k, v in pairs(self.toolMap) do
      v.isVisible = not v.isVisible
    end
  end
end

function M:hideToolMap ()
  if self.toolMap then
    for k, v in pairs(self.toolMap) do
      v.isVisible = false
    end
  end
end

--
return M
