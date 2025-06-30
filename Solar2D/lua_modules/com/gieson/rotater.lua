local TouchHandlerObj = require ("TouchHandlerObj")
local tools = require ("Tools")

local retObj = {}

function retObj:newRotater(params)

	local popup = params.popup
	local rotateTarget = params.rotateTarget
	local callback = params.callback

	local rotater = display.newImage(params.image, 0, 0)

	local myStartPos = {x=0, y=0}
	local targetStartPos = {x=0, y=0}

	local dumby = {x=0, y=0}

	rotater.touched = false


	local MATH_PI_180 = math.pi / 180
	local MATH_180_PI = 180 / math.pi

	local function dealWithIt(touchData)
		local x = rotateTarget.parent.x - touchData.x + rotateTarget.x
		local y = rotateTarget.parent.y - touchData.y + rotateTarget.y

		--local degrees = (math.atan2( y, x ) / MATH_PI_180)

		local degrees = (math.atan2(y, x) / MATH_PI_180)

		--[[
		if degrees > 180 then
			degrees = degrees - 180
		end
		--]]

		rotateTarget.rotation = 90 + degrees

		popup:pos(touchData.x, touchData.y)
		popup:text(math.round(degrees))

		rotater.callback (degrees)
	end

	function rotater:onRelease(touchData)
		popup:off()
		self.touched = false
	end

	function rotater:onDown(touchData)
		popup:on(touchData.x, touchData.y)

		dealWithIt(touchData)

		self.touched = true

	end

	function rotater:onMove(touchData)

		if self.touched == false then
			self:onDown(touchData)
		end

		dealWithIt(touchData)

	end

	rotater.callback = params.callback
	rotater.touch = TouchHandlerObj
	rotater:addEventListener( "touch", rotater )

	rotater.x = params.x
	rotater.y = params.y

	return rotater

end

return retObj