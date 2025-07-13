local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")
local muiData = require( "materialui.mui-data" )
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")

function M:createColor (name, value, row)
	local group = display.newGroup()

	local arr = {}
	for key,value in pairsByKeys(value) do
		arr[#arr + 1] = tostring(key) .. "=" .. tostring(value)
	end

	local textOptions =
	{
		parent = group,
		text = table.concat(arr, ", "),
		x = 10,--display.contentCenterX,
		y = 0,
		width = row.contentWidth-100,
		font = native.systemFont,
		fontSize = row.params.fontSize,
		align = "left" -- Alignment parameter
	}
	local rowTitle = display.newText( textOptions )
	print("rowTitle", rowTitle.x, rowTitle.y)
	rowTitle:setFillColor(0,0,0)
	return group
end


function M:createText (name, value, row)
	local group = display.newGroup()

	local arr = {}
	for key,value in util.pairsByKeys(value) do
		print("", key, value)
		if type(value) == 'table' then
			arr[#arr + 1] = tostring(key) .. "= {" .. table.concat(value,",") .."}"
		else
			arr[#arr + 1] = tostring(key) .. "=" .. tostring(value)
		end
	end

	local textOptions =
	{
		parent = group,
		text = table.concat(arr, ", "),
		x = 10,--display.contentCenterX,
		y = 0,
		width = row.contentWidth-100,
		font = native.systemFont,
		fontSize = row.params.fontSize,
		align = "left" -- Alignment parameter
	}
	local rowTitle = display.newText( textOptions )
	print("rowTitle", rowTitle.x, rowTitle.y)
	rowTitle:setFillColor(0,0,0)
	return group
end

function M:newTextField(name, value)
	print(name, value)
	local defaultField

	local function textListener( event )

		if ( event.phase == "began" ) then
			-- User begins editor "defaultField"

		elseif ( event.phase == "ended" or event.phase == "submitted" ) then
			-- Output resulting text from "defaultField"
			print( event.target.text )

		elseif ( event.phase == "editor" ) then
			print( event.newCharacters )
			print( event.oldText )
			print( event.startPosition )
			print( event.text )
		end
	end

	-- Create text field
	defaultField = native.newTextField( 90, 0, 180, 30 )
	defaultField:addEventListener( "userInput", textListener )
	defaultField.text = value
	defaultField.padding =  200
	defaultField.align = "left"
	return defaultField
	-- mui.newTextField({
	-- 	name = name,
	-- 	text = value,
	-- 	font = native.systemFont,
	-- 	width = 200,
	-- 	height = 40,
	-- 	activeColor = { 0.12, 0.67, 0.27, 1 },
	-- 	inactiveColor = { 0.4, 0.4, 0.4, 1 },
	-- 	callBack = mui.textfieldCallBack,
	-- 	--inputType = "number"
	-- })
    -- return  mui.getWidgetBaseObject(name)
end

function M:onRowRender(event )
	local row = event.row

	-- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added

	local rowHeight = row.contentHeight
	local rowWidth = row.contentWidth
    -- print(row.id, rowWidth)
	print("row.params.text--------", row.params.text)
	if self[row.id.."Handler"] == nil then
		local _value = tostring(row.params.value)
		if type(row.params.value) == 'table' then
			_value = " {" .. table.concat(row.params.value,",") .."}"
		end
		print(_value)

		mui.newTextField({
			name = self.name.."textField"..row.index,
			text = _value,
			font = native.systemFont,
			width = rowWidth/2, --200,
			height = 40,
			activeColor = { 0.12, 0.67, 0.27, 1 },
			inactiveColor = { 0.4, 0.4, 0.4, 1 },
			callBack = mui.textfieldCallBack,
			--inputType = "number"
		})
		mui.attachToRow( row, {
			widgetName = self.name.."textField"..row.index,
			widgetType = "TextField",
			align = "right", -- left | right supported
			params = row.params,
			finish = true
		})
	else
		local widget = self[row.id.."Handler"](self, self.name.."-"..row.index, row.params.value, row)
		---[[


		local newX = 0
		local newY = 0
		local nh = row.contentHeight
		local nw = row.contentWidth
		local padding = widget.padding or 10
		local rowName = "row" .. row.index
		local basename = row.params.basename
		local align = widget.align or "right"

		newY = (nh - widget.contentHeight) * 0.5
		newX = newX + padding

		-- keep tabs on the toolbar objects
		if muiData.widgetDict[basename]["list"] == nil then muiData.widgetDict[basename]["list"] = {} end
		if muiData.widgetDict[basename]["list"][rowName] == nil then
			muiData.widgetDict[basename]["list"][rowName] = {}
			muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] = 0
			muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] = 0
		end

		if align == "left" then
			if muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] > 0 then
				newX = newX + padding
			end
			newX = newX + muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"]
			widget.x = widget.contentWidth * 0.5 + newX
			muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] = widget.x + widget.contentWidth * 0.5
		else
			newX = nw
			if muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] > 0 then
				newX = newX - padding
			end
			newX = newX - muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"]
			widget.x = newX - widget.contentWidth * 0.5
			muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] = padding + muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] + widget.contentWidth * 0.5
		end


		widget.y = widget.contentHeight * 0.5 + newY

		mui.setRowObjectVerticalAlign({
			rowHeight = row.contentHeight,
			obj = widget,
			valign = align,
			lineHeight = row.params.lineHeight or 0
		})

		--]]

		row:insert( widget, false )

		if widget.finish == true then
			muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] = 0
			muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] = 0
		end

		-- mui.setRowObjectVerticalAlign({
		-- 	obj = obj,
		-- 	valign = "right",
		-- 	rowHeight = rowHeight,
		-- 	lineHeight = row.params.lineHeight,
		-- 	--heightOfFont = rowTitle.contentHeight
		-- })
		-- row:insert(obj, false)
	--]]
	end

	-- print(self.name.."textField"..row.index)
	-- print("",mui.getTextFieldProperty(self.name.."textField"..row.index, "value"))


	local textOptions =
	{
		parent = row,
		text = row.params.text,
		x = 5,
		y = rowHeight * 0.5,
		width = rowWidth/4,
		font = font,
		fontSize = row.params.fontSize,
		align = row.params.align or "left" -- Alignment parameter
	}
	local rowTitle = display.newText( textOptions )
	rowTitle:setFillColor( unpack( textColor ) )

	-- Align the label left and vertically centered
	rowTitle.anchorX = 0

	row.params.valign = row.params.valign or "middle"
	mui.setRowObjectVerticalAlign({
			obj = rowTitle,
			valign = row.params.valign,
			rowHeight = rowHeight,
			lineHeight = row.params.lineHeight
		})
	self.lastIndex = row.index

	if row.params.text == "color" then
		rowTitle:addEventListener("tap", function(event)
			local colorPicker = require("color_picker")
			print("color picker")
			colorPicker.show(function(r, g, b,a) print(r, g, b,a) end, 1,0,0,1)
		end)
	end
