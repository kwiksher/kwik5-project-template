local M = {}

local selectors
local UI
local bookTable
local pageTable
local scene

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
end

-- for layer'class with Tool
function M.test_4_save_class()
  local data  = {
    -- new data for class's props
    name = "updated"
  }
  ---
  local params = {
    isNew = false,
    index = 1,
    book = "book",
    page = "page01",
    layer = "butBlue", -- "groupOne/A"
    class = "linear" -- "button"
  }
  local tool = UI.editor:getClassModule(class)
  tool.controller:load(params.book, params.page, params.layer, params.class, params.isNew)
  local objs = tool.controller.selectbox.objs

  tool.controller.selectbox:commandHandler{target=objs[params.index]}

  local decoded, index = tool.controller:getValue()
  if params.index ~= index then
    print("something wrong!!")
  end
  --
  local props = tool.controller:useClassEditorProps()
  -- merge with data
  for k, v in pairs(data) do
    if data[k] then
      props[k] = data[k]
    end
  end
  tool.controller:setValue(props, index) -- index = 1
  --
  UI.scene.app:dispatchEvent {
    name = "editor.classEditor.save",
    UI = UI,
    decoded = decoded,
    props = props
  }
  -- this will call editor.controller.save and commands.publishForSelections will run
end

function M.test_5_save_class_console()
  local data  = {
    -- new data for class's props
    name = "updated"
  }
  ---
  local params = {
    isNew = false,
    index = 1,
    book = "book",
    page = "page01",
    layer = "butBlue", -- "groupOne/A"
    class = "linear" -- "button"
  }

  local layerManager = require("server.controller.layerManager")
  layerManager.save(params.book, params.page, params.layer, params.class, data, params.index, params.isNew)
  -- this will call editor.controller.save and commands.publishForSelections will run

end

-- for audio, group, timer, variable
function M.test_6_save()
  local commandClass = "audio"

  -- group uses command() of group.controller.selectGroup
  --
  -- parts/controller/selector/selectAudio.lua uses command() of controller/index.lua

end

function M.test_6_save_console()
  local commandClass = "audio"
  local componentManager = require("server.controller.componentManager")

end

return M
