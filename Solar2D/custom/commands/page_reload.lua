local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )
    local sceneGroup = self.view
    local reloadTxt = display.newText("reloading..", display.contentWidth/2, display.contentHeight/2, native.systemFont, 48)
    reloadTxt:setFillColor( 1 )
    sceneGroup:insert(reloadTxt)
end -- ends scene:create

function scene:show( event )
   local sceneGroup = self.view
   if event.phase == "did" then
    timer.performWithDelay( 250, function()
      print("reload "..composer.getSceneName( "previous" ))
        composer.removeScene(composer.getSceneName( "previous" ))
        composer.gotoScene( composer.getSceneName( "previous" ))
        composer.reloading = false
        end)
   end --ends phase did
end -- ends scene:show

function scene:hide( event )
   -- all disposal happens here
   if event.phase == "will" then
   elseif event.phase == "did" then
  end
end

function scene:destroy( event )
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
