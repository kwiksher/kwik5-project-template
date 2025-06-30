---------------------------------------------------------------------------------------
-- Dronebot
-- Mike Gieson (www.gieson.com)
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.
---------------------------------------------------------------------------------------


--math.randomseed(os.time())
math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )


local floor = math.floor
local abs = math.abs
local rand = math.random
local round = math.round

-- Clear out the un-random-ness
rand()
rand()
rand()

-- //////////////////////////////////////
-- 
--          Useful Blocks
-- 
-- //////////////////////////////////////
--[[

-- Object:
for k, v in pairs(val) do
	if type(v) ~= "table" and type(v) ~= "function" and type(v) ~= "userdata" then
		print(k .. " : " .. v)
	end
end
print("--------------------------------")

-- Array:
local Atemp = _apl
for k=1 in ipairs(Atemp) do
	local v = Atemp[k]
	if type(v) ~= "table" and type(v) ~= "function" and type(v) ~= "userdata" then
		print(k .. " : " .. v)
	end
end
print("--------------------------------")
--]]


-- //////////////////////////////////////
-- 
--          Tools
-- 
-- //////////////////////////////////////
local retObj = {}

function retObj:cleanString(theString)
	local pattern = "[^-a-zA-Z0-9()_ !@&*+=?,.<>/]"
	return string.gsub( theString, pattern, "" )
end

function retObj:log(theString)
	--print(theString)
	return true
end

function retObj:concat(t1, t2)
	local k, v
	for k,v in ipairs(t2) do 
		table.insert(t1, v) 
	end
	k = nil
	v = nil
	return t1 
end

function retObj:splice(t,i,len, replaceWith)
	if (len > 0) then
		local r
		for r=0, len do
			if(r < len) then
				table.remove(t,i + r)
			end
		end
		r = nil
	end
	if(replaceWith) then
		table.insert(t,i,replaceWith)
	end
	local count = 1
	local tempT = {}
	local i
	for i=1, #t do
		if t[i] then
			tempT[count] = t[i]
			count = count + 1
		end
	end
	i = nil
	count = nil
	return tempT
end

function retObj:sizeof(theObject)
	local count = 0
	local key, val
	for key, val in pairs(theObject) do
		count = count + 1
	end
	key = nil
	val = nil
	return count
end

function retObj:indexOf(theStringOrArray, theValue)
	local myIndex = 0
	if type(theStringOrArray) == "string" then
		myIndex = string.find (theStringOrArray, theValue, 1, false)
		if not myIndex then
			myIndex = 0
		end
	else
		local i
		for i=1, #theStringOrArray do
			if(theStringOrArray[i] == theValue) then
				myIndex = i
			end
		end
		i = nil
	end
	return myIndex
end

function retObj:inArray(theHaystack, theNeedle)
	if(retObj:indexOf(theHaystack, theNeedle) > 0) then
		return true
	else
		return false
	end
end


function retObj:indexOfArray(theArray, theValue)
	local myIndex = 0
	local i, val
	for i, val in ipairs(theArray) do
		if(val == theValue) then
			myIndex = i
			break
		end
	end
	i = nil
	val = nil
	return myIndex
end

function retObj:round(num, decimalPlaces)
	if decimalPlaces and decimalPlaces > 0 then
		local shift = 10 ^ decimalPlaces
		return floor( num*shift + 0.5 ) / shift
	else
		return floor(num+.5)
	end
end


function retObj:getTimestamp()
	return ( os.time() * 1000 ) + round( system.getTimer() )
end

--[[
function retObj:randomNumber(minNum, maxNum, asFloat)
	if asFloat == true or (abs(minNum) <= 1 and abs(maxNum) <= 1) then
		return ( rand(minNum * 100, maxNum * 100) * 0.01 )
	else
		return ( rand(minNum, maxNum) )
	end
end
--]]

-- This just "feels" more natural than using the built in rand()
function retObj:randomNumber(minNum, maxNum, asFloat)
	if asFloat == true or ( abs(minNum) <= 1 and abs(maxNum) <= 1) then
		--minNum = minNum * 100
		--maxNum = maxNum * 100
		return ( minNum + (rand() * (maxNum - minNum)) )
		--return ( ( minNum + floor(rand() * (maxNum - minNum + 1)) )  / 100 )
	else
		return (minNum + floor(rand() * (maxNum - minNum + 1)) )
	end
