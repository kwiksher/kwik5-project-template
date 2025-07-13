local tools = require("Tools")
local retObj = {}

function retObj:new(outerColor, innerColor, smoothness, rolloff_in, ref_in, max_in, model, clamped)
	
	local smoothVal = smoothness or 20
	local exponetialVal = rolloff_in or false
	
	local obj = display.newGroup()
	
	local r = innerColor[1]
	local g = innerColor[2]
	local b = innerColor[3]
	
	local rr = outerColor[1]
	local gg = outerColor[2]
	local bb = outerColor[3]
	
	local radius = 100
	
	
	local function getRadius(inc)
		
		
		-- CLAMP FORMULA
		-- distance = max(distance,AL_REFERENCE_DISTANCE);
		-- distance = min(distance,AL_MAX_DISTANCE)
		
		--local distance = math.min( math.max( 1, ref ), max)
		
		
		if model == "INVERSE_DISTANCE" then
		
			----------------------------------------------
			-- INVERSE_DISTANCE
			----------------------------------------------
		
			-- Formula:
			--			ref / (ref + rolloff * (distance - ref))
			--			distance = math.min( math.max( 1, ref ), max)
		
		
			-- Inversed (Doing the outer band first)
			local _p = (smoothVal - inc) / smoothVal
		
		
			-- Using *2 to fudge a distance. This is a guestimate (based on tiral and error)
			-- for what the actaul reference discance would be, since we don't know what the 
			-- true or default) "max" distance is. AL_MAX_DISTANCE is only used to clamp, 
			-- and is not used **directly** in any of the calculations.
		
			-- 1 +  so that the outer ring is set to zero gain.
			local distance = 1 + (2 * _p)
		
			if clamped == 1 then
				--[[
				distance = max(distance,AL_REFERENCE_DISTANCE)
				distance = min(distance,AL_MAX_DISTANCE)
				--]]
				
				distance = math.max( distance, 1 )
				distance = math.min( distance, max_in)

			end
		
		
			-- Settign the "ref" to 1, since we are calculating the gain at a 
			-- based reference level. Then applying actual numbers in the return.
		
			-- Had to fudge the rolloff factor (1/rolloff) in order 
			-- to get the visual to go in the proper direction.
			local gain = 1 / (1 + (1/rolloff_in) * (distance - 1))
		
			-- Not sure how to determine if a number is inf, so just doing a string conversion here.
			if gain < 0 or tostring(gain) == "inf" then
				gain = 0
			end
		
			-- Calculating the radius using the old 4pi*r(squared), since the distance we've calculated is a radius.
			local set_radius = (ref_in*2) + ( (distance) * (1/gain) ) 
			local ret = 4 * math.pi * set_radius ^ 2
		
			-- NOTE: The inner ring doesn 't quite line up exactly with the ref_in dimension
			-- (Which is the "myDistRef" in model_top.lua), not sure why, but what we have is good
			-- enough for government work. Uncomment the "SEE EDGES" section below 
			-- to see what I'm talking about. See also the "Beneficial Error Margerine" section for
			-- how this cludge works to our advantage.
		
			-- Head Banger's Delight:
			-- Cirular (Power vs intensity)
			-- local ret =  radius * (smoothVal) * (exponetialVal / (4 * math.pi * (inc/1)) )
		
			return ret
		
		elseif model == "LINEAR_DISTANCE" then
		
			----------------------------------------------
			-- LINEAR_DISTANCE
			----------------------------------------------
		
			-- Formula:
			-- 		distance = min(distance, AL_MAX_DISTANCE) // avoid negative gain
			-- 		gain = 1 - ( rolloff * (distance - ref) / (max - ref) )
			-- Bug? (bugs)
			-- 		- Rolloff doesn't seem to have any audible affect.
			--		- The "formula" above doesn't seem to reflect what's actually happening. 
			--		  Through trial and error, I came up with a "fudge" chuck of code that 
			--		  seems to reflect what's actaully happening.
			
			-- Inversed (Doing the outer band first)
			local _p = (smoothVal - inc) / smoothVal
			local tack = ref_in * (1-_p) * 100
			local ret = max_in * _p * 100 + tack
			
			return ret
			
		elseif model == "EXPONENT_DISTANCE" then
			----------------------------------------------
			-- EXPONENT_DISTANCE
			----------------------------------------------
		
			-- Formula:
			-- 		gain = (distance / ref) ^ (- rolloff)
			
			
			-- Inversed (Doing the outer band first)
			local _p = (smoothVal - inc) / smoothVal
			
			-- Percent (_p) becomes our AL_REFERENCE_DISTANCE 
			-- and 1 is our "default" distance of 1.
			-- So it's as if we're constantly changing our 
			-- reference distance, so we can see what the gain 
			-- will be at that particular reference distance. 
			-- So we need to keep the "distance" as a default of 1, 
			-- and change the reference distance.
			local gain = ( (1/_p) ^ (-rolloff_in) )
			
			-- "3 * _p" to fudge our outer boundary relative to 
			-- our reference (one is always our reference to derive a 
			-- basic "any point" model)
			local distance = ref_in + ( 3 * _p * gain )
			
			
			if clamped == 1 then
				
				--[[
				distance = max(distance,AL_REFERENCE_DISTANCE)
				distance = min(distance,AL_MAX_DISTANCE)
				--]]
				
				distance = math.max( distance, ref_in )
				distance = math.min( distance, max_in )
			end
			
			local ret = distance * 100
			
			--[[
			print("clamped: " .. clamped)
			print("distance: " .. distance)
			print("gain: " .. gain)
			print("ret: " .. ret)
			print("-------------")
			--]]
			
			
			return ret
		
		else
			----------------------------------------------
			-- NONE
			----------------------------------------------

			return 1000
		end
		
	end
	
	
	
	
	local i
	for i = 0, smoothVal  do
		
		radius = getRadius(i)

		local percent = i/smoothVal
		local amt = (1.0 - percent )

		local myRed  = amt * rr + percent * r
		local myGreen =  amt * gg + percent * g
		local myBlue = amt * bb + percent * b

		local newRect = display.newCircle(0,0,radius)
		newRect:setFillColor(myRed,myGreen,myBlue,255)

		obj:insert(newRect)

		--[[---------------------------------
		-- SEE EDGES
		-------------------------------------
		-- Used to see the inner and outer boundaries more clearly
		
		if i == 0 then
			newRect:setFillColor(255,255,100,255)
		elseif i == smoothVal then
			newRect:setFillColor(100,255,255,255)
		end
		--]]

			
	end
	
	
	-----------------------------------
	-- Beneficial Error Margerine
	-----------------------------------
	-- There seems to be a rapid gain as you approach AL_REF_DISTANCE
	-- So indicate that here. Plus there's a little fudge difference between
	-- the calcualations for the final inner circle to the AL_REF_DISTANCE.
	-- We can use this fudge-factor to our advantage :)

	if model == "INVERSE_DISTANCE" then
		
		-- Difference between AL_REF_DISTANCE and the 
		-- inner dimensions of the rendered gradient.
		
		-- /4 since we're starting the loop at 0 (as opposed t the normal 1)
		local dif = ( radius - ((ref_in*2) * 50) ) / 4
		
		-- Color difference between inner gradient and our new overlay max color (more white).
		-- /4 since we're starting the loop at 0 (as opposed t the normal 1)
		local c_dif = (230 - r) / 4
		
		for i=0, 3 do
		
			-- Start with the outer circle first, then work inward.
			local r_dif = radius - (dif * i)
			local newRect = display.newCircle(0,0,r_dif)
			
			-- Increase the color
			local inc = (c_dif * (i+1))
			local rr = r + inc
			local gg = g + inc
			local bb = b + inc
			
			newRect:setFillColor(rr,gg,bb,255)
			obj:insert(newRect)
		end
		
	end
	
	function obj:destroy()
		if obj.numChildren then
			-- we have a group, so first clean that out
			while obj.numChildren > 0 do
				-- clean out the last member of the group (work from the top down!)
				obj[obj.numChildren]:removeSelf()
			end
	    end
	end
	
	return obj
end


return retObj