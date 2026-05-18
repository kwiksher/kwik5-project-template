---------------------------------------------------------------------------------------
-- Slider
-- Mike Gieson (www.gieson.com)
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.
---------------------------------------------------------------------------------------



--///////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////
--
--
-- 				        WARNING WARNING WARNING
-- 		  The Horizontial sid eof things hasn't been fleshed out!!!
--
--
--///////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////

local retObj = {}

local TouchHandlerObj = require ("TouchHandlerObj")
local tools = require("Tools")
-- newSlider( params )
-- where params is a table containing:
--		track			- name of track image
--		thumb	- name of default thumb image
--		thumbOver		- name of thumb over image (optional)
--		minValue		- min value (optional, defaults to 0)
--		maxValue		- max value (optional, defaults to 100)
--		value			- initial value (optional, defaults to minValue)
--		isInteger		- true if integer, false if real (continuous value) (defaults to false)
--		isVertical		- true if vertical; otherwise is horizontal (defaults to horizontal)
--		onPress			- function to call when slider is pressed
--		onRelease		- function to call when slider is released
--		onEvent			- function to call when an event occurs
--
function retObj:newSlider( params )

	local _Mf = math.floor

	local slider = display.newGroup()

	slider.popup 		= params.popup

	slider.id 			= params.id
	slider.f_value		= params.f_value
	slider.maxValue 	= params.value_max
	slider.minValue 	= params.value_min
	slider.value 		= params.value
	slider.totalRange 	= slider.maxValue - slider.minValue

	slider.w 			= params.width or 0
	slider.h 			= params.height or 0




	local useValueFunction = false
	if slider.f_value ~= nil then
		useValueFunction = true
	end

	local thumb = {}

	local track_center = {}
	local track_A = {}
	local track_B = {}
	local track = display.newGroup()

	if slider.w > slider.h then
		slider.isVertical = false

		thumb = display.newImage( "assets/images/slider_handle_h.png", 0, 0 )

		track_center 	= display.newImage( "assets/images/slider_track_h.png", 0, 0 )
		track_A 		= display.newImage( "assets/images/slider_track_h_left.png", 0, 0 )
		track_B 		= display.newImage( "assets/images/slider_track_h_right.png", 0, 0 )

		track_center:setReferencePoint(display.TopLeftReferencePoint)
		track_A:setReferencePoint(display.TopLeftReferencePoint)
		track_B:setReferencePoint(display.TopLeftReferencePoint)

		local setW 			= slider.w - track_A.width - track_B.width

		track_center.xScale = setW / track_center.width
		track_center.x 		= track_A.width

		track_B.x 			= track_A.width + setW

		track:insert(track_center)
		track:insert(track_A)
		track:insert(track_B)

		track:setReferencePoint(display.TopLeftReferencePoint)
		thumb:setReferencePoint(display.TopLeftReferencePoint)

		thumb.y = track.y + (track.height/2) - (thumb.height/2)

	else
		slider.isVertical = true

		thumb = display.newImage( "assets/images/slider_handle_v.png", 0, 0 )

		track_center = display.newImage( "assets/images/slider_track_v.png", 0, 0 )
		track_A = display.newImage( "assets/images/slider_track_v_top.png", 0, 0 )
		track_B = display.newImage( "assets/images/slider_track_v_bot.png", 0, 0 )

		track_center:setReferencePoint(display.TopLeftReferencePoint)
		track_A:setReferencePoint(display.TopLeftReferencePoint)
		track_B:setReferencePoint(display.TopLeftReferencePoint)

		local setH 			= slider.h - track_A.height - track_B.height

		track_center.yScale = setH / track_center.height
		track_center.y 		= track_A.height

		track_B.y 			= track_A.height + setH

		track:insert(track_center)
		track:insert(track_A)
		track:insert(track_B)

		track:setReferencePoint(display.TopLeftReferencePoint)
		thumb:setReferencePoint(display.TopLeftReferencePoint)

		local base = track.x + (track.width/2)
		thumb.x = _Mf( base - (thumb.width/2) )
	end



	slider.track = track
	slider.thumb = thumb

	slider:insert( track )
	slider:insert( thumb )

	slider:setReferencePoint(display.TopLeftReferencePoint)

	slider.maxX = slider.track.width - (thumb.width)
	slider.maxY = slider.track.height - (thumb.height)

	slider.thumbH = thumb.height
	slider.thumbW = thumb.width

	local thumbMaxLo = 0
	local thumbMaxHi = slider.maxX

	if slider.isVertical == true then
		thumbMaxLo = slider.maxY
		thumbMaxHi = 0
	end

	local myStartPos = 0
	local thumbStartPos = 0


	local usingLabel = false
	if params.label ~= nil then
		usingLabel = true
		slider.textKind 	= params.textKind or "normal" -- "embossed" "retina"
		slider.textLabel	= params.label or "Slider Label Not Set"
		slider.textSize		= params.labelSize or 20
		slider.textFont		= params.labelFont or "HelveticaNeue-Bold"
		slider.textColor 	= params.labelColor or {0, 0, 0, 255}

		slider.label_x 		= params.label_x or "center"
		slider.label_y		= params.label_y or "below"

		if slider.textKind == "embossed" then
			-- display.newEmbossedText( [parentGroup,] string, left, top, [width, height,] font, size, [color] )
			slider.label = display.newEmbossedText(obj.textLabel,
											0,
											0,
											slider.textFont, slider.textSize )
		elseif slider.textKind == "retina" then
			--display.newRetinaText( [parentGroup,] string, left, top, [width, height,] font, size )
			slider.label = display.newRetinaText(obj.textLabel,
											0,
											0,
											slider.textFont, slider.textSize )
		else
			-- display.newText( [parentGroup,] string, left, top, [width, height,] font, size )
			slider.label = display.newText(slider.textLabel,
											0,
											0,
											slider.textFont, slider.textSize )
		end
		slider.label.align = "center"
		slider.label:setTextColor( slider.textColor[1], slider.textColor[2], slider.textColor[3], slider.textColor[4] )

		slider.label:setReferencePoint(display.TopLeftReferencePoint)

		local text = slider.textLabel
		local Yoffset = 1.2
		--[[
		if string.find(text, "[gjpqy]") ~= nil then
			Yoffset = 1.15
		end
		--]]

		if slider.isVertical == true then

		else
			if slider.label_x == "center" then
				slider.label.x = (slider.w / 2) - (slider.label.width / 2)
			else
				slider.label.x = slider.label_x
			end

			if slider.label_y == "below" then
				local bigger = math.max(slider.track.height, slider.thumb.height)
				slider.label.y = bigger
			else
				slider.label.y = slider.label_y
			end


		end

		slider.label:setReferencePoint(display.TopLeftReferencePoint)

		slider:insert(slider.label)

		track:toFront()
		thumb:toFront()
	end

	function slider:setText( theNewText )
		if slider.textKind == "embossed" then
			slider.label:setText(theNewText)
		elseif slider.textKind == "retina" then
			slider.label:setText(theNewText)
		else
			slider.label.text = theNewText
		end

		slider.label:setReferencePoint(display.TopLeftReferencePoint)

		-- Re position
		if slider.label_x == "center" then
			slider.label.x = (slider.w / 2) - (slider.label.width / 2)
		else
			slider.label.x = slider.label_x
		end

		if slider.label_y == "below" then
			local bigger = math.max(slider.track.height, slider.thumb.height)
			slider.label.y = bigger
		else
			slider.label.y = slider.label_y
		end

	end

	----------------- Touch Stuff. No really, you should touch stuff, it is an amazing sense we've been given.

	slider.touched = false

	function slider:onRelease(touchData)
		self.popup:off()
		self.touched = false
	end

	function slider:onDown(touchData)
		self.popup:on(touchData.x, touchData.y)

		if slider.isVertical == true then
			myStartPos = touchData.y
			thumbStartPos = self.thumb.y
		else
			myStartPos = touchData.x
			thumbStartPos = self.thumb.x
		end

		local displayVal = tools:round(self.value, 2)

		if usingLabel == true then
			self:setText(self.textLabel .. " : " .. displayVal)
		end

		self.popup:text(displayVal)

		self.touched = true

	end


	function slider:onMove(touchData)

		if self.touched == false then
			self:onDown(touchData)
		end

		-- find new position of thumb
		local _newPos = 0

		if slider.isVertical == true then
			_newPos = thumbStartPos + touchData.y - myStartPos
		else
			_newPos = thumbStartPos + touchData.x - myStartPos
		end

		if _newPos < thumbMaxLo then
			_newPos = thumbMaxLo
		end

		if _newPos > thumbMaxHi then
			_newPos = thumbMaxHi
		end

		local _totalRange = self.totalRange
		local _val = self.value
		local _p = 0

		if _newPos >= thumbMaxLo and _newPos <= thumbMaxHi then

			if slider.isVertical == true then
				self.thumb.y = _newPos
				_p = _newPos / self.maxY
			else
				self.thumb.x = _newPos
				_p = 1 - (_newPos / self.maxX)
			end

			_val = self.minValue + _totalRange - (_p * _totalRange)

			if useValueFunction == true then
				-- Sends: (lo, hi, theVal, percent, backwardation)
				_val = self.f_value(self.minValue, self.maxValue, _val, _p, false)
			end

		end

		self.value = _val

		self.popup:pos(touchData.x, touchData.y)
		local displayVal = tools:round(_val, 2)
		if usingLabel == true then
			self:setText(self.textLabel .. " : " .. displayVal)
		end
		self.popup:text(displayVal)

		self.callback (self.id, _val, _p)

	end


	function slider:setValue(theVal)

		local newVal = theVal


		if useValueFunction == true then

			-- Backward-ize for proper Y val (last argument is "true"),
			-- which causes the handler to deal with it.
			-- Sends: (lo, hi, theVal, percent, backwardation)
			local _p = 0
			if slider.isVertical == true then
				_p = (newVal - self.minValue ) / self.totalRange
			else
				_p = 1 - ((newVal - self.minValue ) / self.totalRange)
			end
			newVal = self.f_value(self.minValue, self.maxValue, newVal,  _p, true)
		end

		if newVal < self.minValue then
			newVal = self.minValue
		end

		if newVal > self.maxValue then
			newVal = self.maxValue
		end

		self.value = newVal

		if slider.isVertical == true then
			self.thumb.y = ( ( ( newVal - self.totalRange - self.minValue) * -1 ) / self.totalRange ) * self.maxY
		else
			self.thumb.x = ( 1 - ( ( newVal - self.totalRange - self.minValue) * -1 ) / self.totalRange ) * self.maxX
		end

		local displayVal = tools:round(newVal, 2)
		if usingLabel == true then
			self:setText(self.textLabel .. " : " .. displayVal)
		end


	end

	slider:setValue(params.value)

	slider.callback = params.callback
	slider.touch = TouchHandlerObj
	slider:addEventListener( "touch", slider )

	slider.x = params.x
	slider.y = params.y


	return slider
end

return retObj
