local M = {}
local filename = "assets.json"
local onDownloadComplete
local onDownloadError
local assetsTableLocal = {}

local zip = require("plugin.zip")
local json = require("json")
local lfs = require("lfs")
local queue = require(kwikGlobal.ROOT.."lib.queue")

local spinner = require(kwikGlobal.ROOT.."components.bookstore.view.spinner").new("download server")

local model = nil
local URL = nil

function isDir(name)
  if type(name) ~= "string" then
    return false
  end
  local cd = lfs.currentdir()
  if cd == nil then return false end
  local is = lfs.chdir(name) and true or false
  lfs.chdir(cd)
  return is
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

local jsonFile = function(filename, baseDir)
  local path = system.pathForFile(filename, baseDir)
  local contents
  local file = io.open(path, "r")
  if file then
    contents = file:read("*a")
    io.close(file)
    file = nil
  end
  return contents
end

local function fetchAssetJson(aQueue)
  local item = aQueue:poll()
  if item then
    local deferred = Deferred()
    local selectedBook = item.name
    local version = item.version
    print("fetchAssetJson", selectedBook, version)
    --
    local url = URL .. selectedBook .. version .. "/" .. filename
    print("---------------------")
    print(url)
    print("---------------------")
    local params = {}
    params.progress = true
    network.download(
      url .. "?a=" .. os.time(),
      "GET",
      function(event)
        if (event.isError) then
          print("Network error - assets.json failed")
          deferred:reject()
        elseif (event.phase == "ended") then
          if (math.floor(event.status / 100) > 3) then
            --NOTE: 404 errors (file not found) is actually a successful return,
            --though you did not get a file, so trap for that
            print("Network error - assets.json failed", event.status)
            deferred:reject()
          else
            local options = {
              jsonFile = event.response.filename,
              jsonBaseDir = event.response.baseDirectory
            }
            local downloadables, assets = M.saveDownloadablesAsJson(options, selectedBook, version)
            deferred:resolve()
          end
        end
      end,
      params,
      selectedBook .. version .. ".json",
      system.TemporaryDirectory
    )
    return deferred:promise()
  else
    return nil
  end
end

local function fetchAssets()
  local aQueue = queue.new()
  -- also load bookName..version.."_assets.json" to assetsTableLocal[page]
  for k, v in pairs(model.books) do
    print(k, v)
    if #v.versions > 0 then
      for i = 1, #v.versions do
        local _version = v.versions[i]
        aQueue:offer({name = v.name, version = _version})
        local path = system.pathForFile(v.name .. _version .. "_assets.json", system.ApplicationSupportDirectory)
        if isFile(path) then
          assetsTableLocal[v.name .. _version] =
            json.decode(jsonFile(v.name .. _version .. "_assets.json", system.ApplicationSupportDirectory))
        else
          assetsTableLocal[v.name .. _version] = {}
        end
      end
    else
      aQueue:offer({name = v.name, version = ""})
      local path = system.pathForFile(v.name .. "_assets.json", system.ApplicationSupportDirectory)
      if isFile(path) then
        assetsTableLocal[v.name] = json.decode(jsonFile(v.name .. "_assets.json", system.ApplicationSupportDirectory))
      else
        assetsTableLocal[v.name] = {}
      end
    end
  end
  local promise = fetchAssetJson(aQueue)
  if promise == nil then
    print("fetchAssets is finished")
  else
    promise:done(
      function()
        fetchAssetJson(aQueue)
      end
    )
    promise:fail(
      function(error)
        print("error in fetchAssets")
      end
    )
    promise:always(
      function()
      end
    )
  end
end

