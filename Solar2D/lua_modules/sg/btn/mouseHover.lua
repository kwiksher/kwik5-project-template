local Library = require "CoronaLibrary"


-- Create library
local mouseHover = Library:new{ name='mouseHover', publisherId='sg.btn' }

-------------------------------------------------------------------------------
-- BEGIN (Insert your implementation starting here)
-------------------------------------------------------------------------------
mouseHover.subModules = {} -- a table to store the full path of submodules

local pluginName = "mouseHover"

local pluginPath = "sg.btn."..pluginName

local mouseHoverStage

local activated = false -- a boolean to check activated
--- redefining the require global here

local oldRequire = require

require = function(relativePath, mode) -- mode can be "plugin" to indicate that it's a plugin require request or nothing to indicate that it's the old require

	local fullPath = relativePath

	if mode == "relative" then
		fullPath = pluginPath.."."..relativePath
		table.insert(mouseHover.subModules, fullPath) -- only remove the relative paths
	end

  -- print(fullPath)
	local returnValue = oldRequire(fullPath)

	return returnValue
end


--- REQUIRE ALL SUB-MODULES HERE

require("newPolygon","relative")


require = oldRequire --- resetting the global require function once all the necessary sub-modules have been loaded

oldRequire = nil

-- END OF REQUIRING ALL SUBMODULES


--- PRIVATE EVENTS START HERE

local function dispatchHoverEvent(object,hoverPhase,xLoc,yLoc)

	local event = { name="mouseHover", target=object ,phase=hoverPhase, x = xLoc, y = yLoc}

	local returnValue = object:dispatchEvent( event )
	--print(returnValue, object.name)

	return returnValue

end


local function getPathCenter(points)

	local xMin,yMix,xMax,yMax,xC,yC

	xMin = display.contentWidth ;xMax = 0;yMin=display.contentHeight;yMax = 0


	for i = 1,#points do
		xMin = math.min(xMin,points[i].x)
		xMax = math.max(xMax,points[i].x)

		yMin = math.min(yMin,points[i].y)
		yMax = math.max(yMax,points[i].y)

	end

	xC = (xMin + xMax)*0.5
	yC = (yMin + yMax)*0.5

	return xC,yC

end



local function verticesToPolygon(vertices)

    local arrayLength = #vertices -- x and y for each point
    local polygonArray = {}
    for i = 1, arrayLength-1, 2 do

        local point = {}
        point.x = vertices[i]
        point.y = vertices[i+1]

        table.insert(polygonArray,point)

    end

    local xC, yC = getPathCenter(polygonArray)

    --print("centroid",xC,yC)

    for j = 1, #polygonArray do
    	polygonArray[j].x = polygonArray[j].x - xC
    	polygonArray[j].y = polygonArray[j].y - yC
    end

    return polygonArray
end


local getRotatedPoint = function(point, angle)
	angle = math.rad(angle)
	local xOrig = point.x
	local yOrig = point.y
	point.x = yOrig*math.sin(angle) + xOrig*math.cos( angle )
	point.y = yOrig*math.cos( angle ) - xOrig*math.sin(angle)

	return point

end


local function insidePolygon(polyObject, point) -- vertices is an array of vertices as corona uses it, point is a {x=X, y=Y} kinda thing

    local polygon = verticesToPolygon(polyObject.vertices or {}) -- gives an array of .x and .y points
    local xPos,yPos = polyObject.parent:localToContent(polyObject.x,polyObject.y)
    point.x = point.x-xPos
    point.y = point.y-yPos

    local xDelta = (0.5 - polyObject.anchorX)*polyObject.width*polyObject.xScale
	local yDelta = (0.5 - polyObject.anchorY)*polyObject.height*polyObject.yScale

    point = getRotatedPoint(point,polyObject.rotation)

    point.x = (point.x-xDelta)/polyObject.xScale
	point.y = (point.y-yDelta)/polyObject.yScale

    local oddNodes = false
    local j = #polygon

   -- print(polyObject.x,polyObject.y)
    --print(point.x,point.y)

    for i = 1, #polygon do
        if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
            if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
                oddNodes = not oddNodes;
            end
        end
        j = i;
    end



    return oddNodes


end


local function insideRect(rectObject,point)

	local xPos,yPos = rectObject.parent:localToContent(rectObject.x,rectObject.y)
    point.x = point.x-xPos
    point.y = point.y-yPos

    point = getRotatedPoint(point,rectObject.rotation)

    point.x = point.x + xPos
    point.y = point.y + yPos

    local bounds = {}
    if rectObject.strokeWidth then
      bounds.xMax = xPos + rectObject.strokeWidth*(1-rectObject.anchorX)*rectObject.xScale
      bounds.yMax = yPos + rectObject.height*(1-rectObject.anchorY)*rectObject.yScale
      bounds.xMin = xPos - rectObject.strokeWidth*rectObject.anchorX*rectObject.xScale
      bounds.yMin = yPos - rectObject.height*rectObject.anchorY*rectObject.yScale
    else
      return false
    end

	local thisWithinBounds = false

	if point.x and point.y and point.x < bounds.xMax and point.x > bounds.xMin and point.y > bounds.yMin and point.y <bounds.yMax then

		thisWithinBounds = true
	end

	return thisWithinBounds

