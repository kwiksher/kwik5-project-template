local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book="book"}, nil,  true)
  pageTable.commandHandler({page="page4"},nil,  true)
  selectors.componentSelector.iconHander()
  -- selectors.componentSelector:onClick(true,  "layerTable")
end

local function selectIcon(toolGroup, tool)
  local toolbar = UI.editor.toolbar
  local obj = toolbar.layerToolMap[toolGroup]
  obj.callBack{target=obj}
  if tool then
    local obj = toolbar.toolMap[obj.id.."-"..tool]
    obj.callBack{target=obj}
  end
end

function M.setup()
end

function M.teardown()
end

function M.xtest_select()
  -- selectIcon("Physics", "Physics")
  -- selectIcon("Physics", "Body")
  -- selectIcon("Physics", "Collision")
  --selectIcon("Physics", "Force")
  selectIcon("Physics", "Joint")
end

function M.xtest_new_body()

  -- local classProps    = require("editor.physics.classProps")
  -- local bodyA = classProps.objs[1]
  -- local bodyB = classProps.objs[2]
  -- -- bodyA.field.text = "test"
  -- bodyA:dispatchEvent{name="tap", target=bodyA}

  layerTable.controlDown = true

  local obj = layerTable.objs[8] -- car
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}

  obj = layerTable.objs[9] -- wheel2
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}

  obj = layerTable.objs[10] -- wheel1
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}

  layerTable.controlDown = false

  selectIcon("Physics", "Body")

  -- local buttons = require("editor.physics.buttons")
  --local obj = buttons.objs["save"]
  -- obj.rect:tap()

end

function M.xtest_select_joints()
  selectors.componentSelector:onClick(true,  "layerTable")
  selectors.componentSelector:onClick(true,  "jointTable")
  local jointTable = require("editor.physics.jointTable")
  local obj = jointTable.objs[1]

  jointTable.altDown = true
  obj:touch{phase="ended"}
  jointTable.altDown = false

end

function M.xtest_new_joint()
  selectIcon("Physics", "Joint")

  local selectbox = require("editor.physics.selectbox")
  local obj = selectbox.objs[10] -- wheel
  obj:dispatchEvent{name="tap", target=obj}

  local classProps    = require("editor.physics.classProps")
  local bodyA = classProps.objs[1]
  local bodyB = classProps.objs[2]
  -- bodyA.field.text = "test"
  bodyA:dispatchEvent{name="tap", target=bodyA}

  obj = layerTable.objs[8] -- car
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}

  bodyB:dispatchEvent{name="tap", target=bodyB}
  obj = layerTable.objs[10] -- wheel1
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}

  local buttons = require("editor.physics.buttons")
  --local obj = buttons.objs["save"]
  -- obj.rect:tap()

end

function M.xtest_phsyics_settings()
  selectIcon("Physics", "Physics")
end

function M.xtest_phsyics_force()
  obj = layerTable.objs[8] -- car
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}
  selectIcon("Physics", "Force")

end

function M.test_phsyics_collision()
  obj = layerTable.objs[8] -- car
  obj:dispatchEvent{name="touch", target=obj, phase="ended"}
  selectIcon("Physics", "Collision")
end

return M
