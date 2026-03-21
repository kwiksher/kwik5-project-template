local parent,root, M = newModule(...)
local layerMod = require(M.layerMod)
--
local infinity = require("components.kwik.layer_image_infinity")
--
M.properties = {
  {{#properties}}
  blendMode = "{{blendMode}}",
  height    = {{height}},
  width     = {{width}} ,
  kind      = "{{kind}}",
  name      = "{{name}}",
  type      = "{{type}}",
  x         = {{x}},
  y         = {{y}},
  alpha     = {{alpha}},
  --
  align       = "{{align}}",
  randXStart  = {{randXStart}},
  randXEnd    = {{randXEnd}},
  randYStart  = {{randYStart}},
  randYEnd    = {{randYEnd}},
  --,
  xScale     = {{xScale}},
  yScale     = {{yScale}},
  rotation   = {{rotation}},
  --,
  layerAsBg     = {{layerAsBg}},
  isSharedAsset = {{isSharedAsset}},
  ---
  {{#color}}
  color    = { {{r}}, {{g}}, {{b}}, {{a}} },
  {{/color}}
  {{#text}}
  text = {{text}},
  font = "{{font}}",
  fontSize = {{fontSize}},
  {{/text}}
  ---
  {{#infinity}}
  infinity = {
    enabled = {{enabled}},
    speed = {{speed}},
    distance = {{distance}},
    direction = "{{direction}}",
  },
  {{/infinity}}
  ---
  {{#imagePath}}
  imagePath   = "{{imagePath}}",
  imageHeight = {{imageHeight}},
  imageWidth  = {{imageWidth}}
  {{/imagePath}}
  {{/properties}}
}

local slash_pos = M.properties.name:find("/")
if slash_pos and slash_pos > 0 then -- pageX/bg.png for shared asset
  if M.properties.kind:len() > 0 then -- use if to jpg
        M.properties.imagePath   = M.properties.name .."."..M.properties.kind
  else
    M.properties.imagePath   = M.properties.name ..".png"
  end
else
  if M.properties.kind:len() > 0 then -- use if to jpg
    M.properties.imagePath   =layerMod.psdPage.."/".. M.properties.name .."."..M.properties.kind
  else
    M.properties.imagePath   =layerMod.psdPage.."/".. M.properties.name ..".png"
  end
end

--
function M:init(UI)
  -- overwrite layerMod properties by M.properties one by one if not nil
  for k, v in pairs(self.properties) do
    if v ~= nil and v ~= "" and v ~= NIL then
      layerMod[k] = v
    end
  end

end
--
function M:create(UI)
  local obj = UI.sceneGroup[self.properties.name]
  self.obj = obj
  print("###", self.properties.name)
  for k, v in pairs(UI.sceneGroup) do print(k ,v) end
  --
  --
  -- obj.imagePath = self.imagePath
  local props = self.properties
  if type(props.x) == "number" or type(props.y) == "number" then
    local catObj = UI.sceneGroup and UI.sceneGroup.cat
    local baseCenterX, baseCenterY = 480, 320
    if display.contentHeight > display.contentWidth then
      baseCenterX, baseCenterY = 320, 480
    end
    local scaleX = display.contentCenterX / baseCenterX
    local scaleY = display.contentCenterY / baseCenterY
    if catObj and scaleX > 0 and scaleY > 0 then
      local catBaseX = catObj.x / scaleX
      local catBaseY = catObj.y / scaleY
      if type(props.x) == "number" then
        obj.x = catObj.x + (props.x - catBaseX)
      end
      if type(props.y) == "number" then
        obj.y = catObj.y + (props.y - catBaseY)
      end
    else
      if type(props.x) == "number" then
        obj.x = props.x
      end
      if type(props.y) == "number" then
        obj.y = props.y
      end
    end
  end
  -- obj.height    = props.height/4
  -- obj.width     = props.width/4
  if props.alpha then
    obj.alpha     = props.alpha
  end
  -- obj.oldAlpha  = props.oriAlpha
  if props.blendMode~="" then
    obj.blendMode = props.blendMode
  end
  --
  obj.layerAsBg = props.layerAsBg
  obj.isSharedAsset = props.isSharedAsset
  ---
  -- obj.shapedWith = props.layerProps.shapedWith
  obj.randXStart  = props.randXStart
  obj.randXEnd    = props.randXEnd
  obj.randYStart  = props.randYStart
  obj.randYEnd    = props.randYEnd
  -- obj.type        = props.layerProps.type
  -- obj.kind        = props.layerProps.kind
  --
  if type(props.randXStart) == "number" and props.randXStart > 0 then
    obj.x = math.random( props.randXStart, props.randXEnd)
  end
  if type(props.randYStart) == "number" and props.randYStart > 0  then
    obj.y = math.random( props.randYStart, props.randYEnd)
  end
  if type(props.xScale) == "number" then
    obj.xScale = props.xScale
  end
  if type(props.yScale) == "number" then
    obj.yScale = props.yScale
  end
  if type(props.rotation) == "number" then
    obj:rotate( props.rotation )
  end
  --
  obj.oriX = obj.x
  obj.oriY = obj.y
  obj.oriXs = obj.xScale
  obj.oriYs = obj.yScale
  -- obj.name = self.name
  -- obj.type = "image"
  --
  -- sceneGroup[self.name] = obj
  -- print("@@@@", self.name, obj)
  --
  if props.layerAsBg == true then
    UI.sceneGroup:insert( 1, obj)
  else
    UI.sceneGroup:insert( obj)
  end
  --
  if self.properties.infinity and self.properties.infinity.enabled then
    infinity.createInfinityImage(UI, self.obj, self.properties.infinity)
  end
end
--
function M:didShow(UI)
  if  self.properties.infinity and self.properties.infinity.enabled then
    infinity.addEventListener(self.obj)
  end
end
--
function M:didHide(UI)
  if  self.properties.infinity and self.properties.infinity.enabled then
    infinity.removeEventListener(self.obj)
  end
end
--
function  M:destroy(UI)
end
--
return M
