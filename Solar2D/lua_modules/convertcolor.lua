local M = {}

local function hex (hex, alpha)
	local redColor,greenColor,blueColor=hex:match('#?(..)(..)(..)')
	redColor, greenColor, blueColor = tonumber(redColor, 16)/255, tonumber(greenColor, 16)/255, tonumber(blueColor, 16)/255
	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100
	if alpha == nil then
		return redColor, greenColor, blueColor
	end
	return redColor, greenColor, blueColor, alpha
end

local function rgb (r, g, b)
	local redColor,greenColor,blueColor=r/255, g/255, b/255
	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100
	return redColor, greenColor, blueColor
end

local function rgba (r, g, b, alpha)
	local redColor,greenColor,blueColor=r/255, g/255, b/255
	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100
	return redColor, greenColor, blueColor, alpha
end

--https://gist.github.com/marceloCodget/3862929

function rgbToHex(r,g,b)

  -- EXPLANATION:
  -- The integer form of RGB is 0xRRGGBB
  -- Hex for red is 0xRR0000
  -- Multiply red value by 0x10000(65536) to get 0xRR0000
  -- Hex for green is 0x00GG00
  -- Multiply green value by 0x100(256) to get 0x00GG00
  -- Blue value does not need multiplication.

  -- Final step is to add them together
  -- (r * 0x10000) + (g * 0x100) + b =
  -- 0xRR0000 +
  -- 0x00GG00 +
  -- 0x0000BB =
  -- 0xRRGGBB
  return string.format("#%02X%02X%02X", math.floor(r*255), math.floor(g*255), math.floor(b*255))
  -- local rgb = (r * 0x10000) + (g * 0x100) + b
  -- return string.format("%x", rgb)
end

M.hex = hex
M.rgb = rgb
M.rgba = rgba
M.tohex = rgbToHex

return M