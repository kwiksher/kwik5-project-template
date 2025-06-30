-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
local _K = require("Application")
local composer = require("composer")
local _Delay = 0 -- Kwik3 was 1000
---------------------
---------------------
function _M:localPos(UI)
    local sceneGroup  = UI.sceneGroup
    local layers       = UI.layers
  -- Page properties
  {{#xScale}}
    sceneGroup.xScale = {{xScale}}
    sceneGroup.yScale = {{yScale}}
    sceneGroup.alpha = {{alpha}}
  {{/xScale}}
end
--
function _M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
  local layers       = UI.layers
  local curPage     = UI.curPage
  local numberOfPages    = UI.numberOfPages
  local allAudios   = UI.allAudios
    -- purges previous and next scenes
    local __prevScene = composer.getSceneName( "previous" )
    if nil~= __prevScene then
      composer.removeScene(__prevScene, true)
    end
      -- Check for previous bookmarks
     if (tonumber(_K.kBookmark) == 1) then
        local path = system.pathForFile(_K.appName.. "book.txt", _K.DocumentsDir )
        local file = io.open( path, "w+" )
        file:write ( curPage.."\n1" )
        io.close( file )
     end

      -- Check for for auto play properties
     if (tonumber(_K.kAutoPlay) > 0) then
       local function act_autoPlay(event)
         if(curPage < numberOfPages) then
            if nil~= composer.getScene( "views.page0"..(curPage+1).."Scene") then composer.removeScene( "views.page0"..(curPage+1).."Scene", true) end
            {{^pageCurl}}
            if(_K.kBidi == false) then
              composer.gotoScene( "views.page0"..(curPage+1).."Scene", { effect = "fromRight"} )
            else
              composer.gotoScene( "views.page0"..(curPage-1).."Scene", { effect = "fromLeft"} )
            end
            {{/pageCurl}}
            {{#pageCurl}}
            if(_K.kBidi == false) then
              composer.gotoScene( "views.page0"..(curPage+1).."Scene" )
            else
              composer.gotoScene( "views.page0"..(curPage-1).."Scene" )
            end
            {{/pageCurl}}
         end
       end
       {{^pageCurl}}
       if (UI.allAudios.kAutoPlay > _K.kAutoPlay*1000) then
           _K.timerStash.timer_AP = timer.performWithDelay(
             UI.allAudios.kAutoPlay + _Delay, act_autoPlay, 1 )
       else
           _K.timerStash.timer_AP = timer.performWithDelay( _K.kAutoPlay*1000, act_autoPlay, 1 )
       end
       {{/pageCurl}}
       {{#pageCurl}}
       if (UI.allAudios.kAutoPlay > _K.kAutoPlay*1000) then
           _K.timerStash.timer_AP = timer.performWithDelay(
             UI.allAudios.kAutoPlay + _Delay ,
              function()
                UI.autoPlayCurl(act_autoPlay)
              end , 1 )
       else
           _K.timerStash.timer_AP = timer.performWithDelay( _K.kAutoPlay*1000,
            function()
              UI.autoPlayCurl(act_autoPlay)
            end , 1 )
       end
      {{/pageCurl}}
     end

    {{^pageCurl}}
    {{#preload}}
       -- Preloads next scene. Must be off to use page curl
      if not _K.exportCurrent then
       _K.timerStash.timer_pl = timer.performWithDelay( 5000, function()
          composer.loadScene( "views.page0{{nextScene}}Scene")
       end)
       end
    {{/preload}}
    {{/pageCurl}}
end
--
function _M:toDispose()
  _K.test = nil
  _K.cancelAllTimers();
end

function _M:willHide()
end

--
function _M:localVars()
end
--
return _M