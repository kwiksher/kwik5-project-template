local dir = ...
local parent = dir:match("(.-)[^%.]+$")
local root = parent:sub(1, parent:len()-1):match("(.-)[^%.]+$")


local function getParentPath(path)
    pattern1 = "^(.+)//"
    pattern2 = "^(.+)\\"

    if (string.match(path,pattern1) == nil) then
        return string.match(path,pattern2)
    else
        return string.match(path,pattern1)
    end
end

--print("",getParentPath(parent))

local Context = require ("robotlegs.Context")
local Class = {
  pathMod = "commands.common"
}
--
function Class.new(app)
    local appName = app.props.appName
    --app:addEventListener("onRobotlegsViewCreated", function(e) print("test") end)
    local context = Context.new(app)
    context.Router = {}
    local appDir = "App."..appName .."."
    --
    function context:init(scenes, props)
        -- your global event if any
        if props.common and props.common.commands then
          for i=1, #props.common.commands do
            self:mapCommand("common."..props.common.commands[i], Class.pathMod..props.common.commands[i])
          end
        end
        --
        -- creat all the contexts of scenes
        --
        for i=1, #scenes do
            --print(scenes[i])
            local scene = require(appDir.."components."..scenes[i]..".index")
            -- print("context:init", appDir.."components."..scenes[i]..".index")
            scene:setProps(props)
            ---
            --- app is set to scene !
            ---
            scene.app = app

            local model = scene.model
            model.pageNum = i

            --
            local commands = scene:getCommands()
            --
            --print(appDir.."scenes."..model.page..".index", appDir.."mediators."..model.page.."Mediator")
            local mediatorName = appDir.."mediators."..model.page.."Mediator"
            package.loaded[mediatorName] = require( 'controller.mediator' ).new(appDir, scenes[i])
            self:mapMediator(appDir.."components."..model.page..".index", mediatorName)
            --
            for k, eventName in pairs(commands) do
              -- print("@@@@@", model.page.."."..eventName)
                self:mapCommand(model.page.."."..eventName, appDir.."commands."..model.page.."."..eventName)
            end
            --
            -- print("context:init", scenes[i], scene)
            self.Router["components."..scenes[i]..".index"] = scene
        end
        -- app init command
        self:mapCommand("app.droidHWKey", "commands.app.droidHWKey")
        self:mapCommand("app.kwkVar", "commands.app.kwkVar")
        -- self:mapCommand("app.memoryCheck",  "commands.app.memoryCheck")
        self:mapCommand("app.statusBar", "commands.app.statusBar")
        self:mapCommand("app.suspend", "commands.app.suspend")
        --
        self:mapMediator(appDir.."index", "controller.ApplicationMediator") -- "Application" is a classType in Application.lua
        --
        Runtime:dispatchEvent({name = "startup"})
    end
    --
    function context:addInitializer(t)
        local t = require(t)
        for k, v in pairs(t) do self.Router[k] = v end
    end
    --
    return context
end
--
return Class
