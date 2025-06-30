local current = ...
local parent,  root = newModule(current)

local TouchHandlerObj = require ("com.gieson.TouchHandlerObj")
local tools = require ("com.gieson.Tools")


local retObj = {}

function retObj:newDragger(params)

	local popup = params.popup

	local dragger = params.img
	local dragTarget = params.dragTarget or dragger

	local myStartPosX = 0
	local myStartPosY = 0

	local imgStartPosX = 0
	local imgStartPosY = 0

	local function doPopup(touchData)
		popup:pos(touchData.x, touchData.y)
		popup:text(string.format("xMin: %d xMax: %d \n yMin: %d yMax: %d",
    tools:round(dragTarget.contentBounds.xMin, 2),
    tools:round(dragTarget.contentBounds.xMax, 2),
    tools:round(dragTarget.contentBounds.yMin, 2),
    tools:round(dragTarget.contentBounds.yMax, 2)))
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

		self.callback (dragTarget.contentBounds.xMin, dragTarget.contentBound.xMax, dragTarget.contentBound.yMin, dragTarget.contentBound.yMax)

	end

	dragger.callback = params.callback
	dragger.touch = TouchHandlerObj
	dragger:addEventListener( "touch", dragger )


	return dragger

end

return retObj