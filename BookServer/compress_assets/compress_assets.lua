--
-- utility to archive asset page by page
--
local M = {}

local platform = system.getInfo("platform")
print(platform)

if not (platform == "win32" or platform == "macos") then
  native.showAlert("Kwik", "Please select Windows or macOS from View> View As > Custom", {"OK", "Cancel"})
end

local ROOT = "BookServer"

--local bookProject = "AssetInfo"
local bookProject = "SpringEn"
local bookServerFolder = "hokkaido"
local bookProjectInServer = "SpringEn"

local json = require("json")
local lfs = require("lfs")

local pageAssets = {}
local jsonFiles = {}

local assetDirs = {"audios", "sprites", "videos", "thumbnails", "particles", "PNGs", "WWW", "images"}

function readPages(bookProjectFolder)
  print(bookProjectFolder)
  local model = {}
  --
  local function readFiles(path, folder)
    local ret = {}
    local path = system.pathForFile(bookProjectFolder .. "/assets/" .. folder, system.ResourceDirectory)
    print("readFiles", path)
    if path then
      for file in lfs.dir(path) do
        if (isDir(path .. "/" .. file)) and file:len() > 2 then
          ret[#ret + 1] = file
          print(file)
        end
      end
    end
    return ret
  end
  --
  for k, folder in pairs(assetDirs) do
    local ret = readFiles(path, folder)
    if #ret > 0 then
      model[#model + 1] = {asset = folder, pages = ret}
    end
  end

  print("-------------")
  for k, v in pairs(model["images"]) do
    print(v)
  end
  print("-------------")

  return model
end

function zip(model)
  local ext = "command"

  local sandboxPath = system.pathForFile("", system.ResourceDirectory)
  if platform == "win32" then
    ext = "bat"
    sandboxPath = sandboxPath:gsub("/", "\\")
  end

  local path = system.pathForFile("compress_assets." .. ext .. ".tmplt", system.ResourceDirectory)
  local file, errorString = io.open(path, "r")
  local cmd = "compress_assets_" .. bookProject .. "." .. ext
  local cmdFile

  if not file then
    print("File error: " .. errorString)
  else
    local contents = file:read("*a")
    io.close(file)
    local lustache = require "lustache"
    model.sandboxPath = sandboxPath
    output = lustache:render(contents, model)

    local path = system.pathForFile(cmd, system.TemporaryDirectory)
    --print(path)
    local file, errorString = io.open(path, "w+")
    if not file then
      print("File error: " .. errorString)
    else
      output = string.gsub(output, "\r\n", "\n")
      file:write(output)
      io.close(file)
    end
    if platform == "win32" then
      cmdFile = '"' .. path:gsub("/", "\\") .. '"'
    else
      cmdFile = path:gsub(" ", "\\ ")
    end
  end

  if platform == "win32" then
    print("copy " .. cmdFile .. " " .. system.pathForFile("", system.ResourceDirectory))
    os.execute("copy " .. cmdFile .. " " .. system.pathForFile("..\\", system.ResourceDirectory))
    os.execute("cd " .. system.pathForFile("..\\", system.ResourceDirectory) .. " & start cmd /k call " .. cmd)
  else
    os.execute("cp " .. cmdFile .. " " .. system.pathForFile("../", system.ResourceDirectory))
    print("cd " .. system.pathForFile("../", system.ResourceDirectory) .. "; source " .. cmd)
    os.execute("cd " .. system.pathForFile("../", system.ResourceDirectory) .. "; source " .. cmd)
  end
end

function isFile(name)
  if type(name) ~= "string" then
    return false
  end
  if not isDir(name) then
    return os.rename(name, name) and true or false
  -- note that the short evaluation is to
  -- return false instead of a possible nil
  end
  return false
end

function isFileOrDir(name)
  if type(name) ~= "string" then
    return false
  end
  return os.rename(name, name) and true or false
end

function isDir(name)
  if type(name) ~= "string" then
    return false
  end
  local cd = lfs.currentdir()
  local is = lfs.chdir(name) and true or false
  lfs.chdir(cd)
  return is
end

function initAssetFolders(bookServerFolder, pageFolders)
  local _path = system.pathForFile(bookServerFolder, system.ResourceDirectory)
  -- Change current working directory
  local success = lfs.chdir(_path) --returns true on success

  if (success) then
    if not isFileOrDir(bookProjectInServer) then
      lfs.mkdir(bookProjectInServer)
    else
      os.remove(system.pathForFile(bookServerFolder .. "/" .. bookProjectInServer, system.ResourceDirectory))
      lfs.mkdir(bookProjectInServer)
    end
  end
end

function createAssetPageFolder(bookServerFolder, bookProjectInServer, pageNum)
  print("createAssetPageFolder", bookServerFolder, bookProjectInServer, pageNum)
  local _path = system.pathForFile(bookServerFolder, system.ResourceDirectory)
  -- Change current working directory
  local success = lfs.chdir(_path) --returns true on success

  if (success) then
    if not isFileOrDir(bookProjectInServer) then
      lfs.mkdir(bookProjectInServer)
    end
    lfs.chdir(bookProjectInServer)
    if not isFileOrDir("p" .. pageNum) then
      lfs.mkdir("p" .. pageNum)
    end
  end
end

function copyJsons(bookServerFolder, bookProject)
  local dst = system.pathForFile(bookServerFolder .. "/" .. bookProject, system.ResourceDirectory)
  for i = 1, #jsonFiles do
    local path = jsonFiles[i]
    if platform == "win32" then
      local cmd = "copy " .. path .. " " .. dst
      cmd = cmd:gsub("/", "\\")
      print(cmd)
      os.execute(cmd)
    else
      local cmd = "cp " .. path .. " " .. dst
      print(cmd)
      os.execute(cmd)
    end
  end
end

function M.setServerFolder(folder, parent)
  bookServerFolder = folder
  ROOT = parent
end

local function setSize(t, folder, path)
  local attr = nil
  local _path = path .. "/" .. folder .. ".zip"
  print("setSize", _path)
  if platform == "win32" then
    _path = _path:gsub("/", "\\")
  end

  if isFile(_path) then
    attr = lfs.attributes(_path)
  end
  if attr ~= nil then
    t[folder] = {date = attr.modification, size = attr.size}
  else
    t[folder] = nil
  end
end

function calcSize(pageFolders, folder)
  local model = {}
  -- print("calcSize", #pageFolders)
  for i = 1, #pageFolders do
    model[pageFolders[i].asset] = {}
    local path = system.pathForFile(folder .. "/" .. pageFolders[i].asset, system.ResourceDirectory)
    -- print("", #pageFolders[i].pages )
    for k = 1, #pageFolders[i].pages do
      local t = {}
      setSize(t, pageFolders[i].pages[k], path)
      table.insert(model[pageFolders[i].asset], t)
    end
  end

  local path = system.pathForFile(folder, system.ResourceDirectory)
  -- print(path)
  local file, errorString = io.open(path .. "/assets.json", "w+")
  if not file then
    print("File error:calcSize " .. errorString)
  else
    output = json.encode(model)
    file:write(output)
    io.close(file)
  end
end

M.calcSize = function(project, serverFolder)
  bookProject = project
  bookProjectInServer = serverFolder
  -- process all pages
  local pageFolders = readPages("../../Solar2D/App/" .. bookProject)
  --
  --
  calcSize("../" .. bookServerFolder .. "/" .. bookProjectInServer)
end

function M.compress(project, serverFolder)
  bookProject = project
  bookProjectInServer = serverFolder
  -- process all pages
  local pageFolders = readPages("../../Solar2D/App/" .. bookProject)
  --  {asset=folder, pages= ret}
  --
  --
  initAssetFolders("../" .. bookServerFolder, pageFolders)
  zip {
    assets = pageFolders,
    folder = bookServerFolder .. "/" .. bookProjectInServer,
    BookServer = ROOT,
    assetFolder = system.pathForFile("../../Solar2D/App/" .. bookProject .. "/assets", system.ResourceDirectory)
  }
  calcSize(pageFolders, "../" .. bookServerFolder .. "/" .. bookProjectInServer)
  copyJsons("../" .. bookServerFolder, bookProjectInServer)
end

function M.updateAsset(project, serverFolder, pageFolder)
  --  {asset="images", pages= {"page1"}}
  bookProject = project
  bookProjectInServer = serverFolder
  local pageFolders = readPages("../../Solar2D/App/" .. bookProject)
  createAssetPageFolder("../" .. bookServerFolder, bookProjectInServer, page)
  -- check pageFolder exists
  local pass = false
  for i = 1, #pageFolders do
    local f = pageFolders[i]
    if f.asset == pageFolder.asset then
      for k = 1, #p.pages do
        if p.pages[k] == pageFolders.pages[1] then
          pass = true
          break
        end
      end
    end
  end
  if pass then
    ---
    zip {
      assets = {pageFolder},
      folder = bookServerFolder .. "/" .. bookProjectInServer,
      BookServer = ROOT,
      assetFolder = system.pathForFile("../../Solar2D/App/" .. bookProject .. "/assets", system.ResourceDirectory)
    }

    -- update size and date
    calcSize(pageFolders, "../" .. bookServerFolder .. "/" .. bookProjectInServer)

    copyJsons("../" .. bookServerFolder, bookProjectInServer)
  else
    print("Error " .. pageFolders.pages[1] .. " is not found")
  end
end

function M.setOnlineImage(project, serverFolder, imagePath)
  bookProject = project
  bookProjectInServer = serverFolder
  local projectFolder = system.pathForFile("../../Solar2D/App/" .. bookProject, system.ResourceDirectory)
  local path = projectFolder .. "/" .. imagePath

  local _path = system.pathForFile("../" .. bookServerFolder, system.ResourceDirectory)
  -- Change current working directory
  local success = lfs.chdir(_path) --returns true on success

  if (success) then
    if not isFileOrDir(bookProjectInServer) then
      lfs.mkdir(bookProjectInServer)
    end
  end

  local dst =
    system.pathForFile("../" .. bookServerFolder .. "/" .. bookProjectInServer .. "/", system.ResourceDirectory)
  print("---setOnlineImage-----")
  if platform == "win32" then
    local cmd = "copy " .. path .. " " .. dst .. "bg.png"
    cmd = cmd:gsub("/", "\\")
    print(cmd)
    os.execute(cmd)
  else
    local cmd = "cp -f " .. path .. " " .. dst .. "bg.png"
    print(cmd)
    os.execute(cmd)
  end
end

return M
