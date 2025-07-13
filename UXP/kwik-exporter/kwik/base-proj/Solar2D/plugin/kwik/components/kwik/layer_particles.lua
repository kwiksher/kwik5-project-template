local M = require(kwikGlobal.ROOT.."components.kwik.layer_base").new()
--
local json = require("json")

local useCanvas = false

function M:create (UI)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  local target     = sceneGroup[layerName]
  -- local group      = display.newGroup()
  if useCanvas then
    self.particleCanvas = display.newContainer( display.contentWidth, display.contentHeight)
    -- local rect = display.newRect(0,0, display.contentWidth, display.contentHeight)
    -- rect:setFillColor(1,1,1,0.8)
    -- self.particleCanvas:insert(rect)
    self.particleCanvas.alpha = 1
  end
  --
  local emitterParams
  -- print(self.properties.filename)
  if self.properties.filename:find(".json") then
    print("---- json -----")
    local filePath = system.pathForFile( "App/"..UI.book.."/assets/".. self.properties.filename,UI.props.systemDir )
    local f = io.open( filePath, "r" )
    local fileData = f:read( "*a" )
    f:close()
    emitterParams = json.decode( fileData )
  elseif self.properties.filename:find(".lua") then
    print("---- lua -----")
    local mod = "App."..UI.book..".assets."..self.properties.filename:gsub(".lua", "")
    mod = mod:gsub("/", ".")
    emitterParams = require(mod)
  else
    print("Error reading",self.properties.filename)
  end

  local params = {}
  for k, v in pairs (emitterParams) do
    params[k] = v
  end
  params.textureFileName = UI.props.particleDir .. params.textureFileName
  -- print( UI.props.particleDir )
  --
  -- printKeys(params)
  local obj = display.newEmitter( params, UI.props.systemDir )
  -- print("@@@", target.x, target.y, obj)
  -- if obj == nil then return end
  -- obj.alpha = 1
  obj.oriX     = target.oriX
  obj.oriY     = target.oriY
  obj.oriXs    = target.scaleX
  obj.oriYs    = target.scaleY
  obj.oldAlpha = target.alpha
  obj.class    = "particles"

  if useCanvas then
    self.particleCanvas:insert(obj)
    self.particleCanvas.x = target.x
    self.particleCanvas.y = target.y
    sceneGroup:insert(self.particleCanvas)
  else
    obj.x        = target.x
    obj.y        = target.y
    sceneGroup:insert(obj)
  end


  -- particleCanvas.x, particleCanvas.y = display.contentCenterX, display.contentCenterY
  -- sceneGroup:insert(rect)

  -- particleCanvas:toFront()
  -- obj.alpha   = target.alpha
  -- group:insert(obj)
  -- group:toFront()
  -- sceneGroup:toBack()
  -- sceneGroup:insert(obj)
  -- obj:toFront()
  -- --
  -- target target should be removed
  target.alpha  = 0 -- removeSelf?
  --
end

function M:didShow(UI)
  if self.properties.autoPlay == false then
    self.obj:pause();
  end
end

M.new = function(instance)
  -- print(instance.x, instance.y, instance.width, instance.height)
  return setmetatable(instance, {__index = M})
end

return M