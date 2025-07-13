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
end

function M.setup()
end

function M.teardown()
end

function M.test_emulator()
  local mod = require("components.kwik.layer_parallax")

  local names = {
    -- "background2",
    -- "background1",
    "cat",
    "water",
    "fish",
  }
  timer.performWithDelay(1000, function()
    local objs = {}
    for i, v in next, names do
      objs[i] = UI.sceneGroup[v] or {}
    end
    mod.dummyDispatcher(objs, 400)
  end)

end

return M
