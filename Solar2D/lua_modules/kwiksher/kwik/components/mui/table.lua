local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")
local muiData = require( "materialui.mui-data" )
local json = require("json")

function M.onRowTouch(event, listener)
    local muiTarget = mui.getEventParameter(event, "muiTarget")
    local muiTargetValue = mui.getEventParameter(event, "muiTargetValue")
    local muiTargetIndex = mui.getEventParameter(event, "muiTargetIndex")
    local muiTargetRowParams = mui.getEventParameter(event, "muiTargetRowParams")
    local muiTableView = mui.getEventParameter(event, "muiTableView")

    -- reset background color for all rows that are out of view.
    -- set background of selected row

    ---[[-- uncomment below to demo row selected stays highlighted and prior rows do not.
    local tableViewRows = nil
    if muiTableView ~= nil then
        tableViewRows = muiTableView._view._rows
    end
    if muiTargetIndex ~= nil and tableViewRows ~= nil then
        for k, row in ipairs(tableViewRows) do
            if k == muiTargetIndex then
                row.params.rowColor = { 0, 1, 0, 1 }
            else
                row.params.rowColor = { 1, 1, 1, 1 }
            end
        end
       -- muiTableView:reloadData()
    end
    --]]--

    if muiTargetValue ~= nil then
        listener(muiTargetIndex, muiTargetValue)
        --print("onRowTouchDemo : row value: "..muiTargetValue)
    end
    -- access the columns of data
    if muiTargetRowParams ~= nil and muiTargetRowParams.columns ~= nil then
        print("onRowTouchDemo : columns of data are:")
        for i, v in ipairs(muiTargetRowParams.columns) do
            print("\tcolumn "..i.." text "..v.text)
            print("\tcolumn "..i.." value "..v.value)
            print("\tcolumn "..i.." align "..(v.align or "left"))
        end
    end
end

function M:createTableView (Props)
    if mui.getWidgetBaseObject(Props.name) ~= nil then
       -- mui.removeWidgetByName(Props.name)
    end

    mui.newTableView{
        parent = Props.parent or mui.getParent(),
        name = Props.name,
        width = Props.width or muiData.safeAreaWidth * 0.2,
        height = Props.height or muiData.safeAreaHeight * 0.2,
        top = Props.top or 20,
        left = Props.left or 20,
        font = native.systemFont,
        fontSize = Props.fontSize or 16,
        textColor = {0, 0, 0, 1},
        lineColor = {1, 1, 1, 1},
        lineHeight = 2,
        rowColor = {1, 1, 1, 1}, -- { default={1,1,1}, over={1,0.5,0,0.2} },
        rowHeight = Props.rowHeight or 20,
        -- rowAnimation = false, -- turn on rowAnimation
        noLines = false,
        callBackTouch = function(event) self.onRowTouch(event, self.listener) end,
        callBackRender = Props.onRowRender or mui.onRowRenderDemo,
        scrollListener = mui.scrollListener, -- needed if using buttons, etc within the row!
        list = Props.list,
        columnOptions = {
            widths = {60, 60, 60} -- must supply each else "auto" is assumed.
        },
        categoryColor = {default = {0.8, 0.8, 0.8, 0.8}},
        categoryLineColor = {1, 1, 1, 0},
        touchpointColor = {0.4, 0.4, 0.4}
    }
    return  mui.getWidgetBaseObject(Props.name)
end

M.new = function()
    local instance = {}
      return setmetatable(instance, {__index=M})
end
--
return M

