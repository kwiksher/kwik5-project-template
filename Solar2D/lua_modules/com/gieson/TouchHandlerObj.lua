---------------------------------------------------------------------------------------
-- Dronebot
-- Mike Gieson (www.gieson.com)
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.
---------------------------------------------------------------------------------------


local function handler( self, event )
	
	
	local _phase = event.phase
	
	
	-- ////////////////////////////////////////////////
	
	--           Set up returned data
	
	-- ////////////////////////////////////////////////
	
		-- Data contained in _callbackData:
		-- phase : began
		-- y : 128
		-- x : 154
		-- time : 1136.03
		-- xStart : 154
		-- yStart : 128
		-- name : touch
		
		--[[
		for key, val in pairs(theData) do
			if type(val) ~= "table" and type(val) ~= "userdata" then
				log(key .. " : " .. val)
			end
		end
		--]]
		
		-- NOTE: Additional data is included in _callbackData for each event.
		
	local _callbackData = {}
	_callbackData.target = self
	local _i, _item
	for _i, _item in next, event do
		if type(_item) ~= "table" then
			_callbackData[_i] = _item
		end
	end

	-- ////////////////////////////////////////////////
	
	--           DETECT AND ACT ON EVENT
	
	-- ////////////////////////////////////////////////

	-- Start detecting which kind of event has occured
	
		-- * "began" 		a sausage touched the screen.
		-- * "moved" 		a sausage moved on the screen.
		-- * "stationary" 	a sausage is touching the screen but hasn’t moved from the previous event.
		-- * "ended" 		a sausage was lifted from the screen.
		-- * "cancelled" 	the system cancelled tracking of the touch.
		
	-- ////////////////////////////////////////////////

	--           Events pinged back to caller

	-- ////////////////////////////////////////////////
	-- onClick
	-- onDown
	-- onRelease
	-- onReleaseOutside
	-- onMove
	-- onCancelled
	-- onStationary
	
	-- -----------------------------------------------
	--                   BEGAN
	-- -----------------------------------------------
	if _phase == "began" then
		
		if self.onDown then
			self:onDown( _callbackData )	
		end
		
	
	-- -----------------------------------------------
	--               ENDED OR CANCELLED
	-- -----------------------------------------------
	
	elseif _phase == "ended" then
		
		-- Get the button's (group's) x,y,w,h info
		local _bounds = self.stageBounds
		local _x,_y = event.x,event.y
		
		
		-- See if the "click" is still "on" our button.
		local _isWithinBounds = 	_bounds.xMin <= _x 
								and _bounds.xMax >= _x 
								and _bounds.yMin <= _y 
								and _bounds.yMax >= _y			
	
		if _isWithinBounds then
			 
			
			-- -----------------------------------------------
			--                  CLICK
			-- -----------------------------------------------
			if self.onClick then
				_callbackData.phase = "click"
				self:onClick( _callbackData )
			end
			
			-- -----------------------------------------------
			--                  RELEASE
			-- -----------------------------------------------
			if self.onRelease then
				_callbackData.phase = "release"
				self:onRelease( _callbackData )
			end
			
		else
		
			-- We're out of Bounds
			
			-- -----------------------------------------------
			--                RELEASE OUTSIDE
			-- -----------------------------------------------
			if self.onReleaseOutside then
				_callbackData.phase = "releaseOutside"
				self:onReleaseOutside( _callbackData )
			else
				if self.onRelease then
					_callbackData.phase = "release"
					self:onRelease( _callbackData )
				end
			end
			
		end
		
		-- Resume "normal" clicking behaviour, which we 
		-- might have set during a "move" operation.
		display.getCurrentStage():setFocus( self, nil )
		
		_bounds = nil
		_x = nil
		_y = nil
		_isWithinBounds = nil
	
		
	-- -----------------------------------------------
	--                MOVED
	-- -----------------------------------------------
	elseif _phase == "moved" then

		if self.onMove then
			self:onMove( _callbackData )
		end
		
		-- The following allows the handlers to work even  
		-- if the touch is outside this buttons x,y,w,h 
		-- boundaries (e.g. self.stageBounds)
		-- e.g. onRelease
		
		display.getCurrentStage():setFocus( self, event.id )
		
	-- -----------------------------------------------
	--                CANCELLED
	-- -----------------------------------------------
	elseif _phase == "cancelled" then
		
		if self.onCancelled then
			self:onCancelled( _callbackData )
		end
		
		if self.onRelease then
			_callbackData.phase = "release"
			self:onRelease( _callbackData )
		end
	
	-- -----------------------------------------------
	--                STATIONARY
	-- -----------------------------------------------
	elseif _phase == "stationary" then
		if self.onStationary then
			self:onStationary( _callbackData )
		end
	end
	
	_phase = nil
	_callbackData = nil
	_i = nil
	_item = nil
	
	-- Setting to "true" ensure objects "below" (z-rder) not's get called through the system's bubbling.
	return true
	
end

return handler