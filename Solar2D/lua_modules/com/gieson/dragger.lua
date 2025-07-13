local current = ...
local parent = current:match("(.-)[^%.]+$")

local TouchHandlerObj = require (parent.."TouchHandlerObj")
local tools = require (parent.."Tools")


local retObj = {}

function retObj:newDragger(params)

	local popup = params.popup

	local dragger = params.img
	local dragTarget = params.dragTarget or dragger

	local myStartPosX = 0
	local myStartPosY = 0

	local imgStartPosX = 0
	local imgStartPosY = 0

  local editorWidth = params.editorWidth or 0
  local editorHeight = params.editorHeight or 0

	local function doPopup(touchData)
		popup:pos(touchData.x, touchData.y)
		popup:text("x: " .. tools:round(xPosReport-editorWidth, 2) .. "\n" .. "y: " .. tools:round(yPosReport-editorHeight, 2))
	end

	function dragger:onRelease(touchData)
		popup:off(self)
		self.touched = false
	end

	function dragger:onDown(touchData)

		myStartPosX = touchData.x
		myStartPosY = touchData.y

		imgStartPosX = dragTarget.x
		imgStartPosY = dragTarget.y

		xPosReport = imgStartPosX + touchData.x - myStartPosX
		yPosReport = imgStartPosY + touchData.y - myStartPosY

		popup:on(myStartPosX, myStartPosY, true)
		doPopup(touchData)

		self.touched = true

	end

	function dragger:onMove(touchData)

		if self.touched == false then
			self:onDown(touchData)
		end

		xPosReport = imgStartPosX + touchData.x - myStartPosX
		yPosReport = imgStartPosY + touchData.y - myStartPosY
		dragTarget.x = xPosReport
		dragTarget.y = yPosReport

		doPopup(touchData)

		self.callback (xPosReport, yPosReport)

	end

	dragger.callback = params.callback
	dragger.touch = TouchHandlerObj
	dragger:addEventListener( "touch", dragger )


	return dragger

end

return retObj