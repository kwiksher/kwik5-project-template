# how to add a component

editor/index.lua and baseTable.lua handles user' selection from xxxTable
commands/selectors/selectXXX.lua reads a json

selectors.lua handles to read values of UI.scene.model.components for xxxTable.

1. editor/models.lua

    this defines layer related components. it does not include audio, group, timer, variables and action.

    ```lua
      local models = {
        {
            name = "Animations",
            icon = "toolAnim",
            tools = {
              {name = "Linear", icon = "animLinear"},
              {name = "Blink", icon = "animBlink"},
              {name = "Bounce", icon = "animBounce"},
              {name = "Pulse", icon = "animPulse"},
              {name = "Rotation", icon = "animRotation"},
              {name = "Shake", icon = "animShake"},
              {name = "Switch", icon = "animSwitch"},
              {name = "Filter", icon = "animFilter"},
              {name = "Path", icon = "animPath"},
            },
            id = "animation"
         },
        ...
    ```

    editor/index.lua loads it. The id is used to load a module for editor a component like

      ``` lua
      animation = require(kwikGlobal.ROOT.."editor.animation.index")
      ```

    For audio, group, timer and variables, the icons and the modules are loaded with their table.lua for instance, **groupTable.lua**

    ```lua
    local name = ...
    local parent = name:match("(.-)[^%.]+$")

    local Props = {
      name = "group",
      anchorName = "selectGroup",
      icons = {"Groups", "trash"},
      id = "group"
    }

    local M = require(parent.."parts.baseTable").new(Props)
    return M

    ```

    action' icon/module ared loaded with **action/index.lua**. It is called by editor/index.lua

    ```lua
      local actionIcon = muiIcon:create {
      icon = {"actions_over", "actions_over","actions_over"},
      text = "",
      name = "action-icon",
      x = display.contentCenterX/2 + 42,
      y = -2,
      -- y = (display.actualContentHeight - display.contentHeight)/2 -2,
      width = 22,
      height = 22,
      fontSize =16,
      listener = function()
        self.isVisible = not self.isVisible
        if self.isVisible then
          self:show()
        else
            self:hide()
          end
        end,
        fillColor = {1.0}
      }

      UI.editor.actionIcon = actionIcon
    ```

1. editor/index.lua

    Add  {name = "selectXXX", btree= "load xxx"}

    ``` lua
    M.commands = {{name="selectApp", btree=nil},
      {name="selectBook", btree="load book"},
      {name="selectPage", btree="load page"},
      {name="selectLayer", btree="load layer"},
      -- {name="selectAction", btree=""},
      {name="selectTool", btree="editor component"},
      -- {name="selectActionCommand", btree=""}
      {name="selectAudio", btree="load audio"},
      {name="selectGroup", btree="load group"},
      -- {name="selectTimer", btree="load timer"},
      -- {name="selectVariable", btree="load variable"},
      -- {name="selectVideo", btree="load video"},
    }

    ```

1. new xxxTable out of baseTable.lua

   write like this

    ``` lua
    local name = ...
    local parent = name:match("(.-)[^%.]+$")

    local Props = {
      name = "group",
      anchorName = "selectGroup",
      icons = {"Groups", "trash"},
      id = "group"
    }

    local M = require(parent.."parts.baseTable").new(Props)
    return M

    ```

    this baseTable fires "load xxx" with a selected entry in xxxTable when user clicks it

    baseTable.lua

    ```lua
      tree.backboard = {
        show = true,
        class = target.class
      }

      tree.backboard[self.name] = target[self.name],

      tree:setConditionStatus("select component", bt.SUCCESS, true)
      tree:setActionStatus("load "..self.name, bt.RUNNING, true)
      tree:setConditionStatus("select "..self.name, bt.SUCCESS)
    ```

    then next, this tree action (load xxx) is called back. It is linked to selectXXX command  by editor/index.lua. commands/selectors/selectXXX to load a json of a selected entry

    > assetTable does not use the bt. See assetTableListener:touchHandler()

    > BT will be better if add key-event conditions, and then handler fucntions could remove 'if'.  All the props of handlers should be put in backboard, if all the conditions are defined in the tree, BT handler aggrigates all conditions with bt.SUCESS and actionStatus with bt.Running to rertive a final action node. Then action node is processed in a command function by eventDispatch

1. selectors.lua

    > this is a view model. You see each command to be displayed as a button. It is a anchorName to xxxTable

    Add set store name "xxxTable" and btree = "select component"

    M:create(UI)

    ```lua
      self.componentSelector =
        selectorBase.new(
        UI,
        33,
        -2,
        {
          {label = "Layer", command = "selectLayer", store = "layerTable", filter = true, btree = "select layer"},
          {label = "Audio", command = "selectAudio", store = "audioTable", btree = "select component"},
          {label = "Group", command = "selectGroup", store = "groupTable", btree = "select component"},
          {label = "Timer", command = "selectTimer"},
          {label = "Var", command = "selectVariable"},
          {label = "Action", command = "selectAction", store = "actionTable"}
        },
        "toolLayer",
        selectLayerFilter,
        propsTable,
        propsButtons
      )

    ```

    M:didShow()

    Add xxxStore:set

    ```lua
        UI.editor.layerStore:set({})
        UI.editor.audioStore:set({})
        UI.editor.actionStore:set({})
        UI.editor.groupStore:set({})
        UI.editor.timerStore:set({})
        UI.editor.variableStore:set({})
        --
        if storeTable then
          -- should we show the last secection?
          if storeTable == "layerTable" then
            UI.editor.layerStore:set(UI.scene.model.components.layers)
          elseif storeTable == "audioTable" then
            print(storeTable)
            UI.editor.audioStore:set(UI.scene.model.components.audios)
          elseif storeTable == "groupTable" then
            print(storeTable)
            UI.editor.groupStore:set(UI.scene.model.components.groups)
          elseif storeTable == "actionTable" then
            UI.editor.actionStore:set(UI.scene.model.commands)
          end
      ...
    ```

1. commands/selector/selectXXX

    write code to read json and set it to propsTable

    ```lua
    local command = function (params)
      local UI    = params.UI
      local xxx =  params.xxx or ""

      local path = system.pathForFile( "App/"..UI.editor.currentBook.."/models/"..UI.page .."/audios/"..params.class.."/"..xxx..".json", system.ResourceDirectory)

        local decoded, pos, msg = json.decodeFile( path )
        if not decoded then
          print( "Decode failed at "..tostring(pos)..": "..tostring(msg), path )
        else
          print( "props is decoded!" )
          UI.editor.propsStore:set(decoded)
          propsButtons:show()
        end
    ```

1. for controllers for components are registered either in index.lua or selectors.lua or buttons.lua

    for instance, action/selectors.lua

    ```lua
    M.commands = {"selectAction", "selectActionCommand"}
    ---
    function M:init(UI, toggleHandler)
      local app = App.get()
      for i = 1, #self.commands do
        app.context:mapCommand(
          "editor.action." .. self.commands[i],
          "editor.action.controller." .. self.commands[i]
        )
      end
      self.togglePanel = toggleHandler
    end
    ```

    for animation/buttons.lua

    ```lua
    M.commands = {"create", "delete", "save", "cancel", "copy", "paste"}
    ---
    function M:init(UI, toggleHandler)
      local app = App.get()
      for i = 1, #self.commands do
        app.context:mapCommand(
          "editor.anim." .. self.commands[i],
          "editor.animation.controller." .. self.commands[i]
        )
      end
      self.togglePanel = toggleHandler
    end
    ```