local env = require("env")
env.book   = "book"
env.page = "landscape"
env.lang   = ""
--
env.restore = false
--
env.mode = "development"
-- env.mode = "production"
-- env.mode = "debug" -- need kwik5-plugin src from kwiksher's repo

--
if env.mode == "development" or env.mode == "debug" then
  env.props = {
    name = env.book,
    editor = true,
    gotoPage = env.page,
    language = env.lang, -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    scale      = 1,
    showPageName = true,
    turnOffNativeVideo = true
  }
elseif env.mode == "production" then
  env.props = {
    name = env.book,
    editor = false,
    gotoPage = env.page,
    language = env.lang, -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false,
    turnOffNativeVideo = false
  }
elseif env.mode == "behaviorTree" then

  require("custom.components.myComponent")

  local resourcePath = system.pathForFile("", system.ResourceDirectory)
  local appPath = "/Behavior/" .. env.book
  local kwikPath = "/lua_modules/kwiksher/kwik"
  package.path = resourcePath .. appPath .. "/?.lua;" ..
                 resourcePath .. appPath .. "/?/?.lua;" ..
                 resourcePath .. kwikPath .. "/?.lua;" ..
                 resourcePath .. kwikPath .. "/?/?.lua;" ..
                 package.path

    -- Require Composer for scene management
  local composer = require("composer")

  -- Start with the selected behavior-tree scene
  local sceneModule = "Behavior."..env.book..".views."..env.page.."."..env.page.."Scene"
  local okScene, sceneOrErr = pcall(require, sceneModule)
  if not okScene then
    print("Failed to load scene module:", sceneModule)
    print(sceneOrErr)
    return
  end

  composer.gotoScene(sceneModule)

  --Start automated test after scene loads
  -- timer.performWithDelay(1000, function()
  --     print("\n=== Starting Automated Test (Jump to Choices) ===\n")
  --     local sceneTest = require("tests."..env.page.."SceneTest")
  --     sceneTest.start()
  -- end)
  return
end
--
--
system.setTapDelay(0.2)
--
--
if env.setPlugin(env.mode)  then
  if env.mode == "development" or env.mode == "debug" then
    local forceReloadModules = {
      "kwiksher.kwik.controller.ApplicationUI",
      "kwiksher.kwik.controller.scene",
      "kwiksher.kwik.controller.Application",
      "kwiksher.kwik.components.kwik.layer_image"
    }
    for i = 1, #forceReloadModules do
      package.loaded[forceReloadModules[i]] = nil
    end
  end

  local kwik = require("kwiksher.kwik")
  --
  --display.setDefault( "background", 0.2, 0.2, 0.2, 0.1 )
  kwik.useGradientBackground()
  --

  if env.restore and  kwik.restore() then
    native.showAlert("kwik", "restored comment it out kwik.restore()")
    return
  end

  kwik.setCustomModule(
    "custom",
    {
      commands = {"myEvent"},
      components = {
        -- "align",
        "myComponent",
        "thumbnailNavigation",
        "index"
        -- "keyboardNavigation",
      }
    }
  )
  --
  kwik.bootstrap(env.props)
  --
end

