

local oldPolygonMethod = display.newPolygon

function display.newPolygon(...)

	local polygon = oldPolygonMethod(unpack(arg))
	--[[for i,v in ipairs(arg) do
        print(i,v)
      end]]--
	polygon.vertices = arg[#arg]

	return polygon
end