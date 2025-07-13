local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local actionTable = require("editor.action.actionTable")
local groupTable = require("editor.group.groupTable")
local actionbox = require("editor.parts.actionbox")
local actionButtonContext = require("editor.action.buttonContext")
local picker = require("editor.picker.name")

local helper = require("test.helper")



--local toolbar  = require("editor.parts.toolbar")


function selectTool(args)
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = args.class, -- obj.class,
      -- toolbar = self,
      isNew = args.isNew
    }
  )
end

function selectAction(name)
  for i, v in next, actionTable.objs do
    if v.text == name then
      -- v:dispatchEvent{name="touch", pahse="ended", target=v}
      v:touch{phase = "ended"}
      return
    end
  end
end

function selectComponent(name)
  for i, v in next, selectors.componentSelector.objs do
    if v.text == name then
      v:dispatchEvent{name="tap", target=v}
      return
    end
  end
end

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.groupTable = groupTable
  helper.init(props)


end

function M.suite_setup()
  -- selectors.projectPageSelector:show()
  -- selectors.projectPageSelector:onClick(true)
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  -- bookTable.commandHandler({book="book"}, nil,  true)
  -- pageTable.commandHandler({page="page1"},nil,  true)
  -- selectors.componentSelector.iconHander()
end

function M.setup()
end

function M.teardown()
end

function xM.test_onTap()

  helper.selectLayer("star", "button", false) -- isRightClick
  helper.selectIcon("Interactions", "Button")
  helper.clickProp(actionbox.objs, "onTap")
  helper.clickButton("New", actionButtonContext)
  picker.obj.field.text = "testAction"
  helper.clickObj(picker.buttonObjs, "Continue")

  helper.selectActionGroup("Animation")
  helper.selectActionCommand("animation", "play")

  --helper.selectLayer("GroupA/SubA/Triangle", "linear", false) -- isRightClick


  -- helper.selectLayer("star", "button", true) -- isRightClick
  -- helper.clickProp(actionbox.objs, "onTap")

end

--[[
function M.test_select_layer()
  local name = "gotoBtn"
  for i, entry in next,layerTable.objs do
    print("", i, entry.text)
    if entry.text == name then
      entry:touch({phase="ended"}) -- layer props
      break
    end
  end
end
--]]
--[[
  function M.test_select_button()
    local name = "gotoBtn"
    for i, entry in next,layerTable.objs do
      print("", i, entry.text)
      if entry.text == name then
        entry.classEntries[1]:touch({phase="ended"}) -- animation
        break
      end
    end
    --
    local button = "save"
    local obj = require("editor.parts.buttons").objs[button]
    obj:tap()
    --
  end
--]]


local function selectCancel()
  local button = "cancel"
  local obj = require("editor.parts.buttons").objs[button]
  obj.rect:tap()
end

function M.xtest_new_group_button()

  selectors.componentSelector:onClick(true,  "groupTable")
  local name = "groupCat"
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Button")
end

---[[
function M.xtest_new_button()
  selectors.componentSelector:onClick(true,  "layerTable")

  local name = "cat"
  for i, entry in next,layerTable.objs do
    print("", i, entry.text)
    if entry.text == name then
      entry:touch({phase="ended"}) -- gotoBtn
      break
    end
  end
    --print("-----------------")
    -- for k, v in pairs(toolbar.layerToolMap.Interactions) do print(k, v) end
    -- for k, v in pairs(toolbar.toolMap) do print(k, v) end
    -- selectTool{class="button", isNew=true}

    helper.selectIcon("Interactions", "Button")

    local obj = actionbox.objs[1]
    obj:dispatchEvent({name="tap", target=obj})

    actionTable.altDown = true
    selectAction("eventOne")
    actionTable.altDown = false

    -- selectCancel()
    --selectIcon("Interactions", "Button")


    -- local button = "save"
    -- local obj = require("editor.parts.buttons").objs[button]
    -- obj.rect:tap()

  -- selectors.componentSelector:onClick(true,  "actionTable")
  -- selectAction("eventOne")

  --  select an over-layer
    -- click "over" of the prop's name to make it active
    --   layerTable is displayed
    --   select a layer

  -- select a mask
    -- click "mask" of the prop's name to make it active
    --   layerTable is displayed
    --   select a layer

  -- selet an action
    -- click "over" of the prop's name to make it active
    --   layerTable is displayed
    --   select a layer

    -- --
  end
--]]

--[[
function M.test_new_button_cancel()
  local name = "gotoBtn"
  for i, entry in next,layerTable.objs do
    print("", i, entry.text)
    if entry.text == name then
      entry:touch({phase="ended"}) -- gotoBtn
      break
    end
  end

  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "button", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )

  -- Canel
  local button = "cancel"
  local obj = require("editor.parts.buttons").objs[button]
  obj:tap()
end
--]]


--[[
  function M.test_add_second_button()
    local name = "gotoBtn"
    for i, entry in next,layerTable.objs do
      print("", i, entry.text)
      if entry.text == name then
        entry.classEntries[1]:touch({phase="ended"}) -- animation
        break
      end
    end

    UI.scene.app:dispatchEvent(
      {
        name = "editor.selector.selectTool",
        UI = UI,
        class = "button", -- obj.class,
        -- toolbar = self,
        isNew = true
      }
    )

    local button = "save"
    local obj = require("editor.parts.buttons").objs[button]
    obj:tap()

  end
--]]


return M
