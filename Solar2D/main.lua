local env = require("env")
env.book   = "book"
env.goPage = "landscape"
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
    gotoPage = env.goPage,
    language = env.lang, -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = true,
    unitTest = true,
    httpServer = false,
    showPageName = true,
    turnOffNativeVideo = true
  }
elseif env.mode == "production" then
  env.props = {
    name = env.book,
    editor = false,
    gotoPage = env.goPage,
    language = env.lang, -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false,
    turnOffNativeVideo = false
  }
end
--
--
system.setTapDelay(0.2)
--
--
if env.setPlugin(env.mode)  then
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

