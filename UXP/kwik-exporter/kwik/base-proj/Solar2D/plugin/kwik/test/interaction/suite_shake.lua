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
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true, "layerTable")
end

function M.setup()
end

function M.teardown()
end

function M.xtest_new()
  local name = "rect_0"
  helper.selectLayer(name)
  helper.selectIcon("Interactions", "Shake"):done(
    function()
    end
  )
end

function M.test_emulator()
  local mod = require("components.kwik.layer_shake")
  local obj = UI.sceneGroup["ellipse_0"]
  if obj then
    mod.createShakeEmulator(obj, function(event)
      event.target = obj
      obj.shake.shakeHandler(event)
    end)
  else
    print("### Error")
  end

end

return M
