local M = {}

local selectors
local UI
local bookTable
local pageTable
local scene

local nanostores         = require("nanostores.index")

function M.init(props)
  selectors = props.selectors
  UI = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable

  scene = {
    components = {
      layers = {
        {
          back = {}
        },
        {butBlue = {class = {"button"}}},
        {
          groupOne = {
            {A = {}},
            {
              B = {class = {"animation"}},
            },
            {
              groupTwo = {
                {C = {}},
                {D = {class = {"linear"}}}
              }
            }
          }
        }
      },
      audios = {},
      groups = {},
      timers = {},
      variables = {},
      others = {}
    },
    commands = {"blueBTN"},
    onInit = function(scene)
      print("onInit")
    end
  }
end

function M.suite_setup()
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
end

function M.setup()
end

function M.teardown()
end

function M.test_1_project_page()
  selectors.projectPageSelector:onClick(true)
  selectors.projectPageSelector:show()
  -- --
  UI.scene.app:dispatchEvent {
    name = "editor.selector.selectApp",
    UI = UI
  }
  print(#bookTable.objs)

end

function M.test_2_book_page()
  -- bookTable.commandHandler({book = "book"}, nil, true)
  -- pageTable.commandHandler({page = "page01"}, nil, true)
  print(#bookTable.objs)
  bookTable.commandHandler(bookTable.objs[1], nil, true)
  pageTable.commandHandler(pageTable.objs[1], nil, true)
end

function M.test_3_layer()
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true, "layerTable")
  UI.editor.layerStore:set(scene.components.layers)
  ret = nanostores.getValue(UI.editor.layerStore)
  print("ret", #ret) -- == 3
end

function M.xtest_action()
  -- timer.performWithDelay( 1000, function()
  --   selectors.componentSelector.iconHander()
  --   selectors.componentSelector:onClick(true,  "actionTable")
  -- end)

  UI.scene.app:dispatchEvent {
    name = "editor.action.selectAction",
    action = "eventOne",
    UI = UI
  }
end

function M.xtest_slider()
  local slider = require("slider")

  -- Example usage
  local obj = slider.createSlider({
    width = 300,
    height = 6,
    thumbRadius = 12,
    minValue = 0,
    maxValue = 100,
    startValue = 50,
    onChange = function(value)
        print("Slider value: " .. value)
    end
  })
  obj.x = display.contentCenterX
  obj.y = 50
end


return M
