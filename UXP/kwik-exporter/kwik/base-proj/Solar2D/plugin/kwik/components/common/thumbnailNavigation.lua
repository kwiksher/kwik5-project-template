local M = {}
local navigation = require(kwikGlobal.ROOT.."custom.page_navigation")
local shapes     = require("shapes")

local navigationProps = { bookFree = {
    backColor       = {255, 255, 255},
    thumbnailWidth  = 1920/10,
    thumbnailHeight = 1280/10,
    alpha           = 0, --background
    direction       = "top",
    -- exclude         = {"page1"}
  }
}
--
local function naviListener()
  print("page_navigation")
end
--
function M:init(UI)
  local props = navigationProps[UI.scene.app.name]
  if props then
    props.UI = UI
  end
end
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  -- print("-- create thumbnailNavigation --", UI.scene.app.name)
  local props = navigationProps[UI.scene.app.name]
  if props then
    local obj = navigation.new(props, naviListener)
    --
    sceneGroup:insert(obj.group)
    self.obj = obj

    -- self.triangle = shapes.triangle.equi( display.contentCenterX, (display.actualContentHeight - 1280/4)/2 - 10, 20 )
    self.triangle = shapes.triangle.equi( 0,320/2, 20 )

    self.triangle:rotate(180)
    self.triangle:setFillColor(1,1,0)
    self.triangle.tap = function(event)
      self.obj:show()
      return true
    end
    sceneGroup:insert(self.triangle)
  end
end
--
function M:didShow(UI)
  if self.obj then
    self.obj:hide()
    if self.triangle and self.triangle.addEventListener then
      self.triangle:addEventListener("tap", self.triangle)
    end
  end
end
--
function M:didHide(UI)
  if self.obj and self.tiangle then
    self.triangle:removeEventListener("tap", self.triangle)
  end
end
--
function M:destroy(UI)
end
--
return M
