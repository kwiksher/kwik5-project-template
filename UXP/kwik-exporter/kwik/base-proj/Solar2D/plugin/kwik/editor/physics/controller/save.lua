local name = ...
local parent, root = newModule(name)
local util = require(kwikGlobal.ROOT.."editor.util")
local controller = require(kwikGlobal.ROOT.."editor.physics.index").controller
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local json = require("json")
--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    -- print("", name, params.class)
    local UI = params.UI
    local props = controller:useClassEditorProps(UI)
    local args = {
      UI = params.UI,
      book = params.book or params.UI.editor.currentBook,
      page = params.page or params.UI.page,
      updatedModel = util.createIndexModel(params.UI.scene.model),
      props = props,
      -- completebox   = params.actionbox or controller.actionbox,
      isNew = props.isNew,
      class = props.class,
    }
    local selectbox = params.selectbox or controller.selectbox
    args.selected = selectbox.selection or {}

    -- if args.isNew then
    if props.class == "joint"  then
      local function isJoint()
        for i, v in next, args.updatedModel.components.joints do
          if v == props.name then
            return true
          end
        end
        return false
      end
      --
      if not isJoint() then
        local index = params.index or #args.updatedModel.components.joints + 1
        table.insert(args.updatedModel.components.joints, index, props.name)
        -- print(json.encode(args.updatedModel.components))
      end
      --
      scripts.publish(UI, args, controller)
    elseif props.class == "page" then  -- physics env
      args.class = "page"
      args.props.name  = "physics"
      local function isPhysics()
        for i, v in next, args.updatedModel.components.page do
          if v == "physics" then
            return true
          end
        end
        return false
      end
      if not isPhysics() then
        table.insert(args.updatedModel.components.page, "physics")
      end
      scripts.publish(UI, args, controller)
    else -- multi new/edit

      -- print("@@@", props.layer, props.class)

        local layer = props.layer or UI.editor.currentLayer
        if layer == nil then
          layer = props.name
          -- print("layer", layer, props.class)
          props.layer = props.name
        else
          -- print("layer", props.name, layer, props.class)
        end

        if not props.isNew or #UI.editor.selections > 1 then

          -- print(json.prettify(props))

          scripts.publishForSelections(
            UI,
            {
              book = props.book,
              page = props.page,
              layer = layer,
              class = props.class,
              props = props
            },
            controller,
            params.decoded or {}
          )
        else
          -- single new/edit
          args.updatedModel = util.createIndexModel(params.UI.scene.model, layer, props.class)
          scripts.publish(UI, args, controller)
        end
    end
  end
)
return instance
