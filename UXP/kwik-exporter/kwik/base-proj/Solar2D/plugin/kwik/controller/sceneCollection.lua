local M = {}
local controller = require(kwikGlobal.ROOT.."controller.sceneCollectionController")
--
local composer = require("composer")
composer.recycleOnSceneChange = false
local sceneName = "sceneCollection"
--
M.new = function(_props)
  local props = _props or {}
    -- sceneName is like App.book01.scenes.page01.index
    local scene = composer.newScene(props.name or sceneName)
    scene._composerFileName = nil
    scene.classType = sceneName
    --
    scene.col_num = 4
    scene.row_num = nil
    scene.width = 480 / scene.col_num
    scene.height = 320/scene.col_num
    scene.x = display.contentCenterX - 480/2 + 480/8
    scene.y = display.contentCenterY - 320/2
    scene.app = require(kwikGlobal.ROOT.."controller.Application").get()
    controller.book = scene.app.props.appName
    --
    function scene:setProps (Props)
      --self.col_num = Props.col_num
      --self.row_num = Props.row_num
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
    function scene:create(event)
      local app = self.app
      local count = 0
      local row_max = math.ceil(#app.props.scenes / self.col_num)
      --print("@@@@", row_max, self.col_num)
      for i=1, row_max do
        for k=1, self.col_num do
          count = count +1
          if count <= #app.props.scenes then
            local sceneName = app.props.scenes[count]
            --print("", sceneName)
            local page = app.context.Router["components."..sceneName..".index"]
            --print("@UI:create", page)
            -- printKeys(page)
            page.UI:create(event.params)
            ---
            local group = page.UI.sceneGroup
            group.x = self.x + (k-1)*self.width
            group.y = self.y + (i-1)*self.height
            group.isVisible = false
            self.view:insert(group)
            ---
          end
        end
      end
    end
    --
    function scene:show(event)
        local sceneGroup = self.view
        for i, sceneName in next, self.app.props.scenes do
          local page = self.app.context.Router["components."..sceneName..".index"]
          if event.phase == "will" then
              page.UI:willShow(event.params)
          elseif event.phase == "did" then
              page.UI.sceneGroup:scale(0.25, 0.25)
              page.UI.sceneGroup.isVisible = true
              page.UI:didShow(event.params)
              page.UI.sceneGroup._sceneName = sceneName
              page.UI.sceneGroup:addEventListener("tap", controller.onClick)
          end
        end
    end
    --
    function scene:hide(event)
      for i, sceneName in next, self.app.props.scenes do
        local page = self.app.context.Router["components."..sceneName..".index"]
        if event.phase == "will" then
        elseif event.phase == "did" then
          page.UI.sceneGroup:scale(4, 4)
          page.UI:didHide(event.params)
          page.UI.sceneGroup._sceneName = nil
          page.UI.sceneGroup:removeEventListener("tap", controller.onClick)
        end
      end
    end
    --
    function scene:destroy(event)
      for i, sceneName in next, self.app.props.scenes do
        local page = self.app.context.Router["components."..sceneName..".index"]
        page.UI:destroy(event.params)
      end
    end

    function scene:init(event)
      for i, sceneName in next, self.app.props.scenes do
        local page = self.app.context.Router["components."..sceneName..".index"]
        page.UI:init()
      end
    end

    function scene:transition(event)
        transition.to(self.view, event.params)
    end
    --
    scene:addEventListener("init", scene)
    scene:addEventListener("transition", scene)
    scene:addEventListener("create", scene)
    scene:addEventListener("show", scene)
    scene:addEventListener("hide", scene)
    scene:addEventListener("destroy", scene)
    --
    --
    -- orientation
    --
    local ratio = display.contentCenterX/display.contentCenterY
    local function onOrientationChange (event)
      if scene.view then
        local sceneGroup = scene.view
        local currentOrientation = event.type
        local ratio = 480/320
        local reverse = 320/480

        sceneGroup.x, sceneGroup.y = display.contentCenterX, display.contentCenterY

        if event.type =="portrait" and event.delta == -90  then
          sceneGroup:scale(ratio, ratio)
          --sceneGroup.x, sceneGroup.y = -(display.contentHeight/2-display.contentCenterX), -(display.contentWidth/2-display.contentCenterY)
        elseif event.type =="portraitUpsideDown" and event.delta == -90  then
          sceneGroup:scale(ratio, ratio)
          --sceneGroup.x, sceneGroup.y = -(display.contentHeight/2-display.contentCenterX), -(display.contentWidth/2-display.contentCenterY)
        elseif event.type =="portrait" and event.delta == 90  then
         sceneGroup:scale(ratio, ratio)

         print("center @2x", display.contentCenterX*2, display.contentCenterY*2)
          --sceneGroup:rotate(event.delta)

          --sceneGroup.x, sceneGroup.y = 0,0
          print("updated scene", sceneGroup.x, sceneGroup.y)
          print("scene bounds",sceneGroup.contentBounds.xMin, sceneGroup.contentBounds.xMax, sceneGroup.contentBounds.yMin, sceneGroup.contentBounds.yMax)
          print("updated anchor", sceneGroup.anchorX, sceneGroup.anchorY)
        elseif event.type =="portraitUpsideDown" and event.delta == 90  then
          sceneGroup:scale(ratio, ratio)
         -- sceneGroup.x, sceneGroup.y = -(display.contentHeight/2-display.contentCenterX), -(display.contentWidth/2-display.contentCenterY)
        elseif event.type =="landscapeLeft"  then
          --sceneGroup.x, sceneGroup.y = 0,0 ---(display.contentHeight/2-display.contentCenterX), -(display.contentWidth/2-display.contentCenterY)
          sceneGroup:scale(reverse, reverse)
        elseif event.type =="landscapeRight"  then
          --sceneGroup.x, sceneGroup.y = 0,0 ---(display.contentHeight/2-display.contentCenterX), -(display.contentWidth/2-display.contentCenterY)
          sceneGroup:scale(reverse, reverse)
        end
        print("view",sceneGroup.x, sceneGroup.y)
      end
    end
    -- Runtime:addEventListener ("orientation", onOrientationChange)
  return scene
end

return M
