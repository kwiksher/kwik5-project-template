local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local actionTable = require("editor.action.actionTable")
local actionCommandTable = require("editor.action.actionCommandTable")
local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local actionEditor = require("editor.action.index")

local colorPicker = require("colorPicker")


local helper = require("test.helper")

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  props.actionTable = actionTable
  helper.init(props)
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  -- --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book="book"}, nil,  true)
  pageTable.commandHandler({page="canvas"},nil,  true)
  selectors.componentSelector.iconHander()
end

function M.setup()
end

function M.teardown()
end

function M.xtest_new_canvas()
  UI.testCallback = function()
    selectors.componentSelector:onClick(true,  "layerTable")
    local name = "Candice"
    helper.selectLayer(name)
    helper.selectTool{class="canvas", isNew=true}

    selectors.componentSelector:onClick(true,  "actionTable")
    helper.selectAction("blueBTN")
    -- actionTable.editButton:tap()
    -- actionTable.newButton:tap()

   -- --
    -- local button = "save"
    -- local obj = require("editor.parts.buttons").objs[button]
    -- obj:tap()
    --
    -- Cancel
    -- local button = "cancel"
    -- local obj = require("editor.parts.buttons").objs[button]
    -- obj:tap()
  end
end

function M.test_blueBTN_brushColor()
  UI.testCallback = function()
    selectors.componentSelector:onClick(true,  "actionTable")
    helper.selectAction("blueBTN")
    actionTable.editButton:tap()
    -- actionTable.newButton:tap()

    local obj = actionCommandTable.objs[2]
    actionCommandTable.singleClickEvent(obj)

    local objColorEntry = actionCommandPropsTable.objs[2]
    objColorEntry:dispatchEvent{name="tap", target=objColorEntry}

    timer.performWithDelay( 2000, function()
      --
      local colorBox = colorPicker.colorBox
      colorBox:dispatchEvent{name="touch", phase="began", target=colorBox,
      x = display.contentWidth*0.5, y = display.contentHeight*0.5}
      colorBox:dispatchEvent{name="touch", phase="ended", target=colorBox}
      -- close
      timer.performWithDelay( 2000, function()
        colorPicker.background:dispatchEvent{name="tap"}
      end)
    end)
    -- --
    -- local button = "save"
    -- local obj = require("editor.parts.buttons").objs[button]
    -- obj:tap()
    --
    -- Cancel
    -- local button = "cancel"
    -- local obj = require("editor.parts.buttons").objs[button]
    -- obj:tap()
  end
end

function M.xtest_colorPicker()
  -- https://github.com/andrewyavors/Lua-Color-Converter
  local converter = require("convertcolor")
  -- print(converter.tohex(10))
  print(converter.tohex(1.0, 0, 0))

  --
  ---[[
  -- https://www.jasonschroeder.com/2014/03/24/add-a-color-picker-to-your-corona-app-with-one-line-of-code/
  -- require the colorPicker module
  local colorPicker = require("colorPicker")
  -- draw a rectangle on the screen
  local myRect = display.newRect(0, 0, display.contentWidth * .5, display.contentWidth * .5)
  myRect.x, myRect.y = display.contentCenterX, display.contentCenterY
  myRect.r, myRect.g, myRect.b, myRect.a = 1, 1, 1, 1

  -- here is our listener function to change the rectangle's color
  local function pickerListener(r, g, b, a)
    print(r, g, b, a)
    -- print("#"..converter.tohex(r)..converter.tohex(g)..converter.tohex(b))
    print(converter.tohex(r, g, b))
    myRect:setFillColor(r, g, b, a)
    myRect.r, myRect.g, myRect.b, myRect.a = r, g, b, a
  end

  colorPicker.show(pickerListener, myRect.r, myRect.g, myRect.b, myRect.a)
 --]]

end

function M.xtest_snapshot_paint()
  -- https://forums.solar2d.com/t/snapshot-as-paint-input/319084/29?page=2
  -- /Applications/Corona/SampleCode/Graphics/SnapshotEraser
  -- /Applications/Corona/SampleCode/Graphics/SnapshotPaint
  -- https://docs.coronalabs.com/guide/graphics/snapshot.html

  -- https://forums.solar2d.com/t/simple-trail-finally-a-corona-plugin-to-render-trails/150187/12

    -- https://github.com/H0neyP0ney/SimpleTrail

    -- https://github.com/ponywolf/ponyblitz/tree/master

end

return M