end


local function insideCircle(circObject,point)

	local xPos,yPos = circObject.parent:localToContent(circObject.x,circObject.y)

	local rad = circObject.path.radius

		-- recacl center based on anchor
	local angle = circObject.rotation
	angle = math.rad(angle)

	local xDelta = (0.5 - circObject.anchorX)*rad*2*circObject.xScale
	local yDelta = (0.5 - circObject.anchorY)*rad*2*circObject.yScale

	point.x = (point.x-xPos)
	point.y = (point.y-yPos)

	point = getRotatedPoint(point,circObject.rotation)

	point.x = (point.x-xDelta)/circObject.xScale
	point.y = (point.y-yDelta)/circObject.yScale


	local thisWithinBounds = false

 	local dist = math.sqrt((point.x)*(point.x) + (point.y)*(point.y))


	if dist <= circObject.path.radius then
		thisWithinBounds = true
	end

	return thisWithinBounds

end



local function insideRoundedRect(rRectObject,point)

	local thisWithinBounds = false
	local withinRect = false


	local xPos,yPos = rRectObject.parent:localToContent(rRectObject.x,rRectObject.y)

    point.x = point.x-xPos
    point.y = point.y-yPos

    point = getRotatedPoint(point,rRectObject.rotation)

    point.x = point.x + xPos
    point.y = point.y + yPos


    local bounds = {}
    bounds.xMax = xPos + rRectObject.width*(1-rRectObject.anchorX)*rRectObject.xScale
    bounds.yMax = yPos + rRectObject.height*(1-rRectObject.anchorY)*rRectObject.yScale
    bounds.xMin = xPos - rRectObject.width*rRectObject.anchorX*rRectObject.xScale
    bounds.yMin = yPos - rRectObject.height*rRectObject.anchorY*rRectObject.yScale


	if point.x < bounds.xMax and point.x > bounds.xMin and point.y > bounds.yMin and point.y <bounds.yMax then

		withinRect = true
		thisWithinBounds = true
	end



	if withinRect then

		if bounds.xMax - point.x < rRectObject.path.radius and bounds.yMax - point.y < rRectObject.path.radius then
			thisWithinBounds = false

			local radX, radY = bounds.xMax - rRectObject.path.radius, bounds.yMax - rRectObject.path.radius

			local dist = math.sqrt((point.x-radX)*(point.x-radX) + (point.y-radY)*(point.y-radY))

			if dist < rRectObject.path.radius then
				thisWithinBounds = true
			end

		end

		if point.x - bounds.xMin < rRectObject.path.radius and  point.y - bounds.yMin < rRectObject.path.radius then
			thisWithinBounds = false

			local radX, radY = bounds.xMin + rRectObject.path.radius, bounds.yMin + rRectObject.path.radius

			local dist = math.sqrt((point.x-radX)*(point.x-radX) + (point.y-radY)*(point.y-radY))

			if dist < rRectObject.path.radius then
				thisWithinBounds = true
			end
		end

		if bounds.xMax - point.x < rRectObject.path.radius and point.y - bounds.yMin < rRectObject.path.radius then
			thisWithinBounds = false

			local radX, radY = bounds.xMax - rRectObject.path.radius, bounds.yMin + rRectObject.path.radius

			local dist = math.sqrt((point.x-radX)*(point.x-radX) + (point.y-radY)*(point.y-radY))

			if dist < rRectObject.path.radius then
				thisWithinBounds = true
			end

		end

		if point.x - bounds.xMin < rRectObject.path.radius and  bounds.yMax - point.y < rRectObject.path.radius then
			thisWithinBounds = false

			local radX, radY = bounds.xMin + rRectObject.path.radius, bounds.yMax - rRectObject.path.radius

			local dist = math.sqrt((point.x-radX)*(point.x-radX) + (point.y-radY)*(point.y-radY))

			if dist < rRectObject.path.radius then
				thisWithinBounds = true
			end
		end

	end


	return thisWithinBounds
end











local isWithinObject = function(object,xLoc,yLoc)

	local bounds = object.contentBounds --- bounds get updated based on scale so not fix needed here

	local withinBounds = false

	if xLoc < bounds.xMax and xLoc > bounds.xMin and yLoc > bounds.yMin and yLoc <bounds.yMax then

		withinBounds = true
	end



	if not object.numChildren then

		if withinBounds == true then

			withinBounds = false

			if object.path then

				if object.path.type == "polygon" then

					withinBounds = insidePolygon(object,{x=xLoc,y=yLoc})

				elseif object.path.type == "rect" then
					withinBounds = insideRect(object,{x=xLoc,y=yLoc})

				elseif object.path.type == "roundedRect" then
					withinBounds = insideRoundedRect(object,{x=xLoc,y=yLoc})
				elseif object.path.type == "circle" then
					withinBounds = insideCircle(object,{x=xLoc,y=yLoc})

				end
			else
				withinBounds = insideRect(object,{x=xLoc,y=yLoc}) --- using this as a proxy to check within rotation
			end
		end
	end

	return withinBounds

