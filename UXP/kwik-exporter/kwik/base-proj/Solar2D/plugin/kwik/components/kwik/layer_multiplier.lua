local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
local shape = require(kwikGlobal.ROOT.."components.kwik.layer_shape")

--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local layeName = self.properties.target
  local props = self.properties
  local layerProps = self.layerProps
  --
  self.group = display.newGroup()
  sceneGroup:insert(self.group)
end
--
function M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  local layeName =self.properties.target
  local props = self.properties
  local layerProps = self.layerProps

  local objs = {}
  local count = 0
  self.maxCopies = props.numOfCopies
  --
  if props.enablePhysics then
    physics.start(true)
  end

  -- self:group:toFront()
  --
  local handler = function(count)
    local obj
    -- for k,v in pairs(layerProps) do print(k, v) end
    if props.enablePhsyics and props.enableWind then
      physics.setGravity(math.random(props.windSpeed * -1, props.windSpeed) / 10, props.gravityY)
    else
      physics.setGravity(props.gravityX, props.gravityY)
    end
    --
    if layerProps.shapedWith == "new_rectangle" then
      obj = shape.createRectangle(layerProps)
    elseif layerProps.shapedWith == "new_elliipse" then
      obj = shape.createCicle(layerProps)
    elseif layerProps.shapedWith == "new_text" then
      local  obj = display.newText(layerProps)
      obj.name = layerProps.name
      if layerProps.color then
        obj:setFillColor(unpack(layerProps.color))
      end
      obj.anchorX = layerProps.anchorX or 0.5
      obj.anchorY = layerProps.anchorY or 0.5
      obj.rotation = layerProps.rotation or 0
      obj.shapedWith = layerProps.shapedWith
      obj.oldAlpha = 1
      obj.oriAlpha = layerProps.alpha or 1
      obj.oriX = layerProps.x
      obj.oriY = layerProps.y
    elseif layerProps.shapedWith == "new_image" then
      native.showAlert("Warning", "Instead of a shape image, use a layer image from Photoshop")
      return
    else
      local target = sceneGroup[props.target]
      local imagePath = layerProps.name.."." .. layerProps.type
      obj = display.newImageRect(UI.props.imgDir .. UI.page.."/"..imagePath, UI.props.systemDir, layerProps.width/4, layerProps.height/4)
      if obj == nil then
        print("Error newImageRect", UI.props.imgDir .. UI.page.."/"..imagePath)
      end
      obj.anchorX = layerProps.anchorX or 0.5
      obj.anchorY = layerProps.anchorY or 0.5
      obj.rotation = layerProps.rotation or 0
      obj.shapedWith = layerProps.shapedWith
      obj.oldAlpha = 1
      obj.oriAlpha = layerProps.alpha or 1
      obj.oriX = target.x
      obj.oriY = target.y
    end
    --
    local editorWidth, editorHeight = display.contentWidth - 480, display.contentHeight -320
    local xStart, yStart  = props.xStart*0.25 + editorWidth/2 , props.yStart*0.25 + editorHeight/2
    local xEnd, yEnd  = props.xEnd*0.25 + editorWidth/2 , props.yEnd*0.25 + editorHeight/2

    if props.fixedDistance then
      obj.x = xStart + ((count - 1) * (xEnd-xStart)/numOfCopies)
      obj.y = yStart + ((count - 1) * (yEnd-yStart)/numOfCopies)
    else
      obj.x = math.random(xStart, xEnd)
      obj.y = math.random(yStart, yEnd)
    end
    --
    obj.count = count
    obj.oldAlpha = obj.oriAlpha
    obj.alpha = math.random(props.alphaMin*100, props.alphaMax*100) / 100
    --
    if props.fixedScaleMax and props.fixedScaleMin then
      obj.xScale = math.random(props.fixedScaleMin*100, props.fixedScaleMax*100) / 100
      obj.yScale = obj.xScale
    else
      obj.xScale = math.random(props.xScaleMin*100, props.xSaleMax*100) / 100
      obj.yScale = math.random(props.yScaleMin*100, props.ySaleMax*100) / 100
    end
    --
    obj.rotation = math.random(props.rotationMin, props.rotationMax)
    --
    if props.enablePhysics then
      physics.addBody(obj, "dynamic", {density = pweight, friction = 0, bounce = 0, shape = props.physicShape})
      --
      if props.enableSeonsor then
        obj.isSensor = true
      end
      --
      local pweight = math.random(props.weightMin, props.weightMax)
      obj.linearDumping = pweight * obj.xScale
    end
    obj:toFront()
    self.group:insert(obj)
    self.group:toFront()
  end
  --
  local function copyHandler()
    -- print("copyHandler")
    -- printKeys(layerProps)
    if self.timer0 then
      count = count + 1
      if handler ~= nil then
        handler(count)
      end
      -- print("", self.maxCopies, props.playForever)
      if (count == self.maxCopies and props.playForever) then
        if self.timer1 then
          timer.cancel(self.timer1)
        end
        self.timer1 = timer.performWithDelay(props.interval*1000, copyHandler, props.numOfCopies)
        self.maxCopies = count + props.numOfCopies
        UI.timers[props.target.."_multiplier1"] = self.timer0
      end
    end
  end
  --
  if props.autoPlay then
    -- print("@@@@@@@@@", props.interval*1000,  props.numOfCopies)
    self.timer0 = timer.performWithDelay(props.interval*1000, copyHandler, props.numOfCopies)
    UI.timers[props.target.."_multiplier0"] = self.timer0
  end
  --
  self.objs = objs
  --
  if self.hashasMutliplier == nil then
    self.hashasMutliplier = true
    -- Clean up memory for Multiplier set to forever
    -- control variable to dispose kClean via kNavi
    self.cleanHandler = function()
      -- runs normal code
      self:codeMultiplier(UI)
    end
    Runtime:addEventListener("enterFrame", self.cleanHandler)
  end
end
--
local function isReachedEnd(y, props)
  if props.gravity == "inverted" then
    return y < 0
  else
    return y > display.actualContentHeight
  end
end
--
function M:codeMultiplier(UI)
  local sceneGroup = UI.sceneGroup
  local layer = UI.layer
  local objs = self.objs
  --
  if objs == nil then return end
  --
  for i = 1, self.maxCopies do
    if objs[i] ~= nil then
      if objs[i].y ~= nil and isReachedEnd(objs[i].y, props) then
        display.remove(objs[i])
        objs[i]:removeSelf()
        objs[i] = nil
      end
    end
  end
end
--
function M:didHide(UI)
  if self.hasMutliplier then
    if self.cleanHandler ~= nil then
      Runtime:removeEventListener("enterFrame", self.cleanHandler)
      self.cleanHandler = nil
    end
  end
  if self.timer0 then
    timer.cancel(self.timer0)
  end
  if self.timer1 then
    timer.cancel(self.timer1)
  end
end
--
function M:destroy(UI)
  local sceneGroup = UI.sceneGroup
  local layer = UI.layer
  self.group:removeSelf()
  self.group = nil
  if self.hashasMutliplier then
    self.cleanHandler = nil
  end
end
--
M.set = function(instance)
  return setmetatable(instance, {__index = M})
end
return M
