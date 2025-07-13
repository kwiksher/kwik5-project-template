local name = ...
local parent, root = newModule(name)
local util = require(kwikGlobal.ROOT.."editor.util")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local json = require("json")

local types = {"page", "timer", "group", "variables", "layer"}

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local props = params.props or {}
    -- print(name)
    if params.props and params.props.book then
      print("delete book")
      scripts.deleteBook(UI.book, UI.page, params.props.book) 
    else
      if UI.editor.selections then
        for i, obj in next, UI.editor.selections do
          if obj.page then
            print("", obj.page)
          elseif obj.layer then
            print("", obj.layer, obj.class)
          elseif obj.audio then
            print("", obj.aduio, obj.class, obj.subclass)
          end
        end
      end

      local book = UI.book
      local page = UI.page

      local selections = UI.editor.selections or {UI.editor.currentLayer}
      -- print(json.prettify(selections))
      --
      local files, targets = {}, {}
      local indexModel = util.createIndexModel(UI.scene.model) -- noRecursive
      -- local indexModel = util.createIndexModel(UI.scene.model, nil, nil, true) -- noRecursive
      -- print(json.prettify(indexModel))

      local updatedModel = UI.scene.model
      -- UI.scene.model
      util.namesMap = {}

      --local classFolder = UI.editor:getClassFolderName(data.class)
      -- print(UI.editor.currentType, params.class, props.class, params.subclass)
      local book, page = UI.book, UI.page
      local class = params.class or props.class
      local entries
      if class == "audio" then
        entries = indexModel.components.audios[params.subclass]
        util:createNamesMap(entries)
      elseif UI.editor.currentType == "group" then
        entries = indexModel.components.groups
        util:createNamesMapByLayer(entries)
      elseif class == "timer" then
        entries = indexModel.components.timers
        util:createNamesMap(entries)
      elseif class == "variable" then
        entries = indexModel.components.variables
        util:createNamesMap(entries)
      elseif class == "joint" then
        entries = indexModel.components.joints
        util:createNamesMap(entries)
      elseif class == "page" then
        -- TODO
      else
        entries = indexModel.components.layers
        util:createNamesMapByLayer(entries)
      end

      --
      -- print(json.prettify(entries))
      print(json.prettify(util.namesMap))

      for i, obj in next, selections do
        local class = params.class or obj.class or props.class
        local name, path, shapedWith
        if class == "audio" then
          path = "App/" .. book .. "/components/" .. page .. "/audios/" .. obj.subclass .. "/" .. obj.audio
          -- name = obj.subclass .. "." .. obj.audio
          name = obj.audio
        elseif UI.editor.currentType == "group" then
          if class == "group" then
            path = "App/" .. book .. "/components/" .. page .. "/groups/" .. obj.layer -- because groupTable is __index=layerTable
            name = obj.layer
          else
            path = "App/" .. book .. "/components/" .. page .. "/groups/" .. obj.layer.. "_" .. obj.class
            name = obj.layer
          end
        elseif class == "timer" then
          path = "App/" .. book .. "/components/" .. page .. "/timers/" .. obj.timer
          name = obj.timer
        elseif class == "variable" then
          path = "App/" .. book .. "/components/" .. page .. "/variables/" .. obj.variable
          name = obj.variable
        elseif class == "joint" then
          path = "App/" .. book .. "/components/" .. page .. "/joints/" .. obj.joint
          name = obj.joint
        elseif class == "page" then
        elseif class and class:len() > 0 then
          path = "App/" .. book .. "/components/" .. page .. "/layers/" .. obj.layer .. "_" .. obj.class
          name = obj.layer
          if obj.parentObj then
            name = util.getLayerPath(obj)
          end
        else --class==nil
          path = "App/" .. book .. "/components/" .. page .. "/layers/" .. obj.layer
          name = obj.layer
          shapedWith = UI.sceneGroup[name].shapedWith
        end

        local entry = util.namesMap[name]
        --
        if entry then
          print(name, entry[1], entry[2], entry[3])
          targets[#targets + 1] = {index = entry[1], layer=entry[2], path = path ..".lua", class = class, shapedWith = shapedWith}
        end
        -- print(json.encode(targets))
      end
      --
      table.sort(
        targets,
        function(a, b)
          return a.index > b.index
        end
      )

      local function getClass(tbl)
        for k, v in pairs(tbl) do
          -- print(k)
          if type(k) == "string" and k:find("class") then
            return k
          end
        end
      end

      local targetsDelete = {}
      for i, v in next, targets do
        print(v.index, v.layer, v.path, v.class)
        local layer = v.layer
        -- printTable(layer)
        -- print(layer.name, classKey)
        if v.class == nil or v.class:len() == 0 then
          print(" deleting the layer")
          -- table.remove(indexModel,v.index) -- delete from index
          table.remove(entries, v.index)
          -- print(json.encode(entries))
        elseif v.class == "audio" then
          table.remove(entries, v.index)
        elseif UI.editor.currentType == "group" or v.class == "group" then
          table.remove(entries, v.index)
        elseif v.class == "timer" then
          table.remove(entries, v.index)
        elseif v.class == "variable" then
          table.remove(entries, v.index)
        elseif v.class == "joint" then
          table.remove(entries, v.index)
        elseif v.shapedWith then
          table.remove(entries, v.index)
        else
          local classKey = getClass(layer)
          local updated = {}
          if layer[classKey] then
            for ii, vv in next, layer[classKey] do -- Notice
              if vv ~= v.class then
                updated[#updated + 1] = vv
              end
            end
            layer[classKey] = updated
          end
        end
        files[#files + 1] = v.path
        targetsDelete[#targetsDelete + 1] = v.path
      end
      --
      scripts.saveSelection(book, page, {{name = "deleted", class = class}})
      --
      print(json.prettify(indexModel))
      -- print(json.prettify(targetsDelete))
      --
      local indexFile = util.renderIndex(book, page, indexModel)
      files[#files + 1] = indexFile
      --
      scripts.backupFiles(files)
      scripts.executeCopyFiles({indexFile})
      scripts.delete(targetsDelete)
    end
  end
)
--
return instance
