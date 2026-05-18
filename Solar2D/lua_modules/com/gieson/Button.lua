---------------------------------------------------------------------------------------
-- Dronebot
-- Mike Gieson (www.gieson.com)
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.
---------------------------------------------------------------------------------------
local current = ...
local parent = current:match("(.-)[^%.]+$")


local TouchHandlerObj = require (parent.."TouchHandlerObj")

local retObj = {}

local fontMetricsComp_y = 3

function retObj:newButton(params)

	local obj = display.newGroup()

	obj.id			= params.id
	obj.callback	= params.callback
	local doStationary 	= params.doStationary or false
	local iconImg	= params.iconImg


	local usingLabel = false
	local setW = params.width or 100
	local setH = params.height or 40
	if params.label ~= nil then
		usingLabel = true
		obj.textKind 	= params.textKind or "embossed" -- "retina" "normal"
		obj.textLabel	= params.label or "Button"
		obj.textSize	= params.textSize or 20
		obj.textFont	= params.textFont or "HelveticaNeue-Bold"
		obj.textColor 	= params.textColor or {0, 0, 0, 255}
		obj.textColorOn = params.textColorOn or {255, 255, 255, 255}

		setH = params.height or obj.textSize * 2
	end

	-- Position the button on the stage.
	obj.x = params.x or 0
	obj.y = params.y or 0

	local usingImages = false
	local bkgdColorUp = params.bkgdColorUp or {255, 255, 255, 255}
	local bkgdColorDown = params.bkgdColorDown or {74, 128, 215, 255}
	-- Create our button states based on images.
	if params.imgUp ~= nil then
		usingImages = true
		obj.up = display.newImage(params.imgUp, 0, 0)
		obj.down = display.newImage(params.imgDown, 0, 0)
	else
		local radius = params.cornerRadius or 5

		-- display.newRoundedRect( [parentGroup,] left, top, width, height, cornerRadius )
		obj.up = display.newRoundedRect(0, 0, setW, setH, radius)
		obj.up:setFillColor(bkgdColorUp[1], bkgdColorUp[2], bkgdColorUp[3], bkgdColorUp[4])
	end
	-- obj.up:setReferencePoint(display.TopLeftReferencePoint)
	obj:insert(obj.up)

	if usingImages then
		obj.down.isVisible = false
		-- obj.down:setReferencePoint(display.TopLeftReferencePoint)
		obj:insert(obj.down)
	end

	if usingImages and iconImg ~= nil then
		obj.icon = display.newImage(iconImg, 0, 0)
		-- obj.icon:setReferencePoint(display.TopLeftReferencePoint)

		obj.icon.x = (obj.up.width/2) - (obj.icon.width/2)
		obj.icon.y = (obj.up.height/2) - (obj.icon.height/2)

		obj:insert(obj.icon)
	end

	if usingLabel == true then

		local Yoffset = 0
		--[[
		if string.find(text, "[gjpqy]") ~= nil then
			Yoffset = 1.15
		end
		--]]

		if obj.textKind == "embossed" then
			-- display.newEmbossedText( [parentGroup,] string, left, top, [width, height,] font, size, [color] )
			obj.label = display.newEmbossedText(obj.textLabel,
											0,
											0,
											obj.textFont, obj.textSize )

			Yoffset = obj.textSize * 0.1

		elseif obj.textKind == "retina" then
			--display.newRetinaText( [parentGroup,] string, left, top, [width, height,] font, size )
			obj.label = display.newRetinaText(obj.textLabel,
											0,
											0,
											obj.textFont, obj.textSize )


		else
			-- display.newText( [parentGroup,] string, left, top, [width, height,] font, size )
			obj.label = display.newText(obj.textLabel,
											0,
											0,
											obj.textFont, obj.textSize )

			Yoffset = obj.textSize * 0.1

		end
		obj.label.align = "center"
		obj.label:setTextColor( obj.textColor[1], obj.textColor[2], obj.textColor[3], obj.textColor[4] )

		-- obj.label:setReferencePoint(display.TopLeftReferencePoint)

		local text = obj.textLabel

		obj.label.x = (obj.up.width / 2) - (obj.label.width / 2)
		--obj.label.y = (obj.up.height / 2) - (obj.textSize / Yoffset) -- + fontMetricsComp_y
		obj.label.y = (obj.up.height / 2) - (obj.label.height / 2) - Yoffset -- + fontMetricsComp_y

		obj:insert(obj.label)
	end

	-- Set main reference point after it's got crap in it.
	-- obj:setReferencePoint(display.TopLeftReferencePoint)


	function obj:setText( theNewText )
		if obj.textKind == "embossed" then
			obj.label:setText(theNewText)
		elseif obj.textKind == "retina" then
			obj.label:setText(theNewText)
		else
			obj.label.text = theNewText
		end

	end
	-- ---------------------------------------------
	-- Touch Handlers
	-- ---------------------------------------------

	local st_timer_start = {}
	local st_timer_run = {}
	local st_timer_start_available = false
	local st_timer_run_available = false
	local st_timer_count = 0
	local st_timer_countMaxMin = 3
	local st_timer_countMax = 2
	local st_timer_countMaxSource = 15

	local function runStationary()
		st_timer_count = st_timer_count + 1
		if st_timer_count > st_timer_countMax then
			st_timer_count = 0
			st_timer_countMax = st_timer_countMax - 1
			if st_timer_countMax < st_timer_countMaxMin then
				st_timer_countMax = st_timer_countMaxMin
			end
			obj:callback(obj.id)
		end
	end

	local function startStationary()
		st_timer_count = 0
		st_timer_countMax = st_timer_countMaxSource
		timer.cancel(st_timer_start)
		st_timer_run = timer.performWithDelay(10, runStationary, 0)
		st_timer_run_available = true
	end

	function obj:onDown( callbackData )
		if usingImages then
			self.down.isVisible = true
			self.up.isVisible = false
		else
			local color = bkgdColorDown
			obj.up:setFillColor(color[1], color[2], color[3], color[4])
		end

		if usingLabel == true then
			obj.label:setTextColor( obj.textColorOn[1], obj.textColorOn[2], obj.textColorOn[3], obj.textColorOn[4] )
		end

		if doStationary == true then
			st_timer_start = timer.performWithDelay(300, startStationary)
			st_timer_start_available = true

		end

	end

	function obj:onRelease(callbackData)

		if usingImages then
			self.up.isVisible = true
			self.down.isVisible = false
		else
			local color = bkgdColorUp
			obj.up:setFillColor(color[1], color[2], color[3], color[4])
		end

		if usingLabel == true then
			obj.label:setTextColor( obj.textColor[1], obj.textColor[2], obj.textColor[3], obj.textColor[4] )
		end


		if doStationary == true then
			if st_timer_start_available == true then
				timer.cancel(st_timer_start)
			end
			if st_timer_run_available == true then
				timer.cancel(st_timer_run)
			end
		end

		-- Tell our dad that we've changed.
		self:callback(self.id)



	end

	function obj:onReleaseOutside( callbackData )
		if usingImages then
			self.up.isVisible = true
			self.down.isVisible = false
		else
			local color = bkgdColorUp
			obj.up:setFillColor(color[1], color[2], color[3], color[4])
		end

		if usingLabel == true then
			obj.label:setTextColor( obj.textColor[1], obj.textColor[2], obj.textColor[3], obj.textColor[4] )
		end

		if doStationary == true then
			timer.cancel(st_timer_start)
			timer.cancel(st_timer_run)
		end

	end



	-- Attach handlers
	obj.touch = TouchHandlerObj
	obj:addEventListener( "touch", obj )

	return obj

end

return retObj
