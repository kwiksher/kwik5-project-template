local M = {}
--
local composer = require("composer")
--
function M:setLanguage(UI, lang, reload)

  -- local currentScene = composer.getSceneName( "current" )
  UI.lang = lang
  if reload and (composer.reloading == nil or not composer.reloading )then
     composer.reloading = true
     composer.gotoScene("page_reload")
  else
    composer.reloading = false
   end
end
--
return M