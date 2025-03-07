-- $weight=-1
--
local _M = {}
local App = require("controller.Application")
local model = require("components.bookstore.index").model
local pageCommand = require("components.bookstore.controller.pageCommand")
--
function _M:init(UI)
  pageCommand.init(model)
end

local buttons = {
  gotoBtn=function(event)
    pageCommand.gotoNextScene()
  end,
  gotoNextBook=function(event)
    pageCommand.gotoNextBook()
  end,
  gotoPreviousBook=function(event)
    pageCommand.gotoPreviousBook()
  end,
  gotoTitle=function(event)
    pageCommand.showView("page1", {effect = "slideRight"})
  end,
  gotoTOC = function(event)
    pageCommand.gotoTOC()
  end
}
--
function _M:create(UI)
  local sceneGroup = UI.sceneGroup
end
--
function _M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  for name, func in pairs(buttons) do
    local button = sceneGroup[name]
    if button then
      button:addEventListener("tap", func)
    end
  end
end
--
function _M:didHide(UI)
  local sceneGroup = UI.sceneGroup
  for name, func in pairs(buttons) do
    local button = sceneGroup[name]
    if button then
      button:removeEventListener("tap", func)
    end
  end
end
--
function _M:destroy()
end
--
return _M
