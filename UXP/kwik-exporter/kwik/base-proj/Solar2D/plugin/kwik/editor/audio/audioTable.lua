local name = ...
local parent,root = newModule(name)
local mui = require("materialui.mui")

local props = require(root.."model").pageTools.audio
props.anchorName = "selectAudio"
props.icons      = {"addAudio", "trash"}
props.objs       = {}

------------
-- baseTable
-----------
local M, bt, tree = require(root.."parts.baseTable").new(props)

local propsTable = require(root .. "parts.propsTable")

local actionCommandPropsTable = require(kwikGlobal.ROOT.."editor.action.actionCommandPropsTable")
local classProps              = require(kwikGlobal.ROOT.."editor.parts.classProps")

local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local contextButtons = require(kwikGlobal.ROOT.."editor.parts.buttons")

local posX = display.contentCenterX*0.75

function M:setPosition()
  self.x = 77
  self.y = 74 -- self.rootGroup.selectAudio.y
end

function M.mouseHandler(event)
  if event.isSecondaryButtonDown and event.target.isSelected then
    -- print("@@@@selected")
        contextButtons:showContextMenu(event.x + 100, event.y,  {
          audio =event.target.text, type = event.target.subclass, selections={event.target},
          isMultiSelection = false})
  else
    -- print("@@@@not selected")
  end
  return true
end

-- target.class will be audio.long or audio.short or audio.sync
-- a sync audio can be multiple

function M:commandHandler(target, event)
  local UI = self.UI
  if event.phase == "began" or event.phase == "moved" then  return end
  layerTableCommands.clearSelections(self, "audio")
  if self:isAltDown() then
    if layerTableCommands.showLayerProps(self, target) then
      print("TODO show audio props")
      print(target.audio)
      --
      tree.backboard = {
        audio = target.audio,
        show = true,
        class = target.class,
        subclass = target.subclass
      }
      tree:setConditionStatus("select component", bt.SUCCESS, true)
      tree:setConditionStatus("select audio", bt.SUCCESS)
      tree:setActionStatus("load audio", bt.RUNNING, true)
    end
  elseif self:isControlDown() then -- mutli selections
    layerTableCommands.multiSelections(self, target)
  else
    if layerTableCommands.singleSelection(self, target) then
      if target.audio then
        UI.editor:setCurrnetSelection(target.audio)
      end
      -- target.isSelected = true
      print("### currentClass ####")
      UI.editor.currentClass = target.name
      --
      -- should we enable one of them?
      if actionCommandPropsTable:setActiveProp(target.audio) then
        self:hide()
      end
      if classProps:setActiveProp(target.audio) then
        self:hide()
      end
    end
  end
  return true
end

--
function M:create(UI)
  -- print(debug.traceback())
  -- if self.rootGroup then return end
  self:initScene(UI)
  self:setPosition()

  self.UI = UI

  self.option = {
    text = "",
    x = 0,
    y = self.y,
    width = 100,
    height = 20,
    font = native.systemFont,
    fontSize = 10,
    align = "left"
  }


  M.selections = {}

  --

  local function render(_models, xIndex, yIndex)
    local option = self.option

    local function newAudio(models, subclass)
      local count = 0
      if models == nil then
        return
      end
      for i = 1, #models do
        local name = models[i]
        print(i, name)

        option.text = name
        if subclass == "long" then
          option.x = self.x +  xIndex * 5 + option.width
        else
          option.x = self.x +  xIndex * 5
        end
        option.y = self.y + option.height * (count-1)
        option.width = 100
        local obj = self.newText(option)
        obj.audio = name
        obj.class = "audio"
        obj.subclass = subclass
        obj.index =1
        -- obj.touch = commandHandler
        -- obj:addEventListener("touch", obj)

        obj.touch = function(eventObj, event)
          self:commandHandler(eventObj, event)
          UI.editor.selections = self.selections
        end
        obj:addEventListener("touch", obj)
        obj:addEventListener("mouse", self.mouseHandler)


        local rect = display.newRect(obj.x, obj.y, obj.width + 10, option.height)
        rect:setFillColor(0.8)
        self.group:insert(rect)
        self.group:insert(obj)

        count = count + 1
        obj.rect = rect
        self.objs[#self.objs + 1] = obj
      end
    end
    --
    newAudio(_models.short, "short")
    newAudio(_models.long, "long")
    --
    self.rootGroup:insert(self.group)
    self.rootGroup.audioTable = self.group
    -- self.group.isVisible = true
  end

  UI.editor.audioStore:listen(
    function(foo, fooValue)
      self:destroy()
      self.selection = nil
      self.selections = {}
      self.objs = {}
      self.iconObjs = {}
      if fooValue.value == nil then
        render({}, 0, 0)
      else
        -- print("@@@@",#fooValue.value.short, #fooValue.value.long)
        render(fooValue.value, 0, 0)
        if fooValue.value.short == nil then
          self:createIcons(0, -21)
        else
          self:createIcons(0, -21)
        end
      end
      self:show()
      if fooValue and fooValue.isActiveProp then
        self.group.x = display.contentCenterX+120
        self.group.y = display.contentCenterY-100
      end
    end
  )
end
--

-- function M:show()
--   self.group.isVisible = true
--   if self.objs then
--     for i=1, #self.objs do
--       self.objs[i].isVisible = true
--     end
--   end
-- end

-- function M:hide()
--   self.group.isVisible = false
--   if self.objs then
--     for i=1, #self.objs do
--       self.objs[i].isVisible = false
--     end
--   end
-- end

--
-- function M:destroy()
--   if self.objs then
--     for i = 1, #self.objs do
--       if self.objs[i].isMUI then
--         -- print("@@@@@", self.objs[i].name)
--         mui.removeWidgetByName(self.objs[i].name)
--       else
--         if self.objs[i].rect then
--           self.objs[i].rect:removeSelf()
--         end
--         if self.objs[i].removeSelf then
--           self.objs[i]:removeSelf()
--         end
--       end
--     end
--   end
--   self.objs = nil
--   self.selection = nil
--   self.rootGroup.audioTable = nil
-- end
--
return M