function M.startDownload(selectedBook, version)
  local deferred = Deferred()
  local downloadables = M.getDownloadables(selectedBook, version)
  print("------ startDownload -------")
  local _version = version or ""
  --local assetsRemote = json.decode(jsonFile("downloadable_"..selectedBook.._version..".json", system.TemporaryDirectory))
  print("downloadable_" .. selectedBook .. _version .. ".json", #downloadables)
  if #downloadables > 0 then
    local aQueue = queue.new()
    print("startDownload #downlodables", #downloadables)
    local size = 0
    for i = 1, #downloadables do
      print(downloadables[i].size)
      aQueue:offer(downloadables[i])
      size = size + downloadables[i].size
    end
    spinner:show()
    spinner.startTime = os.time()
    spinner.numOfDownloadables = #downloadables
    spinner.book = selectedBook .. " " .. _version
    spinner.bookSize = math.floor(size / (1024 * 1024))
    spinner.size = 0
    M.processDownload(aQueue, deferred, selectedBook, version)
  else
    timer.performWithDelay(
      10,
      function()
        deferred:resolve()
      end
    )
  end
  return deferred:promise()
end

function updatedAssetsTable(item, bookName, version)
  print("updateAssetsTable", filename, bookName, version)
  local asset = item.asset -- filename:sub(bookName:len()+1, filename:find("_")-1)
  local page = item.page -- filename:sub(filename:find("_") + 1, filename:find(".zip")-1)
  print("--- updateAssetsTable ---", asset, page)

  local _version = version or ""

  if assetsTableLocal[bookName .. _version][asset] == nil then
    assetsTableLocal[bookName .. _version][asset] = {}
  end

  if assetsTableLocal[bookName .. _version][asset][page] == nil then
    assetsTableLocal[bookName .. _version][asset][page] = {}
  end

  assetsTableLocal[bookName .. _version][asset][page].date = item.date
  ---
  local path = system.pathForFile(bookName .. _version .. "_assets.json", system.ApplicationSupportDirectory)
  local file = io.open(path, "w+")
  jsonString = json.encode(assetsTableLocal[bookName .. _version])
  contents = file:write(jsonString)
  io.close(file)
end

function isUpdated(book, asset, page, date)
  if assetsTableLocal[book][asset] and assetsTableLocal[book][asset][page] then
    return not (assetsTableLocal[book][asset][page].date == date)
  end
  return true
end

M.saveDownloadablesAsJson = function(options, name, version)
  print("saveDownloadablesAsJson")
  local _version = version or ""
  local downloadables = {}
  local data = json.decode(jsonFile(options.jsonFile, options.jsonBaseDir))
  for asset, pages in pairs(data) do
    print("", asset, #pages)
    for k = 1, #pages do
      for page, info in pairs(pages[k]) do
        if isUpdated(name .. _version, asset, page, info.date) then
          table.insert(downloadables, {asset = asset, page = page, size = info.size, date = info.date})
        end
      end
    end
  end
  local path = system.pathForFile("downloadable_" .. name .. _version .. ".json", system.TemporaryDirectory)
  local fh, reason = io.open(path, "w+")
  if fh then
    fh:write(json.encode(downloadables))
    io.close(fh)
  else
    print("error", reason)
  end
  return downloadables, assets
end

M.getDownloadables = function(name, version)
  local _version = version or ""
  local path = system.pathForFile("downloadable_" .. name .. _version .. ".json", system.TemporaryDirectory)
  print("getDownloadables", path)
  if isFile(path) then
    return json.decode(jsonFile("downloadable_" .. name .. _version .. ".json", system.TemporaryDirectory))
  else
    print("getDownloadables None")
    return {}
  end
end

local function setFlagDownloaded(book, version)
  local _ver = version or ""
  local path = system.pathForFile(model.books[book].name .. _ver, system.ApplicationSupportDirectory)
  -- io.open opens a file at path. returns nil if no file found
  local fh, reason = io.open(path .. "/copyright.txt", "w+")
  if fh then
    fh:write("downloaded\n")
    io.close(fh)
  else
    print("error", reason)
  end
end

M.processDownload = function(downloadables, deferred, selectedBook, version)
  local promise = M.downloadAsset(downloadables, selectedBook, version)
  if promise == nil then
    setFlagDownloaded(selectedBook, version)
    onDownloadComplete(selectedBook, version)
    deferred:resolve()
    spinner:remove()
  else
    promise:done(
      function(item)
        print(item.asset)
        spinner.size = spinner.size + math.floor(item.size / (1024 * 1024))
        spinner:updateText()
        updatedAssetsTable(item, selectedBook, version)
        M.processDownload(downloadables, deferred, selectedBook, version)
      end
    )
    promise:fail(
      function(error)
        onDownloadError(selectedBook, version)
        deferred:reject()
        spinner:remove()
        print("Download Finished", error)
      end
    )
    promise:always(
      function()
      end
    )
  end
end

local function moveAsset(bookProject, version, item)
  print("moveAsset")
  local path = system.pathForFile("", system.ApplicationSupportDirectory)
  local success = lfs.chdir(path) --returns true on success
  if (success) then
    if not isFileOrDir(bookProject .. version) then
      lfs.mkdir(bookProject .. version)
    else
      --os.remove(system.pathForFile(bookServerFolder .."/"..bookProject, system.ResourceDirectory ))
      --lfs.mkdir( bookProject)
    end
    path = system.pathForFile(bookProject .. version, system.ApplicationSupportDirectory)
    lfs.chdir(path)
    print("", item.asset, item.page)
    if not isFileOrDir(item.asset) then
      lfs.mkdir(item.asset)
    end
    path = system.pathForFile(bookProject .. version .. "/" .. item.asset, system.ApplicationSupportDirectory)
  end

  -- assets sub dir
  print("", item.asset, bookProject .. version .. "/" .. item.asset)
  print(
    system.pathForFile(item.asset, system.ApplicationSupportDirectory),
    system.pathForFile(bookProject .. version .. "/" .. item.asset, system.ApplicationSupportDirectory)
  )
  --[[
        os.rename(system.pathForFile(const[item.asset], system.ApplicationSupportDirectory),
            system.pathForFile(bookProject.."/"..const[item.asset], system.ApplicationSupportDirectory))
    ]]
  local function _move(src, dst)
    local assetFolder = system.pathForFile(src, system.ApplicationSupportDirectory)
    for file in lfs.dir(assetFolder) do
      -- "file" is the current file or directory name
      print("Found file: " .. file)
      if isDir(file) then
        if file:len() > 3 then
          _move(file, dst .. "/" .. file)
        end
      else
        local _src = system.pathForFile(src .. "/" .. file, system.ApplicationSupportDirectory)
        local _dst = system.pathForFile(dst .. "/" .. src .. "/" .. file, system.ApplicationSupportDirectory)
        local result, error = os.rename(_src, _dst)
        if error and error:find("File exists") then
          os.remove(_dst)
          result, error = os.rename(_src, _dst)
        end
      end
    end
  end
  _move(item.page, bookProject .. version)
end

local function uncompressZip(filename, baseDir, bookProj, version, item, deferred)
  print("uncompressZip", filename, baseDir)
  local options = {
    zipFile = filename,
    zipBaseDir = baseDir,
    dstBaseDir = system.ApplicationSupportDirectory,
    listener = function(event)
      if (event.isError) then
        print("Unzip error")
        deferred:reject()
        spinner:remove()
      else
        print("event.name:" .. event.name)
        print("event.type:" .. event.type)
        if (event.response and type(event.response) == "table") then
          -- for i = 1, #event.response do
          --     print( event.response[i] )
          -- end
          -- local selectedBook = event.response[1]
          -- selectedBook = selectedBook:sub(1, selectedBook:len()-1)
          print("zipListener:" .. filename)
          moveAsset(bookProj, version, item)
        end
        deferred:resolve(item)
      end
    end
  }
  zip.uncompress(options)
end

local function downloadZip(url, filename, bookProj, version, item, deferred)
  print("downloadZip", url, filename)
  local params = {}
  params.progress = true
  network.download(
    url .. "?a=" .. os.time(),
    "GET",
    function(event)
      if (event.isError) then
        print("Network error - pageX.json failed")
        deferred:reject()
        spinner:remove()
      elseif (event.phase == "ended") then
        if (math.floor(event.status / 100) > 3) then
          --NOTE: 404 errors (file not found) is actually a successful return,
          --though you did not get a file, so trap for that
          print("Network error - assets.json failed", event.status)
          deferred:reject()
          spinner:remove()
        else
          uncompressZip(filename, event.response.baseDirectory, bookProj, version, item, deferred)
        end
      end
    end,
    params,
    filename,
    system.TemporaryDirectory
  )
end

M.downloadAsset = function(aQueue, selectedBook, version)
  local _version = version or ""
  local item = aQueue:poll()
  if item then
    local deferred = Deferred()

    local url = URL .. selectedBook .. _version .. "/" .. item.asset .. "/" .. item.page .. ".zip"
    downloadZip(
      url,
      selectedBook .. _version .. "_" .. item.asset .. "_" .. item.page .. ".zip",
      selectedBook,
      _version,
      item,
      deferred
    )
    --[[

          local url = URL ..selectedBook.._version.."/"..item.asset.."/"..item.page..".json"
          print("------- downloadAsset --------------")
          print(url)
          print("---------------------")
          local params    = {}
          params.progress = true
          network.download( url.."?a="..os.time(), "GET",
          function(event)
            if ( event.isError ) then
              print( "Network error - pageX.json failed" )
              deferred:reject()
              spinner:remove()
            elseif ( event.phase == "ended" ) then
              if ( math.floor(event.status/100) > 3 ) then
                print( "Network error - assets.json failed", event.status )
                deferred:reject()
                spinner:remove()
                --NOTE: 404 errors (file not found) is actually a successful return,
                --though you did not get a file, so trap for that
              else
                local url = URL ..selectedBook.._version.."/p"..item.page.."/"..item.asset..".zip"
                downloadZip(url, selectedBook.._version.."p"..item.page.."_"..item.asset..".zip",
                selectedBook, _version, item, deferred)
              end
            end
          end,
          params, selectedBook.."page"..item.page..".json", system.TemporaryDirectory )
        -- ]]
    return deferred:promise()
  else
    return nil
  end
end

function M.isUpdateAvailable(book, version)
  print("M.isUpateAvailable", book.name, model.books)
  if version == nil and #model.books[book.name].versions > 0 then
    for k, v in pairs(model.books[name].versions) do
      print(k, v)
      local downloadables = M.getDownloadables(book.name, v)
      if #downloadables > 0 then
        return true
      end
    end
    return false
  else
    local downloadables = M.getDownloadables(book.name, version)
    return #downloadables > 0
  end
end

M.setButtonImage = function(_obj, name, version)
  print("setButtonImage", name, version)
  local params = {}
  local version = version or ""
  local obj = _obj
  local imgName = model.backgroundImg or obj.imagePath:sub(1, obj.imagePath:len() - 4) .. display.imageSuffix .. ".png"
  local _time = os.time()
  params.progress = true
  print("download image", obj.name, URL .. name .. version .. "/" .. imgName)

  --
  local function buttonImageListener(event)
    if (event.isError) then
      print("Network error - download failed: ", event.response)
      local path = system.pathForFile(obj.name .. ".png", system.TemporaryDirectory)
      local fhd = io.open(path)
      -- Determine if file exists
      if fhd then
        obj.fill = {
          type = "image",
          filename = obj.name .. ".png",
          baseDir = system.TemporaryDirectory
        }
        fhd:close()
      else
        print("File does not exist!")
      end
    elseif (event.phase == "began") then
      print("Progress Phase  began")
    elseif (event.phase == "ended") then
      print("Displaying response image file with " .. obj.name .. ".png")
      obj.fill = {
        type = "image",
        filename = obj.name .. ".png",
        baseDir = system.TemporaryDirectory
      }
    end
  end
  print("download image", obj.name, URL .. name .. version .. "/" .. imgName)
  --
  network.download(
    URL .. name .. version .. "/" .. imgName .. "?time=" .. _time,
    "GET",
    buttonImageListener,
    params,
    obj.name .. ".png",
    system.TemporaryDirectory
  )
end

function M.isDownloadQueue()
  return false
end

function M.hasDownloaded(book, version)
  print("hasDownloaded", book, version)
  if not book.isDownloadable then
    print("no model.URL means it is embedded")
    return true
  end
  local _ver = version or ""
  local path = system.pathForFile(book.name .. _ver .. "/copyright.txt", system.ApplicationSupportDirectory)
  -- return os.rename(path,path) and true or false
  local f = io.open(path, "r")
  return f ~= nil and io.close(f)
end

M.init = function(_model, onSuccess, onError)
  onDownloadComplete = onSuccess
  onDownloadError = onError
  model = _model
  URL = _model.URL
  print("--------fetchAssets---------")
  fetchAssets()
end

return M
