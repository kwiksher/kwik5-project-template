local current = ...
local parent,  root = newModule(current)
--
local json = require("json")

local AtoBbutton
local selectbox
local classProps
local pointABbox
local actionbox
local buttons

local M = require(kwikGlobal.ROOT.."editor.controller.index").new("replacement.particles")

function M:init(viewGroup)
  self.viewGroup = viewGroup
  --
  AtoBbutton    = viewGroup.AtoBbutton
  selectbox      = viewGroup.selectbox
  classProps    = viewGroup.classProps
  pointABbox    = viewGroup.pointABbox
  actionbox = viewGroup.actionbox
  buttons       = viewGroup.buttons


  AtoBbutton.useClassEditorProps = function() return self:useClassEditorProps() end
  buttons.useClassEditorProps = function() return self:useClassEditorProps() end

  --AtoBbutton.useBreadcrumbProps = useBreadcrumbProps
  -- buttons.useBreadcrumbProps = useBreadcrumbProps

  -- selectbox.setValue = function(decoded, index)
  --   setValue(decoded, index)
  --   self:redraw()
  -- end
  -- --
  selectbox.useClassEditorProps = function() self:useClassEditorProps() end

  selectbox.classEditorHandler = function(decoded, index)
    self:reset()
    self:setValue(decoded, index)
    self:redraw()
  end


end
  -------
-- I/F
--
function M:useClassEditorProps()
  -- print("useClassEditorProps")
  local props = {
    index = selectbox.selectedIndex,
    name = selectbox.selectedObj.text, -- UI.editor.currentLayer,
    class=selectbox.selectedText.text,
    properties = {},
    easing="Linear",
    to = {},
    from={},
    actionName = nil,
    layerOptions = {
      referencePoint = "Center",
      -- for text
      deltaX         = 0,
      deltaY         = 0
    },
    -- path = false,
    -- breadcrumb = false
    xSwipe = "nil",
    ySwipe = "nil",
    reverse = "nil",
    resetAtEnd = "nil",
  }
  --
  local properties = classProps:getValue()
  for i=1, #properties do
    -- print("", properties[i].name, type(properties[i].value))
    props.properties[properties[i].name] = properties[i].value
  end
  --from
  --to
  local AB = pointABbox:getValue()
  for i=1, #AB do
    props.from[AB[i].name] = tonumber(AB[i].A )
    props.to[AB[i].name] = tonumber(AB[i].B )
  end
  props.actionName = actionbox.selectedTextLabel
  --breadcrumbs
  return props
end

function M:usetBreadcrumbProps()
  return {}
end

--

-- this handler should be called from selectbox to set one of animtations user selected
function M:setValue(decoded, index, template)
  if decoded == nil then print("## Error setValue ##") return end
  if not template then
    --print(json.encode(decoded[index]))
    selectbox:setValue(decoded, index)  -- "linear 1", "rotation 1" ...
    classProps:setValue(decoded[index].properties)
    -- -- breadcrumbs:setValue(decoded[index].breadcrumbs)
    pointABbox:setValue(decoded[index].from, decoded[index].to)
    actionbox:setValue({name="onComplete", value=decoded[index].actionName})
  else
    selectbox:setTemplate(decoded)  -- "linear 1", "rotation 1" ...
    classProps:setValue(decoded.properties)
    -- -- breadcrumbs:setValue(decoded.breadcrumbs)
    pointABbox:setValue(decoded.from, decoded.to)
    actionbox:setValue({name="onComplete", value=decoded.actionName})
  end
end

return M