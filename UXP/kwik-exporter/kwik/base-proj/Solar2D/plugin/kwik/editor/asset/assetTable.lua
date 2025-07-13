local name = ...
local parent,root = newModule(name)
local mui = require("materialui.mui")
local muiIcon    = require(kwikGlobal.ROOT.."components.mui.icon").new()
local assetTableListener = require(parent.."assetTableListener")
local layerTable = require(root.."parts.layerTable")

local propsTable = require(root .. "parts.propsTable")
local selectors = require(root.."parts.selectors")

local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local contextButtons = require(kwikGlobal.ROOT.."editor.parts.buttons")
local json = require("json")
local AudioSet = table:mySet{"short","long"}

local props = require(root.."model").assetTool
props.anchorName = "selectAction"
props.icons      = {"repVideo", "trash"}
props.objs       = {}
props.marginX = nil-- display.contentCenterX

------------
-- baseTable
-----------
local M, bt, tree = require(root.."parts.baseTable").new(props)
--
M.x = 22 -- display.contentCenterX + 480*0.75
M.y = 22
M.width = 100

local posX = display.contentCenterX*0.75
local _marginX, _marginY = -16, 38

function M:setPosition()
  -- self.x = self.rootGroup.layerTable.contentBounds.xMax
end

function M:setClassProps(classProps)
  self.classProps = classProps
end

function M:createIcons (icons, class, tool)
  -- print("createIcons", class, self.anchorName, self.x, self.y, _marginX, _marginY)
  local marginX = _marginX or self.marginX
  local marginY = _marginY or 0
  ---
  for k, icon in next, self.icons do
    mui.removeWidgetByName(icon.name)
  end
  self.icons = {}
  ---
  for i=1, #icons do
    local name = icons[i]
    -- print("asset icon", name, self.x + i*22 - self.width/2-11)
    local actionIcon = muiIcon:create {
      icon = {name.."_over", name.."Color_over", name},
      text = "",
      name = name.."-icon",
      x = self.x + i*22 - self.width/2,
      y = self.y-2 ,
      width = 22,
      height = 22,
      fontSize =16,
      fillColor = {1.0},
      listener = function(event)
        self:iconsHandler(event, class, tool)
      end
    }
    -- print("", class, actionIcon)
    self.icons[i] = actionIcon
    self.group:insert(actionIcon)
    -- print("group.x", self.group.x)
  end
end

function M:init(UI, x, y, w, h)
  -- self.x = x or self.x
  -- self.y = y or self.y
  -- self.width = w or self.width
  -- self.height = h or self.height
end
--
function M:create(UI)

