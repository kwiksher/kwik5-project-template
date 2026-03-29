local parent,root, M = newModule(...)
local layerMod = require(M.layerMod)
local layerProps = layerMod.layerProps or {}
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
  -- overwrite layerProps from the base image layer with local property overrides
  for k, v in pairs(self.properties) do
    if v ~= nil and v ~= "" and v ~= NIL then
      layerProps[k] = v
    end
  end

  if type(layerMod.setProps) == "function" then
    layerMod:setProps(layerProps)
  end

end
--
function M:create(UI)
  local props = layerMod.layerProps or self.properties
  local obj = UI.sceneGroup[props.name]
  if obj == nil then
    return
  end

  self.obj = obj
  print("###", props.name)
  for k, v in pairs(UI.sceneGroup) do print(k ,v) end
  --
  --
  -- obj.imagePath = self.imagePath
  if type(layerMod.mX) == "number" then
    obj.x = layerMod.mX
  elseif type(props.x) == "number" then
    obj.x = props.x
  end
  if type(layerMod.mY) == "number" then
    obj.y = layerMod.mY
  elseif type(props.y) == "number" then
    obj.y = props.y
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
  obj.type        = props.type
  obj.kind        = props.kind
  --
  if type(layerMod.randXStart) == "number" and layerMod.randXStart > 0 then
    obj.x = math.random(layerMod.randXStart, layerMod.randXEnd)
  end
  if type(layerMod.randYStart) == "number" and layerMod.randYStart > 0  then
    obj.y = math.random(layerMod.randYStart, layerMod.randYEnd)
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
  if props.infinity and props.infinity.enabled then
    infinity.createInfinityImage(UI, self.obj, props.infinity)
  end
end
--
function M:didShow(UI)
  local props = layerMod.layerProps or self.properties
  if  props.infinity and props.infinity.enabled then
    infinity.addEventListener(self.obj)
  end
end
--
function M:didHide(UI)
  local props = layerMod.layerProps or self.properties
  if  props.infinity and props.infinity.enabled then
    infinity.removeEventListener(self.obj)
  end
end
--
function  M:destroy(UI)
end
--
return M
