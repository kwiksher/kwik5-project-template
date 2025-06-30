local current = ...
local parent,  root, M = newModule(current)

local spritesheet = require(kwikGlobal.ROOT.."components.kwik.layer_spritesheet")
local json = require("json")

M.x = display.contentCenterX
M.y =  50

function M:hide()

  if self.instance then
    self.instance:destroy{sceneGroup = self.group}
    self.instance = nil
    self.group:removeSelf()
  end
end

function M:show(UI, props)
  props.layerProps = {name = "_preview", mX= self.x, mY = self.y}
  if props.properties.target == nil then
    props.properties.target = {x=self.x, y = self.y}
  end

  if props.properties.sheetInfo and props.properties.sheetInfo:len() > 0 then
    if props.properties.sheetInfo:find(".lua") then
      props.sheetType = "TexturePacker"
    else
      props.sheetType = "Animate"
    end
  end

  -- props = {
  --   name ="{{name}}",
  --   class = "{{class}}", -- spritesheet
  --   type  = "{{type}}", -- uniform-sized, texturePacker, Aniamte
  --   -- sheet = {{name}}_sheet,
  --   properties = {
  --     filename = "{{filename}}",
  --     sheetInfo = "{{sheetInfo}}",
  --     sheetContentWidth  = {{sheetWidth}}/4,
  --     sheetContentHeight = {{sheetHeight}}/4,
  --     numFrames          = {{autoFrames}},
  --     width              = {{frameWidth}}/4,
  --     height             = {{frameHeight}}/4,
  --   }
  -- }
  --
  -- props.sequenceData = {
  --   {{#sequences}}
  --       {{^count}}
  --           { name = "{{name}}",
  --             frames = {{{frames}}},
  --       {{/count}}
  --       {{#count}}
  --           { name = "{{name}}",
  --             start = {{start}},
  --             count = {{count}},
  --       {{/count}}
  --             time = {{length}},
  --             loopCount = {{loopCount}},
  --             loopDirection = "{{loopDirection}}",
  --           },
  --   {{/sequences}}
  -- }

  local options = nil
  if props.sheetType == "TexturePacker" then
    --
    local path = "App."..UI.book..".assets."..props.properties.sheetInfo
    path = path:gsub("/", ".")
    path = path:gsub(".lua", "")
    local sheetInfo = require(path)
    options = {frames = sheetInfo.frames}
    --
  elseif props.sheetType == "Animate" then
    --
    local function newSheetInfo()
      local sheetInfo = {}
      sheetInfo.frames = {}
      local jsonFile = function(filename )
          local path = system.pathForFile( "App/"..UI.book.."/assets/"..filename, system.ResourceDirectory )
          local contents
          local file = io.open( path, "r" )
          if file then
            contents = file:read("*a")
            io.close(file)
            file = nil
          end
          return contents
      end
      --
      local animateJson = json.decode( jsonFile(props.properties.sheetInfo) )
      --print (sheetInfo, #animateJson.frames)
      for i=1, #animateJson.frames do
          local frame = animateJson.frames[i].frame
          local spriteSourceSize = animateJson.frames[i].spriteSourceSize
          sheetInfo.frames[i] = {x=frame.x, y=frame.y, width=frame.w, height= frame.h, sourceX = spriteSourceSize.x, sourceY = spriteSourceSize.y, sourceWidth = spriteSourceSize.w, sourceHeight = spriteSourceSize.h}
      end
      sheetInfo.sheetContentWidth = animateJson.meta.size.w
      sheetInfo.sheetContentHeight = animateJson.meta.size.h
      return sheetInfo
    end
    --
    options = newSheetInfo()
    --props.properties.numFrames = #sheetInfo.frames
  else
    options = {
        width              = props.properties._width,
        height             = props.properties._height,
        numFrames          = props.properties.numFrames,
        sheetContentWidth  = props.properties.sheetContentWidth,
        sheetContentHeight = props.properties.sheetContentHeight
    }
    props.imageWidth = options.width
    props.imageHeight = options.height
  end
  ---
  props.sheet = graphics.newImageSheet( "App/"..UI.book.."/assets/"..props.properties._filename, system.ResourceDirectory, options )
  --

  if self.instance then
    self.instance:destroy()
    self.group:removeSelf()
  end
    -- print("", props.layerProps.name)
    props.objs = {}
    self.instance = spritesheet.new(props)
  --end

  self.group = display.newGroup()
  self.instance:create{sceneGroup = self.group}

  local obj = self.instance.objs[1]
  -- print("", obj.name, obj.width, obj.height)
  local size = 100
  if obj.width > 100 or obj.height > 100 then
    local scaleW = obj.width/100
    local scaleH = obj.height/100
    if scaleW > scaleH then
      obj:scale(1/scaleW, 1/scaleW)
    else
      obj:scale(1/scaleH, 1/scaleH)
    end
    if obj.height > 100 then
      obj.height = 100
    end
  end

end

return M