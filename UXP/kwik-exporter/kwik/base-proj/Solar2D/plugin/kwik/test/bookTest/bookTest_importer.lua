module(..., package.seeall)

local selectors
local UI
local bookTable
local pageTable

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  UI.scene.app:dispatchEvent {
    name = "editor.selector.selectApp",
    UI = UI
  }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book="bookTest"}, nil,  true)
  pageTable.commandHandler({page="parts"},nil,  true)

end

function M.setup()
end

function M.teardown()
end

local layerProps = {
  blendMode = "normal",
  height    =  967 - 847,
  width     = 1513 - 1386 ,
  kind      = solidColor,
  name      = "redRect",
  type      = "png",
  x         = 1513 + (1386 -1513)/2,
  y         = 847 + (967 - 847)/2,
  alpha     = 100/100,
}

function xtest_layer()
  local model ={
    path = "bookTest.components.parts.layers.buttonGroup.redRect",
    name = "rectCopied",
    class = {"button", "linear"},
  }
  --
  print("-----------------", model.path)
  --

  local layerProps = {
    blendMode = "normal",
    height    = 50,
    width     = 50,
    kind      = solidColor,
    name      = model.name, --"redRect",
    type      = "png",
    x         = display.contentCenterX - 150,
    y         = display.contentCenterY - 100,
    alpha     = 100/100,
    color     = {1, 1, 0}
  }

  model.layerProps = layerProps
  model.classProps = {
    button = {},
    linear = {}
  }

  local M = require("components.kwik.importer").new(model)
  for i=1, #M.modules do
    print("", i, M.modules[i].name)
  end
  print("-----------------")
end

function test_layerGroup()
  local model ={
    path = "bookTest.components.parts.layers.buttonGroup.index",
    name = "buttonGroup",
  }
  --
  print("-----------------", model.path)
  model.props = {
    redRect = {layerProps = {}},
    redRect_button = {},
    redRect_linear = {},
    greenRect = {layerProps = {}},
    blueRect = {layerProps = {}},
  }
  --
  local M = require("components.kwik.importer").new(model)
  for i=1, #M.modules do
    print("", i, M.modules[i].name)
  end
  print("-----------------")
end
