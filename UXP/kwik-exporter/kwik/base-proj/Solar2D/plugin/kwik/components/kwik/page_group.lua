local M = {
  -- name       = {{name}},
  -- members   = {
    --  {{#members}} {{.}}, {{/members}}
    -- },
  -- properties = {
    -- isLuaTable = false,               -- if true, a group holds names of layers but not creating diplay.newGroup()
    -- alpha = {{alpha}},
    -- xScale = {{scaleW}},
    -- yScale = {{scaleH}},
    -- rotation = {{rotation}},
  --}
}

-- "name"  : "myGroup",
-- "members":["copyright", "star"],

-- "name"  : "GroupA",
-- "members":["GroupA.Ellipse", "GroupA.SubA"],

-- "name"  : "SubA",
-- "members":["GroupA.SubA.Triangle"],



---------------------
-- Capture and set group position
 local function groupPos(obj)
    local minX, minY = 0, 0
    for i = 1, obj.numChildren do
       local currentRecord = obj[ i ]
       if i == 1 then
          minX = currentRecord.x - currentRecord.contentWidth * 0.5
          minY = currentRecord.y - currentRecord.contentHeight * 0.5
       end
       local mX = currentRecord.x - currentRecord.contentWidth * 0.5
       if mX < minX then
          minX = mX
       end
       local mY = currentRecord.y - currentRecord.contentHeight * 0.5
       if mY < minY then
          minY = mY
       end
    end
    obj.x = minX + obj.contentWidth * 0.5
    obj.y = minY + obj.contentHeight * 0.5
end
--

function M:init(UI)
end

function M:create(UI)
  local sceneGroup  = UI.sceneGroup
  local layers       = UI.layers
  local props = self.properties
  if props.isLuaTable then
    UI.groups[self.name] = {}
    for k, v in pairs(self.members) do
      UI.groups[self.name][k] = v -- {{chldName}}
    end
  else
    local group = display.newGroup()
    group.anchorX = 0.5
    group.anchorY = 0.5
    group.anchorChildren = true

    -- printKeys(sceneGroup)
    for i=1, #self.members do
      local member = self.members[i]:gsub("%.","/")
      local obj = sceneGroup[member]
      if obj then
        group:insert(obj)
      else
        print("## error layer not found", self.members[i], member )
      end
    end

    group.alpha = NilCheck(props.alpha) or 1
    group.oldAlpha = props.alpha
    group.oriXs = group.xScale
    group.oriYs = group.yScale
    group.xScale = NilCheck(props.xScale) or 1
    group.yScale = NilCheck(props.yScale) or 1
    group.rotation = NilCheck(props.rotation) or group.rotation
    group.oriX = group.x
    group.oriY = group.y

    groupPos(group)
    sceneGroup:insert(group)
    sceneGroup[self.name] = group
    -- print("@@@@", self.name)
    self.group = group
    UI.groups[self.name] = group
  end
end
--
function M:didShow(UI)
end
--
function M:destroy(UI)
  if props.isLuaTable then
    UI.groups[self.name] = nil
  else
    UI.groups[self.name]:removeSelf()
    UI.groups[self.name] = nil
  end
end
--
function M:willHide(UI)
end

M.set = function(instance)
	return setmetatable(instance, {__index=M})
end

return M