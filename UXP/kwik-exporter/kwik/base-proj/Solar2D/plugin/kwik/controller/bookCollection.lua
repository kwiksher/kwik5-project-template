local M = {}
--local controller = require(kwikGlobal.ROOT.."controller.sceneCollectionController")
--
local composer = require("composer")
composer.recycleOnSceneChange = true
local sceneName = "bookCollection"
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
    scene.props = _props
    -- scene.app = require(kwikGlobal.ROOT.."controller.Application").get()
    -- controller.book = scene.props.appName
    --
    function scene:setProps (Props)
      --self.col_num = Props.col_num
      --self.row_num = Props.row_num
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
    function scene:create(event)
      local props = self.props
      local count = 0
      local row_max = math.ceil(#props.books / self.col_num)
      --print("@@@@", row_max, self.col_num)
      for i=1, row_max do
        for k=1, self.col_num do
          count = count +1
          if count <= #props.books then
            local book = props.books[count]
            local bookImg = display.newImage("App/"..book.name.."/assets/thumbnails/"..book.image, 0,0)
            ---
            bookImg.x = self.x + (k-1)*self.width
            bookImg.y = self.y + (i-1)*self.height
            bookImg.width = self.width
            bookImg.height = self.height
            self.view:insert(bookImg)
            book.obj = bookImg
            ---
          end
        end
      end
    end
    --
    function scene:show(event)
        local sceneGroup = self.view
        for i, book in next, self.props.books do
          if event.phase == "will" then
          elseif event.phase == "did" then
              -- book.obj:addEventListener("tap", controller.onClick)
          end
        end
    end
    --
    function scene:hide(event)
      for i, book in next, self.props.books do
        if event.phase == "will" then
        elseif event.phase == "did" then
          -- book.obj:removeEventListener("tap", controller.onClick)
        end
      end
    end
    --
    function scene:destroy(event)
    end

    function scene:init(event)
    end

    --
    scene:addEventListener("init", scene)
    scene:addEventListener("create", scene)
    scene:addEventListener("show", scene)
    scene:addEventListener("hide", scene)
    scene:addEventListener("destroy", scene)
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
        elseif event.type =="portraitUpsideDown" and event.delta == -90  then
          sceneGroup:scale(ratio, ratio)
        elseif event.type =="portrait" and event.delta == 90  then
         sceneGroup:scale(ratio, ratio)
          print("updated scene", sceneGroup.x, sceneGroup.y)
          print("scene bounds",sceneGroup.contentBounds.xMin, sceneGroup.contentBounds.xMax, sceneGroup.contentBounds.yMin, sceneGroup.contentBounds.yMax)
          print("updated anchor", sceneGroup.anchorX, sceneGroup.anchorY)
        elseif event.type =="portraitUpsideDown" and event.delta == 90  then
          sceneGroup:scale(ratio, ratio)
        elseif event.type =="landscapeLeft"  then
          sceneGroup:scale(reverse, reverse)
        elseif event.type =="landscapeRight"  then
          sceneGroup:scale(reverse, reverse)
        end
        print("view",sceneGroup.x, sceneGroup.y)
      end
    end
    -- Runtime:addEventListener ("orientation", onOrientationChange)
  return scene
end

return M