--  if self.rootGroup then return end

  self:initScene(UI)
  self.selections = {}
  -- print("group.x", self.group.x)
  self.group:translate(self.width*0.5, 0)
  self.option = {
    text = "",
    x = 0,
    y = 0,
    width = 100,
    height = 20,
    font = native.systemFont,
    fontSize = 10,
    align = "left"
  }
  --
  local function render(models, class)
    self:setPosition()
    --print(json.prettify(models))
    -- print("group.x", self.group.x)
    self.linkGroup = display.newGroup()

    local count = 0
    local marginX, marginY = 44, 50
    local option = self.option
    option.y = self.y
    for i = 1, #models do
      local asset = models[i]
      if asset.path:len() > 0 and AudioSet[asset.path] then
        option.text =  asset.path .."/"..asset.name
      else
        option.text =  asset.name
      end
      option.x = self.x + marginX
      option.y = self.y + option.height * (count-1) +marginY
      option.width = self.width + 80
      local obj = self.newText(option)
      obj.index = i
      obj.asset = asset
      obj.class = class
      -- obj.touch = commandHandler
      -- obj:addEventListener("touch", obj)

      obj.touch = function(eventObj, event)
        -- print("touch")
        self:touchHandler(eventObj, event)
        -- UI.editor.selections = self.selections
        if event.phase == "ended" then
          self.linkGroup:removeSelf()
          self.linkGroup = display.newGroup()
          self:renderLink(eventObj.asset.links)
        end
      end
      obj:addEventListener("touch", obj)
      obj:addEventListener("mouse", self.mouseHandler)

      local rect = display.newRect(obj.x, obj.y, obj.width + 10, option.height)
      rect:setFillColor(0.8)
      rect.strokeWidth = 1
      self.group:insert(rect)
      self.group:insert(obj)

      -- count = count + 1
      obj.rect = rect
      obj.links = {}
      count = count + 1
      self.objs[#self.objs + 1] = obj
    end
    --
    --
    self.rootGroup:insert(self.group)
    -- print("group.x", self.group.x)
    self.rootGroup.assetTable = self.group
    self.group:insert(self.linkGroup)
    -- self.group.isVisible = true
  end

  if self.initStore == nil then
    local function listener (foo, fooValue)
      self:storeListener(foo, fooValue, render)
    end
    UI.editor.assetStore:listen(listener)
    self.initStore = true
  end
  -- print("group.x", self.group.x)
end
--

function M:renderLink(links)
  local posX = display.contentCenterX - 480*0.25
  local posY = 33
  local option = self.option

  for k=1, #links do
    local link = links[k]
    if link.layers then
      local pageObj
      option.text =  link.page
      option.x = posX -- + option.width/2 + 10
      option.y = posY + option.height*k
      option.width = self.width
      pageObj = self.newText(option)
      pageObj.layers = {}
      ---
      local rect = display.newRect(pageObj.x, pageObj.y, pageObj.width + 10, option.height)
      rect:setFillColor(0.8)
      pageObj.rect = rect
      self.linkGroup:insert(rect)
      self.linkGroup:insert(pageObj)

      ----
      for j=1, #link.layers do
        option.text =  link.layers[j]
        option.x = posX + option.width*j
        option.y = posY + option.height
        local layerObj = self.newText(option)
        layerObj.index = j
        layerObj.touch = function(eventObj, event)
          print(eventObj.text)
        end
        layerObj:addEventListener("touch", layerObj)
        table.insert(pageObj.layers, layerObj)

        local rect = display.newRect(layerObj.x, layerObj.y, layerObj.width + 10, option.height)
        rect:setFillColor(0.8)
        layerObj.rect = rect
        self.linkGroup:insert(rect)
        self.linkGroup:insert(layerObj)
      end
      -- count = count + 1
      -- print("count", count)
    else
      option.text =  link.page
      option.x = posX + option.width/2 *k
      pageObj = self.newText(option)
      local rect = display.newRect(pageObj.x, pageObj.y, pageObj.width + 10, option.height)
      rect:setFillColor(0.8)
      pageObj.rect = rect
      self.linkGroup:insert(rect)
      self.linkGroup:insert(pageObj)
      -- count = count + 1
    end
    -- table.insert(obj.links, pageObj)
  end
end

function M:show()
  -- print(debug.traceback())
  -- print("group.x", self.group.x)
  self.group.isVisible = true
  if self.objs then
    for i=1, #self.objs do
      self.objs[i].isVisible = true
    end
  end
  if self.linkGroup then
    self.linkGroup.isVisible = true
  end
end

function M:hide()
  self.group.isVisible = false
  if self.objs then
    for i=1, #self.objs do
      self.objs[i].isVisible = false
    end
  end
  if self.linkGroup then
    self.linkGroup.isVisible = false
  end
  for i=1, #self.icons do
    -- print(type(self.icons[i]))
    if type(self.icons[i]) == "table" then
      self.icons[i].isVisible = false
    end
  end
end

--
function M:destroy()
  for k, icon in next, self.icons do
    if type(icon) == "table" then
      -- for name, value in pairs(icon) do print(name, value) end
      mui.removeWidgetByName(icon.name)
    else
      -- print(icon)
    end
  end

  if self.objs then
    for i = 1, #self.objs do
      if self.objs[i].isMUI then
        -- print("@@@@@", self.objs[i].name)
        mui.removeWidgetByName(self.objs[i].name)
      else
        if self.objs[i].rect and self.objs[i].rect.removeSelf then
          self.objs[i].rect:removeSelf()
        end
        if self.objs[i].removeSelf then
          self.objs[i]:removeSelf()
          self.objs[i] = nil
        end
      end
    end
  end

  if self.linkGroup then
    self.linkGroup:removeSelf()
    self.linkGroup = nil
  end
  -- self.icons = nil
  self.objs = nil
  self.selection = nil
  self.rootGroup.assetTable = nil
end

local function copy(tbl)
	local newTbl = {}

	for key, value in pairs(tbl) do
		newTbl[key] = value
	end

	return newTbl
end
--
return setmetatable(copy(assetTableListener), {__index=M})

--[[
https://devforum.community/t/how-do-i-do-conditional-multiple-inheritance-in-lua-with-oop/343/2

-- Enemy:

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
	return setmetatable({}, Enemy)
end

-- Boss:

local Boss = setmetatable({}, Enemy)
Boss.__index = Boss

function Boss.new()
	return setmetatable({}, Boss)
end

-- Orc:

local Orc = {}

function Orc:method()

end

-- Orc methods and properties must be defined before you copy them!

local OrcBoss = setmetatable(copy(Orc), Boss)
OrcBoss.__index = OrcBoss

local OrcEnemy = setmetatable(copy(Orc), Enemy)
OrcEnemy.__index = OrcEnemy

-- You can construct the different orc types like this:

function Orc.enemy()
	return setmetatable({}, OrcEnemy)
end

function Orc.boss()
	return setmetatable({}, OrcBoss)
end

Orc.enemy()
Orc.boss()

-- or like this:

function OrcEnemy.new()
	return setmetatable({}, OrcEnemy)
end

function OrcBoss.new()
	return setmetatable({}, OrcBoss)
end

OrcEnemy.new()
OrcBoss.new()

--]]
