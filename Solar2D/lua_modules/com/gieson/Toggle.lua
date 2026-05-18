---------------------------------------------------------------------------------------
-- Dronebot
-- Mike Gieson (www.gieson.com)
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.
---------------------------------------------------------------------------------------

-- Toggle.lua 


local retObj = {}

local TouchHandlerObj = require ("TouchHandlerObj")

function retObj:newToggle(params)
	
	-- Container
	local obj = display.newGroup()
	
	obj.id 				= params.id
	obj.callback 		= params.callback
	
	local starupState 	= params.starupState or 0
	local f_bkgdOff		= params.bkgdOff
	local f_bkgdOn		= params.bkgdOn
	local f_icon		= params.icon
	local f_label		= params.label
	obj.textKind 		= params.textKind or "normal" -- "embossed" "retina"
	obj.textLabel		= params.label or "Toggle"
	obj.textSize		= params.textSize or 20
	obj.textFont		= params.textFont or "HelveticaNeue-Bold"
	obj.textColor 		= params.textColor or {0, 0, 0, 255}
	obj.textColorOn 	= params.textColorOn or {255, 255, 255, 255}
	
	local bkgdColorUp 	= params.bkgdColorUp or {255, 255, 255, 255}
	local bkgdColorDown = params.bkgdColorDown or {74, 128, 215, 255}
	
	local labelColor 	= params.labelColor or {255, 255, 255, 255}
	local labelColorOn 	= params.labelColorOn or labelColor
	
	local setW 			= params.width or 100
	local setH 			= params.height or 40
	
	if f_bkgdOff == nil then
		local radius = params.cornerRadius or 5
		
		-- display.newRoundedRect( [parentGroup,] left, top, width, height, cornerRadius )
		f_bkgdOff = display.newRoundedRect(0, 0, setW, setH, radius)
		f_bkgdOff:setFillColor(bkgdColorUp[1], bkgdColorUp[2], bkgdColorUp[3], bkgdColorUp[4])
		
		f_bkgdOn = display.newRoundedRect(0, 0, setW, setH, radius)
		f_bkgdOn:setFillColor(bkgdColorDown[1], bkgdColorDown[2], bkgdColorDown[3], bkgdColorDown[4])
		
		obj.bkgdOn = f_bkgdOn
		obj.bkgdOff = f_bkgdOff
	else
		
		obj.bkgdOn = display.newImage(f_bkgdOn, 0, 0)
		obj.bkgdOff = display.newImage(f_bkgdOff, 0, 0)
	end
	
	
	-- The state 1 = on, 0 = off
	obj.state = 0
	
	-- ////////////////////////////////////////////////

	--                SET UP

	-- ////////////////////////////////////////////////
	
	-- Show the first image

	obj.bkgdOff:setReferencePoint(display.TopLeftReferencePoint)
	obj.bkgdOn:setReferencePoint(display.TopLeftReferencePoint)
	
	local baseW = obj.bkgdOff.width
	local baseH = obj.bkgdOff.height
	
	obj:insert(obj.bkgdOff)
	obj:insert(obj.bkgdOn)
	
	if f_icon then
		obj.icon = display.newImage(f_icon, 0, 0)
		obj.icon:setReferencePoint(display.TopLeftReferencePoint)
		
		obj.icon.x = (obj.bkgdOff.width/2) - (obj.icon.width/2)
		obj.icon.y = (obj.bkgdOff.height/2) - (obj.icon.height/2)
		
		obj:insert(obj.icon)
	end
	
	local label
	if f_label then
		
		local Yoffset = 0
		
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

		obj.label:setReferencePoint(display.TopLeftReferencePoint)
		
		local text = obj.textLabel
		
		--[[
		if string.find(text, "[gjpqy]") ~= nil then
			Yoffset = 1.15
		end
		--]]
		obj.label.x = (obj.bkgdOn.width / 2) - (obj.label.width / 2)
		--obj.label.y = (obj.bkgdOn.height / 2) - (obj.textSize / Yoffset) -- + fontMetricsComp_y
		obj.label.y = (obj.bkgdOn.height / 2) - (obj.label.height / 2) - Yoffset -- + fontMetricsComp_y
		
		obj:insert(obj.label)
	end

	obj:setReferencePoint(display.TopLeftReferencePoint)

	-- Position the button on the stage.
	obj.x = params.x
	obj.y = params.y
	
	function obj:setState(theState, isSoft)
		if theState == 1 then
			self.bkgdOff.isVisible = false
			self.bkgdOn.isVisible = true
			if f_label then
				obj.label:setTextColor( obj.textColorOn[1], obj.textColorOn[2], obj.textColorOn[3], obj.textColorOn[4] )
			end
		else
			self.bkgdOff.isVisible = true
			self.bkgdOn.isVisible = false
			if f_label then
				obj.label:setTextColor( obj.textColor[1], obj.textColor[2], obj.textColor[3], obj.textColor[4] )
			end
		end
		
		self.state = theState
		
		-- Tell our dad that we've changed.
		if isSoft ~= true then
			isSoft = false
			self:callback(self.id, theState, isSoft)
		end
	end
	
	function obj:setLabel(theText)
		label:setText(theText)
	end
	
	function obj:onRelease(callbackData)
		
		if self.state == 0 then
			self.state = 1
		else
			self.state = 0
		end
		
		self:setState(self.state)
		
	end


	-- Attach handlers
	obj.touch = TouchHandlerObj
	obj:addEventListener( "touch", obj )
	
	-- Set startup state:
	obj:setState(starupState, true)
	
	-- Return our object so it can be interacted with.
	return obj
	
	
end

return retObj
