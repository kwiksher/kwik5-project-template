--version 1.1 modified by Alex (adding rotation angle) Apr. 14, 2012
--version 1.2 modified by Alex (adding newAngle parameter to adjust objects from right to left) Set. 4, 2013
module(..., package.seeall)

local gtween = require("gtween")

local function copyTableTo(t1, t2)
  for k,v in pairs(t1) do
    t2[k] = v
  end
  return t2
end

local function copyTable(t)
  local t2 = {}
  return copyTableTo(t, t2)
end

function new(target, duration, values, extraValues,_option)
	-- these three arguments are absolutely required
	if not target or not duration or not values then
		--error("btween.new() requires target, duration, and values arguments.")
		return
	end

	local option
	-- the _option table may be nil
	if _option then
		option = copyTable(_option)
	else
		option = {}
	end
	option.pathCurves = values

	local overrideRotation = false
	local newAngle = 180

	--similarly the extraValues table may be nil
	if extraValues then
		-- the whole point of this class is to change x and y on a bezier curve
		-- so x and y cannot be placed in extraValues. get rid of them to avoid
		-- conflict.
		extraValues.x = nil
		extraValues.y = nil

		-- optional newAngle adjustment for objects coming from right to left
		if extraValues.newAngle ~= nil then
		   newAngle = extraValues.newAngle --~= nil
	    end

		overrideRotation = extraValues.rotation ~= nil
	else
		-- it's okay, we can tween nothing. the real magic happens in onChange.
		extraValues = {}
	end

	local oldOnInit = option.onInit
	local oldOnChange = option.onChange

	option.onInit = function(tween)
		local p1 = tween.pathCurves[1]
		tween.prevX = p1.x
		tween.prevY = p1.y
    print("onInit", p1.x, p1.y)
		if oldOnInit then
			oldOnInit(tween)
		end
	end

  -- for k, v in pairs(extraValues) do print(k, v) end

	option.onChange = function(tween)
		if not tween.prevX then
			return
		end

		local pathCurves = tween.pathCurves

		local sectionCount = math.floor(#pathCurves / 4)
		local sectionRatio = (1 / sectionCount)
		local sectionIndex = math.min(sectionCount - 1, math.floor(sectionCount * tween.ratio))

		--some easing functions go negative or larger than 1, but we don't
		--support that
		local adjustedRatio = math.max(math.min(tween.ratio, 1), 0)
		local t = (tween.ratio % sectionRatio) / sectionRatio
		local t1 = 1 - t

		local t1_3 = t1*t1*t1
		local t1_3a = (3*t)*(t1*t1)
		local t1_3b = (3*(t*t))*t1
		local t1_3c = (t * t * t )

		local startIndex = sectionIndex * 4
		local p1 = pathCurves[startIndex + 1] -- start point
		local p2 = pathCurves[startIndex + 2] -- start control point
		local p3 = pathCurves[startIndex + 3] -- end control point
		local p4 = pathCurves[startIndex + 4] -- end point

		local 	x = t1_3  * p1.x
		x = 	x + t1_3a * p2.x
		x = 	x + t1_3b * p3.x
		x =		x + t1_3c * p4.x

		local 	y = t1_3  * p1.y
		y = 	y + t1_3a * p2.y
		y = 	y + t1_3b * p3.y
		y =		y + t1_3c * p4.y

		target.x = x
		target.y = y

    -- print(target.x, target.y)

		if not overrideRotation then
			local angle = math.atan2( target.y - tween.prevY, target.x - tween.prevX)
			angle = angle * newAngle / math.pi --angle * 180 / math.pi
			local modAng = 0
			if (values.angle ~= nil) then modAng = values.angle end
			target.rotation = angle - modAng
		end

		tween.prevX = target.x
		tween.prevY = target.y

		if oldOnChange then
			oldOnChange(tween)
		end
	end

	return gtween.new(target, duration, extraValues, option)
end