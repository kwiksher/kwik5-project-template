local current = ...
local parent,  root = newModule(current)
--
local json = require("json")

local pointA
local pointB
local AtoBbutton
local selectbox
local classProps
local breadcrumbsProps
local referencePoint
local pathProps
local filterProps
local pointABbox
local actionbox
local popup
local buttons

local M = require(kwikGlobal.ROOT.."editor.controller.index").new("animation")

function M:init(viewGroup)
  self.viewGroup = viewGroup
  --
  pointA        = viewGroup.pointA
  pointB        = viewGroup.pointB
  AtoBbutton    = viewGroup.AtoBbutton
  selectbox      = viewGroup.selectbox
  classProps    = viewGroup.classProps
  breadcrumbsProps = viewGroup.breadcrumbsProps
  referencePoint = viewGroup.referencePoint
  filterProps      = viewGroup.filterProps
  pathProps    = viewGroup.pathProps
  pointABbox    = viewGroup.pointABbox
  actionbox = viewGroup.actionbox
  popup         = viewGroup.popup
  buttons       = viewGroup.buttons

  AtoBbutton.useClassEditorProps = function(UI) return self:useClassEditorProps(UI) end
  buttons.useClassEditorProps = function(UI) return self:useClassEditorProps(UI) end

  --AtoBbutton.useBreadcrumbProps = useBreadcrumbProps
  -- buttons.useBreadcrumbProps = useBreadcrumbProps

  -- selectbox.setValue = function(decoded, index)
  --   setValue(decoded, index)
  --   self:redraw()
  -- end
  -- --
  selectbox.useClassEditorProps = function(UI) self:useClassEditorProps(UI) end

  selectbox.classEditorHandler = function(decoded, index)
    self:reset()
    self:setValue(decoded, index)
    self:redraw()
  end

end

--- this is a callback from redraw
function M:onShow(UI)
  pointA:setActiveEntryObjs(pointABbox.objs.A[1],pointABbox.objs.A[2])
  pointB:setActiveEntryObjs(pointABbox.objs.B[1],pointABbox.objs.B[2])
  breadcrumbsProps.targetObject = nil
  referencePoint.targetObject = nil
  classProps.targetObject = nil
  --
  local basePropsControl = require(kwikGlobal.ROOT.."editor.parts.basePropsControl")
  basePropsControl.enableFillColor = false

  if UI.editor.currentClass ~= "linear" then
    pointA:hide()
    pointB:hide()
  end
  if UI.editor.currentClass == "switch" or  UI.editor.currentClass == "filter" then
    pointABbox:hide()
  end
  if UI.editor.currentClass ~="path" then
    pathProps:hide()
  end
  -- print("UI.editor.currentClass", UI.editor.currentClass)
  if UI.editor.currentClass ~="filter" then
    filterProps:hide()
  end
