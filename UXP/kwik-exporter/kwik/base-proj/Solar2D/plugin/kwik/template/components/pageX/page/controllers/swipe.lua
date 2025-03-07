-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
local _K = require "Application"
local composer = require("composer")
local Navigation = require("extlib.kNavi")
--
{{#ultimate}}
local xFactor = display.contentWidth/1920
local yFactor = display.contentHeight/1280
local pSpa =  {{pSpa}}/4
{{/ultimate}}
{{^ultimate}}
local pSpa  = {{pSpa}}
{{/ultimate}}

{{#isTmplt}}
local ui  = require("components.store.UI")
{{/isTmplt}}

--
function _M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
  local layers       = UI.layers
  local curPage     = UI.curPage
  local numberOfPages    = UI.numberOfPages

  if sceneGroup.{{backLayer}} == nil then return end
  _K.Gesture.activate( sceneGroup.{{backLayer}}, {swipeLength= pSpa }) --why
  {{#infinity}}
    if sceneGroup.{{backLayer}}_2 == nil then return end
    _K.Gesture.activate( sceneGroup.{{backLayer}}_2, {swipeLength= pSpa })
  {{/infinity}}
{{#isTmplt}}
  _K.pageSwap = function (event )
    local options
    if event.phase == "ended" and event.direction ~= nil then
       local wPage = ui.currentPage
       if event.direction == "left" and _K.kBidi == false then
          wPage = ui.currentPage + 1
          if wPage > ui.numberOfPages then return end
          ui.gotoNextScene({ effect = "fromRight"})
       elseif event.direction == "left" and _K.kBidi == true then
          wPage = ui.currentPage - 1
          if wPage < 0 then return end
          ui.gotoPreviousScene({ effect = "fromLeft"})
       elseif event.direction == "right" and _K.kBidi == true then
          wPage = ui.currentPage + 1
          if wPage > numberOfPages then return end
          ui.gotoNextScene({ effect = "fromRight"})
       elseif event.direction == "right" and _K.kBidi == false then
          wPage = ui.currentPage - 1
          if wPage == 0 then
            _K.systemDir = system.ResourceDirectory
            _K.imgDir = "assets/images/"
            _K.audioDir = "assets/audios/"
            ui.gotoSceneBook("TOC", { effect = "fromLeft"})
          else
            ui.gotoPreviousScene({ effect = "fromLeft"})
          end
       end
        {{#hasShake}}
        if _K.shakeMe ~= nil then
        Runtime:removeEventListener("accelerometer", _K.shakeMe);
        _K.shakeMe = nil
        end
        {{/hasShake}}
        {{#invert}}
        if _K.kOrientation_act ~= nil then
        Runtime:removeEventListener("orientation", _K.kOrientation_act);
        _K.kOrientation_act = nil
        end
        {{/invert}}
        {{#navigation}}
          Navigation.hide()
        {{/navigation}}
     end
   end
{{/isTmplt}}
{{^isTmplt}}
  _K.pageSwap = function (event )
    local options
    if event.phase == "ended" and event.direction ~= nil then
       local wPage = curPage
       if event.direction == "left" and _K.kBidi == false then
          wPage = curPage + 1
          if wPage > numberOfPages then wPage = curPage end
          options = { effect = "fromRight"}
       elseif event.direction == "left" and _K.kBidi == true then
          wPage = curPage - 1
          if wPage < 1 then wPage = 1 end
          options = { effect = "fromLeft"}
       elseif event.direction == "right" and _K.kBidi == true then
          wPage = curPage + 1
          if wPage > numberOfPages then wPage = curPage end
          options = { effect = "fromRight"}
       elseif event.direction == "right" and _K.kBidi == false then
          wPage = curPage - 1
          if wPage < 1 then wPage = 1 end
          options = { effect = "fromLeft"}
       end
    {{#bookshelf}}
      local ui           = require("components.store.UI")
       if tonumber(wPage) ~= tonumber(curPage) then
          if ui.setDir(wPage) then
              ui.showView(curPage, wPage, options)
          end
       else
          ui.gotoTOC(options)
       end
    {{/bookshelf}}
    {{^bookshelf}}
       if tonumber(wPage) ~= tonumber(curPage) then
          {{#hasShake}}
          if _K.shakeMe ~=nil then
            Runtime:removeEventListener("accelerometer", _K.shakeMe);
            _K.shakeMe = nil
          end
          {{/hasShake}}
          {{#invert}}
          if _K.kOrientation_act ~= nil then
          Runtime:removeEventListener("orientation", _K.kOrientation_act);
          _K.kOrientation_act = nil
          end
          {{/invert}}
          {{#navigation}}
            Navigation.hide()
          {{/navigation}}
          _K.appInstance:showView("views.page0"..wPage.."Scene", options)
         end
    {{/bookshelf}}
    end
  end
{{/isTmplt}}
    sceneGroup.{{backLayer}}:addEventListener( _K.Gesture.SWIPE_EVENT, _K.pageSwap )
    {{#infinity}}
      sceneGroup.{{backLayer}}_2:addEventListener( _K.Gesture.SWIPE_EVENT, _K.pageSwap )
    {{/infinity}}
end
--
function _M:toDispose(UI)
    local layers       = UI.layers
    if  sceneGroup.{{backLayer}} and _K.pageSwap  then
      sceneGroup.{{backLayer}}:removeEventListener( _K.Gesture.SWIPE_EVENT, _K.pageSwap )
      {{#infinity}}
        sceneGroup.{{backLayer}}_2:removeEventListener( _K.Gesture.SWIPE_EVENT, _K.pageSwap )
      {{/infinity}}
      _K.pageSwap = nil
   end
  --_K.Gesture.deactivate(sceneGroup.{{myLName+') ;
end
--
function _M:toDestroy(UI)
  _K.pageSwap = nil
end
--
return _M