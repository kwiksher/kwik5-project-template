local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")
local muiData = require( "materialui.mui-data" )


function M.createEntry(Props)
	local value = "off"
	if Props.isActive then
		value = "on"
	end
	return {
		key = Props.text,
		value = Props.text,
		--icon = "home",
		labelText=Props.text,
		isActive = Props.isActive,
		iconImageOn = nil,
		state = {
			value = value,
			off = {
				textColor = {1, 1, 1, 1},
				strokeColor = {.3, .3, .3, 1},
				labelColor = {1, 1, 1, 1}
			},
			on = {
				textColor = {1, 0, 0, 1},
				strokeColor = {.3, .3, .3, 1},
				labelColor = {1, 0, 0, 1}
			},
			disabled = {
				textColor = {.7, .7, .7, 1},
				strokeColor = {.7, .7, .7, 1},
				labelColor = {.7, .7, .7, 1}
			},
			-- image = {
			-- 	src = "assets/mui/if-hi-1024.png", -- source image file
			-- 	-- Below is optional if you have buttons on a sheet
			-- 	-- The 'sheetOptions' is directly from Corona sheets
			-- 	sheetIndex = 1, -- which frame to show for image from sheet
			-- 	touchIndex = 2, -- which frame to show for touch event
			-- 	disabledIndex = -1, -- which frame to show when disabled
			-- 	touchFadeAnimation = true, -- helpful with shadows
			-- 	touchFadeAnimationSpeedOut = 500,
			-- 	sheetOptions = {
			-- 		-- The params below are required by Corona

			-- 		width = 512,
			-- 		height = 512,
			-- 		numFrames = 2,

			-- 		-- The params below are optional (used for dynamic image sheet selection)

			-- 		sheetContentWidth = 1024, -- width of original 1x size of entire sheet
			-- 		sheetContentHeight = 512 -- height of original 1x size of entire sheet

			-- 	}
			}
		}
end

function M:createToolbar (Props)
	local buttonHeight = Props.height or 40
    mui.newToolbar{
        parent = Props.parent or mui.getParent(),
        name = Props.name,
        height = buttonHeight,
		width = Props.width,
        buttonHeight = buttonHeight,
        x = Props.x or 0,
        y = Props.y or  (muiData.safeAreaHeight - (buttonHeight * 0.5)),
        layout = "horizontal",
        labelFont = native.systemFont,
        color = {0, 0.46, 1, 1},
        fillColor = {0, 0.46, 1, 1},
        labelColor = {1, 1, 1},
        labelColorOff = {0, 0, 0},
        callBack = Props.listener,
        sliderColor = {1, 1, 1},
        list = Props.list,
		textWidth = 60
    }
    -- ]]--
    -- local bTest = mui.getChildWidgetProperty("toolbar_demo", "text", 1)
    -- bTest:setFillColor(1, 0, 0, 1)


	local obj = mui.getWidgetBaseObject(Props.name)
	--obj.anchorY = 0
    return  obj
end

M.new = function()
    local instance = {}
      return setmetatable(instance, {__index=M})
end
--
return M