end

local checkHoverBlocked = false

local checkHover

checkHover = function(thisGroup, xLoc,yLoc)

	if thisGroup == mouseHoverStage then
		checkHoverBlocked = false
	end



	for i = thisGroup.numChildren, 1, -1 do -- reverse order so the one's on top get the hover event before the one's on the bottom

		if (thisGroup[i].alpha>0 and thisGroup[i].isVisible == true) or ((thisGroup[i].alpha == 0 or thisGroup[i].isVisible == false) and thisGroup[i].isHoverTestable) then
			if thisGroup[i].numChildren then --- the child is a group

				checkHover(thisGroup[i],xLoc,yLoc)

				if thisGroup[i].anchorChildren == true then -- putting this after the repeat checkHover means the group gets the hover only after the chidlren


					local isWithin = isWithinObject(thisGroup[i],xLoc,yLoc)

					if isWithin == true and thisGroup[i].isHovering == nil then
						if checkHoverBlocked ~= true then
							hoverPhase = "began"
							thisGroup[i].isHovering = true
							local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
							if block then
								--break -- should cause it to jump out of the for loop
								checkHoverBlocked = true
							end
						end

					elseif isWithin == true and thisGroup[i].isHovering == true then



						if checkHoverBlocked == true then -- you know this group is hovering

							hoverPhase = "ended"
							thisGroup[i].isHovering = nil
							local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
							if block then
								--break -- should cause it to jump out of the for loop
								checkHoverBlocked = true
							end

						else
							hoverPhase = "moved"
							local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
							if block then
								--break -- should cause it to jump out of the for loop
								checkHoverBlocked = true
							end
						end

					elseif isWithin == false and thisGroup[i].isHovering == true then

						hoverPhase = "ended"
						thisGroup[i].isHovering = nil
						local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
						if block then
							--break -- should cause it to jump out of the for loop
							checkHoverBlocked = true
						end
					end


				end

			else -- no children, it isn't a group

				local isWithin = isWithinObject(thisGroup[i],xLoc,yLoc)

				if isWithin == true and thisGroup[i].isHovering == nil then
					if checkHoverBlocked ~= true then
						hoverPhase = "began"
						thisGroup[i].isHovering = true
						local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
						if block then
							--break -- should cause it to jump out of the for loop
								checkHoverBlocked = true
						end
					end

				elseif isWithin == true and thisGroup[i].isHovering == true then


						if checkHoverBlocked == true then -- you know this group is hovering

							hoverPhase = "ended"
							thisGroup[i].isHovering = nil
							local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
							if block then
								--break -- should cause it to jump out of the for loop
								checkHoverBlocked = true
							end

						else
							hoverPhase = "moved"
							local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
							if block then
								--break -- should cause it to jump out of the for loop
								checkHoverBlocked = true
							end
						end

				elseif isWithin == false and thisGroup[i].isHovering == true then

					hoverPhase = "ended"
					thisGroup[i].isHovering = nil
					local block = dispatchHoverEvent(thisGroup[i],hoverPhase,xLoc,yLoc)
					if block then
						--break -- should cause it to jump out of the for loop
							checkHoverBlocked = true
					end
				end




			end


		end

	end -- for isHoverTestable
end


local onMouseEvent = function(event)

	if mouseHoverStage then
		checkHover(mouseHoverStage,event.x,event.y)
	end

end






--- API STARTS HERE



function mouseHover.activate()

	if activated == false then
		Runtime:addEventListener( "mouse", onMouseEvent )
		activated = true
		--print("activating")
	end

	local env = system.getInfo( "environment" )
	local platform = system.getInfo( "platform" )
	-- print(env,platform)
	if env == "simulator" and platform ~= "android" then
		print("Note: If you're using Corona Simulator on Windows then Corona's 'mouse' events will only work with an Android skin.")
	end

end

mouseHover.activate()

function mouseHover.deactivate()
	if activated == true then
		Runtime:removeEventListener( "mouse", onMouseEvent )
		activated = false

	end

end


function mouseHover.setScope(theGroup)

	mouseHoverStage = theGroup

end

mouseHoverStage = display.getCurrentStage( )

function mouseHover.unRequire() -- this will only work if all the local or global variable that points to the plugin's package.loaded table is also nilled. Otherwise it will not work.
	mouseHover.deactivate()

	for i =1, #mouseHover.subModules do

		package.loaded[mouseHover.subModules[i]] = nil

	end

	package.loaded[pluginPath] = nil -- un-requiring self



end




return mouseHover

--Runtime:addEventListener( "enterFrame", onEnterFrame )
