local M = {}
local UI = require(kwikGlobal.ROOT.."controller.ApplicationUI")

local composer = require("composer")
composer.recycleOnSceneChange = false
-- TBI should be the recycleOnSceneChange?
-- [[
  -- https://forums.solar2d.com/t/runtime-error-bad-argument-2/311235/10
  --  self.view:insert(self.UI.sceneGroup)
--]]

M.new = function(sceneName, model)
    -- sceneName is like App.book01.scenes.page01.index
    local parent = sceneName:match("(.-)[^%.]+$")
    local scene = composer.newScene(sceneName)
    scene._composerFileName = nil
    local componentFolder = sceneName:gsub(".index", "")
    scene.classType = sceneName
    local page = componentFolder:sub(componentFolder:match('^.*()%.')+1)
    -- print("@@@@", page)
    model.page = page
    scene.UI = UI.create(scene, model)
    scene.model = model
    scene.customCommands = nil
    --
    function scene:setProps (Props)
        self.UI.props = Props
        self.UI.numberOfPages = #Props.scenes
        -- UI.currentBook       = Porps.appName
    end
    ------------------------------------------------------------
    ------------------------------------------------------------
    function scene:create(event)
      if self.UI.props.appName == nil then
        self.calssType = event.params.sceneProps.classType
        self.UI = event.params.sceneProps.UI
        self.model = event.params.sceneProps.model
        self.getCommands = event.params.sceneProps.getCommands
        self.app = event.params.sceneProps.app
      end
      --
      -- local sceneGroup = self.view -- this comes from composer
      --self.UI.sceneGroup = self.view
      --
      if self.UI.props.editor  then
        -- self.UI.sceneGroup.x = display.contentCenterX
        -- self.UI.sceneGroup.y = display.contentCenterY
        -- self.UI.sceneGroup.anchorX = .5
        -- self.UI.sceneGroup.anchorY = .5
      end

      self.view:insert(self.UI.sceneGroup)

      self.UI:create(event.params)
      if self.model.onInit then self.model.onInit(self.UI) end
      self.app:dispatchEvent({name = "onRobotlegsViewCreated", target = self, UI=self.UI})

    end
    --
    function scene:show(event)
        self.isActive = true
        local sceneGroup = self.view
        if event.phase == "will" then
            self.UI:willShow(event.params)
        elseif event.phase == "did" then
            self.UI:didShow(event.params)
            self.app:dispatchEvent({name = "onRobotlegsViewDidShow", target = self, UI=self.UI})
        end
    end
    --
    function scene:hide(event)
        if event.phase == "will" then
          self.isActive = false
            if event.parent then event.parent.UI:resume() end
            self.UI:didHide(event.params)
        elseif event.phase == "did" then
          self.app:dispatchEvent({name = "onRobotlegsViewDidHide", target = self, UI=self.UI})
        end
    end
    --
    function scene:destroy(event)
        self.UI:destroy(event.params)
        self.app:dispatchEvent({name = "onRobotlegsViewDestroyed", target = self,UI=self.UI})
    end

    function scene:init(event)
      print("scene:init") -- never called?
      self.UI:init()
      -- self.view = display.newGroup()
      -- self.view.x = display.contentCenterX
      -- self.view.y = display.contentCenterY
      -- self.UI.sceneGroup.x = display.contentCenterX
      -- self.UI.sceneGroup.y = display.contentCenterY
      -- self.UI.sceneGroup.anchorX = .5
      -- self.UI.sceneGroup.anchorY = .5
      -- self.view:insert(self.sceneGroup)
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
    function scene:getCommands()
        local commands = self.customCommands or {}
        -- print("$$$$$$", #commands)
        -- local commands = {"initMenu","printStack",
        --    "layersList.select", "layersList.drag",
        --    "layerProps.new", "layerProps.update","layerProps.attachFile", "layerProps.drag"
        -- }
        local function iterator(layers)
            if type(layers) == "table" then
                for i = 1, #layers do
                    local layer = layers[i]
                    for name, value in pairs(layer) do
                        --print(name, #value)
                        -- print("", "string")
                        if value.commands then
                            for k, eventName in pairs(value.commands) do
                               -- print("", name .. "." .. eventName)
                                table.insert(commands,
                                             name .. "." .. eventName)
                            end
                        elseif value.types then
                            -- do nothing
                        else
                            if #value == 0 then
                                -- do nothing
                            else
                                iterator(value)
                            end
                            -- print("", value, parent)
                        end
                    end
                end
            end
        end
        -- for layers
        -- iterator(self.model.components.layers)
        for i=1, #self.model.commands do
            table.insert(commands, self.model.commands[i])
        end
        return commands
    end

    --
    -- orientation
    --
    local ratio = display.contentCenterX/display.contentCenterY
    local function onOrientationChange (event)
      if scene.view then
        local sceneGroup = scene.UI.sceneGroup
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
    Runtime:addEventListener ("orientation", onOrientationChange)

    return scene

end

return M
