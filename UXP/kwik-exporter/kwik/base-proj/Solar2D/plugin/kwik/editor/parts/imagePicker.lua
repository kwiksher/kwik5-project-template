local imagePicker = {}

------------------------------------------------------------------------------------
-- DECLARE SCREEN POSITION VARIABLES
------------------------------------------------------------------------------------
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenBottom = display.screenOriginY+display.actualContentHeight
local screenRight = display.screenOriginX+display.actualContentWidth
local screenWidth = screenRight - screenLeft
local screenHeight = screenBottom - screenTop
------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------
local M = {}
--
local widget = require("widget")
local util   = require(kwikGlobal.ROOT.."editor.util")
local wildcard = require("wildcard")
local json     = require("json")
--
local prevHover, hoverObj
local mouseHover = require "sg.btn.mouseHover" -- the plugin is activated by default.
--
local onMouseHover = function(event)
  local hoverText = event.target.imageFile
  -- print("hover", hoverText)
  if hoverObj == nil and prevHover ~= hoverText then
    local textOptions = {
      --   parent = group,
      text = hoverText,
      x = event.x,
      --display.contentCenterX,
      y = event.y -20,
      width = hoverText:len() * 10,
      font = native.systemFont,
      fontSize = 10,
      align = "left" -- Alignment parameter
    }
    hoverObj = display.newText(textOptions)
    hoverObj:setFillColor(1, 0, 1)
    prevHover = hoverText
    timer.performWithDelay(
      1000,
      function()
        hoverObj:removeSelf()
        hoverObj = nil
        prevHover = nil
      end
    )
  end
  --for k, v in pairs (event.target) do print(k ,v ) end
end
---
--

local  _W = display.safeActualContentWidth
local  _H = display.safeActualContentHeight
--
local spacer = 10 --pixels distance between images
--

