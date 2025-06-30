local M = {}
--
function M:init(UI)
  -- print(#self.modules)
  for i = 1, #self.modules do
    -- print(self.modules[i].name)
    self.modules[i]:init(UI)
  end
end
--
function M:create(UI)
  for i = 1, #self.modules do
    self.modules[i]:create(UI)
  end
end
--
function M:didShow(UI)
  for i = 1, #self.modules do
    self.modules[i]:didShow(UI)
  end
end
--
function M:didHide(UI)
  for i = 1, #self.modules do
    self.modules[i]:didHide(UI)
  end
end
--
function M:destroy(UI)
  for i = 1, #self.modules do
    self.modules[i]:destroy(UI)
  end
end

local function iterator(entries, parent, entry, path)
  local classEntries = {}
  local parentPath = parent or ""
  -- print(parentPath)
    --for i = 1, #entry do -- { {childOne = {}}, {childTwo={class={"linear"}}, {childThree = {{childFour={}}}} }
      --local layer = entry[i]
      --for name, value in pairs(layer) do --
      for name, value in pairs(entry) do --
        -- print("", name, value)
        -- print("", "string")
        if type(value)=="table" and #value > 0 then
          entries[#entries + 1] = parentPath .. name .. ".index"
          for i = 1, #value do
            ---
            local entry = value[i]
            if type(entry) == "table" then
              local ret = iterator(entries, name..".", entry)
              for j = 1, #ret do
                entries[#entries + 1] = ret[j].path .. "_" .. ret[j].class
              end
            end
          end

          -- local ret =
          --   iterator(
          --   entries,
          --   name,
          --   value, -- value is array of entry
          --   parentPath .. name .. "."
          -- )

          -- for j = 1, #ret do
          --   entries[#entries + 1] = ret[j].path .. "_" .. ret[j].class
          -- end
        else
          if value.class then
            for k, class in pairs(value.class) do
              -- print("", class, parentPath .. name)
              local className = class:split('.')
              table.insert(
                classEntries,
                {
                  class = className[1],
                  path = parentPath .. name
                }
              )
              -- entries[funcName](entries, class, parentPath .. name, false)
            end
          end
          entries[#entries + 1] = parentPath .. name
        end
      end
    --end
  return classEntries
end

M.new = function(instance)
  local modules = {}
  local pos =  instance.path:find("index")
  if pos then
    local mod = require("App."..instance.path)
    if mod.children == nil then
      local paths = instance.path:split(".")
      local scenePath = paths[1] .. "." .. paths[2] .. "." .. paths[3] .. ".index"
      -- print("@@@@@@@@",scenePath)
      local scene = require("App."..scenePath)
      -- scene.models.layers
      scene:init()
    end
    local moduleEntries = {}
    for i = 1, #mod.children do
      ---
      local entry = mod.children[i]
      if type(entry) == "table" then
        local ret = iterator(moduleEntries, nil, entry, nil)
        for j = 1, #ret do
          moduleEntries[#moduleEntries + 1] = ret[j].path .. "_" .. ret[j].class
        end
      end
    end
    --
    local function getProps(t, name_class)
      local index = 1
      local args = name_class:split('.')
      -- for k, v in pairs(args) do print(k, v) end
      ---
      local function propsIterator(t, args, index)
        if #args == index then
          -- print("     @", t[args[index]])
          return t[args[index]]
        else
          local tt = t[args[index]]
          if type(tt) == "table" and tt[args[index+1]] then
            return  propsIterator(tt, args, index+1)
          end
          return nil
        end
      end
      --
      ret = propsIterator(t, args, index)
      return ret
    end
    --
    for i=1, #moduleEntries do
      local name_class = moduleEntries[i]
      -- print("@@@@@@@@@@", name_class)
      local props = getProps(instance.props, name_class)
      if props then
       -- props.parent = instance.name
        -- print("", instance.path:sub(1, pos-1)..moduleEntries[i])
        modules[#modules + 1] = require("App."..instance.path:sub(1, pos-1)..name_class):new(props)
      end
    end
  else
    -- print("@@@@", "App."..instance.path)
    local mod = require("App."..instance.path)
    table.insert(modules, mod:new(instance))
    if instance.class then
      for i = 1, #instance.class do
        local class = instance.class[i]
        mod = require("App."..instance.path.."_"..class)
        local props = instance.classProps[class]
        props.name = instance.name
        table.insert(modules, mod:new(props))
      end
    end
  end
  instance.modules = modules
  return setmetatable(instance, {__index = M})
end
--
return M
