local M = {}
local json = require("json")

local selectors
local UI
local bookTable
local pageTable
local layerTable = require("editor.parts.layerTable")
local actionTable = require("editor.action.actionTable")
local commandbox = require("editor.action.commandbox")
local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local helper = require("test.helper")

local muiName = "editor.action.commandView-"
local actionTable = require("editor.action.actionTable")
local controller = require("editor.action.controller.index")
local buttons = require("editor.parts.buttons")

local audioTable = require("editor.audio.audioTable")
local variableTable = require("editor.variable.variableTable")
local assetTable = require("editor.asset.assetTable")

local util = require("lib.util")

--
function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.actionTable   = actionTable
  props.buttons       = buttons
  props.audioTable    = audioTable
  props.variableTable = variableTable
  props.assetTable = assetTable
  helper.init(props)
end

function M.suite_setup()
  -- selectors.projectPageSelector:show()
  -- selectors.projectPageSelector:onClick(true)
  -- --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
end

function M.setup()
  -- local obj = helper.selectBook("bookFree")
  --  bookTable.commandHandler(obj, {phase="ended"},  true)
end

function M.teardown()
end

-- auto save or save button while indicating layers are not saved yet?

function M.xtest_new_rectangle()
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    -- shortcut t to select and transform
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}

    -- then drag to a new position
    local shape = require("editor.shape.index")
    local props = shape.drawRect(UI, function(phase, props)
      print(json.prettify( props ))
    end)

    Runtime:dispatchEvent{name="touch", phase="moved", xStart=100, yStart=100, x=100, y=100}
    Runtime:dispatchEvent{name="touch", phase="ended", xStart=100, yStart=100, x=300, y=300}

      -- drawRect isFinal will dispatch save
      --
      -- editor save layers
      --   update index.lua or command a reload with auto update index.lua
      --   both of them, needs to be back the select book/page/ and componentView
      --
      -- if this unit testing executes 'save' automaticall, it will make infinity loop.
      -- Instead, draw it manually to create a rectangle. It fires save event and
      -- the simulator will auto reload itself till the shape.drawRect() above
      -- And unit test should be turned off after the run
      --  or  use httpYack to make the unit test run for invoking this test_new_rectangle
      --   POST /unittest
   end
end

function M.xtest_new_ellipse()
   UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    -- shortcut t to select and transform
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}

    -- then drag to a new position
    local shape = require("editor.shape.index")
    local props = shape.drawEllipse()

   end
end

function M.xtest_new_text()
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    -- shortcut t to select and transform
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}

    -- then drag to a new position
    local shape = require("editor.shape.index")
    local props = shape.drawText(UI, function(phase, v)
      if phase == "ended" then
        print(json.prettify( v ))
      elseif phase == "editor" then
          local obj = v.field
          obj:dispatchEvent{name="userInput", phase = "editor", target=obj, newCharacters="hello"}
          obj:dispatchEvent{name="userInput", phase = "ended", target=obj}
      end
    end)

    local x, y = display.contentCenterX, display.contentCenterY
    Runtime:dispatchEvent{name="touch", phase="moved", xStart=x, yStart=x, x=x, y=y}
    Runtime:dispatchEvent{name="touch", phase="ended", xStart=y, yStart=y, x=x+100, y=y+20}
    --
    -- then type in the filed and Enter key to finish
    --
   end
end

function M.xtest_new_line()
end

function M.xtest_new_polygon()
end

function M.xtest_new_bezier()
   UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    -- shortcut t to select and transform
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}
    -- then drag to a new position
    local shape = require("editor.shape.index")
    shape.bezierCubicCurve()
   end
end

function M.xtest_move()
   UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    local name = "title"
    local target = util.getLayer(UI, name)
    print(target.text)
    --
    -- shortcut v to select and move
    Runtime:dispatchEvent{name="key", keyName="v", phase="down"}

    -- then drag to a new position
    local shape = require("editor.shape.index")
    shape.move(UI, target, function(phase, props)
      if event.phase == "ended" then
        print(json.prettify( props ))
      end
    end)
    local x, y = target.x, target.y
    local dx, dy = display.contentCenterX, display.contentCenterY
    print(x, y)
    -- target:dispatchEvent{name="touch", phase="began",target=target, xStart=x, yStart=x, x=x, y=y}
    -- target:dispatchEvent{name="touch", phase="moved",target=target, xStart=x, yStart=x, x=dx, y=dy}
    -- target:dispatchEvent{name="touch", phase="ended",target=target, xStart=y, yStart=y, x=dx, y=dy}


   end
