local current = ...
local parent,root, M = newModule(current)
--
local model      = require(kwikGlobal.ROOT.."editor.physics.model")
local json       = require("json")
local yaml = require("server.yaml")


local selectIndex = 1

function M:setValue(decoded, index, template)
  if decoded == nil then return end
  if template then
    if decoded.class == "joint" then
      self.selectbox:setTemplate(decoded)  -- "linear 1", "rotation 1" ...
      local value = self.selectbox.model[selectIndex]
      self.classProps:setValue(value.entries)
    else
      --self.selectbox:setTemplate(decoded)  -- "linear 1", "rotation 1" ...
      --local value = self.selectbox.model[selectIndex]
      self.selectbox:setValue({})
      -- print("@@@@", decoded.class)
      if decoded.class ~= "page" then
        decoded.properties["_body"] = self.layer
      end
      self.classProps:setValue(decoded)
    end
    self.class = decoded.class

    local props = {}
    if decoded.actions then
      for k, v in pairs (decoded.actions) do
        -- print("actions", k)
        props[#props+1] = {name=k, value=""}
      end
      self.actionbox:setValue(props)
      -- self.actionbox:initActiveProp(props)

    else
      --self.actionbox:hide()
      -- print("no actionbox")
      self.actionbox:setValue()
    end
  else
    -- print(json.encode(decoded[index]))
    self.classProps:setValue(decoded[index].properties)
    local props = {}
    local actions = decoded[index].actions
    if actions then
      for k, v in pairs (actions) do
        props[#props+1] = {name=k, value=v}
      end
      self.actionbox:setValue(props)
      -- self.actionbox:initActiveProp(actions)
    end
    if decoded[index].class == "joint" then
      self.selectbox:setValue(decoded, index)  -- "linear 1", "rotation 1" ...
    else
      self.selectbox:setValue({})
    end
    self.class = decoded[index].class
  end
end

function M:useClassEditorProps(UI)
  -- print("physics.useClassEditorProps",  self.class)
  local props = { properties = {}}
  --
  if self.classProps == nil then
    print("#Error self.classProps is nil for ", self.tool)
  end

  -- print ("@@", #self.classProps.objs)

  for i, obj in next, self.classProps.objs do
    local name = obj.text
    local value = obj.field.text
    name = name:gsub("_body", "body")
    if name == "_type" then
      props.properties[#props.properties + 1] = {name=value, value=true}
    elseif name == "walls" then
      local _value =yaml.evalTable(value)
      props.properties[#props.properties + 1] = {name = name, value=_value}
    else
      props.properties[#props.properties + 1] = {name = name, value=value}
    end

    if name == "body" then
      -- props.name = value
      props.layer = value
    end
  end
  if self.class == "joint" then
    local objs = self.classProps.objs
    -- print("@@@@", objs[1], objs[2])
    if objs[2].text == "_type" then
      local body, typeObj = objs[1], objs[2]
      props.name = body.field.text.."_"..typeObj.field.text
    else
      local bodyA, bodyB, typeObj = objs[1], objs[2], objs[3]
      props.name = bodyA.field.text.."_"..bodyB.field.text .."_"..typeObj.field.text
    end
    props.isNew = true
  end
  props.class = self.class
  --
  -- props.actionName =self.actionbox.value

  if self.actionbox then
    props.actions =self.actionbox:getValue()
  end
  --
  -- if self.picker then
  --   props.name = picker:getValue()
  -- end

  return props
end

function M:show()
  -- print(self.id, self.class)
  if self.viewGroup then
    for k, v in pairs(self.viewGroup) do
      v:show()
    end
    self.view.group.isVisible = true
  end
  if self.class ~="joint" then
    self.pointA:hide()
    self.pointB:hide()
  end
end

function M:hide()
  if self.viewGroup and self.view.group then
    for k, v in pairs(self.viewGroup) do
      v:hide()
    end
    self.view.group.isVisible = false
  end
end


function M.new(views)
  local module = require(kwikGlobal.ROOT.."editor.controller.index").new(model.id)
  -- print(module.id, model.id)
  -- print(debug.traceback())
  module:init(views)
  module.setValue = M.setValue
  module.show = M.show
  module.hide = M.hide
  module.useClassEditorProps = M.useClassEditorProps
  module.buttons.useClassEditorProps = M.useClassEditorProps

  return module
end

return M
