local name = ...
local parent,  root = newModule(name)

local Props = {
  name = "layerTable",
  anchorName = "selectLayer",
  id = "layer"
}

local M = require(parent .."baseTable").new(Props)
local commands = require(parent.."layerTableCommands")
local util = require(kwikGlobal.ROOT.."editor.util")

local function parse(model)
  local name = nil
  local children = nil
  local class = nil
  for k, v in pairs(model) do
    name = k
    -- print(k, v)
    if type(v) == "table" then
        for _name, value in pairs(v) do
          -- print("", _name)
          if not (_name == "weight" or _name == "class" or _name == "events") then
            local layer = {}
            layer[_name] = value
            if children == nil then
              children = {}
            end
            -- children[#children + 1] = layer
            children[_name] = value
            --print("", _name, class, #children)
          end
          if _name == "class" then
            if type (value) == "table" then
              class = value
            else
              print("Warning", value, "is not in table {} ")
            end
          end
        end
    end
  end
  -- print(name, class, children)
  return name, class, children
end

--
-- this is used for physics.classProps, must be reset for other tools
--
function M:setClassProps(classProps)
  self.classProps = classProps
end

function M:getPosition(_xIndex, _yIndex)
  local xIndex = _xIndex or 0
  local yIndex = _yIndex or 0

  local marginX, marginY =22 + xIndex*5, 44 + yIndex
  -- self.x = self.rootGroup.selectLayer.x + marginX
  self.rectWidth = 100 + 10
  -- self.x = self.rectWidth/2 + marginX
  -- self.y = self.rootGroup.selectLayer.y + marginY
  return  self.rectWidth/2 + marginX, self.rootGroup.selectLayer.y + marginY
end

function M:render(models, xIndex, yIndex, parentObj)
  local UI = self.UI
  local count = 0
  local objs = {}
  local option = self.option
  --
  local posX, posY = self:getPosition(xIndex, yIndex)
  --
  for i = 1, #models do
    local model = models[i]
    local entry = {}
    local count_for_class = 0

    count = count + 1
    entry.name, entry.class, entry.children = parse(model)

    if xIndex > 0 then
      option.text = "├ " .. entry.name
      if i == #models then
        option.text = "└ " .. entry.name
      end
    else
      option.text = entry.name
    end
    option.x = posX
    option.y = posY + option.height * (count - 1 + yIndex)
    option.width = 100

    local obj = self.newText(option)
    obj.layer = entry.name
    obj.class = ""
    obj.parentObj = parentObj
    if UI.sceneGroup[entry.name] then
      obj.shapedWith = UI.sceneGroup[entry.name].shapedWith
    end

    obj.touch = function(eventObj, event)
      self:commandHandler(eventObj, event)
      return true
    end
    obj:addEventListener("touch", obj)
    obj:addEventListener("mouse", self.mouseHandler)

    local rect = display.newRect(obj.x - xIndex * 5, obj.y, self.rectWidth, option.height)
    rect:setFillColor(0.8 + xIndex * 0.05)
    rect.strokeWidth = 1
    self.group:insert(rect)
    self.group:insert(obj)

    obj.rect = rect
    objs[#objs + 1] = obj

    -- class
    if entry.class then
      obj.classEntries = {}
      local last_x = 10
      local second_class_x = 0
      local second_offset_x = 60
      local vertical_offset = 1
      local toggleButton = nil -- Define toggleButton here

      for k = 1, #entry.class do
        option.text = entry.class[k]

        if k == 1 then
          -- First class stays in the original position
          option.x = posX + last_x
          option.y = posY + option.height * (count - 1 + yIndex)
        elseif k == 2 then
          -- Second class goes to the right of the first class
          option.x = posX + last_x + second_offset_x
          option.y = posY + option.height * (count - 1 + yIndex)
          second_class_x = option.x  -- Save this position for later classes
        else
          -- Third and subsequent classes stack vertically below the second class
          option.x = second_class_x
          option.y = posY + option.height * (count - 1 + yIndex + vertical_offset)
          vertical_offset = vertical_offset + 1
        end

        -- print(k, entry.name, option.text, option.x, option.y)

        option.width = nil
        local classObj = self.newText(option)
        classObj.parentObj = parentObj
        classObj.layer = entry.name

        local class, suffix = util.getClassSuffix(entry.class[k])
        classObj.class = class
        classObj.suffix = suffix
        classObj.touch = function(eventObj, event)
          self:commandHandlerClass(eventObj, event)
          return true
        end
        classObj:addEventListener("touch", classObj)
        classObj:addEventListener("mouse", self.mouseHandler)

        local rect = display.newRect(classObj.x, classObj.y, classObj.width + 10, option.height)
        rect:setFillColor(0.8)
        self.group:insert(rect)
        self.group:insert(classObj)

        if k <= 2 then
          -- Update the horizontal position for the first two classes
          last_x = classObj.width + 2 + last_x
        end

        classObj.rect = rect
        objs[#objs + 1] = classObj
        obj.classEntries[k] = classObj

        -- Create toggle button only for the first class
        if k == 1 and  #entry.class > 1 then
          local buttonSize = 16
          local buttonX = rect.x + rect.width + 10
          local buttonY = rect.y + rect.height / 2 - buttonSize/2

          toggleButton = display.newRect(buttonX, buttonY, buttonSize, buttonSize)
          toggleButton:setFillColor(0, 0, 1) -- Default: Blue (On)
          toggleButton.isToggled = true
          classObj.toggleButton = toggleButton
        elseif k > 1 then
          classObj.alpha = 0
          classObj.rect.alpha = 0
        end
      end

      if #entry.class > 1 then
        self.group:insert(toggleButton)
        toggleButton.tap = function(event)
          -- printKeys(event)
            toggleButton.isToggled = not toggleButton.isToggled
            if toggleButton.isToggled then
              toggleButton:setFillColor(0, 0, 1) -- Blue (On)
              -- Add logic to turn ON subsequent classes
              for i, v in next, obj.classEntries do
                if i > 1 then
                  v.alpha = 0
                  v.rect.alpha = 0
                end
              end
            else
              toggleButton:setFillColor(1, 0, 0) -- Red (Off)
              -- Add logic to turn OFF subsequent classes
              for i, v in next, obj.classEntries do
                if i > 1 then
                  v.alpha = 1
                  v.rect.alpha = 1
                end
              end
            end
          return true
        end
        toggleButton:addEventListener("tap", toggleButton)
        toggleButton:toFront()
      end
      -- Adjust count to account for vertical space used by classes after the second one
      if #entry.class > 2 then
        count_for_class = count_for_class + (#entry.class - 2)
      end
    end

    -- children
    if entry.children and #entry.children > 0 then
      local childEntries, c = self:render(entry.children, xIndex + 1, count + yIndex, obj)
      count = count + c
      obj.text = obj.layer

      for k, v in pairs(childEntries) do
        objs[#objs + 1] = v
      end
      obj.childEntries = childEntries
      obj.isIndex = true
    end
  end

  self.rootGroup:insert(self.group)
  self.rootGroup.layerTable = self.group
  return objs, count
end

--
function M:create(UI)
  self.commandHandlerClass = commands.commandHandlerClass
  self.commandHandler = commands.commandHandler
  self.mouseHandler = commands.mouseHandler

  -- if self.rootGroup then return end

  self:initScene(UI)
  self.selections = {}

  self.UI = UI


  UI.editor.layerStore:listen(
    function(foo, fooValue)
      -- local json = require("json")
      self:destroy()
      -- print("layerStore", #fooValue.value)
      self.selection = nil
      self.selections = {}
      -- local json = require("json")
      -- print(json.encode(fooValue.value))
      --
      -- reset classProps to be used for setActiveProp
      if #fooValue.value == 0 then
        self.classProps = nil
      end
      self.objs = self:render(fooValue.value, 0, 0)
      self:show() -- this needs from asset > activeProp
      if fooValue.isActiveProp then
        self.group.oriX = self.group.x
        self.group.oriY = self.group.y
        self.group.x = display.contentCenterX+120
        self.group.y = display.contentCenterY-200
      end
    end
  )
end

local function findClassObj(obj, class)
  if obj.classEntries then
    --look for class
    for j=1, #obj.classEntries do
      local classObj = obj.classEntries[j]
      if classObj.class == class then
        -- create or create class
        classObj.index = j
        return classObj
      end
    end
  end
  return nil
end

--
-- args = {"book", "page", "groupOne", "groupTwo", "chidLayer"}
--  so findObj(layerTable.objs, args, 3) to start the function
--
local function findObj(objs, args, nLevel)
  local layer = args[nLevel]
  local argsLength = #args
  for i=1, #objs do
    local obj = objs[i]
    -- print(i, obj.layer, layer, nLevel, argsLength)
    if argsLength == nLevel then
      if obj.layer == layer then
        -- print("matched", i, obj.layer)
        return obj
      end
    elseif obj.layer == layer then
      obj = findObj(obj.childEntries, args, nLevel+1)
      if obj then
        return obj
      end
    end
  end
  return nil
end

M.findClassObj = findClassObj
M.findObj = findObj
--
--
return M
