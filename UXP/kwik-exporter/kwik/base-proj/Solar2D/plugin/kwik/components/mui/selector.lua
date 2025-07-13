local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")
local muiData = require( "materialui.mui-data" )

	local list = { -- if 'key' use it for 'id' in the table row
		   { key = "Row1", text = "Apple", value = "Apple", isCategory = false, backgroundColor = {1,1,1,1} },
		   { key = "Row2", text = "Cookie", value = "Cookie", isCategory = false },
		   { key = "Row3", text = "Pizza", value = "Pizza", isCategory = false },
		   { key = "Row4", text = "Shake", value = "Shake", isCategory = false },
		   { key = "Row5", text = "Shake 2", value = "Shake 2", isCategory = false },
		   { key = "Row6", text = "Shake 3", value = "Shake 3", isCategory = false },
		   { key = "Row7", text = "Shake 4", value = "Shake 4", isCategory = false },
		   { key = "Row8", text = "Shake 5", value = "Shake 5", isCategory = false },
		   { key = "Row9", text = "Shake 6", value = "Shake 6", isCategory = false },
	   }

function M:onRowTouchSelector(event)
	local muiTarget = mui.getEventParameter(event, "muiTarget")
	local muiTargetValue = mui.getEventParameter(event, "muiTargetValue")
	local muiTargetIndex = mui.getEventParameter(event, "muiTargetIndex")

	if muiTargetIndex ~= nil then
		mui.debug("row index: "..muiTargetIndex)
	end

	if muiTargetValue ~= nil then
		mui.debug("row value: "..muiTargetValue)
	end

	if event.row.miscEvent ~= nil and event.row.miscEvent.name ~= nil then
		local parentName = string.gsub(event.row.miscEvent.name, "-List", "")

		if muiTargetIndex ~= nil then
			muiData.widgetDict[parentName]["selectorfieldfake"].text = muiData.widgetDict[parentName].list[muiTargetIndex].text -- was muiTargetValue
		end
		muiData.widgetDict[parentName]["value"] = muiTargetValue
		timer.performWithDelay(500, function() mui.finishSelector(parentName) end, 1)
	else
		local parentName = muiData.focus

		muiData.widgetDict[parentName]["selectorfieldfake"].text = muiTargetValue
		muiData.widgetDict[parentName]["value"] = muiTargetValue
		timer.performWithDelay(500, function() mui.finishSelector(parentName) end, 1)
	end

	if self.listener then
		self.listener({index=muiTargetIndex, value=muiTargetValue})
	end
	muiData.touched = true
	return true -- prevent propagation to other controls
end


function M:createSelector (Props)
   -- create a drop down list
   local numOfRowsToShow = 3
   mui.newSelect{
		parent = Props.parent or mui.getParent(),
		name = Props.name,
	   labelText = Props.labelText or "",
	   text = Props.text or "Default",
	   font = native.systemFont,
	   textColor = { 0.4, 0.4, 0.4 },
	   fieldBackgroundColor = { 1, 1, 1, 1 },
	   rowColor = { default={ 1, 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } }, -- 0.01 = transparent -- default is the highlighting
	   rowBackgroundColor = { 1, 1, 1, 1 }, -- the drop down color of each row
	   touchpointColor = { 0.4, 0.4, 0.4 }, -- the touchpoint color
	   activeColor = { 0.12, 0.67, 0.27, 1 },
	   inactiveColor = { 0.4, 0.4, 0.4, 1 },
	   strokeColor = { 0.4, 0.4, 0.4, 1 },
	   strokeWidth = 2,
	   hideBackground = true,
	   width = Props.width or 210,
	   height = Props.height or 30,
	   listHeight = 30 * (Props.numOfRowsToShow or 3),
	   x = Props.x or display.contentCenterX,
	   y = Props.y or display.contentCenterY,
	   callBackTouch = function(event) self:onRowTouchSelector(event) end, --mui.onRowTouchSelector,
	   scrollListener = nil,
	   list = Props.list,
	   state = {
		   value = "off",
		   disabled = {
			   fieldBackgroundColor = { .7,.7,.7,1 },
			   callBack = buttonMessage,
			   callBackData = {message = "button is disabled"}
		   }
	   },
	   arrow = {
		   off = {
			   color = { 0.4, 0.4, 0.4 },
			   --image = kwikGlobal.PATH.."../resources/mui/arrow-down.png",
			   svg = {
				   fillColor = { .5, .12, .5, 1 },
				   path = kwikGlobal.PATH.."../resources/mui/arrow-down.svg"
			   }
		   },
		   disabled = {
			   color = { 0.4, 0.4, 0.4 },
			   --image = kwikGlobal.PATH.."../resources/mui/arrow-down.png",
			   svg = {
				   fillColor = { .3, .3, .3, 1 },
				   path = kwikGlobal.PATH.."../resources/mui/arrow-down.svg"
			   }
		   }
	   },
	   backgroundFake = {
		   off = {
			   --image = kwikGlobal.PATH.."../resources/mui/TextBackground.jpg",
			   svg = {
				   path = kwikGlobal.PATH.."../resources/mui/jigsaw.svg"
			   }
		   },
		   disabled = {
			   --image = kwikGlobal.PATH.."../resources/mui/TextBackground-disabled.jpg",
			   svg = {
				   path = kwikGlobal.PATH.."../resources/mui/jigsaw.svg"
			   }
		   }
	   },
	   background = {
		   --image = "TextBackground.jpg",
		   svg = {
			   path = "jigsaw.svg"
		   }
	   },
   }
   ---
    return  mui.getWidgetByName(Props.name)
end

M.new = function()
    local instance = {}
      return setmetatable(instance, {__index=M})
end
--
return M

