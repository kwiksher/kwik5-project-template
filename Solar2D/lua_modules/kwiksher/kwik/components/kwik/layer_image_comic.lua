-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
local _K = require "controller.Application"
local util = require "lib.util"
-- Infinity background animation

--
function _M:comicImage(UI)
  local sceneGroup = UI.sceneGroup
  local options = {
    frames ={},
     sheetContentWidth = self.imageWidth,
     sheetContentHeight = self.imageHeight
   }
   local widthDiff = options.sheetContentWidth - self.mX/2
   local heightDiff = options.sheetContentHeight - self.mY/2
   --
   for i=1, #self.layerSet do
     local target = self.layerSet[i]
     local _x = (target.x - target.width/2)/4 + widthDiff/2
     local _y = (target.y - target.height/2)/4 + heightDiff/2
     -- print(_x, _y)
     options.frames[i] = {
       x = _x,
       y = _y,
       width = target.width/4,
       height = target.height/4
     }
     -- print(target.width/4, target.height/4)
   end
   local group = display.newGroup()
   local sheet = graphics.newImageSheet(UI.props.imgDir..self.imagePath, UI.props.systemDir, options )
   for i=1, #self.layerSet do
     local target = self.layerSet[i]
     local frame = options.frames[i]
     local frame1 = display.newImageRect( sheet, i, frame.width, frame.height )
     frame1.x, frame1.y = _K.getPosition(target.x, target.y)
     frame1.name = target.myLName
     frame1.oriX              = frame1.x
     frame1.oriY              = frame1.y
     frame1.oriXs             = 1
     frame1.oriYs             = 1
     frame1.oldAlpha          = 1
     frame1.anim              = {}
     target.panel = frame1
     UI.layer[target.myLName] = frame1
     group:insert(frame1)
   end
   --
   UI.layer[self.layerSetName] = group
  --  sceneGroup:insert(layer) necessary?
end

_M.new = function()
	local instance = {}
	return setmetatable(instance, {__index=_M})
end

return _M