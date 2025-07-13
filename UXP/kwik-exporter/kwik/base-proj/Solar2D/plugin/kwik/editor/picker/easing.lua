local M = {}

local util = require(kwikGlobal.ROOT.."lib.util")
local option, newText = util.newTextFactory {
  text = "",
  x    = 0,
  y    = 100,
  width    = 72,
  height   = 20,
  fontSize = 10,
}

M.model = {
  -- linear = {},
  -- continuousLoop = nil,
  expo = {"inExpo","outExpo","inOutExpo"}, --outInExpo
  sine = {"inSine","outSine","inOutSine"},--outInSine
  quad = {"inQuad","outQuad","inOutQuad"}, --outInQuad
  cubic = {"inCubic","outCubic","inOutCubic"},--outInCubic
  quart = {"inQuart","outQuart","inOutQuart"},--outInQuart
  quint = {"inQuint","outQuint","inOutQuint"},--outInQuint
  circ = {"inCirc","outCirc","inOutCirc"},--outInCirc
  back = {"inBack","outBack","inOutBack"},--outInBack
  elastic = {"inElastic","outElastic","inOutElastic"},-- outInElastic
  bounce = {"inBounce","outBounce","inOutBounce"},--outInBounce
}

M.x = display.contentCenterX
M.y = display.contentCenterY-200
M.width = 80
M.height = 40

function M:create(UI)
  -- local sceneGroup = UI.sceneGroup
  self.objs = {}
  local rowNum = 0
  for k, v in pairs(self.model) do

    local options =
    {
        -- Required parameters
        width = 1080/4,
        height = 124,
        numFrames = 4,

        -- Optional parameters; used for scaled content support
        sheetContentWidth = 1080,  -- width of original 1x size of entire sheet
        sheetContentHeight = 124  -- height of original 1x size of entire sheet
    }

    local imageSheet = graphics.newImageSheet(kwikGlobal.PATH.. "../resources/images/easing/easing-"..k..".png", options )

    for i, name in next, v do
      option.x = self.x + self.width*i + 10
      option.y = self.y + self.height*rowNum
      option.text = name
      local obj = newText(option)
      obj.image = display.newImage(imageSheet, i, option.x, option.y)
      local ratio = self.width/obj.image.width
      obj.image:scale(ratio, ratio)
      obj:toFront()
      self.objs[#self.objs +1] = obj
    end
    rowNum = rowNum + 1
  end
end

function M.tapHandler(event)
  local target = event.target
  M.listener(target.text)
end

function M:show(UI)
  for i, obj in next, self.objs do
    obj:addEventListener("tap",self.tapHandler)
  end
end

function M:destroy(UI)
  for i, obj in next, self.objs do
    obj:removeEventListener("tap", self.tapHandler)
    obj.image:removeSelf()
    obj:removeSelf()
  end
end

return M