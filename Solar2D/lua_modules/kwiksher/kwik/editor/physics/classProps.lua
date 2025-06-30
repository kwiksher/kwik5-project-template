local current = ...
local parent,root, M = newModule(current)
local keyEventManager = require("editor.keyEventManager")

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"

local function onKeyEvent(self, event)
  -- Print which key was pressed down/up
  local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
  -- print(M.name, message)
  -- for k, v in pairs(event) do print(k, v) end
  self.altDown = false
  self.controlDown = false
  if isWindows then
    if event.phase == "down" then
      -- printKeys(event)
      self.altDown = event.isCtrlDown and event.isShiftDown
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      self.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      self.shiftDown = true
    end
  else
    if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
      -- print("baseTable", self.name, message)
      self.altDown = true
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      self.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      self.shiftDown = true
    end
  end
  -- print("controlDown", M.controlDown)
end
--
local basePropsControl   = require(kwikGlobal.ROOT.."editor.parts.basePropsControl")
local layerTable         = require(kwikGlobal.ROOT.."editor.parts.layerTable")
local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local selectbox          = require(kwikGlobal.ROOT.."editor.physics.selectbox")
local model              = require(kwikGlobal.ROOT.."template.components.pageX.physics.defaults.joint")
local pointA        = require(kwikGlobal.ROOT.."editor.animation.pointA")
local pointB        = require(kwikGlobal.ROOT.."editor.animation.pointB")
--
function M:tapListener(event, type)
  -- print("tapListener", type)
  -- event.actionbox = self
  if self:isAltDown() then -- show Focus
    -- print("altDown")
    local bodyA = self.objs[1].field.text
    local bodyB = self.objs[2].field.text

    local selections = {}
    for i, v in next, layerTable.objs do
      if v.layer == bodyA or v.layer == bodyB then
        selections[#selections + 1] = v
      end
    end
    layerTable.selections = selections
    layerTableCommands.showFocus(layerTable)
  else
    self.activeProp = event.target.text
    -- print("activeProp", event.target.text)
    layerTable.classProps = self
    basePropsControl.handler[type](event, self)
  end
end

M.onTapLayerSet = table:mySet{"_target", "_bodyA", "_bodyB", "_body"}
M.onTapActionSet =  table:mySet{"onComplete", "onCollision"}
M.onTapPosXYSet = table:mySet{"anchor_x", "anchorA_x", "anchorB_x", "statA_x", "stateB_x", "bodyA_x", "bodyB_x", "offsetA_x", "offsetB_x"}
--
function M:setActiveProp(layer, class)
  print("setActiveProp", self.activeProp, layer, class)
  local name =self.activeProp
  local value = layer
  local UI = self.UI
  --
  if self.activeProp =="others" then
    -- print("@@@@", layer, class)
    for i,v in next, self.objs do
      if v.text == "others" then
        v.field.text = layer
        break
      end
    end
  elseif self.onTapLayerSet[self.activeProp] then
    local fields = {_bodyA=NIL, _bodyA=NIL, _body=NIL, anchor_x=NIL, anchor_y=NIL, anchorA_x=NIL, anchorA_y=NIL, anchorB_x=NIL, anchorB_y=NIL, statA_x=NIL, statB_x=NIL, statB_y=NIL, bodyA_x, bodyA_y, bodyB_x, bodyB_y}
    for i,v in next, self.objs do
      if v.text == name then
        -- print("name", name)
        v.field.text = value
      end
      -- print("", name)
      fields[v.text] = v
    end
    -- print("joint type", selectbox.selectedTextLabel)
    local joint = selectbox.selectedTextLabel
    local bodyA, bodyB = self.objs[1], self.objs[2]

    -- for k, v in pairs(UI.sceneGroup) do print(k) end

    local objA = UI.sceneGroup[bodyA.field.text]
    local objB = UI.sceneGroup[bodyB.field.text]

    local bodyA_x = bodyA.field.text .. ".x"
    local bodyA_y = bodyA.field.text .. ".y"
    local bodyB_x = bodyB.field.text .. ".x"
    local bodyB_y = bodyB.field.text .. ".y"
    local offsetA_x, offsetA_y, offsetB_x, offsetB_y = 0, 0, 0, 0

    if objA.shapedWith and objA.anchorX == 0 then
      bodyA_x = bodyA_x .."+".. bodyA.field.text ..".width/2"
      bodyA_y = bodyA_y.."+" .. bodyA.field.text ..".height/2"
      offsetA_x = bodyA.field.text ..".width/2"
      offsetA_y =  bodyA.field.text ..".height/2"
    end

    if objB and objB.shapedWith and objB.anchorY == 0 then
      bodyB_x = bodyA_x .."+".. bodyB.field.text ..".width/2"
      bodyB_y = bodyA_y.."+" .. bodyB.field.text ..".height/2"
      offsetB_x =  bodyB.field.text ..".width/2"
      offsetB_y =  bodyB.field.text ..".height/2"
    end

    if joint == "touch" then
      fields.anchor_x.field.text = bodyA_x
      fields.anchor_y.field.text = bodyA_y
      pointA:setValue{x=objA.x + objA.width/2, y = objA.y + objA.height/2}
      pointA:setActiveEntry(bodyA)
      pointB:setValue()
    else
      -- for A
      if bodyA.field.text:len() > 0 then
        -- print(joint, bodyA.field.text)
        if joint == "pivot" or joint == "weld"  or joint == "friction" then
          fields.anchor_x.field.text = bodyA_x
          fields.anchor_y.field.text = bodyA_y
        elseif joint == "piston" then
          fields.anchor_x.field.text = bodyA_x
          fields.anchor_y.field.text = bodyA_y
        elseif joint == "distance" then
          fields.anchorA_x.field.text = bodyA_x
          fields.anchorA_y.field.text = bodyA_y
        elseif joint == "rope" then
          fields.offsetA_x.field.text = offsetA_x
          fields.offsetA_y.field.text = offsetA_y
        elseif joint == "pulley" then
          fields.statA_x.field.text = bodyA_x
          fields.statA_y.field.text = bodyA_y
          fields.bodyA_x.field.text = bodyA_x
          fields.bodyA_y.field.text = bodyA_y
        end
        pointA:setValue{x=objA.x + objA.width/2, y = objA.y + objA.height/2}
        -- pointA:setActiveEntry(bodyA)
        pointA:setBodyName(bodyA.field.text)
      else
        pointA:setValue()
      end
      -- for B
      if bodyB.field.text:len() > 0 then
        if joint == "distance" then
          fields.anchorB_x.field.text = bodyB_x
          fields.anchorB_y.field.text = bodyB_y
        elseif joint == "pulley" then
          fields.statB_x.field.text = bodyB_x
          fields.statB_y.field.text = bodyB_y
          fields.bodyB_x.field.text = bodyB_x
          fields.bodyB_y.field.text = bodyB_y
        elseif joint == "rope" then
          fields.offsetB_x.field.text = offsetB_x
          fields.offsetB_y.field.text = offsetB_y
        elseif joint == "wheel" then
          fields.anchor_x.field.text = bodyB_x
          fields.anchor_y.field.text = bodyB_y
          pointA:setValue()
        end
        pointB:setValue{x=objB.x + objB.width/2, y = objB.y + objB.height/2}
        -- pointB:setActiveEntry(bodyB)
        pointB:setBodyName(bodyB.field.text)
      else
        pointB:setValue()
      end
    end
  else
    -- TBI show popup
  end
  return true
end

--
function M:isAltDown()
    return self.altDown
end
--
function M:isControlDown()
  return self.controlDown
end
--
function M:isShiftDown()
  return self.shiftDown
end

function M:didShow(UI)
  self.UI = UI
  self.keyListener = function(event) onKeyEvent(self, event)end
  keyEventManager.register("physicsClassProps", self.keyListener, 1)
end

--
function M:didHide(UI)
  -- print(self.name, "didHide")
  keyEventManager.unregister("physicsClassProps")
end

return setmetatable( M, {__index=require(root.."parts.classProps")} )