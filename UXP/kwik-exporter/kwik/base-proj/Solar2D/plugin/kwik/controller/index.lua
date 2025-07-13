--system.activate("multitouch")


local trialCnt    = 1 -- set 0 for production

-- Create library
local lib = {}
-----------------------------------------------

local common = {commands = {"myEvent"}, components = {"keyboardNavigation", "bookstoreNavigation"}}

function lib.bootstrap(Props)
  local bookstore = require("App.bookstore")
  local App = require(kwikGlobal.ROOT.."controller.Application")
  package.loaded["Application"] = App

    local app = App.getByName(Props.name)
    if app == nil then

       local getLang = function(name)
       if bookstore.languageBooks then
          return bookstore.languageBooks[name]
       end
      end

      app = App.new{
        appName     = Props.name,
        editor     = Props.editor,
        systemDir   = system.ResourceDirectory,
        assetDir      = "App/"..Props.name.."/assets/",
        imgDir      = "App/"..Props.name.."/assets/images/",
        spriteDir   = "App/"..Props.name.."/assets/sprites/",
        thumbDir    = "App/"..Props.name.."/assets/thumbnails/",
        audioDir    = "App/"..Props.name.."/assets/audios/",
        videoDir    = "App/"..Props.name.."/assets/videos/",
        particleDir = "App/"..Props.name.."/assets/particles/",
        wwwDir = "App/"..Props.name.."/assets/www/",
        trans       = {},
        gt          = {},
        timerStash  = {},
        allAudios   = {kAutoPlay = 5},
        kBidi       = false,
        gotoPage      = Props.gotoPage, -- sceneIndex,
        scenes       = require("App."..Props.name..".index"),
        kAutoPlay   = 0,
        lang        = Props.language or getLang(Props.name) or "",
        position    = Props.position,
        --stage       = display.getCurrentStage(),
        randomAction = {},
        randomAnim   = {},
        DocumentsDir = system.DocumentsDirectory,
        common       = Props.common,
        turnOffNativeVideo = Props.turnOffNativeVideo
      }
    end
    App.gtween      = require("gtween")
    App.btween      = require("btween")
    App.Gesture     = require("dmc_gesture")
    App.MultiTouch  = require("dmc_multitouch")
    App.syncSound   = require("syncSound")
    App.currentName = Props.name
    app:init()
    common = Props.common or common

--
end

--
local function onError(e)
    print("--- unhandledError ---")
    print(e)
    return true
end
--
Runtime:addEventListener("unhandledError", onError)
--timer.performWithDelay(100, startThisMug)
--
local composer = require("composer")

local function resetPacakges()
     package.loaded["syncSound"] = nil
     package.loaded["custom.page_navigation"] = nil
     package.loaded["commands.kwik.pageAction"] = nil
     package.loaded["commands.kwik.animationAction"] = nil
     package.loaded["commands.kwik.actionCommand"] = nil
     package.loaded["commands.kwik.languageAction"] = nil
     -- bookstore UI
     -- this has a reference to App.TOC or bookXX, so need to unload it?
     package.loaded["components.bookstore.controller.pageCommand"] = nil
     package.loaded["components.common.index"] = nil
     --  package.loaded["editor.index"] = nil

    -- package.loaded["editor.bookstore.controller.pageCommand"] = nil
    --  for k, v in pairs(package.loaded) do
    --   if k:find("editor") then
    --     package.loaded[k] = nil
    --   end
    --  end
end

Runtime:addEventListener("changeThisMug", function(event)
  -- print("---------- changeThisMug -------------")
  local App = require(kwikGlobal.ROOT.."controller.Application")
  local app = App.get()
  -- print (event.appName, event.gotoPage, app.props.appName, app.currentViewName)
  --local gotoPage = "components." .. app.props.scenes[self.props.gotoPage]..".index"
  if event.appName == app.props.appName and event.gotoPage == app.props.gotoPage then
    print("not changeThisMug")
  else
    -- composer.gotoScene("components.bookstore.view.page_cutscene")
    -- composer.removeHidden(false)
    resetPacakges()
    lib.bootstrap({name=event.appName, gotoPage=event.gotoPage, editor = event.editor, position = {x=0, y=0}, common=common}) -- scenes.index
  end
end)




-- Return library instance
return lib
