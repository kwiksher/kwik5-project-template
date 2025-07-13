local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")
local muiData = require( "materialui.mui-data" )

function M:createText (Props)
    local textWidth = muiData.safeAreaWidth
    local options =
    {
        parent = Props.parent or mui.getParent(),
        name = Props.name,
        text = Props.text or "",
        x = Props.x or display.contentCenterX,
        y = Props.y or display.contentCenterY,
        width = textWidth,     --required for multi-line and alignment
        font = native.systemFont,
        fontSize = Props.fontSize or 18,
        fillColor = { 1, 1, 1, 1 },
        align = "left"  --new alignment parameter
    }
    options.width = Props.width or mui.getTextWidth( options )
    mui.newText( options )
    ---
    return  mui.getWidgetBaseObject(Props.name)
end

M.new = function()
    local instance = {}
      return setmetatable(instance, {__index=M})
end
--
return M