M.new = function(_params, listener)
  --
  local excludedImages = _params.exclude or {}
  local instance      = {blur=_params.blur}
  local params        = _params or {}
  local images     = {}
  local thumbW        = params.thumbnailWidth/4
  local thumbH        = params.thumbnailHeight/4
  local dire          = params.direction
  local currentImage   = params.currentImage

  --creates instance.group for the full navigation
  instance.group = display.newGroup()

  local function isIncluded(filename, page)
    if filename:find("@2x") or filename:find("@4x") then
      return false
    end

    for k = 1, #excludedImages do
      if (filename == excludedImages[k]) then
        return false
      end
    end
    if not wildcard.matchesWildCardedString(filename, page) then
      return false
    end
    return filename:find('.jpg') or filename:find('.png') or filename:find('.jpeg')
  end

  -- local function loadImages(path, baseDir)
  --   local ret = {}
  --   local image = {}
  --   if isIncluded(image) then
  --     table.insert(ret, image)
  --   end
  --   return ret
  -- end

  --Loads all images to the table
  --images = loadImages(params.path or "App/bookFree/assets/images/page1/", params.baseDir or system.ResourceDirectory)
  local book = params.book or "book"
  local asset = util.readAssets(book, "images")

  print(json.prettify(asset))

  -- scrollview
  local nTop, nLeft, nWidth, nHeight, nVert, nHor
  -- background
  local nTop1, nLeft1, nWidth1, nHeight1
  --
  if (dire == "top") then
    nTop    = 0
    nLeft   = 0
    nWidth  = _W
    nHeight = (spacer * 2) + thumbH
    nVert   = true
    nHor    = false
    --background
    nTop1    = (thumbH + (spacer * 2)) / 2
    nLeft1   = _W / 2
    nWidth1  = _W
    nHeight1 = (spacer * 2) + thumbH
  elseif (dire == "bottom") then
    nTop    = _H - (thumbH + (spacer * 2))
    nLeft   = 0
    nWidth  = _W
    nHeight = (spacer * 2) + thumbH
    nVert   = true
    nHor    = false
    --background
    nTop1    = _H - ((thumbH + (spacer * 2)) / 2)
    nLeft1   = _W / 2
    nWidth1  = _W
    nHeight1 = (spacer * 2) + thumbH
  elseif (dire == "left") then
    nTop    = 0
    nLeft   = 0
    nWidth  = thumbW + (spacer * 2)
    nHeight = _H
    nVert   = false
    nHor    = true
    --background
    nTop1    = _H / 2
    nLeft1   = (thumbW + (spacer * 2)) / 2
    nWidth1  = thumbW + (spacer * 2)
    nHeight1 = _H
  elseif (dire == "right") then
    nTop    = 0
    nLeft   = _W - (thumbW + (spacer * 2))
    nWidth  = thumbW + (spacer * 2)
    nHeight = _H
    nVert   = false
    nHor    = true
    --background
    nTop1    = _H / 2
    nLeft1   = _W - ((thumbW + (spacer * 2)) / 2)
    nWidth1  = thumbW + (spacer * 2)
    nHeight1 = _H
  end

  print(nLeft1, nTop1, nWidth1, nHeight1)
  --creates the background
  local background = params.background or display.newRect(nLeft1, nTop1, nWidth1, nHeight1)
  background.alpha = params.alpha
  background:setFillColor(params.backColor[1] / 255, params.backColor[2] / 255, params.backColor[3] / 255)
  instance.group:insert(background)

  -- create the searchbox
  local option = {
    text = params.page or "*page*",
    x    = nLeft - nWidth,
    y    = screenTop + 10,
    --self.viewStore.selectLayer.y,
    width    = nWidth1,
    height   = 12,
    font     = native.systemFont,
    fontSize = 8,
    align    = "left"
  }

  local function inputListener(event)
    if ( event.phase == "began" ) then
   elseif ( event.phase == "ended" or event.phase == "submitted" ) then
    print("@@@@@", event.target.text )

    instance.scrollView:removeSelf()
    -- instance.group:removeSelf()
    instance.thumbnails:removeSelf()

    instance:createTable(event.target.text )
   end
  end

  local searchbox = native.newTextField( option.x, option.y, option.width, option.height )
  -- searchbox = native.newTextBox( option.x, option.y, option.width, option.height )
  -- searchbox.isEditable = true
  -- searchbox.font = native.newFont( option.font, 8 )
  --searchbox:resizeFontToFitHeight()
  searchbox:setReturnKey( "done" )
  --searchbox.placeholder = "Enter text"
  searchbox:addEventListener( "userInput", inputListener )
  native.setKeyboardFocus( searchbox )
  searchbox.text = option.text
  searchbox.anchorX = 0
  instance.searchbox =searchbox

  --
  function instance:createTable(page)

        --create handler for each thumbnail
    local thumbnails = display.newGroup()
    local tapHandler = function(event)
      local path = event.target.image
      print("",path)
      if path then
        if listener then
          listener(path)
        end
      end
      instance:destroy()
      -- instance:hide()
      return true
    end

    --builds thumbnails
    local objs = {}
    --
    local lastObj
    for index, image in next, asset.images do
      if isIncluded(image, page)  then
        -- print(image)
        local obj = display.newImageRect("App/"..book.."/assets/images/"..image,  thumbW, thumbH) -- params.baseDir
        obj.anchorX = 0
        obj.anchorY = 0.5
        obj.image = "App/"..book.."/assets/images/"..image
        if currentImage == image then
          obj.alpha = 0.5
        end
        obj:addEventListener("tap", tapHandler)
        obj.instance = instance

        local splited = util.split(image, "/")
        obj.imageFile =  splited[#splited]
        obj:addEventListener("mouseHover", onMouseHover)

        -- navigation positioning
        if #objs == 0 then
          if dire == "bottom" then
            obj.x = spacer
            obj.y = (thumbH / 2) + (spacer / 2)
          elseif dire == "top" then
            obj.x = spacer
            obj.y = (thumbH / 2) + (spacer / 2) --0 + spacer + obj.y
          elseif dire == "left" then
            obj.x = spacer + obj.x
            obj.y = 0 + spacer + (obj.height / 2)
          elseif dire == "right" then
            obj.x = 0 + spacer + obj.x
            obj.y = 0 + spacer + (obj.height / 2)
          end
        else
          if dire == "bottom" then
            obj.x = lastObj.x + spacer + lastObj.width
            obj.y = lastObj.y
          elseif dire == "top" then
            obj.x = lastObj.x + spacer + lastObj.width
            obj.y = (thumbH / 2) + (spacer / 2)
          elseif dire == "left" then
            obj.x = lastObj.x
            obj.y = lastObj.y + spacer + obj.height
          elseif dire == "right" then
            obj.x = lastObj.x
            obj.y = lastObj.y + spacer + obj.height
          end
        end
        objs[#objs+1] = obj
        lastObj = obj
        thumbnails:insert(obj)
      end
    end
    instance.objs = objs

    local scrollView =
      widget.newScrollView {
      top                      = nTop,
      left                     = nLeft,
      width                    = nWidth,
      height                   = nHeight,
      hideScrollBar            = false,
      hideBackground           = true,
      verticalScrollDisabled   = nVert,
      horizontalScrollDisabled = nHor
      --bgColor                = { 255,255,255,255 }
    }
    scrollView:insert(thumbnails)
    self.group:insert(scrollView)
    self.scrollView = scrollView
    self.thumbnails = thumbnails

    if (dire == "top") then
      self.group:translate(0, (display.contentHeight - display.safeActualContentHeight) / 2)
    elseif (dire == "bottom") then
      self.group:translate(0, (display.contentHeight - display.safeActualContentHeight) / 2)
    elseif (dire == "left") then
      self.group:translate((display.contentWidth - display.safeActualContentWidth) / 2, 0)
    elseif (dire == "right") then
      self.group:translate((display.contentWidth - display.safeActualContentWidth) / 2, 0)
    end

    --do not allow swipe of the next/previous page
    self.group:addEventListener("touch", function(event) return true end)
  end
  -- Scroll objects
  --Position of the scrollview

  function instance:getItems()
    return self.thumbnails
  end

  function instance:hide ()
    self.group.alpha = 0
    self.searchbox.alpha = 0
  end

  function instance:show()
    print("show")
    self.group.alpha = 1
    --calculates current page in the scroll
    local function getIndex ()
      for i = 1, #images do
        if (images[i] == currentImage) then
          return i
        end
      end
    end

    local index = getIndex()
    local amount = 0
    if (dire == "bottom" and self.scrollView.width > _W) then
      amount = (((index - 1) * spacer) + ((index - 1) * thumbW))
      self.scrollView:scrollToPosition {x = amount * -1, y = nil}
    elseif (dire == "top" and self.scrollView.width > _W) then
      amount = (((index - 1) * spacer) + ((index - 1) * thumbWg))
      self.scrollView:scrollToPosition {x = amount * -1, y = nil}
    elseif (dire == "left" and self.scrollView.width > _H) then
      amount = (((index - 1) * spacer) + ((index - 1) * thumbH))
      self.scrollView:scrollToPosition {x = nil, y = amount * -1}
    elseif (dire == "right" and self.scrollView.width > _H) then
      amount = (((index - 1) * spacer) + ((index - 1) * thumbH))
      self.scrollView:scrollToPosition {x = nil, y = amount * -1}
    end

    --starts a timer. If nothing is pressed in 5 seconds, hide the panel
    local function hideAgain()
      if self.group.alpha == 1 then
        self:hide()
      end
    end
    --
    self.timer = timer.performWithDelay( 5000, hideAgain )
  end

  function instance:destroy()
    self.scrollView:removeSelf()
    self.group:removeSelf()
    self.thumbnails:removeSelf()
    self.searchbox:removeSelf()
    self.blur:removeSelf()
  end

  return instance
end

M.closePicker = function(instance)
  instance.scrollView:removeSelf()
  instance.group:removeSelf()
  instance.thumbnails:removeSelf()
  instance.searchbox:removeSelf()
end

------------------------------------------------------------------------------------
-- SHOW image PICKER
------------------------------------------------------------------------------------
function imagePicker.show(listener, value, book, page)

  local blur = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
  blur.x, blur.y = centerX, centerY
  blur:setFillColor(.9,.9,.9, .9)
  -- blur.fill.effect = "filter.blur"
  blur.alpha = 0.1

-- create a display group to contain the picker
  local params =     {
    backColor = { 255,255,255 },
      thumbnailWidth   = 200,
      thumbnailHeight   = 150,
      alpha    = 0.5,
      direction     = "right",
      currentImage = value,
      -- background = background
      book = book,
     page = page,
     blur = blur
  }
  local instance = M.new( params, listener)
  instance:createTable(params.page)

  blur:addEventListener("tap", function(event)
    M.closePicker(instance)
    event.target:removeSelf()
  end)
  -- blur:addEventListener("touch", function() return true end)
  imagePicker.obj = instance

end
--

return imagePicker