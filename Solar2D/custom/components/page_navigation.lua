local M = {}
--
local widget = require("widget")
--
local  _W = display.safeActualContentWidth
local  _H = display.safeActualContentHeight
--
local spacer = 10 --pixels distance between images
--
M.new = function(_params, naviListener)
  local UI            = _params.UI
  local app           = UI.scene.app
  --
  local excludedPages = _params.exclude or {}
  local instance      = {}
  local params        = _params or {}
  local sceneList     = {}
  local thumbW        = params.thumbnailWidth/4
  local thumbH        = params.thumbnailHeight/4
  local dire          = params.direction
  local currentPage   = UI.page

  --creates instance.group for the full navigation
  instance.group = display.newGroup()

  local function isIncluded(scene)
    for k = 1, #excludedPages do
      if (scene == excludedPages[k]) then
        return false
      end
    end
    return true
  end

  --Loads all images to the table
  for i = 1, #UI.props.scenes do
    local scene = UI.props.scenes[i]
    if isIncluded(scene) then
      table.insert(sceneList, scene)
    end
  end

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

  -- print(nLeft1, nTop1, nWidth1, nHeight1)
  --creates the background
  local naviBackground = display.newRect(nLeft1, nTop1, nWidth1, nHeight1)
  naviBackground.alpha = params.alpha
  naviBackground:setFillColor(params.backColor[1] / 255, params.backColor[2] / 255, params.backColor[3] / 255)
  instance.group:insert(naviBackground)

  --create navigation
  local navItems = display.newGroup()
  local menuItemTap = function(event)
    local scene = event.target.scene
    print("",scene)
    event.target.instance:hide()
    if scene then
      if naviListener then
        naviListener()
      end
      app:showView("components."..scene..".index")
    end
    return true
  end

  --builds thumbnails
  local menuTab = {}
  for i = 1,#sceneList do
    local scene = sceneList[i]
    local path = system.pathForFile(app.props.thumbDir..scene..".png", UI.props.systemDir)
    if  path then
      menuTab[i] = display.newImageRect(app.props.thumbDir..scene..".png", UI.props.systemDir, thumbW, thumbH)
    else
      print(scene .. " does not exist!")
      menuTab[i] = display.newRect(0, 0, thumbW, thumbH)
    end

    menuTab[i].anchorX = 0
    menuTab[i].anchorY = 0.5
    if currentPage ~= scene then
      menuTab[i].scene = scene
    else
      menuTab[i]:setFillColor(1, 1, 1, 0.2)
    end
    menuTab[i]:addEventListener("tap", menuItemTap)

    menuTab[i].instance = instance

    -- navigation positioning
    if i == 1 then
      if dire == "bottom" then
        menuTab[i].x = spacer
        menuTab[i].y = (thumbH / 2) + (spacer / 2)
      elseif dire == "top" then
        menuTab[i].x = spacer
        menuTab[i].y = (thumbH / 2) + (spacer / 2) --0 + spacer + menuTab[i].y
      elseif dire == "left" then
        menuTab[i].x = spacer + menuTab[i].x
        menuTab[i].y = 0 + spacer + (menuTab[i].height / 2)
      elseif dire == "right" then
        menuTab[i].x = 0 + spacer + menuTab[i].x
        menuTab[i].y = 0 + spacer + (menuTab[i].height / 2)
      end
    else
      if dire == "bottom" then
        menuTab[i].x = menuTab[i - 1].x + spacer + menuTab[i - 1].width
        menuTab[i].y = menuTab[i - 1].y
      elseif dire == "top" then
        menuTab[i].x = menuTab[i - 1].x + spacer + menuTab[i - 1].width
        menuTab[i].y = (thumbH / 2) + (spacer / 2)
      elseif dire == "left" then
        menuTab[i].x = menuTab[i - 1].x
        menuTab[i].y = menuTab[i - 1].y + spacer + menuTab[i].height
      elseif dire == "right" then
        menuTab[i].x = menuTab[i - 1].x
        menuTab[i].y = menuTab[i - 1].y + spacer + menuTab[i].height
      end
    end

    navItems:insert(menuTab[i])
  end

  -- Scroll objects
  --Position of the scrollview
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
  scrollView:insert(navItems)
  instance.group:insert(scrollView)
  instance.scrollView = scrollView
  instance.navItems = navItems

  if (dire == "top") then
    instance.group:translate(0, (display.contentHeight - display.safeActualContentHeight) / 2)
  elseif (dire == "bottom") then
    instance.group:translate(0, (display.contentHeight - display.safeActualContentHeight) / 2)
  elseif (dire == "left") then
    instance.group:translate((display.contentWidth - display.safeActualContentWidth) / 2, 0)
  elseif (dire == "right") then
    instance.group:translate((display.contentWidth - display.safeActualContentWidth) / 2, 0)
  end

  --do not allow swipe of the next/previous page
  instance.group:addEventListener("touch", function(event) return true end)

  function instance:getItems()
    return self.navItems
  end

  function instance:hide ()
    self.group.alpha = 0
  end

  function instance:show()
    print("show")
    self.group.alpha = 1
    --calculates current page in the scroll
    local function getIndex ()
      for i = 1, #sceneList do
        if (sceneList[i] == currentPage) then
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
      amount = (((index - 1) * spacer) + ((index - 1) * thumbW))
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

  return instance
end

return M