end

function retObj:getLogVal(power, lo, hi, linearVal)
	
	-- If lo = 0 (or one-ish), then simple formula is:
	-- max *  math.pow(linear / max, power)
	
	local _p
	if linearVal == nil then
		_p = retObj:randomNumber(0.01, 1)
	else
		_p = linearVal / hi
	end
	return lo + ( (hi - lo) *  math.pow(_p, power) )
end

function retObj:reverse(t)
	local tempT = {}
	local count = #t
	local i
	for i=1, #t do
		tempT[i] = t[count]
		count = count - 1
	end
	count = nil
	i = nil
	return tempT
end

function retObj:arrayReverse(theArray)
	local Anew = {}
	local i
	for i = #theArray,1,-1 do
		table.insert(Anew, theArray[i])
    end
	i = nil
	return Anew
end

function retObj:logObj( t,tab,lookup )
	local lookup = lookup or { [t] = 1 }
	local tab = tab or ""
	local i, v
	for i,v in pairs(t) do
		retObj:log	( tab..tostring(i), v )
		if type(i) == "table" and not lookup[i] then
			lookup[i] = 1
			retObj:logObj( i,tab.."\t",lookup )
		end
		if type(v) == "table" and not lookup[v] then
			lookup[v] = 1
			retObj:logObj( v,tab.."\t",lookup )
			--retObj:log ("\n")
		else
			retObj:log (tab.."\t"..tostring(v).."\n")
		end
	end
	i = nil
	v = nil
end


function retObj:printArray( t,tab,lookup )
	local lookup = lookup or { [t] = 1 }
	local tab = tab or ""
	for i,v in ipairs(t) do
		log	( tab..tostring(i), v )
		if type(i) == "table" and not lookup[i] then
			lookup[i] = 1
			retObj:logObj( i,tab.."\t",lookup )
		end
		if type(v) == "table" and not lookup[v] then
			lookup[v] = 1
			retObj:logObj( v,tab.."\t",lookup )
			log ("\n")
		end
	end
	tab = nil
end

local myFont = "HelveticaNeue"
local myFontSize = 16
local myLineHeight = myFontSize + (myFontSize * 0.3)
local myFontColor = {152, 255, 7, 255}
local alertCount = 1
local alertArray = {}

local alertContainer = display.newGroup()
--retval:setReferencePoint(display.TopLeftReferencePoint)
function retObj:alertXY(theX, theY)
	alertContainer.x = theX
	alertContainer.y = theY
end
function retObj:alert(theText, append)

	if not append then
		if #alertArray > 0 then
			local i
			for i = #alertArray, 1, -1 do
				cleanGroup(alertArray[i])
				alertArray[i] = nil
			end
			i = nil
		end
		alertCount = 1
	end
	
	alertArray[alertCount] = display.newText(theText, 0, (alertCount-1)*myLineHeight, myFont, myFontSize )
	alertArray[alertCount]:setTextColor(myFontColor[1], myFontColor[2], myFontColor[3], myFontColor[4])
	
	alertContainer:insert(alertArray[alertCount])
	alertContainer:setReferencePoint(display.TopLeftReferencePoint)

	alertContainer:toFront()
	alertCount = alertCount + 1
end

function retObj:trim (s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- Trig

local MATH_PI_180 = math.pi / 180
local MATH_180_PI = 180 / math.pi

function retObj:radToDeg(rad)
	return rad * MATH_180_PI
end

function retObj:distance(me, it)
	local dx = me.x - it.x
	local dy = me.y - it.y
	return math.sqrt( (dx * dx) + (dy * dy) )
end



function retObj:getAngleInRadians(obj1, obj2)
	-- The source (speaker) needs to be the "1", and listener (person) "2" otherwise, 
	-- the graphics flips out between positive and negative values
	local x1 = obj1.x
	local y1 = obj1.y
	
	local x2 = obj2.x
	local y2 = obj2.y
	
	return math.atan2( (y1 - y2), (x1 - x2) )
end

retObj.MATH_PI_180 = MATH_PI_180
retObj.MATH_180_PI = MATH_180_PI


return retObj

