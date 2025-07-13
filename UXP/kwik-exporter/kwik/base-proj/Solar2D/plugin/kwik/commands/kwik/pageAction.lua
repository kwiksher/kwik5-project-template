local M = {}
local Application = require(kwikGlobal.ROOT.."controller.Application")
local Navigation = require("custom.components.page_navigation")
local composer = require("composer")
--
function M:autoPlay(effect, delay, duration)
  local options = {}
  local app = Application.get()
  if effect and effect ~="" then
    options =  { effect = effect,  time= duration}
 end
 app:autoPlay(delay, options)
end

function M:autoPlayCancel()
  local app = Application.get()
  app:autoPlayCacnel()
end

--
function M:showHideNavigation()
  if not Navigation.isVisible then
     Navigation.show()
  else
     Navigation.hide()
  end
end--
--
function M:reloadPage(canvas)
	if canvas then
   app.reloadCanvas = 0
	end
	composer.gotoScene("custom.commands.page_reload")
end
--
function M:gotoPage(pageName, effect, delay, duration)
  local app = Application.get()
  local options = {}
  local scene = app.scene.UI.page
  if pageName == "PREVIOUS" then
    for i, v in next, app.props.scenes do
      if v == scene then
         if i == 1 then
          scene = app.props.scenes[#app.props.scenes]
         else
          scene = app.props.scenes[i-1]
         end
         break
      end
    end
  elseif pageName == "NEXT" then
    for i, v in next, app.props.scenes do
      if v == scene then
         if i == #app.props.scenes then
          scene = app.props.scenes[1]
         else
          scene = app.props.scenes[i+1]
         end
         break
      end
    end
  else
    scene = pageName
  end
  ---
  local myClosure_switch= function()
      -- if nil~= composer.getScene("views.page0"..pnum.."Scene") then
      --    composer.removeScene("views.page0"..pnum.."Scene", true)
      -- end
      if effect and effect ~="" then
         options =  { effect = effect,  time= duration*1000}
      end
      -- print(debug.traceback())
      app:showView("components."..scene..".index", options)
  end
  if delay > 0 then
    -- print("#### gotoPage performWithDelay")
    local t = timer.performWithDelay(delay, myClosure_switch, 1)
    app.scene.UI.timers["pageActionTimer"] = t
  else
    -- print("#### gotoPage ")
    myClosure_switch()
  end
end
--
return M