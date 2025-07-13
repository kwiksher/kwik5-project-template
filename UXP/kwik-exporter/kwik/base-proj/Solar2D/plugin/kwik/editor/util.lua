local M = {}
local json = require("json")
local lfs = require("lfs")
local lustache = require("lustache")
local formatter = require("formatter")
local platform = system.getInfo("platformName")

function M.getPath(str)
  return str:match("(.*[/\\])")
end

function M.getFileName(str)
  local n = str:match("^.+/(.+)$")
  return n:sub(0, #n - 4)
end

local getLayer = function(layerEntry, parent)
  -- print(json.encode(layerEntry))
  for key, v in pairs(layerEntry) do
    -- print("", key)
    if key == "class" then
    elseif key == "event" then
    else
      if parent then
        return parent .."/"..key, v
      else
        return key,  v
      end
    end
  end
  return nil
end

local isTarget = function(layerName, layerEntry, parent)
  for key, v in pairs(layerEntry) do
    -- print("", key)
    if key == "class" then
    elseif key == "event" then
    elseif key == layerName then
      return true
    end
  end
  return false
end
--
local isClass = function(v, class)
  -- print(v, class)
  if v.class then
    for j = 1, #v.class do
      if v.class[j] == class then
        return true
      end
    end
  end
  return false
end

function M.isExist(book, page, layer, class)
  local path =
    system.pathForFile(
    "App/" .. book .. "/components/" .. page .. "/layers/" .. layer .. "_" .. class .. ".lua",
    system.ResourceDirectory
  )
  return path
end

function M.updateIndexModel(_scene, _layerName, class, _type)
  -- print("%%%", _layerName)
  local layerName = _layerName
  -- local child    = _layerName:split("/")
  -- if #child > 1 then
  --   layerName = child[1]
  --   child = child[2]
  -- else
  --   child = nil
  -- end
  --
  local scene =
    _scene or
    {
      components = {
        layers = {},
        audios = {},
        groups = {},
        timers = {},
        variables = {},
        others = {}
      }
    }
  --
  local onInit = scene.onInit
  scene.onInit = nil
  local copied = M.copyTable(scene)
  scene.onInit = onInit
  -- print("----- copied -----")
  -- print(json.prettify(copied))

  -- print("%%%", layerName)
  local function processLayers(layers, nLevel, parent)
    -- print(json.encode(layers))
    for k, layer in pairs(layers) do
      local children = {}
      ---
      local name, value = getLayer(layer, parent)
      -- print("@@@", name, layerName, value )
      if name == layerName then
        -- if child then -- continue to find the target child
        --   layerName = child
        --   child = nil
        -- else
          if value.class == nil then
            value.class = {}
          end
          --
          if not isClass(value, class) and class:len() > 0 then
            table.insert(value.class, class)
          end
          layerName = "found it!"
        -- end
      end

      --
      ---[[
      if layer.class then
        for key, value in pairs(layer) do
          if key == "class" then
          else
            processLayers(value, nLevel + 1, key)
          end
        end
      else
        for key, value in pairs(layer) do
          if type(value) == "table" then
            processLayers(value, nLevel + 1, name)
          end
        end
      end
      --[[
      local children = {}
      for key, value in pairs(layer) do
        print(key, value.class)
        if key == "class" then
        else
          children[#children + 1] = value
          if type(value) == "table" and next(value) then
            if value.class == nil then
              --
              -- {aName = {A={}, B={}}}
              --
              children[#children + 1] = value
            else
              local field, child = next(value, nil)
              while field do
                -- print(field, "=", child, #children +1)
                if field ~= "class" then
                  -- child.layers = false
                  children[#children + 1] = child
                -- elseif newEntry.class == nil then
                --   newEntry.class = child
                end
                field, child = next(value, field)
              end
            end
          end
        end
      end
      --]]

      --[[
      if #children > 0 then
        -- if next(v) == nil then
        --   -- just empty layer without class nor event
        --   v.class = {class}
        -- end
        processLayers(children, nLevel + 1, name)
      else
        -- newEntry.layers = false
      end
      --]]
    end
  end
  --
  if _type == "group" then
    processLayers(copied.components.groups, 1)
  else
    processLayers(copied.components.layers, 1)
  end
  return copied
end

-- https://stackoverflow.com/questions/7526223/how-do-i-know-if-a-table-is-an-array
local function is_array(t)
  local prev = 0
  for k in pairs(t) do
    if k ~= prev + 1 then
      return false
    end
    prev = prev + 1
  end
  return true
end
--
-- nLevel is used for lustache render in createIndexModel
--
function M.createIndexModel(_scene, layerName, class, noRecursive)
  local scene =
    _scene or
    {
      components = {
        layers = {},
        audios = {},
        groups = {},
        timers = {},
        variables = {},
        others = {}
      }
    }
  --
  local onInit = scene.onInit
  scene.onInit = nil
  local copied = M.copyTable(scene)
  scene.onInit = onInit

  local function processLayers(layers, nLevel)
    for i = 1, #layers do
      -- print("------------------", nLevel)
      local layer = layers[i]
      local newEntry = {}
      local children = {}
      --
      if isTarget(layerName, layer) then
        local target = layer[layerName]
        if target.class == nil then
          newEntry["class".. nLevel] = {}
        else
          newEntry["class".. nLevel] = target.class
        end
        --
        if not isClass(newEntry, class) then
          if noRecursive then
            local numOfchildren = #newEntry["class"]
            newEntry["class"][numOfchildren + 1] = class
          else
            local numOfchildren = #newEntry["class".. nLevel]
            newEntry["class".. nLevel][numOfchildren + 1] = class
          end
        end
      end

      --
      local children = {}
      for key, value in next, layer do
        -- print("", key, #value, tostring(is_array(value)))
        if key == "class" then
          -- if newEntry.class == nil then -- this means not isTarget(layerName, layer)
          --   newEntry.class = value
          -- end
        elseif key == "event" then
        else
          if type(key) == "string" then
            newEntry.name = key
          end
          if type(value) == "table" and next(value) then
            if value.class == nil then
              --
              -- {aName = {A={}, B={}}}
              --
              if is_array(value) then
                children = value
              else
                children[#children + 1] = value
              end
            else
              -- print("@@@@", json.encode(children ))
              --
              -- {aName = {class = {"button"), A={}, B={}}}
              --  => {"class"]["button"], "1":{ "A":[]}, "2":{"B":[]}} see the A's and B's object is array

              -- print("###", json.encode(value ))
              if noRecursive then
                local field, child = next(value, nil)
                while field do
                  -- print(field, "=", child, #children +1)
                  if field ~= "class" then
                    -- child.layers = false
                    children[#children + 1] = child
                  elseif newEntry["class"] == nil then
                    newEntry["class"] = child
                  end
                  field, child = next(value, field)
                end
              else
                local field, child = next(value, nil)
                while field do
                  -- print(field, "=", child, #children +1)
                  if field ~= "class" then
                    -- child.layers = false
                    children[#children + 1] = child
                  elseif newEntry["class".. nLevel] == nil then
                    newEntry["class".. nLevel] = child
                  end
                  field, child = next(value, field)
                end
              end
            end
          end
        end
      end
      if #children > 0 then
        -- if next(v) == nil then
        --   -- just empty layer without class nor event
        --   v.class = {class}
        -- end
        -- print(json.prettify(children))
        newEntry["layers" .. nLevel] = processLayers(children, nLevel+1)
      else
        -- newEntry.layers = false
      end
      layers[i] = newEntry
    end
    return layers
  end
  --
  --if layerName then
  processLayers(copied.components.layers, 1)
  processLayers(copied.components.groups, 1)
  -- print(json.encode(copied.components.groups))
  -- local groups = {}
  -- for i, v in next, copied.components.groups do
  --   local entry = {}
  --   for key, value in pairs(v) do
  --     entry.name = key
  --     entry.class = value
  --   end
  --   groups[i] = entry
  -- end
  -- copied.components.groups = groups
  --end
  --
  return copied
end

function M.selectFromIndexModel(model, args)
  --
  local function processLayers(layers, target, level)
    local nextTarget = target[level+1]
    -- print("nextTarget", nextTarget, level)
    for i = 1, #layers do
      local layer = layers[i]
      local children = {}
      --
      for key, value in pairs(layer) do
        -- print(key, value)
        if isTarget(target[level], layer) then
          if nextTarget == nil then
            return {type = "layer", file = key, value = value}
          elseif layer.class and isClass(layer, nextTarget) then
            return {type = "class", file = key .. "_" .. nextTarget}
          else -- look into childen
            if key == "class" then
            elseif key == "event" then
            else
              if next(value) then
                if value.class == nil then
                  --
                  -- {aName = {A={}, B={}}}
                  --
                  children[#children + 1] = value
                else
                  -- print("@@@@", json.encode(children ))
                  --
                  -- {aName = {class = {"button"), A={}, B={}}}
                  --  => {"class"]["button"], "1":{ "A":[]}, "2":{"B":[]}} see the A's and B's object is array

                  -- print("###", json.encode(value ))

                  local field, child = next(value, nil)
                  while field do
                    -- print(field, "=", child, #children +1)
                    if field ~= "class" then
                      -- child.layers = false
                      children[#children + 1] = child
                    elseif layer.class == nil then
                    end
                    field, child = next(value, field)
                  end
                end
              end

              if #children > 0 then
                local ret = processLayers(children, target, level + 1)
                return {type = ret.type, file = target .. "/" .. ret.file}
              end
            end
          end
        end
      end
      -- print("return nil")
      return nil
    end
  end
  --
  local out = processLayers(model.components.layers, args, 1)
  -- print(json.encode(out))
  return out
end

-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function M.copyTable(tbl, convert)
  local new_tbl = {}
  if tbl then
    for key, value in pairs(tbl) do
      local valid =
        key ~= "__index" and key ~= "_class" and key ~= "_tableListeners" and key ~= "_proxy" and
        key ~= "_functionListeners" and
        key ~= "selections" and
        key ~= "rect"
      local value_type = type(value)
      local new_value
      if value_type == "function" then
        -- new_value = loadstring(string.dump(value))
        -- Problems may occur if the function has upvalues.
      elseif value_type == "table" and valid then
        -- print(key)
        if value == NIL then
          new_value = ""
        else
          new_value = M.copyTable(value, convert)
        end
      elseif convert then
        new_value = tostring(value)
      else
        new_value = value
      end

      if value_type ~= "function" and valid then
        new_tbl[key] = new_value
      end
    end
  else
    print("#Error tbl is nil")
  end
  return new_tbl

  -- if decoded then
  --   local ret = json.encode(decoded)
  --   ret = ret:gsub("<type 'function' is not supported by JSON.>", "nil")
  --   return json.decode(ret)
  -- else
  --   return {}
  -- end
end

function M.mkdir(...)
  -- print("#### mkdir")
  local folders = {...}
  local path = system.pathForFile(nil, system.TemporaryDirectory)
  lfs.chdir(path)
  local parent = lfs.currentdir()
  for i = 1, #folders do
    local name = folders[i]
    -- print("",name)
    local isDir = lfs.chdir(name) and true or false
    if not isDir then
      lfs.mkdir(name)
      local newFolderPath = lfs.currentdir() .. "/" .. name
      lfs.chdir(newFolderPath)
    end
    parent = parent .. "/" .. lfs.currentdir()
  end
  -- print(parent)
end

function M.getLayerDirs(book, page, layer)
  local  ret = {"App", book, "components", page, "layers"}
  local layerFolders = layer:split("/")
  for i=1, #layerFolders-1 do
    ret[#ret+1] = layerFolders[i]
  end
  return ret
end

function M.getModelDirs(book, page, layer)
  local  ret = {"App", book, "models", page}
  local layerFolders = layer:split("/")
  for i=1, #layerFolders-1 do
    ret[#ret+1] = layerFolders[i]
  end
  return ret
end

-- function M.getLayerNameWithParent(obj)
--   local ret = obj.layer
--   if obj.parentObj then
--     ret = obj.parentObj.layer.."/"..obj.layer
--     -- print("", ret)
--   end
--   return ret
-- end

function M.getParent(obj)
  local ret = ""
  if obj.parentObj then
    ret = M.getParent(obj.parentObj, ret) .. obj.parentObj.layer .. "/" .. ret
  end
  return ret
end

function M.getLayerPath(obj)
  local ret = obj.layer
  if obj.parentObj then
    local parent = M.getLayerPath(obj.parentObj)
    return parent.."/"..ret
    -- print("", ret)
  else
    return ret
  end
end

function M.saveLua(tmplt, dst, _model, partial)
  -- print("local tmplt='" .. tmplt .. "'")
  -- print("local dst ='" .. dst .. "'")
  local model = M.copyTable(_model)
  -- print("local model = json.decode('".. json.encode(model).. "')" )

  local path = system.pathForFile(tmplt, system.ResourceDirectory)
  local file, errorString = io.open(path, "r")
  if not file then
    print("ERROR:" .. errorString)
    return nil
  else
    local contents = file:read("*a")
    io.close(file)
    -- print(json.encode(model.events))
    -- print(contents)
    local output = lustache:render(contents, model, partial)
    local path = system.pathForFile(dst, system.TemporaryDirectory) --system.TemporaryDirectory)
    --print(path)
    local file, errorString = io.open(path, "w+")
    if not file then
      print("ERROR:" .. errorString)
    else
      output = string.gsub(output, "\r\n", "\n")
      output = output:gsub("\n\n+", "\n")
      output = output:gsub("&#x2F;", "/")
      output = output:gsub("&#39;", "'")
      output = output:gsub("class={  }", "")
      output = output:gsub("&quot;", '"')
      output = output:gsub('"NIL"', '""')

      local formatted = formatter.indentcode(output, "\n", true, "  ")
      if formatted then
        -- print(formatted)
        file:write(formatted)
      else
        -- print(output)
        file:write(output)
      end
      io.close(file)
    end
    return path
  end
end

function M.writeLines(_path, lines)
  local path = system.pathForFile(_path, system.TemporaryDirectory)
  local file, errorString = io.open(path, "w")
  if not file then
    -- Error occurred; output the cause
    print("ERROR: " .. errorString)
  else
    for i, l in ipairs(lines) do
      io.write(l, "\n")
    end
    io.close(file)
    return true
  end
  return false
end

function M.saveJson(_path, _model)
  local path = system.pathForFile(_path, system.TemporaryDirectory)
  local model = M.copyTable(_model)

  -- print(_path)
  local file, errorString = io.open(path, "w")
  if not file then
    -- Error occurred; output the cause
    print("ERROR: " .. errorString)
    return false
  else
    -- Write encoded JSON data to file
    file:write(json.encode(model))
    -- Close the file handle
    io.close(file)
    return true
  end
end

function M.decode(book, page, class, _name, options)
  -- print("", class, _name, options.subclass)
  local name = _name
  if options.isNew then
    local path = "template.components.pageX." .. class .. ".defaults." .. class
    if class == "joint" then
      path = "template.components.pageX.physics.defaults." .. class
    end
    return require(kwikGlobal.ROOT..path)
  elseif options.isDelete then
    print(class, "delete")
    return {}
  else
    if options.subclass then
      name = options.subclass .. "." .. name
    end
    local path = "App." .. book .. ".components." .. page .. "." .. class .. "s." .. name
    -- print(path)
    return require(path)
  end
end

function M.decodeJson(book, page, class, name, options)
  -- print("$$$$", options.isNew)
  if options.isNew then
    local path = "template.components.pageX." .. class .. ".defaults." .. class
    return require(kwikGlobal.ROOT..path)
  elseif options.isDelete then
    -- print(class, "delete")
    return {}
  else
    local name = name or ""
    if options.subclass then
      name = options.subclass .. "/" .. name
    end
    local path =
      system.pathForFile(
      "App/" .. book .. "/models/" .. page .. "/" .. class .. "s/" .. name .. ".json",
      system.ResourceDirectory
    )
    if path then
      -- print("App/" .. book .. "/models/" .. page .. "/" .. class .. "s/" .. name .. ".json")
      decoded, pos, msg = json.decodeFile(path)
    end
    if not decoded then
      -- print("Decode failed at " .. tostring(pos) .. ": " .. tostring(msg), path)
      decoded = {}
    end
    return decoded or {}
  end
end

-- function M.read(book, page, filter)
--   local path =system.pathForFile("App/"..book.."/models/"..page .."/commands"
--   , system.ResourceDirectory)
--   print(path)
--   return {}
-- end

function M.read(book, page, filter)
  local path = system.pathForFile("App/" .. book .. "/models/" .. page .. "/index.json", system.ResourceDirectory)
  -- print("@@@@", path)

  local ret = {}
  --
  -- TODO read it recurrsively!
  --
  local decoded, pos, msg = json.decodeFile(path)
  if not decoded then
    print("Decode failed at " .. tostring(pos) .. ": " .. tostring(msg))
  else
    local function parser(entries, parent)
      local layers = nil
      for i = 1, #entries do
        local name = nil
        local entry = entries[i]
        for k, v in pairs(entry) do
          if k ~= "class" and k ~= "commands" and k ~= "weight" then
            local layer = {name = k, parent = parent}
            --  ret.layers[#ret.layers+1] = {name=k}
            if filter then
              layer.isFiltered = filter(parent, k)
            end
            if layers == nil then
              layers = {}
            end
            layers[#layers + 1] = layer

            name = k
            --print(k)
            if parent then
              if type(v) == "table" then
                layer.children = parser(v, parent .. "." .. k)
              end
            else
              if type(v) == "table" then
                layer.children = parser(v, k)
              end
            end
            break
          end
        end
        local classEntries = entry.class or {}
        for j = 1, #classEntries do
          local className = classEntries[j]
          -- print("", name.."_"..className)
          local t = ret[className]
          if t == nil then
            t = {}
            ret[className] = t
          end
          local f = name .. "_" .. className .. ".json"
          -- print(f)
          local path = system.pathForFile("App/" .. book .. "/models/" .. page .. "/" .. f, system.ResourceDirectory)
          if path then
            local decoded, pos, msg = json.decodeFile(path)
            if not decoded then
              print("Decode failed at " .. tostring(pos) .. ": " .. tostring(msg))
            else
              for l = 1, #decoded do
                t[#t + 1] = {name = decoded[l].name, file = name .. "_" .. className, index = l}
              end
            end
          end
        end
      end
      return layers
    end
    --
    --print(json.encode(decoded))
    ret.layers = parser(decoded.components.layers)
    --
    ret.audios = {}
    ret.groups = {}
    ret.commands = {}
    --
    -- read audios/*.json
    local function setFiles(t, dir)
      -- print( "App/"..UI.editor.currentBook.."/models/"..UI.editor.currentPage..dir)
      local path = system.pathForFile("App/" .. book .. "/models/" .. page .. dir, system.ResourceDirectory)
      if path then
        for file in lfs.dir(path) do
          if file:find(".json") ~= nil then
            -- print( "Found file: " .. file )
            t[#t + 1] = {name = file:gsub(".json", "")}
          end
        end
      end
    end
    --
    setFiles(ret.audios, "/audios/short")
    setFiles(ret.audios, "/audios/long")
    setFiles(ret.groups, "/groups")
    setFiles(ret.commands, "/commands")
  end
  --print(json.encode(ret))
  return ret
end

M.setSelection = function(self, obj)
  -- print("@@@@", obj.text)
  if not self:isControlDown() then
    -- UI.scene.app:dispatchEvent {
    --   name = "editor.group.selectLayer",
    --   UI = UI,
    --   index = obj.index,
    --  -- value = self.actions[obj.index]
    -- }

    for i = 1, #self.selections do
      self.selections[i].rect:setFillColor(1)
    end

    if obj.isSelected then
      obj.rect:setFillColor(1)
      self.selections = {}
    else
      self.selections = {obj}
      obj.rect:setFillColor(0, 1, 0)
    end
    obj.isSelected = not obj.isSelected
  else -- multi
    --obj:setFillColor(1)
    if not obj.isSelected then
      self.selections[#self.selections + 1] = obj
      obj.rect:setFillColor(0, 1, 0)
    else
      obj.rect:setFillColor(1)
    end
    obj.isSelected = not obj.isSelected
    local tmp = {}
    for i = 1, #self.selections do
      if self.selections[i].isSelected then
        tmp[#tmp + 1] = self.selections[i]
      end
    end
    self.selections = tmp
  end
end

function M.renderIndex(book, page, model)
  local dst = "App/" .. book .. "/components/" .. page .. "/index.lua"
  --local dst = "index.lua"
  local tmplt = kwikGlobal.RESOUECES_PATH.."template/components/pageX/index.lua"

  M.mkdir("App", book, "components", page)

  local n = ""
  local function getRecursive(n)
    return [[
    {
      {{name}} = { {{ #layers]] ..
      n ..
        [[ }}{{>recursive]] ..
          n .. [[}} {{/layers]] .. n .. [[}}
      class={ {{#class]]..n..[[}}"{{.}}",{{/class]]..n..[[}} }  }
    },
   ]]
  end

  -- {
  --   {{name}} = { {{ #layers]]..n..[[ }}{{>recursive]]..n..[[}} {{/layers]]..n..[[}}
  --   {{#class}} class={ {{#class}}"{{.}}"{{/class}} } {{/class}} }
  -- },

  local partial = {recursive = getRecursive(1)}
  local numOfchildren = 3
  for i = 1, numOfchildren do
    partial["recursive" .. i] = getRecursive(i + 1)
  end
  -- print(json.encode(partial))
  M.saveLua(
    tmplt,
    dst,
    {
      name = model.name,
      events = model.commands,
      layers = model.components.layers,
      audios = model.components.audios,
      timers = model.components.timers,
      groups = model.components.groups,
      variables = model.components.variables,
      joints = model.components.joints,
      page = model.components.page
    },
    partial
  )
  return dst
end

function M.saveIndex(book, page, layer, class, model)
  local dst = "App/" .. book .. "/models/" .. page .. "/index.json"
  --local dst = "index.json"
  M.mkdir("App", book, "models", page)
  --
  local decoded = M.copyTable(model)
  if layer then
    for i = 1, #decoded.components.layers do
      local entry = decoded.components.layers[i]
      -- for k, v in pairs(entry) do print(k,v) end
      if entry.name == layer then
        if entry.class == nil then
          entry.class = {}
        end
        table.insert(entry.class, class)
        -- for j = 1, #entry.class do
        --   print(entry.class[j])
        -- end
        break
      end
    end
  else
    print("save index.json:TODO for timer, variable, audio")
  end
  decoded.onInit = nil
  -- print(json.encode(decoded))
  M.saveJson(dst, decoded)
  return dst
end

function M.readAssets(book, type, filter)
  local path = system.pathForFile("App/" .. book .. "/assets/", system.ResourceDirectory)
  local ret = {
    fonts = {},
    images = {},
    particles = {},
    sprites = {},
    thumbnails = {},
    videos = {}
  }
  ret["audios.short"] = {}
  ret["audios.long"] = {}
  ret["audios.sync"] = {}
  --
  local _filter = filter or {}
  for k, v in pairs(ret) do
    if not _filter[k] and type == k then
      local out = M.split(k, ".")
      local folder = out[1]
      local sub = out[2]
      local target = ret[k]
      if sub and sub:len() > 0 then
        target = ret[folder .. "." .. sub]
        folder = folder .. "/" .. sub
      end
      --
      local success = lfs.chdir(path .. "/" .. folder) -- Returns true on success
      if success then
        local fullpath = lfs.currentdir()
        ---
        local function getFiles(fullpath, _folder, parent)
          local children = {}
          -- print(fullpath)
          local full_path = fullpath
          local _parent = parent or ""
          if _folder then
            full_path = fullpath .. (_folder or "")
          -- print(full_path)
          end
          --
          for file in lfs.dir(full_path) do
            -- print("", file)
            if file:len() > 2 then
              local isDir = lfs.chdir(file) and true or false
              if k == "audios.long" then
                print(file)
              end
              if isDir then
                getFiles(full_path, "/" .. file, _parent .. "/" .. file)
                lfs.chdir(full_path)
              else
                if _folder then
                  table.insert(target, _parent:sub(2) .. "/" .. file)
                else
                  table.insert(target, _parent:sub(2) .. file)
                end
              end
            end
          end
          return children
        end
        ---
        getFiles(fullpath)
      end
    end
  end
  return ret
end

function M.split(str, sep)
  local out = {}
  for m in string.gmatch(str, "[^" .. sep .. "]+") do
    out[#out + 1] = m
  end
  return out
end

function M.uniqueName(str, _sep)
  local sep = _sep or "_"
  local out = M.split(str, sep)
  if #out == 1 then
    return str..sep.."1"
  else
    local num = tonumber(out[#out]) + 1
    out[#out] = tostring(num)
    return table.concat(out, "_")
  end
end

function M:createNamesMapByLayer(layers, parent)
  for i, v in next, layers do
    if parent then
      self.namesMap[parent.."/"..v.name] = {i, v}
    else
      self.namesMap[v.name] = {i, v}
    end
    for k, vv in pairs(v) do
      -- layers1, layer2, layers3
      if k:find("layers") then
          self:createNamesMapByLayer(vv ,v.name)
      end
    end
  end
end

function M:createNamesMap(entries)
  for i, v in next, entries do
      self.namesMap[v] = {i, v}
  end
end

function M.getClassSuffix(classText)
  local className, suffix = string.match(classText, "([^%d]+)(%d.*)") -- Split at first digit
  return className or classText,  suffix or "" -- Empty string if no suffix
end

--
-- merge
local exports = require(kwikGlobal.ROOT.."lib.util")
return setmetatable(M, {__index = exports})
