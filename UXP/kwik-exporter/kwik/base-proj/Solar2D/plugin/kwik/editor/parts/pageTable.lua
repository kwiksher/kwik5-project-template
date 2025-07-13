local name = ...
local parent,  root = newModule(name)
local widget = require( "widget" )
local buttons    = require(kwikGlobal.ROOT.."editor.parts.buttons")

local Props = {
  name = "page",
  icons      = {"lockPage", "Properties", "newPage", "trash"},
  marginX = 69,
  setPosition = function(self)
    -- self.x = self.x
    -- self.y = self.y
    self.x = 0
    self.y = 52
    self.width = 84
    --
    self.option = {
      text = "",
      x = self.x,
      y = self.y,
      width = nil,
      height = 20,
      font = native.systemFont,
      fontSize = 10,
      align = "left"
    }

  end ,
  id = "page"
}

local horizontal = false
local PAGE_MAX = 24

local M, bt, tree = require(parent .."baseTable").new(Props)

local btNodeName = "select page"

--M.anchorName = "selectPageIcons"
M.eventMap = {
  lockPage = "lockPage",
  Properties = "selectPageIcons",
  newPage    = "selectPageIcons",
  trash      = "selectPageIcons"
}

function M.btHandler(target)
  local self = M
  if self.selection and self.selection.rect then
    self.selection.rect:setFillColor(0.8)
    if self.selection.page ~= target.page then
      self.selection.rect:setFillColor(0.8)
      tree:setConditionStatus(btNodeName, bt.FAILED, true)
      tree:setActionStatus("load page", bt.RUNNING) -- need a tick to call self.group:tick()
    end
  else
    tree:setConditionStatus(btNodeName, bt.FAILED, true)
    tree:setActionStatus("load page", bt.RUNNING) -- need a tick to call self.group:tick()
  end

  self.selection = target
  if self.selection.rect then
    self.selection.rect:setFillColor(0,1,0)
  end

  tree.backboard = {
      page = target.page,
  }
  tree:setConditionStatus("select page", bt.SUCCESS)
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectPage",
  --   UI = self.UI,
  --   page = eventObj.page
  -- }
end

local function mouseHandler(event)
  if event.isSecondaryButtonDown then
    -- print(event.target.page, event.target.x, event.target.y, event.x, event.y)
    buttons:showContextMenu(event.x + 30, event.y+10,
      {page=event.target.text, selections={event.target},
      contextMenu = {"create", "rename", "delete"}, orientation = "vertical", isPageContent = true})
  else
    -- print("@@@@not selected")
  end
  return true
end

-- use baseTable:commandHandler? no it does not have isReload yet
---[[
function M.commandHandler(target, event, isReload)
  -- local target = event.target
  local UI = M.UI
  local self = M
  -- print("touch", event.phase)
  buttons:hide()
  if event and (event.phase == "began" or event.phase == "moved") then  return end

  -- print("commandHandler", self.objs)
  -- print("", debug.traceback())
  self.isReload = isReload -- we will take if off when reload is ended
  self.btHandler(target)
  if isReload then
    -- print("###### isReload")
    self.lockPage = target.page
    -- for i=1, #self.objs do
    --   if self.objs[i].page == target.page then
    --     -- print("", self.objs[i].page)
    --     target = self.objs[i]
    --     target.lockIcon.isVisible = true
    --     self.selection = target
    --     break
    --   end
    -- end
  end

end
--]]

