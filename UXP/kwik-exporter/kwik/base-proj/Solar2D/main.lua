local kwik = require "plugin.kwik"

system.setTapDelay(0.2)
--
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local lldebugger = loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH"))()
  lldebugger.start()
end

-- kwik.restore()
-- kwik.autoUpdate()

--display.setDefault( "background", 0.2, 0.2, 0.2, 0.1 )
kwik.useGradientBackground()

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

local mode = "editing"
-- local mode = "production"

--
if mode == "editing" then
  kwik.bootstrap{
      name = "book",
      editor = true,
      gotoPage = "landscape",
      language = "", -- empty string "" is for a single language project
      position = {x = 0, y = 0},
      gotoLastBook = true,
      unitTest = false,
      httpServer = false,
      showPageName = true
  }
elseif mode == "production" then
  -- for product release
  kwik.bootstrap{
    name = "book",
    editor = false,
    gotoPage = "landscape",
    language = "", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false
  }
end