end

function M:getTextFields()
	local list = {}
	for i=1, self.lastIndex do
		table.insert(list, mui.getTextFieldProperty(self.name.."textField"..i, "layer_2"))
	end
	return list
end

M.new = function()
    local instance = {}
      return setmetatable(instance, {__index=M})
end

--
return M


	--[[
		local count = 0

		for k, v in pairs(value) do
			print("", k, v)
			--
			--
			local textOptions =
			{
				parent = group,
				text = k,
				x = 0,--display.contentCenterX,
				y = 50 * count,
				width = row.contentWidth,
				font = native.systemFont,
				fontSize = row.params.fontSize,
				align = "left" -- Alignment parameter
			}
			local rowTitle = display.newText( textOptions )
			print("rowTitle", rowTitle.x, rowTitle.y)
			-- group:insert(rowTitle, true)
			rowTitle:setFillColor(1,0,0)
			--rowTitle.x = row.contentWidth
			--rowTitle.y = 50 * count
			count = count + 1

			local myRectangle = display.newRect(group, rowTitle.x, rowTitle.y, rowTitle.width, rowTitle.height )
			myRectangle.strokeWidth = 1
			myRectangle:setFillColor( 0.1,0.1,0.1,0.1 )
			myRectangle:setStrokeColor( 1, 0, 0 )

		end
	--]]
	--[[


		-- local myRectangle = display.newRect(group, rowTitle.x, rowTitle.y, rowTitle.width, rowTitle.height )
		-- myRectangle.strokeWidth = 1
		-- myRectangle:setFillColor( 0.1,0.1,0.1,0.1 )
		-- myRectangle:setStrokeColor( 1, 0, 0 )
		group.x = 0 --display.contentCenterX
		group.y = 0 -- display.contentCenterY
		print("group", group.x, group.y)
	--]]
