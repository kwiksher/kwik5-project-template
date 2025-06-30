local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")

function M:createButton (Props)
	mui.newRoundedRectButton{
        parent = Props.parent or mui.getParent(),
		name = Props.name,
		text = Props.text or "",
		width = Props.width or 100,
		height = Props.height or 30,
		x = Props.x or display.contentCenterX,
		y = Props.y or display.contentCenterY,
		font = native.systemFont,
		fillColor = { 0.31, 0.65, 0.03, 1 },
		textColor = { 1, 1, 1 },
		--iconText = "arrow_back",
		iconFont = mui.materialFont,
		iconFontColor = { 1, 1, 1, 1 },
		-- iconImage = "1484026171_02.png",
		callBack =  self.listener,
		state = {
			value = "off",
			off = {
				textColor = {1, 1, 1},
				fillColor = {0, 0.81, 1}
				--svg = {path = "ic_view_list_48px.svg"}
			},
			on = {
				textColor = {1, 1, 1},
				fillColor = {0, 0.61, 1}
				--svg = {path = "ic_help_48px.svg"}
			},
			disabled = {
				textColor = {1, 1, 1},
				fillColor = {.3, .3, .3}
				--svg = {path = "ic_help_48px.svg"}
			}
		},
		callBackData = Props.callBackData or {} -- scene menu.lua
	}
	local obj = mui.getWidgetBaseObject(Props.name)
	obj.anchorY = 0
    return  obj

end



M.new = function()
    local instance = {}
      return setmetatable(instance, {__index=M})
end
--
return M

