local name = ...
local parent, root = newModule(name)
local util = require(kwikGlobal.ROOT.."editor.util")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local json = require("json")

local instance = require("commands.kwik.baseCommand").new(
function(params)
  local UI = params.UI
  --  print(name)

  local layer = UI.editor.currentLayer
  local selections = UI.editor.selections or { layer }

  local data = UI.editor.clipboard:read()
  -- clipboard.actions = {}
  -- clipboard.actionCommands = {}
  -- --

  -- print(json.prettify(data))

  local files = {}
  local indexModel =  util.createIndexModel(UI.scene.model)
  local updatedModel = UI.scene.model
  -- UI.scene.model
  util.namesMap = {}

  local classFolder = UI.editor:getClassFolderName(data.class or "")
  local book, page, class = UI.book, UI.page, data.class
  local isLayerClass = false
  --
  if params.selections then
  elseif data.class == nil then
    -- print("paste page")
    local src = "App/" .. book .. "/index.lua"
    scripts.backupFiles(src)
    scripts.copyPage(book, data.page, data.page.."_copied") -- _dst == Solar2D
  else
    local mod, entries, indexEntries
    if class == "audio" then
      mod = require(kwikGlobal.ROOT.."editor.audio.index")
      entries = data.components.audios
      indexEntries = indexModel.components.audios
      util:createNamesMapByLayer(indexEntries)
    elseif data.type == "group" then
      mod = require(kwikGlobal.ROOT.."editor.group.index")
      entries = data.components.groups
      indexEntries =indexModel.components.groups
      util:createNamesMapByLayer(indexEntries)
      if class and class:len() > 0 and class ~="group" then -- it should be one of animations or interactins
        isLayerClass = true
      end
    elseif class == "timer" then
      mod = require(kwikGlobal.ROOT.."editor.timer.index")
      entries = data.components.timers
      indexEntries = indexModel.components.timers
      util:createNamesMap(indexEntries)
    elseif class == "variable" then
      mod = require(kwikGlobal.ROOT.."editor.variable.index")
      entries = data.components.variables
      indexEntries = indexModel.components.variables
      util:createNamesMap(indexEntries)
    elseif class == "joint" then
      mod = require(kwikGlobal.ROOT.."editor.physics.index")
      entries = data.components.joints
      indexEntries = indexModel.components.joints
      util:createNamesMap(indexEntries)
    elseif class == "page" then
    elseif class and class:len() > 0 then
      mod = UI.editor:getClassModule(class) or {}
      entries = data.components.layers
      indexEntries = indexModel.components.layers
      isLayerClass = #entries == 1
      util:createNamesMapByLayer(indexEntries)
    else --class==nil
      mod = {controller=require(kwikGlobal.ROOT.."editor.controller.index")}
      entries = data.components.layers
      indexEntries = indexModel.components.layers
      util:createNamesMapByLayer(indexEntries)
    end

    local controller = mod.controller

    if not isLayerClass then
      -- print(json.prettify(indexEntries))
      for i, model in next, entries do
        -- local layer = model.name
        -- printKeys(model)
        local entry = util.namesMap[model.name]
        --
        if entry then -- and (data.class == nil or data.class:len() ==0)
          -- print("####", model.name)
          model.name = util.uniqueName(model.name)
          -- print("@@@@", model.name)
        else
          -- print("not found in indexEntries", model.name)
          -- for k, v in pairs(util.namesMap) do
          --   print(k, v)
          -- end
        end

        if data.type == "group" then
          local entry = {}
          entry[model.name] = {}
          table.insert(updatedModel.components.groups, entry)
          model.type = "group"
          classFolder = "group"
        elseif class == "timer" then
          table.insert(updatedModel.components.timers, model.name)
        elseif class == "variable" then
          table.insert(updatedModel.components.variables, model.name)
        elseif class == "joint" then
          table.insert(updatedModel.components.joints, model.name)
        elseif model.layerProps and model.layerProps.shapedWith then  -- shape
          local props = model.layerProps
          local newLayer = {}
          newLayer[model.name] = {}
          classFolder = "shape"
          class = props.shapedWith
          for k, v in pairs(props) do
            if k == "color" then
              model.fill = {r=v[1], g= v[2], b=v[3], a=v[4]}
            elseif k == "radius" then
              model.path = {radius = v}
            elseif k~="name" then
              model[k] = v
            end
          end
          table.insert(updatedModel.components.layers, newLayer)
        else
          updatedModel = util.updateIndexModel(updatedModel, model.name, class, model.type)
        end
        --
        -- print ("@@@", model.name, class)
        -- print(json.prettify(model))
        --
        -- save lua
        if class == "timer" then
          files[#files+1] = controller:render(book, page, nil, model.name, model)
          -- save json
          files[#files+1] = controller:save(book, page, nil, model.name, model)
        else
          files[#files+1] = controller:render(book, page, model.name, classFolder, class, model)
            -- save json
          files[#files+1] = controller:save(book, page, model.name, classFolder, model)
        end
      end
    else -- this is for class entry of layer and group
      -- print("-- copy a class model to selected layers or groups --")
      local model = entries[1]
      for i, v in next, selections do
        local layer = v.layer
        model.name = layer
        model.layer = layer
        if model.properties and model.properties.target then
          model.properties.target = layer
        end
        if data.type == "group" then
          -- classFolder = "group"
          model.type  = "group" -- is a linear/button copied from a normal layer instead of a group?
        end
        -- print ("@@@", layer, class, data,type)
        -- print(json.prettify(model))

        updatedModel = util.updateIndexModel(updatedModel, layer, class, data.type) -- data.type for group
        -- save lua
        files[#files+1] = controller:render(book, page, layer, classFolder, class, model)
            -- save json
        files[#files+1] = controller:save(book, page, layer, classFolder, model)

      end
    end
    local renderdModel = util.createIndexModel(updatedModel)
    -- save index lua
    files[#files+1] = util.renderIndex(book,page,renderdModel)
    -- save index json
    files[#files+1] = util.saveIndex(book,page, nil, nil, renderdModel)

    scripts.saveSelection(book, page, {{name = "pasted", class= class}})
    scripts.backupFiles(files)
    scripts.executeCopyFiles(files)
  end
end)
--
return instance