end
-------
-- I/F
--
function M:useClassEditorProps(UI)
  print("useClassEditorProps", UI)
  local props = {
    properties = {},
    breadcrumbs = {enable = false},
    easing="Linear",
    to = {
      x = "nil",
      y = "nil",
      alpha = "nil",
      rotation = "nil",
      xScale = "nil",
      yScale = "nil"
    },
    from={
      x = "nil",
      y = "nil",
      alpha = "nil",
      rotation = "nil",
      xScale = "nil",
      yScale = "nil"
    },
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
    useLang  = false
  }

  if selectbox.selectedObj then
    props.index = selectbox.selectedIndex
    props.layer = selectbox.selectedObj.text -- UI.editor.currentLayer,
    props.class=selectbox.selectedText.text
  else
    props.layer = UI.editor.currentLayer -- will be overwritten by classProps._target
    props.type = UI.editor.currentType or NIL
  end
  --
  local properties = classProps:getValue()
  for i=1, #properties do
    -- print("", properties[i].name, type(properties[i].value))
    if properties[i].name == "_target" then
      props.properties.target = properties[i].value
    else
      props.properties[properties[i].name] = properties[i].value
    end
  end

  if props.properties._target then
    props.layer = props.properties._target
  end
  --
  local breadcrumbsProperties = breadcrumbsProps:getValue()
  if #breadcrumbsProperties == 0 then
    props.breadcrumbs = nil
  else
    for i=1, #breadcrumbsProperties do
      -- print("", properties[i].name, type(properties[i].value))
      local name = breadcrumbsProperties[i].name
      if name == "_width" then
        props.breadcrumbs.width = breadcrumbsProperties[i].value
      elseif name == "_height" then
        props.breadcrumbs.height = breadcrumbsProperties[i].value
      elseif name == "color" then
        local value = breadcrumbsProperties[i].value
        local v = {r=value[1], g = value[2], b = value[3], a = value[4]}
        props.breadcrumbs[name] = v
      else
        props.breadcrumbs[name] = breadcrumbsProperties[i].value
      end
    end
  end
  --
  props.layerOptions = {}
  local refProps = referencePoint:getValue()
  for i=1, #refProps do
    -- print("", properties[i].name, type(properties[i].value))
    local name = refProps[i].name
    local value = refProps[i].value
    props.layerOptions[name] = value or 0
   end
  --
  local pathProperties = pathProps:getValue()
  if #pathProperties == 0 then
    props.path = nil
  else
    props.path = {
      filename = "nil",
      newAngle = "NIL",
      closed = "nil",
      pause = "nil",
      autoTurn = "nil"
    }
    --
    for i=1, #pathProperties do
      local name = pathProperties[i].name
      if name == "_filename" then
        props.path.filename = pathProperties[i].value
      elseif pathProperties[i].value:len() > 0 then
        props.path[name] = pathProperties[i].value
      end
    end
    if props.path.closed == nil then
      props.path.closed = path.filename:find("closed") > 0
    end
  end

  local filterProperties, filterPropertiesTo = filterProps:getValue()
  if filterProperties and #filterProperties ~= 0 then
    local util = require(kwikGlobal.ROOT.."lib.util")
    local params = {}
    for i=1, #filterProperties do
      local name = filterProperties[i].name
      if name == "_effect" then
        params.effect = filterProperties[i].value
      elseif name == "_type" then
          params.type = filterProperties[i].value
      else
        params[name] = filterProperties[i].value
      end
    end
    --
    props[params.type] = params
    props[params.effect] = true
    --
    props.from = params
    -- print("------------------")
    -- printTable(props.from, true)
    -- --
    params = {}
    for i=1, #filterPropertiesTo do
      local name = filterPropertiesTo[i].name
      params[name] = filterPropertiesTo[i].value
    end
    props.to = params
    --
  elseif #pointABbox.objs.A > 0 or #pointABbox.objs.B > 0 then
  --from
  --to
    local AB = pointABbox:getValue()
    -- print(json.prettify(AB))

    for i=1, #AB do
      if AB[i].name == "x" or AB[i].name == "y" then
        if AB[i].A:len() > 0 then
          props.from[AB[i].name] = tonumber(AB[i].A ) or "nil"
        else
          props.from[AB[i].name] = "nil"
        end
        if AB[i].B:len() > 0 then
          props.to[AB[i].name] = tonumber(AB[i].B ) or "nil"
        else
          props.from[AB[i].name] =  "nil"
        end
      else
        if AB[i].A:len() > 0 then
          props.from[AB[i].name] = tonumber(AB[i].A ) or "nil"
        else
          props.from[AB[i].name] = "nil"
        end
        --
        if AB[i].B:len() > 0 then
          props.to[AB[i].name] = tonumber(AB[i].B ) or "nil"
        else
          props.to[AB[i].name] = "nil"
        end
      end
    end
  end

  -- print(json.prettify(props.from))
  -- print(json.prettify(props.to))

  props.actions = {onComplete = actionbox.getValue("onComplete")} --selectedTextLabel
  --breadcrumbs
  -- printTable(props)
  return props
end

function M:usetBreadcrumbProps()
  return {}
end

--

-- this handler should be called from selectbox to set one of animtations user selected
function M:setValue(decoded, index, template)
  -- print(debug.traceback())
  if decoded == nil then print("## Error setValue ##") return end
  if not template then
    local model = decoded[index]
    -- print(json.encode(decoded[index]))
    selectbox:setValue(decoded, index)  -- "linear 1", "rotation 1" ...
    classProps:setValue(model.properties)
    breadcrumbsProps:setValue(model.breadcrumbs)
    referencePoint:setValue(model.layerOptions)
    -- if model.composite then
    --   filterProps:setValue(model.composite)
    -- elseif model.filter then
    --   filterProps:setValue(model.filter)
    -- elseif model.generator then
    --   filterProps:setValue(model.generator)
    -- end
    if model.filter then
      filterProps:setValue{
        effect = model.filter.effect,
        type= model.filter.type,
        to =   model.to,
        from = model.from
      }
    end
    if model.path then
      pathProps:setValue(model.path)
    end
    pointA:setValue(model.from, model.layerProps)
    pointB:setValue(model.to, model.layerProps)
    -- -- breadcrumbs:setValue(model.breadcrumbs)
    pointABbox:setValue(model.from, model.to, model.layerProps)
    actionbox:setValue{{name = "onComplete", value=model.actions.onComplete}}
  else
    if decoded.properties.target then
      decoded.properties.target = self.layer
    end
    selectbox:setTemplate(decoded)  -- "linear 1", "rotation 1" ...
    classProps:setValue(decoded.properties)
    breadcrumbsProps:setValue(decoded.breadcrumbs)
    referencePoint:setValue(decoded.layerOptions)
    ---
    if decoded.composite then
      filterProps:setValue(decoded.composite)
    elseif decoded.filter then
      filterProps:setValue(decoded.filter)
    elseif decoded.generator then
      filterProps:setValue(decoded.generator)
    end
    if decoded.path then
      pathProps:setValue(decoded.path)
    end
    pointA:setValue(decoded.from, decoded.layerProps)
    pointB:setValue(decoded.to, decoded.layerProps)
    -- -- breadcrumbs:setValue(decoded.breadcrumbs)
    pointABbox:setValue(decoded.from, decoded.to)
    actionbox:setValue{{name="onComplete", decoded.actions.onComplete}}
  end
end

return M