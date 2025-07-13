local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable

local helper = require("test.helper")
local json = require("json")

local groupTable = require("editor.group.groupTable")
local buttons = require("editor.group.buttons")

function M.init(props)
  selectors = props.selectors
  UI = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.groupTable = groupTable
  props.buttons = buttons
  helper.init(props)
end

function M.suite_setup()
  -- selectors.projectPageSelector:show()
  -- selectors.projectPageSelector:onClick(true)
  -- selectors.componentSelector.iconHander()
  -- selectors.componentSelector:onClick(true, "layerTable")
end

function M.setup()
end

function M.teardown()
end

function M.test_emulator()
  local mod = require("components.kwik.layer_pinch")

  local obj = UI.sceneGroup["ellipse_0"]
  -- transition.to(obj, {time=3000, xScale = 0.1, yScale = 0.1})
  if obj then
    mod.createPinchEmulator(obj, function(scale)
      if scale == nil then return end
      if  scale < obj.pinch.properties.scaleMax then
        transition.to(obj, {time=1000, xScale = scale, yScale = scale})
      else
        transition.to(obj, {time=1000, xScale = obj.pinch.properties.scaleMax, yScale = obj.pinch.properties.scaleMax})
      end
    end)
  else
    print("### Error")
  end

end

return M
