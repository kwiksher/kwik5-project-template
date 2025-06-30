local current = ...
local parent,root = newModule(current)
local util = require(kwikGlobal.ROOT.."editor.util")
local json = require("json")
--
local model = {
  id ="asset",
  props = {
    {name="filename", value = ""},
    {name="name", value = ""},
    {name="type", value = ""},
  }
}

local assetTable      = require(parent .. "assetTable")
local classProps    = require(parent.."classProps")
local buttons       = require(parent.."buttons")
local controller = require(kwikGlobal.ROOT.."editor.controller.index").new("asset")

--
local M = require(root.."parts.baseClassEditor").new(model, controller)

M.x = display.contentCenterX +  480/2
M.y	= 20
M.width = 80
M.height = 16

function M:init(UI)
  self.UI = UI
  self.group = display.newGroup()
  UI.editor.assetEditorGroup = self.group
  --
  assetTable:init(UI, display.contentCenterX, 40, self.width*0.74, self.height)
  classProps:init(UI, self.x + self.width*1.5, self.y,  self.width, self.height)
  classProps.model = model.props
  classProps.type  = current

  classProps.UI = UI
  --
  --actionbox:init(UI)
  buttons:init(UI)

  -- --
  controller:init{
    selectbox      = assetTable, -- Audio, Particles, Spritesheet, SyncText, Video
    classProps    = classProps, -- select a media entry then click the icon to insert media, it can be a layer replacement
    buttons       = buttons
  }
  controller.view = self
  --
  UI.useAssetEditorProps = function() return controller:useAssetEditorProps() end
  --
end

function controller:toggle()
  self.isVisible = not self.isVisible
  if self.isVisible then
    self:show()
  else
    self:hide()
  end
end

function controller:render(book, page, class, name, model)
  local dst = "App/"..book.."/"..page .."/components/audios/"..class.."/"..name ..".lua"
  local tmplt =  kwikGlobal.PATH.."template/components/pageX/audios/audio.lua"
  util.mkdir("App", book, page, "components", "audios", class)
  util.saveLua(tmplt, dst, model)
  return dst
end

function controller:save(book, page, class, name, model)
  local dst = "App/"..book.."/models/"..page .."/audios/"..class.."/"..name..".json"
  util.mkdir("App", book, "models", page, "audios", class)
  util.saveJson(dst, model)
  return dst
end

