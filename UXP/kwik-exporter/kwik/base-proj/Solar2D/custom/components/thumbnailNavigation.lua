local M = {}
local navigation = require("plugin.kwik.extlib.kNavi")
local shapes     = require("plugin.kwik.extlib.shapes")

local navigationProps = { book = {
    backColor       = {255, 255, 255},
    thumbnailWidth  = 1920/10,
    thumbnailHeight = 1280/10,
    alpha           = 0, --background
    direction       = "top",
    exclude         = {"shape"}
  }
}
--
local function naviListener(page)
  print("page_navigation", page)
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
    self.kNavi = obj

    -- self.triangle = shapes.triangle.equi( display.contentCenterX, (display.actualContentHeight - 1280/4)/2 - 10, 20 )
    self.triangle = shapes.triangle.equi( 10, 10, 20 )

    self.triangle:rotate(90)
    self.triangle:setFillColor(0,0,1)
    self.triangle.tap = function(event)
      self.kNavi:show()
      return true
    end
    sceneGroup:insert(self.triangle)
  end
end
--
function M:didShow(UI)
  if self.kNavi then
    self.kNavi:hide()
    if self.triangle and self.triangle.addEventListener then
      self.triangle:addEventListener("tap", self.triangle)
    end
  end
end
--
function M:didHide(UI)
  if self.kNavi and self.tiangle then
    self.triangle:removeEventListener("tap", self.triangle)
  end
end
--
function M:destroy(UI)
end
--
return M
