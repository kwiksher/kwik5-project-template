local M = {}
--
local widget = require("widget")
local App = require(kwikGlobal.ROOT.."controller.application")
--
function M:setScroll(UI)
  local sceneGroup = UI.sceneGroup
  local obj = sceneGroup[self.properties.target]
  local contents = sceneGroup[self.properties.contents]

  -- print(self.properties.contents)
  -- print(contents)
  -- printKeys(contents)

  if self.isPage then
    self.obj = sceneGroup
  end

  if obj == nil then
    print("Error not found", self.properties.target)
    return
  end
  ---
  local props = self.properties
  local _top = 0
  local _left = 0
  local _width = 0
  local _height = 0
  local _scrollWidth = 0
  local _scrollHeight = 0
  --
  if props.type == "group" or props.type == "page" then
    if props.type == "group" then
      contents = UI.groups[self.properties.contents]
    else
      contents = sceneGroup
    end
  --
  end
  --
  if props.area == "page" then
    _top = 0
    _left = 0
    _width = props.width or display.actualContentWidth
    _height = props.height or display.actualContentHeight
    _scrollWidth = props.scrollWidth or display.actualContentWidth
    _scrollHeight = props.scrollHeight or display.actualContentHeight
  elseif props.area == "paragraph" or props.type == "paragraph" then
    _top = obj.layerProps.mY   -  obj.layerProps.height/8
    _left = obj.layerProps.mX  -  obj.layerProps.width/8
    _width = obj.layerProps.width/4
    _height = obj.layerProps.height/4
    _scrollWidth = obj.widht   -- props.scrollWidth
    _scrollHeight = obj.height  --props.scrollHeight
  elseif props.area == "object" or props.area == "layer" then
    _top = obj.contentBounds.yMin
    _left = obj.contentBounds.xMin
    _width = obj.width -- - props.width
    _height = obj.height
    _scrollWidth = props.scrollWidth or obj.width
    _scrollHeight = props.scrollHeight or obj.height
  elseif props.area == "manual" then
    _top = props.top
    _left = props.left
    _width = props.width
    _height = props.height
    _scrollWidth = props.scrollWidth or props.width
    _scrollHeight = props.scrollHeight or props.height
  end

  -- ScrollView listener
  local function scrollListener(event)
    local phase = event.phase
    if (phase == "began") then
      print("Scroll view was touched")
    elseif (phase == "moved") then
      print("Scroll view was moved")
    elseif (phase == "ended") then
      print("Scroll view was released")
    end

    -- In the event a scroll limit is reached...
    if (event.limitReached) then
      if (event.direction == "up") then
        print("Reached bottom limit")
      elseif (event.direction == "down") then
        print("Reached top limit")
      elseif (event.direction == "left") then
        print("Reached right limit")
      elseif (event.direction == "right") then
        print("Reached left limit")
      end
    end

    return true
  end

  local options = {
    top = _top,
    left = _left,
    width = _width,
    height = _height,
    scrollWidth = nil,
    scrollHeight = nil,
    baseDir = UI.props.systemDir,
    -- listener = scrollListener
  }

  options.hideScrollBar            = props.hideScrollBar
  options.hideBackground           = props.hideBackGround
  options.horizontalScrollDisabled = props.horizontalScrollDisabled
  options.verticalScrollDisabled   = props.verticalScrollDisabled

  local scrollObj = widget.newScrollView(options)
  -- if scrollObj then
  --   printKeys(options)
  -- end

  if props.maskFile then
    local mask = graphics.newMask(_K.imgDir .. props.maskFile)
    obj:setMask(mask)
  end
  --
  -- local background = display.newImageRect( "App/interaction/assets/images/scroll/scrollimage.png", 768, 1024 )
  --scrollObj:insert( background )
  --
  -- print("@@@ contents width, height", contents.width, contents.height)
  -- print("@@@ scroll (visible) width, height", scrollObj.width, scrollObj.height)

  contents.x = contents.width/2
  contents.y = contents.height/2
  sceneGroup:insert(scrollObj)
  scrollObj:insert(contents)

  -- print("@@@ scrollWidth, scrollHeight", options.scrollWidth, options.scrollHeight)
---[[

  if type(props.positionX) == "number" and type(props.positionY) == "number"  then
    scrollObj:scrollToPosition {x = -1 * props.positionX, y = -1 * props.positionY}
  elseif type(props.positionX) == "number" then
      scrollObj:scrollToPosition {x = -1 * props.positionX, y = nil}
  elseif type(props.positionY) == "number" then
    scrollObj:scrollToPosition {x = nil, y = -1 * props.positionY}
  elseif props.horizontalScrollDisabled then
    if props.type == "group" then
      scrollObj:scrollToPosition {x = nil, y=-contents.height/2 + contents.height/contents.numChildren*0.5}
    else
      -- scrollObj:scrollToPosition {x = nil, y=-contents.height/2}
    end
  elseif props.verticalScrollDisabled then
    -- scrollObj:scrollToPosition {x =  -1*(scrollObj.contentBounds.xMax-scrollObj.contentBounds.xMin), y = nil}
    if props.type == "group" then
      scrollObj:scrollToPosition {x = -contents.width/2 + contents.width/contents.numChildren*0.5, y = nil}
    else
      -- scrollObj:scrollToPosition {x = contents.width/2, y=nil}
    end
  end
--]]

  --
  -- if props.area ~= "manual" then
  --   scrollObj.x = scrollObj.width / 2
  --   scrollObj.y = 0
  -- end
end

M.set = function(model)
  return setmetatable(model, {__index = M})
end
--
return M
