-- local M = require(kwikGlobal.ROOT.."editor.parts.linkTable")
local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new()

-- print(debug.traceback())
---------------------------
M.name = "onComplete"
M.selectedTextLabel = ""
M.onTapActionSet = table:mySet{"onTap", "onComplete", "onMoved", "onDropped", "onReleased", "onCollision",
  "onEnded", "onCounterClockwise", "onClockwise",
  "onUp", "onDown", "onLeft", "onRight"}
M.props = {
  -- {name="onComplete", value=""}
}
-- M.activeProp = M.props[1].name
--
-- load(UI, type, x, y, selectedValue)
--    type = {"action", "animation", "group", "audio"}
--    type.animation loads pageX/index.json to list layers
--    type.action loads the list of files in pageX/commands folder
--  see editor/util.lua read
--        setFiles(ret.audios, "/audios/short")
--        setFiles(ret.audios, "/audios/long")
--        setFiles(ret.groups, "/groups")
--        setFiles(ret.groups, "/commands")

function M:setActiveProp(value)
  local name =self.activeProp or ""
  for i,v in next, self.objs or {} do
    if v.text == name then
      -- print("setActiveProp", self.activeProp, value)
      v.field.text = value
      -- print("###", self.activeProp, value, #self.objs, self)
      return true
    end
  end
  print("Warning activeProp name is not found for", self.activeProp)
end

    -- if self.objs then
    --   for i,v in next, self.objs do
    --     print("@@@@@@@", v.text)
    --     if v.text == name then
    --       v.field.text = value
    --     end
    --   end
    -- end

function M:setValue(value)
  if value == nil then
    self.props = {}
  else
    self.props = value
  end
end

function M:initActiveProp(actions)
  for _name, value in pairs(actions) do
    -- print("@@@@", _name)
    -- print(debug.traceback())
    local name = _name or self.activeProp
    for i,v in next, self.props do
        if v.name == name then
          v.value = value
          return
        end
      end
 end
end

function M:getValue(name)
  -- print(name)
  if self.objs then
    if name then
      for i,v in next, self.objs do
        -- print(v.text)
        if v.text == name then
          return v.field.text
        end
      end
    else
      local ret = {}
      for i,v in next, self.objs do
        ret[v.text] = v.field.text
      end
      return ret
    end
  end
end

return M