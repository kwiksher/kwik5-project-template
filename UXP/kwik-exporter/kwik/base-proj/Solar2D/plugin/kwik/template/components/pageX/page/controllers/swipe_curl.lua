-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
local _K = require "Application"
local page_curl  = require("extlib.page_curl")
-- local ui     = require("components.store.UI")
-----------------------------------------------
-- local _BackgroundLayerName = "background.jpg"
-----------------------------------------------
local flip_audio = false
local laserSound
local laserChannel
--
if flip_audio then
  laserSound = audio.loadSound(_K.audioDir.."page-flip-02.wav", _K.systemDir)
end
------------------------------------------------
local debug = false
------------------------------------------------
{{#landscape}}
{{#ultimate}}
local bgW, bgH = display.contentWidth, display.contentHeight               --  sceneGroup.{{backLayer}}.width, sceneGroup.{{backLayer}}.height
local pgX, pgY = _K.ultimatePosition(960, 640) --  sceneGroup.{{backLayer}}.x, sceneGroup.{{backLayer}}.y
local curlWidth = 400/4
{{/ultimate}}
{{^ultimate}}
local bgW, bgH = 2048, 1152
local pgX, pgY = 1024, 768
local curlWidth = 400
{{/ultimate}}
{{/landscape}}
--
{{#portrait}}
{{#ultimate}}
local bgW, bgH = display.contentWidth, display.contentHeight                 --  sceneGroup.{{backLayer}}.width, sceneGroup.{{backLayer}}.height
local pgX, pgY = _K.ultimatePosition(640, 960) --  sceneGroup.{{backLayer}}.x, sceneGroup.{{backLayer}}.y
local curlWidth = 400/4
{{/ultimate}}
{{^ultimate}}
local bgW, bgH = 1152, 2048
local pgX, pgY = 768,  1024
local curlWidth = 400
{{/ultimate}}
{{/portrait}}

local pageNextUI, pagePrevUI

{{#isTmplt}}
local ui  = require("components.store.UI")
{{/isTmplt}}
local passed_threshold = false
-----------------------------------------------
function _M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
  local layers       = UI.layers
  local curPage     = UI.curPage
  local numberOfPages    = UI.numberOfPages
  local back, next, prev
  local prevPage, nextPage
{{#isTmplt}}
  nextPage = ui.currentPage + 1
  if nextPage > ui.numberOfPages then nextPage = ui.currentPage end
  prevPage = ui.currentPage - 1
  if prevPage < 1 then prevPage = 1 end
{{/isTmplt}}
{{^isTmplt}}
  nextPage = curPage + 1
  if nextPage > numberOfPages then nextPage = curPage end
  prevPage = curPage - 1
  if prevPage < 1 then prevPage = 1 end
{{/isTmplt}}

  if sceneGroup.{{backLayer}} == nil then return end
  local W, H = sceneGroup.{{backLayer}}.width, sceneGroup.{{backLayer}}.height
  local function Grabbed(event)
    local curl = event.target
    curl.alpha = 1
    if event.dir == "right" then
{{^isTmplt}}
      if next == nil and curPage~=nextPage then
{{/isTmplt}}
        -- next = display.newImageRect( _K.imgDir.. "p"..nextPage.."/".._BackgroundLayerName, _K.systemDir, bgW, bgH )
        -- next.x = pgX
        -- next.y = pgY
        -- sceneGroup:insert(next)
        -- next:toFront()
{{#isTmplt}}
      if next == nil and curPage~=nextPage and ui.setDir(nextPage) then
        local scene ={view=display.newGroup()}
        pageNextUI    = require("components.page0"..ui.getPageNum(nextPage).."UI").new(scene)
        pageNextUI.dummy   = nextPage
        pageNextUI:create()
        next = scene.view
        sceneGroup:insert(next)
        next:toFront()
{{/isTmplt}}
{{^isTmplt}}
        local scene ={view=display.newGroup()}
        pageNextUI    = require("components.page0"..nextPage.."UI").new(scene)
        pageNextUI.dummy   = nextPage
        pageNextUI:create()
        next = scene.view
        sceneGroup:insert(next)
        next:toFront()
{{/isTmplt}}

      end
    else
{{^isTmplt}}
      if prev == nil and curPage ~= prevPage then
{{/isTmplt}}
        -- prev = display.newImageRect( _K.imgDir.."p"..prevPage.."/".._BackgroundLayerName, _K.systemDir,bgW, bgH )
        -- prev.x = pgX
        -- prev.y = pgY
        -- sceneGroup:insert(prev)
        -- prev:toFront()
{{#isTmplt}}
      if prev == nil and curPage ~= prevPage and ui.setDir(prevPage) then
        local scene ={view=display.newGroup()}
        pagePrevUI    = require("components.page0"..ui.getPageNum(prevPage).."UI").new(scene)
        pagePrevUI.dummy   = prevPage
        pagePrevUI:create()
        prev = scene.view
        sceneGroup:insert(prev)
        prev:toFront()
{{/isTmplt}}
{{^isTmplt}}
        local scene ={view=display.newGroup()}
        pagePrevUI    = require("components.page0"..prevPage.."UI").new(scene)
        pagePrevUI.dummy   = prevPage
        pagePrevUI:create()
        prev = scene.view
        sceneGroup:insert(prev)
        prev:toFront()
{{/isTmplt}}
      end
    end
    back:toFront()
  end
  --
  local function Released(event)
    back:toBack()
    back.alpha = 0.1
    if pagePrevUI then
       pagePrevUI:didHide()
       pagePrevUI = nil
    end
    if pageNextUI then
        pageNextUI:didHide()
        pageNextUI = nil
    end
    if next then
      next:removeSelf()
      next = nil
    end
    if prev then
      prev:removeSelf()
      prev = nil
    end
  end
  --
  --
  local function Moved (event)
    local curl = event.target
    --
{{#isTmplt}}
    local function GoNext()
       local wPage = ui.currentPage
       timer.performWithDelay(500, function() passed_threshold = false end )
       if event.dir == "right" and _K.kBidi == false then
          wPage = ui.currentPage + 1
          if wPage > ui.numberOfPages then return end
          ui.gotoNextScene({ effect = "fromRight"})
       elseif event.dir == "right" and _K.kBidi == true then
          wPage = ui.currentPage - 1
          if wPage < 1 then wPage = 1 end
          ui.gotoPreviousScene({ effect = "fromLeft"})
       elseif event.dir == "left" and _K.kBidi == true then
          wPage = ui.currentPage + 1
          if wPage > ui.numberOfPages then return end
          ui.gotoNextScene({ effect = "fromRight"})
       elseif event.dir == "left" and _K.kBidi == false then
          wPage = ui.currentPage - 1
          if pagePrevUI then
             pagePrevUI:didHide()
             pagePrevUI = nil
          end
          if pageNextUI then
              pageNextUI:didHide()
              pageNextUI = nil
          end
          if wPage == 0 then
            _K.systemDir = system.ResourceDirectory
            _K.imgDir = "assets/images/"
            _K.audioDir = "assets/audios/"
            composer.gotoScene("views.page01Scene", {params = { effect = "fromLeft"}})
          else
            ui.gotoPreviousScene({ effect = "fromLeft"})
          end
       end
    end
{{/isTmplt}}
{{^isTmplt}}
    local function GoNext()
       if event.dir == "right" and _K.kBidi == false then
          wPage = curPage + 1
          if wPage > numberOfPages then wPage = curPage end
          options = { effect = "fromRight"}
       elseif event.dir == "right" and _K.kBidi == true then
          wPage = curPage - 1
          if wPage < 1 then wPage = 1 end
          options = { effect = "fromLeft"}
       elseif event.dir == "left" and _K.kBidi == true then
          wPage = curPage + 1
          if wPage > numberOfPages then wPage = curPage end
          options = { effect = "fromRight"}
       elseif event.dir == "left" and _K.kBidi == false then
          wPage = curPage - 1
          if wPage < 1 then wPage = 1 end
          options = { effect = "fromLeft"}
       end
    {{#bookshelf}}
       local ui           = require("components.store.UI")
       if tonumber(wPage) ~= tonumber(curPage)  then
          if pagePrevUI then
             pagePrevUI:didHide()
             pagePrevUI = nil
          end
          if pageNextUI then
              pageNextUI:didHide()
              pageNextUI = nil
          end
          if ui.setDir(wPage) then
            ui.showView(curPage, wPage, options)
          end
       else
          ui.gotoTOC(options)
       end
       {{/bookshelf}}
      {{^bookshelf}}
       if tonumber(wPage) ~= tonumber(curPage)  then
          if pagePrevUI then
             pagePrevUI:didHide()
             pagePrevUI = nil
          end
          if pageNextUI then
              pageNextUI:didHide()
              pageNextUI = nil
          end
          _K.appInstance:showView("views.page0"..wPage.."Scene", options)
       end
      {{/bookshelf}}
       passed_threshold = false
    end
{{/isTmplt}}
    if event.dir == "right" and not passed_threshold then
      if curl.edge_x < .45 then
        passed_threshold = true
        if flip_audio then
          laserChannel = audio.play( laserSound )
        end
        transition.to(curl, {edge_x=0, time=100, transition=easing.inOutSine, onComplete = GoNext})
      end
    else
      if curl.edge_x > .55 and not passed_threshold then
        passed_threshold = true
        if flip_audio then
          laserChannel = audio.play( laserSound )
        end
        transition.to(curl, {edge_x=1, time=100, transition=easing.inOutSine, onComplete = GoNext})
      end
    end
  end
  --
  if back == nil then
    local function saveWithDelay()
      if sceneGroup then
      display.save( sceneGroup, { filename="entireGroup.jpg", baseDir=system.TemporaryDirectory, captureOffscreenArea=false, backgroundColor={0,0,0,0} } )
      back = page_curl.NewPageCurlWidget{width =bgW, height=bgH, size = curlWidth}
      -- back:SetImage(_K.imgDir.."p"..curPage.."/".._BackgroundLayerName)
      back:SetImage("entireGroup.jpg", {dir=system.TemporaryDirectory})
      back.x = display.contentCenterX - bgW/2
      back.y  = display.contentCenterY - bgH/2
      back:SetTouchSides("left_and_right")
      back:addEventListener("page_grabbed", Grabbed)
      back:addEventListener("page_dragged", Moved)
      back:addEventListener("page_released", Released)
      sceneGroup:insert(back)
      back:toBack()
      back.alpha = 0.1
      sceneGroup.pageCurl = back
      end
    end
    timer.performWithDelay( 100, saveWithDelay )
    -- debug mode
    if debug then
      ---[[
      local regions = back:GetGrabRegions()
      for _, region in pairs(regions) do
        local rect = display.newRoundedRect(back.parent, region.x, region.y, region.width, region.height, 12)
        rect:setFillColor(.3, .3)
        rect:setStrokeColor(.4, .5, .2)
        rect.strokeWidth = 10
        sceneGroup:insert(rect)
      end
    end
    --]]
  end
  -----------------
  -----------------
  UI.autoPlayCurl = function(act_autoPlay)
    if UI.curPage < UI.numberOfPages then
      back.angle_radians = math.pi/10
      back.edge_x, back.edge_y =  0.9, 0.5
      Grabbed({target=back, dir="right"})
      if flip_audio then
          laserChannel = audio.play( laserSound )
       end
      transition.to(back, {edge_x=0, time=1000, transition=easing.inOutSine, onComplete = act_autoPlay})
    end
  end
  -- sceneGroup.{{backLayer}}.alpha = 1
end
--
function _M:toDispose()
  if laserSound and laserChannel then
    audio.stop( laserChannel)
  end
end
--
function _M:toDestroy(UI)
end
--
return _M