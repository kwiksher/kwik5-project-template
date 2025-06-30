local name = ...
local parent, root = newModule(name)
local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")
local util = require(kwikGlobal.ROOT.."editor.util")

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local props = params.props
    -- printKeys(props.target)
    -- print(props.layer, props.class)
    -- for i, v in next, UI.editor.selections do
    --   print("", v.text)
    -- end
    --
    if UI.editor.selections and #UI.editor.selections > 1 then
      -- use selection to load the props and if saved, apply it to the selected layers
      -- how to tell multiple editor to save button' event?
      --
    else
      -- edit one layer
      -- local layer = UI.editor.selections[1]
      if props.class and props.class:len() > 0 then
        if props.class == "timer" then
          print(props.target.timer)
          UI.scene.app:dispatchEvent {
            name = "editor.selector.selectTimer",
            UI = UI,
            class = props.class,
            isNew = false,
            timer = props.target.timer
            -- toogle = true -- <========
          }
        elseif props.class == "variable" then
          print(props.target.variable)
          UI.scene.app:dispatchEvent {
            name = "editor.selector.selectVariable",
            UI = UI,
            class = props.class,
            isNew = false,
            timer = props.target.variable
            -- toogle = true -- <========
          }
        elseif props.class == "joint" then
          print(props.target.joint)
          UI.scene.app:dispatchEvent {
            name = "editor.selector.selectJoint",
            UI = UI,
            class = props.class,
            isNew = false,
            joint = props.target.joint
            -- toogle = true -- <========
          }
        else
          UI.scene.app:dispatchEvent {
            name = "editor.selector.selectTool",
            UI = UI,
            class = props.class,
            isNew = false,
            layer = props.layer
            -- toogle = true -- <========
          }
        end
      elseif UI.editor.currentType == "group" then
        UI.scene.app:dispatchEvent {
          name = "editor.selector.selectGroup",
          UI = UI,
          class = "group",
          group = props.layer
        }
      else
        local path = util.getParent(props)
        UI.scene.app:dispatchEvent {
          name = "editor.selector.selectLayer",
          UI = UI,
          path = path,
          isIndex = props.isIndex,
          layer = props.layer
        }
      end
    end

    -- local props = UI.useClassEditorProps()
    -- for k, v in pairs(props) do
    --   print("", k, v)
    -- end

    -- toolbar:toogleToolMap()

    --
    -- TBI
    --  show layerProps table for editor with save/cancel buttons
    --
  end
)
--
return instance