function M:createTable(UI, entries, selection)
    -- print("-----pageStore", #entries, self.selection)
    -- timer.performWithDelay( 500, function()
    local option = self.option
    -- local objs = {}

    local max = math.min(PAGE_MAX, #entries)
    local width = self.width
    local height = self.option.height
    local scrollView

    if horizontal then
      scrollView = widget.newScrollView
      {
        top                      = option.y - option.height/2,
        left                     = self.x,
        width                    =  max*width,
        height                   = option.height,
        scrollHeight             = option.height,
        scrollWidth              = #entries*width,
        verticalScrollDisabled   = true,
        horizontalScrollDisabled = false,
        backgroundColor          = {0.8},

        -- width                    =  option.width,
        -- height                   = max*option.height,
        -- scrollHeight             = #entries*option.height,
        -- -- scrollWidth            = #entries*option.width,
        -- verticalScrollDisabled   = false,
        -- horizontalScrollDisabled = true,
        friction                 = 2,
      }
    else
      scrollView = widget.newScrollView
      {
        top                      = option.y - option.height/2,
        left                     = self.x+width,
        width                    =  width,
        height                   =  max*height,
        scrollHeight             = #entries*height,
        scrollWidth              = width,
        verticalScrollDisabled   = false,
        horizontalScrollDisabled = true,
        backgroundColor          = {0.8},

        -- width                    =  option.width,
        -- height                   = max*option.height,
        -- scrollHeight             = #entries*option.height,
        -- -- scrollWidth            = #entries*option.width,
        -- verticalScrollDisabled   = false,
        -- horizontalScrollDisabled = true,
        friction                 = 2,
      }
    end


    local function createColumn(index, entry)
      local group = display.newGroup()
      --
      option.text = entry.name
      option.y = option.height/2

      -- option.x = option.x
      -- option.y = option.height/2 + index*option.height

      local obj = self.newText(option)
      -- obj:setFillColor(0,1,0)
      obj.page = entry.name
      obj.tap = self.commandHandler

      obj.x = obj.width/2
      -- function(eventObj)
      --   self:commandHandler(eventObj)
      --   self.selection.rect:setFillColor(0,1,0)
      -- end
      obj:addEventListener("tap", obj)
      obj:addEventListener("mouse", mouseHandler)

      obj.index = index

      local rect = display.newRect(obj.x, obj.y, obj.width+4, option.height)
      rect:setFillColor(0.8)
      obj.rect = rect

      if index > 1 then
        if horizontal then
          obj.x = self.objs[index-1].rect.contentBounds.xMax + obj.rect.width/2
          obj.rect.x = obj.x
        else
          obj.y = self.objs[index-1].y + obj.rect.height
          obj.rect.y = obj.y
        end
      end

      local lockIcon = display.newImage(kwikGlobal.PATH.."../resources/images/icons/lockPage.png")
      lockIcon.x = obj.x + 40
      lockIcon.y = obj.y
      lockIcon.isVisible = false
      if self.lockPage == obj.page then
        lockIcon.isVisible = true
      end

      obj.lockIcon = lockIcon

      group:insert(obj.rect)
      group:insert(obj)
      group:insert(obj.lockIcon)
      scrollView:insert(group)
      return obj
    end

    for index=1, #entries do
      self.objs[index] = createColumn(index, entries[index])
    end


    if selection == nil then
      self.selection = self.objs[#self.objs]
      -- print("", "backboard", objs[#objs].page, objs[#objs])
      -- tree.backboard = {
      --   page = objs[#objs].page,
      -- }
      -- tree:setConditionStatus("select page", bt.SUCCESS)
    else
      for i=1, #self.objs do
        if self.objs[i].page == selection.page then
          self.selection = self.objs[i]
          break
        end
      end
    end
    --self.selection.rect:setFillColor(0, 1, 0)
    self.scrollView = scrollView
    self.group:insert(scrollView)
    self.rootGroup:insert(self.group)
    self.rootGroup.pageTable = self.group
    -- self.objs = objs
    -- print("-----------", "Done")
  -- end)

end
--
function M:create(UI)
  -- if self.rootGroup then return end
  self:initScene(UI)
  self.selections = {}
  ---


  UI.editor.pageStore:listen(
    function(foo, fooValue)
      -- print(debug.traceback())
      self:setPosition()
      self:clean()
      self.objs = {}
      self.iconObjs = {}
      self:createTable(UI, fooValue.value, self.selection )
      self:createIcons()
    end
  )

  -- local function compare(a,b)
  -- 	return a.name < b.name
  -- end
  -- --
  -- table.sort(fooValue.value,compare)
end

function M:setLock(page)
  for i=1, #self.objs do
    if self.objs[i].page == page then
      self.objs[i].lockIcon.isVisible = true
    elseif self.objs[i].lockIcon then
      self.objs[i].lockIcon.isVisible = false
    end
  end
end
--
-- function M:didShow(UI)
--   self.UI = UI
-- end
--
-- function M:didHide(UI)
-- end
--
-- function M:destroy()
--   -- self:clean()
--   -- print(debug.traceback())
--   if self.objs then
--     for k, obj in next, self.objs do
--       obj.rect:removeSelf()
--       obj:removeEventListener("touch", obj)
--       obj:removeEventListener("mouse", mouseHandler)
--       obj:removeSelf()
--     end
--   end
--   self.objs = nil

-- end
--
--
return M