local function readAsset(path, folder, map, parent)
  -- print(path.."/"..folder)
  local entries = {}
  local success = lfs.chdir( path.."/"..folder )
  if success then
    for file in lfs.dir( path.."/"..folder ) do
      if util.isDir(file) and file~="." and file~=".."  then
        -- print("", "@Found dir " .. file )
        local children = readAsset(path.."/"..folder, file, map, folder)
        for i=1, #children do
          entries[#entries + 1] = children[i]
        end
      elseif file~="." and file~=".."  and file:find(".lua")  ==  nil and file:find("@") == nil and file:find(".json")  ==  nil
        and file:sub(1, 1) ~="." then
        local mapEntry = map[file]
        if mapEntry == nil then
          if parent==nil then
            entries[#entries + 1] = {name=file, path=folder, links={}}
          else
            local v = parent.."/"..folder
            entries[#entries + 1] = {name=file, path=v, links={}}
          end
        else
          mapEntry.isExist = true
          entries[#entries + 1] = {name=mapEntry.name, path=mapEntry.path, links=mapEntry.links}
        end
      end
    end
    lfs.chdir( path )
  end
  return entries
end

local function readAssetAudio(path, folder, map, parent)
  -- print(path.."/"..folder)
  local entries = {}
  local success = lfs.chdir( path.."/"..folder )
  if success then
    for file in lfs.dir( path.."/"..folder ) do
      if util.isDir(file) and file~="." and file~=".."  then
        -- print("", "@Found dir " .. file )
        local children = readAssetAudio(path.."/"..folder, file, map, folder)
        for i=1, #children do
          entries[#entries + 1] = children[i]
        end
      elseif file~="." and file~=".."  and file:find(".lua")  ==  nil and file:find("@") == nil and file:find(".json")  ==  nil
        and file:sub(1, 1) ~="." then
        local mapEntry = map[file]
        if mapEntry == nil then
          if parent==nil then
            entries[#entries + 1] = {name=file, path=folder, links={}}
          else
            local v = parent.."/"..folder
            entries[#entries + 1] = {name=file, path=v:gsub("audios/",""), links={}}
          end
        else
          mapEntry.isExist = true
          entries[#entries + 1] = {name=mapEntry.name, path=mapEntry.path, links=mapEntry.links}
        end
      end
    end
    lfs.chdir( path )
  end
  return entries
end

local function readAssetParticles(path, folder, map, parent)
  -- print(path.."/"..folder)
  local entries = {}
  local success = lfs.chdir( path.."/"..folder )
  if success then
    for file in lfs.dir( path.."/"..folder ) do
      if util.isDir(file) and file~="." and file~=".."  then
        -- print("", "@Found dir " .. file )
        local children = readAssetParticles(path.."/"..folder, file, map, folder)
        for i=1, #children do
          entries[#entries + 1] = children[i]
        end
      elseif file~="." and file~=".."  and file:find(".lua") or file:find(".json") and file:sub(1, 1) ~="." then
        local mapEntry = map[file]
        if mapEntry == nil then
          if parent==nil then
            entries[#entries + 1] = {name=file, path=folder, links={}}
          else
            local v = parent.."/"..folder
            entries[#entries + 1] = {name=file, path=v:gsub("particles/",""), links={}}
          end
        else
          mapEntry.isExist = true
          entries[#entries + 1] = {name=mapEntry.name, path=mapEntry.path, links=mapEntry.links}
        end
      end
    end
    lfs.chdir( path )
  end
  return entries
end

function controller:read(book, _model)
  -- print("read assets.model in ", book)
  local assets = {audios={}}
  local model = _model or require("App." ..book..".assets.model")
  local map = {}
  for k, v in pairs(model) do
    for i, entry in next, v do
      entry.index = i
      map[entry.name] = entry
      -- print(k, i, entry.name)
    end
  end
  --
  local path =system.pathForFile( "App/"..book.."/assets", system.ResourceDirectory)
	local success = lfs.chdir( path ) -- isDir works with current dir
	if success then
		for folder in lfs.dir( path ) do
			if util.isDir(folder) and folder~="." and folder~=".."  then
				-- print( "Found dir " .. folder )
        if folder == "particles" then
          assets[folder] = readAssetParticles(path, folder, map)
        elseif folder == "audios" then
          assets[folder] = readAssetAudio(path, folder, map)
        else
          assets[folder] = readAsset(path, folder, map)
        end
			end
		end
	end
  local audios = {}
  local syncs = {}
  for i, entry in next, assets.audios do
    -- print(entry.path)
    if entry.path:find("sync") then
      --entry.path = entry.path:gsub("sync","")
      syncs[#syncs+1] = entry
    else
      audios[#audios + 1] = entry
    end
  end
  assets.audios = audios
  assets.syncs = syncs
  -- print(json.prettify(assets))
  return assets, map
end

function controller:updateAsset(book, page, layer, classFolder, class, model, assets)
  print("update assets", book, page, layer, calssFolder, class, model.filename)
  local ret   = assets
  local name  = model.filename
  local path = class.."s"
  if class == "particles" then
    path = "particles"
  end
  ---
  if class == nil then
    -- audio
    entry.path = path .."/".. model.type -- short/long
  else
    -- spritesheet, particles, videos, web
    --
    -- is layer_xxx.lua exist?
    local props = {}
    if util.isExist(book, page, layer, class) then
      props = require("App."..book..".components." ..page..".layers."..layer.."_"..class)
    end

    local currentName = props.name
    if class == "video" then
      name = model.url
      currentName = props.url
    end

    local target = assets[path]
    ---------------------------------
    local function findEntry(target, name)
      for i, entry in next, target do
        if entry.name == name then
          -- update
          return entry
        end
      end
      local newEntry = {
        name = name,
        path = path,
        links = {}
      }
      target[#target+1] = newEntry
      return newEntry
    end
    --
    local entry = findEntry(target, name)
    entry.path = path
    ---------------------------------
    local function findLinkEntry(target, page)
      for i, entry in next, target do
        if entry.page == page then
          -- update
          return entry
        end
      end
      local newEntry = {
        page = page,
        layers = {}
      }
      target[#target+1] = newEntry
      return newEntry
    end
    --
    local linkEntry = findLinkEntry(entry.links, page)
    ---------------------------------
    local function findLayerEntry(target, layer)
      for i, entry in next, target do
        if entry == layer then
          -- do nothing, the layer has been linked to the media
          return i
        end
      end
      target[#target+1] = layer
      return #target
    end
    --
    local layerEntryIndex = findLayerEntry(linkEntry.layers, layer)
    --
    -- if layer is updated with different asset, let(s remove the layer name from the links of the old asset table)
    --
    local oldEntry = findEntry(target, currentName)
    local oldLinkEntry = findLinkEntry(oldEntry.links, page)
    local oldLayerEntryIndex = findLayerEntry(oldLinkEntry.layers, layer)
    --
    print("oldLayerEntryIndex", oldLayerEntryIndex)
    table.remove(oldLinkEntry.layers, oldLayerEntryIndex)
    --
    -- for replacements, layer can not be linked with mutiple media files
    -- so remove the layer name from links[x].layers
    local function removeDuplicatedLayer(class, layer)
      local target = assets[class]
      for i, entry in next, target do
        if entry.name ~= name then -- ex videoA.mp4
          for j, linkEntry in next, entry.links do
            if linkEntry.page == page then
              for k, layerEntry in next, linkEntry.layers do
                print(k, layerEntry)
                if layerEntry == layer then
                  table.remove(linkEntry.layers, k)
                end
              end
            end
          end
        end
      end
    end
    removeDuplicatedLayer("videos", layer)

  end
  -- print(json.encode(ret))
  return ret
end


--print(M.hide)
return M
