local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable

local groupTable = require("editor.group.groupTable")
local buttons = require("editor.group.buttons")

local helper = require("test.helper")

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.groupTable = groupTable
  props.buttons = buttons
  helper.init(props)

end

local book = "bookFree"
local page = "page4"

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
  bookTable.commandHandler({book=book}, nil,  true)
  pageTable.commandHandler({page=page},nil,  true)
  selectors.componentSelector.iconHander()
end

function M.setup()
end

function M.teardown()
end

function M.xtest_new_group()
    UI.testCallback = function()
      UI.page = "page4"
      selectors.componentSelector:onClick(true,  "groupTable")
       -- click the icon for creatign a new group
      UI.scene.app:dispatchEvent {
        name = "editor.selector.selectGroup",
        UI = UI,
        isNew = true, --(name ~= "Trash-icon"),
        isDelete =false -- (name == "Trash-icon")
      }

    end
end

function M.test_cancel_group()
  UI.testCallback = function()
    UI.page = "page4"
    selectors.componentSelector:onClick(true,  "groupTable")
     -- click the icon for creatign a new group
    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectGroup",
      UI = UI,
      isNew = true, --(name ~= "Trash-icon"),
      isDelete =false -- (name == "Trash-icon")
    }

    local objs = require("editor.group.buttons").objs
    for k, v in pairs(objs) do
      print(k, v.text)
    end
    local button = "cancel"
    local obj = require("editor.group.buttons").objs[button]
    obj:tap()

  end
end

function M.xtest_select_group()
  UI.testCallback = function()
    UI.page = "page4"
    selectors.componentSelector:onClick(true,  "groupTable")
    helper.selectGroup("myGroup")
     -- click the icon for creatign a new group
    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectGroup",
      UI = UI,
      isNew = false, --(name ~= "Trash-icon"),
      isDelete =false -- (name == "Trash-icon")
    }

  end
end


function M.xtest_add()
  UI.testCallback = function()
      UI.page = "page4"
      local name = "myGroup"
      selectors.componentSelector:onClick(true,  "groupTable")
      helper.selectGroup(name)
       -- click the icon for creatign a new group
      UI.scene.app:dispatchEvent {
        name = "editor.selector.selectGroup",
        UI = UI,
        group = name,
        isNew = false, --(name ~= "Trash-icon"),
        isDelete =false -- (name == "Trash-icon")
      }

    -- layersbox -> layersTable
    local layersbox = require("editor.group.layersbox")
    local names = {"Ellipse", "Triangle"}
    -- layersbox.controlDown = true -- multi
    layersbox.controlDown = true
    helper.selectEntries(layersbox, names)


    -- click add button
    helper.clickButton("add")
    -- hello in layersbox should be grayed
  end
end

function M.xtest_remove()
  UI.testCallback = function()
      UI.page = "page4"
      local name = "myGroup"
      --selectors.componentSelector:onClick(true,  "layerTable") --isVisible = true
      selectors.componentSelector:onClick(true,  "groupTable")
      helper.selectGroup(name)
       -- click the icon for creatign a new group
      UI.scene.app:dispatchEvent {
        name = "editor.selector.selectGroup",
        UI = UI,
        group = name,
        isNew = false, --(name ~= "Trash-icon"),
        isDelete =false -- (name == "Trash-icon")
      }

    -- layersbox -> layersTable
    local layersbox = require("editor.group.layersbox")
    local names = {"hello"}
    -- layersbox.controlDown = true -- multi
    helper.selectEntries(layersbox, names)

    -- click add button
    helper.clickButton("add")

    -- hello in layersbox should be grayed

    -- layersbox <- layersTable
    local layersTable = require("editor.group.layersTable")
    -- layersTable.controlDown = true -- multi

    local objs = helper.getObjs(layersTable, names) -- {"hello"}
    local target = objs[1].parent
    local layerName = objs[1].text
    local xStart = target.x
    local yStart = target.y
    layersTable.listener(target, {phase="ended", id="myscollview"})

    helper.clickButton("remove")

    -- hello should be removed from layersTable
    objs = helper.getObjs(layersTable, names) -- {"hello"}
    ---
    assert(#objs==0, "remove fail #objs="..#objs)
    ---
    -- hello become active color in layersbox
    objs = helper.getEntries(layersbox, {"bg", "hello"})
    --local fillColor = getFillColor(objs[1].rect)
    print("@@",objs[1].alpha, objs[2].alpha)
    ---
    assert(objs[1].alpha == objs[2].alpha, "hello not become active")
    ---

  end
end

function M.xtest_add_from_group()
  UI.testCallback = function()
      UI.page = "page4"
      local name = "myGroup"
      --selectors.componentSelector:onClick(true,  "layerTable") --isVisible = true
      selectors.componentSelector:onClick(true,  "groupTable")
      helper.selectGroup(name)
       -- click the icon for creatign a new group
      UI.scene.app:dispatchEvent {
        name = "editor.selector.selectGroup",
        UI = UI,
        group = name,
        isNew = false, --(name ~= "Trash-icon"),
        isDelete =false -- (name == "Trash-icon")
      }

    -- layersbox -> layersTable
    local layersbox = require("editor.group.layersbox")

    local names = {"Ellipse"}
    -- layersbox.controlDown = true -- multi
    helper.selectEntries(layersbox, names)

    -- click add button
    helper.clickButton("add")

    -- Ellipse in layersbox should be grayed

  end
end


function M.xtest_add_drag()
  UI.testCallback = function()
      UI.page = "page4"
      local name = "myGroup"
      --selectors.componentSelector:onClick(true,  "layerTable") --isVisible = true
      selectors.componentSelector:onClick(true,  "groupTable")
      helper.selectGroup(name)
       -- click the icon for creatign a new group
      UI.scene.app:dispatchEvent {
        name = "editor.selector.selectGroup",
        UI = UI,
        group = name,
        isNew = false, --(name ~= "Trash-icon"),
        isDelete =false -- (name == "Trash-icon")
      }

    -- add layersbox -> layersTable
    local layersbox = require("editor.group.layersbox")
    -- select them
    local names = {"bg", "Ellipse"}
    layersbox.controlDown = true -- multi
    helper.selectEntries(layersbox, names)

    -- click add button
    helper.clickButton("add")

    -- drag an object in layersTable
    local layersTable = require("editor.group.layersTable")
    local target = layersTable.objs[3].parent
    local layerName = layersTable.objs[3].text
    local xStart = target.x
    local yStart = target.y
    layersTable.listener(target, {phase="began", id="myscollview"})
    target:dispatchEvent{name="touch", target=target, phase="began", x =target.x, y=target.y, xStart=xStart, yStart=yStart}
    target:dispatchEvent{name="touch", target=target, phase="moved", x=target.x, y= target.y-40, xStart=xStart, yStart=yStart}
    target:dispatchEvent{name="touch", target=target, phase="ended", x=target.x, y= target.y-40, xStart=xStart, yStart=yStart}

    assert_match(layersTable.objs[2].text, layerName, "moved to index 2")
    --print(layersTable.objs[2].text, layerName, "moved to index 2")

    -- click remove
    -- local layersTable = require("editor.group.layersTable")
    --
  end
end



return M