end

---
-- scale up&down, rotate
---

function M.xtest_scale()
  UI.testCallback = function()
   selectors.componentSelector.iconHander()
   selectors.componentSelector:onClick(true,  "layerTable")
   local name = "title"
   --
   local target = util.getLayer(UI, name)
   --
   -- shortcut t to select and transform
   Runtime:dispatchEvent{name="key", keyName="", phase="down"}
   -- then drag to a new position
   local shape = require("editor.shape.index")
   shape.scale(UI, target, function(props)
      print(json.prettify( props ))
   end)
   -- shape.pinchtozoom(target)
   --shape.pinchZoomGesture(target)
  end
end

function M.xtest_rotate()
  local obj = helper.selectBook("bookFree")
   bookTable.commandHandler(obj, {phase="ended"},  true)
   UI.testCallback = function()
    -- obj = helper.getPage("page4")
    -- pageTable.commandHandler(obj, {phase="ended"},  true)

    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    local name = "title"
    -- -- layerTable.altDown = true
    local target = util.getLayer(UI, name)
    --
    -- shortcut t to select and transform
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}

    -- then drag to a new position
    local shape = require("editor.shape.index")
    shape.rotate(UI, target, function(props)
      print(json.prettify( props ))
    end)
    -- shape.rotateWithMouse(target)
    -- shape.spin(target)
    -- select a corner
      -- drag for scaling
      -- drag for rotating
   end
end

function M.xtest_z_rotate()
   UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    ---
    local name = "title"
    local target = util.getLayer(UI, name)
    --
    -- shortcut t to select and transform
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}

    -- then drag to a new position
    local shape = require("editor.shape.index")
    shape.z_rotate(target)
   end
end


function M.xtest_RG_freeStuff_gridDragDrop()
  -- show grid with a shortcut key of 'g'?
  -- for moving(drag and drop) an object
  -- for creating an object
end

-- this is for animation with path
function M.xtest_RG_freeStuff_draw_follow_path()
end

function M.xtest_RG_freeStuff_centerScaleGroup()
  -- set  group.anchorChildren = true
end

function M.xtest_RG_freeStuff_dragIntoOffsetGroup()
  -- Insert drag object into group, then...
  --
  -- Use 'contentToLocal()' to adjust our cooridnate system to
  -- match the group and it's offset.
  --
  local x,y = rightGroup:contentToLocal( target.x, target.y )
  rightGroup:insert( target )
  target:toFront()
  target.x = x
  target.y = y
end

function M.test_fill_image()
  -- local obj = helper.selectBook("bookFree")
  --  bookTable.commandHandler(obj, {phase="ended"},  true)
  UI.testCallback = function()
    -- obj = helper.getPage("page4")
    -- pageTable.commandHandler(obj, {phase="ended"},  true)

    -- selectors.componentSelector.iconHander()
    -- selectors.componentSelector:onClick(true,  "layerTable")
    local name = "rect_2"
    -- -- layerTable.altDown = true
    -- local target = util.getLayer(UI, name)
    helper.selectLayerProps(name)

    local propsTable = require("editor.parts.propsTable")
    local obj = propsTable:getObj("imageFile")
    obj:dispatchEvent{name="tap", target = obj}

    ---
    local imagePicker = require("editor.parts.imagePicker")
    local searchbox = imagePicker.obj.searchbox
    searchbox.text = "*canvas*"
    searchbox:dispatchEvent{name="userInput", phase="ended", target=searchbox}
    for i, obj in next, imagePicker.obj.objs do
      if obj.imageFile == "butCamera.png" then
        obj:dispatchEvent{name="tap", target=obj}
        break
      end
    end

    -- helper.selectLayer(name, nil, true) -- isRightClick true
    -- helper.clickButton("Edit")


    -- --
    -- -- shortcut t to select and transform
    -- -- Runtime:dispatchEvent{name="key", keyName="", phase="down"}

    -- -- then drag to a new position
    -- local shape = require("editor.shape.index")

    -- shape.rotate(UI, target, function(props)
    --   print(json.prettify( props ))
    -- end)
   end
end

------
return M
