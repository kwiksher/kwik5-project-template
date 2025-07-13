local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
local Var = require(kwikGlobal.ROOT.."components.kwik.vars")
--
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local props = self.properties
  local layerProps = self.layerProps
  local options
  --
  local options = {
    text = props.text,
    inputType = props.inputType,
    fontSize = props.fontSize / 2,
    font = props.font,
    --align = props.alignment,
    width = layerProps.width,
    height = layerProps.height
  }

  if layerProps.shapedWith then
    options.x = layerProps.x + (props.paddingX or 0)
    options.y = layerProps.y + (props.paddingY or 0)
  else
    options.x = layerProps.mX + (props.paddingX or 0)
    options.y = layerProps.mY + (props.paddingY or 0)
  end


  if props.width == NIL then
    options.width = nil
  end

  if props.height == NIL then
    options.height = nil
  end

  if props.font == "native.systemFont" then
    options.font = native.systemFont
  end

  --   local textOptions =
  -- {
  -- 	parent = group,
  -- 	text = table.concat(arr, ", "),
  -- 	x = 10,--display.contentCenterX,
  -- 	y = 0,
  -- 	width = row.contentWidth-100,
  -- 	font = native.systemFont,
  -- 	fontSize = row.params.fontSize,
  -- 	align = "left" -- Alignment parameter
  -- }
  printKeys(options)

  local obj = native.newTextField(options.x, options.y, options.width, options.height)
  obj.text = options.text
  obj.inputType = options.inputType
  --
  obj.originalH = obj.height
  obj.originalW = obj.width
  -- obj:setFillColor(unpack(props.color))
  -- obj.x = obj.x + options.width/2 + (props.paddingX or 0)
  -- --
  -- obj.y = obj.y + (props.paddingY or 0)
  -- --
  obj.anchorX = 0.5
  obj.anchorY = 0.5
  obj.xScale = props.scaleX or 1
  obj.yScale = props.scaleY or 1
  ---
  obj:rotate(props.rotate or 0)
  if self.randXStart and self.randXStart > 0 then
    obj.x = math.random(self.randXStart, self.randXEnd)
  end
  if self.randYStart and self.randYStart > 0 then
    obj.y = math.random(self.randYStart, self.randYEnd)
  end
  ---
  obj.oriX = obj.x
  obj.oriY = obj.y
  obj.oriXs = obj.xScale
  obj.oriYs = obj.yScale
  obj.alpha = layerProps.alpha or 1
  obj.oldAlpha = layerProps.alpha or 1
  obj.layerProps = layerProps
  sceneGroup:insert(obj)
  if sceneGroup[layerProps.name] then
    sceneGroup[layerProps.name]:removeSelf()
    sceneGroup[layerProps.name] = nil
  end
  sceneGroup[layerProps.name] = obj
  self.obj = obj
end

function M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  local props = self.properties
  local layerProps = self.layerProps
  if self.obj == nil then
    return
  end
  --
  if type(props.variable) == "string"  and props.variable:len() > 0 then
    if Var:kwkVarCheck(props.variable) ~= nil then
      local value = Var:kwkVarCheck(props.variable)
      self.obj.text = value
    else
      self.obj.text = props.text
    end
  end
  -- --
  local function fieldHandler(event)
    print(event.phase)
    if ("began" == event.phase) then
    elseif ("ended" == event.phase) then
    elseif ("submitted" == event.phase) then
      local value = self.obj.text
      if type(props.variable) == "string" and props.variable:len() > 0 then
        UI.variables[props.variable] = value
        local path = system.pathForFile(props.variable, system.ApplicationSupportDirectory)
        local file = io.open(path, "w+")
        file:write(self.obj.text)
        io.close(file)
      end
      --
      if props.dynamicText:len() > 0 then
        local target = sceneGroup[props.dynamicText]
        if target then
          target.text = value
        end
      end
      --
      if self.actions and self.actions.onCompelete then
        UI.scene:dispatchEvent({name = self.actions.onComplete, layer = obj})
      end
      native.setKeyboardFocus(nil)
    end
  end
  self.obj:addEventListener("userInput", fieldHandler)
  self.fieldHandler = fieldHandler
end
--
function M:didHide(UI)
  if self.fieldHandler then
    self.obj:removeEventListener("userInput", self.fieldHandler)
    self.fieldHandler = nil
  end
end
--
M.set = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end
--
return M
