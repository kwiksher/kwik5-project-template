local M = {}

local json = require("json")
local lfs = require("lfs")
local lustache = require("lustache")
--local formatter = require("formatter")
local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"
local util = require(kwikGlobal.ROOT.."editor.util")
local libUtil = require(kwikGlobal.ROOT.."lib.util")

local currentScript
local Solar2DPath = system.pathForFile("./", system.ResourceDirectory)

-- Helper function to format paths for Windows and non-Windows systems
local function formatPaths(root, ...)
  local formattedPaths = {}

  if isWindows then
    root = '"'..root:gsub("/", "\\") .. '"'
    for i, path in ipairs({...}) do
      if path then
        formattedPaths[i] = '"'..path:gsub("/", "\\").. '"'
      else
        formattedPaths[i] = nil
      end
    end
  else
    root = root:gsub(" ", "\\ ")
    for i, path in ipairs({...}) do
      if path then
        formattedPaths[i] = path:gsub(" ", "\\ ")
      else
        formattedPaths[i] = nil
      end
    end
  end

  return root, unpack(formattedPaths)
end

local function saveScript(filename, model)
  -- print("saveScript")
  local ext = "command"
  if isWindows then
    ext = "bat"
  end
  --
  local path = system.pathForFile(kwikGlobal.PATH.."editor/scripts/" .. filename .. ext .. ".tmplt", system.ResourceDirectory)
  -- print("", path)
  local file, errorString = io.open(path, "r")
  local cmd = filename .. ext -- create_book.command
  local cmdFile

  if not file then
    print("ERROR: " .. errorString)
  else
    local contents = file:read("*a")
    io.close(file)
    output = lustache:render(contents, model)
    -- print(output)
    output = output:gsub("&#39;", '"')
    output = output:gsub("&#x2F;", "/")
    -- for win
    output = output:gsub("&quot;", '"')
    output = output:gsub("&gt;", '>')

    local path = system.pathForFile(cmd, system.TemporaryDirectory)
    --print(path)
    local file, errorString = io.open(path, "w+")
    if not file then
      print("ERROR: " .. errorString)
    else
      output = string.gsub(output, "\r\n", "\n")
      file:write(output)
      io.close(file)
    end
    if isWindows then
      cmdFile = '"' .. path:gsub("/", "\\") .. '"'
    else
      cmdFile = path:gsub(" ", "\\ ")
    end
  end

  return cmd, cmdFile
end

local function executeScript(filename, model)
  timer.performWithDelay( 500, function ()
    local cmd, cmdFile = saveScript(filename, model)
    if isWindows then
      -- print(cmd)
      -- print(cmdFile)
      local command = 'call "'.. system.pathForFile(cmd, system.TemporaryDirectory) .. '"'
      -- local command = 'start /min "" cmd /c /k call "'.. system.pathForFile(cmd, system.TemporaryDirectory) .. '"'
      -- print(command)
      os.execute(command)
      -- os.execute("copy " .. cmdFile .. ' "' .. system.pathForFile("", system.TemporaryDdirectory)..'"' )
      -- os.execute('cd "' .. system.pathForFile("", system.TemporaryDirectory) .. '" && ./' .. cmd)
    else
      -- print("cd " .. system.pathForFile("", system.TemporaryDirectory) .. "; source " .. cmd)
      -- os.execute("cp " .. cmdFile .. ' "' .. system.pathForFile("", system.TemporaryDirectory)..'"')
      os.execute('cd "' .. system.pathForFile("", system.TemporaryDirectory) ..'"'.. "; source " .. cmd)
    end
    return cmd
  end )
end

function M.createBook(book, _dst)
  local root = _dst or Solar2DPath
  return executeScript("create_book_bg.", {dst = root, book = book})
  --
  -- prepare application sandbox folder
  --
  -- util.mkdir("App", book)
  -- return M.createPage(book, "page1", root, weight)
end

function M.createPage(book, _index, _page, _root, _weight)
  local root = _root or Solar2DPath
  local dst = root .. "/App/" .. book .. "/index.lua"
  local tmplt = kwikGlobal.PATH.."template/index.lua"
  local pages = {}
  local weight = _weight or 1 -- for book.index
  --
  -- print("createPage", book, _index, _page, root)
  local scenes = require("App." .. book .. ".index")
  local index = #scenes
  if _page ~= nil and _index == nil then
    for i, v in next, scenes do
      if v == _page then
        index = i
        break
      end
    end
  end
  local page = _page or "page"..(index+1)
  --
  local path = system.pathForFile("App/" .. book .. "/index.lua", system.ResourceDirectory)
  if path then -- lfs.attributes(path)
    -- print("File exists")
    local scenes = require("App." .. book .. ".index")
    for i = 1, #scenes do
      pages[i] = scenes[i]
    end

    -- for i = 1, #scenes do
    --   pages[i] = {name = scenes[1]}
    -- end
    table.insert(pages, index+1,  page)
    -- weight = libUtil.readWeight(path)
  else
    print("Could not get attributes")
    pages[1] =  page
  end
  --
  -- print(tmplt)
  local newIndex = util.saveLua(tmplt, "App/" .. book .. "/index.lua", {pages = pages})
  -- page index
  util.mkdir("App", book, "components", page)

  local updatedModel = util.createIndexModel(nil, nil, nil)
  updatedModel.components.layers[1] = {name = "bg"}
  local newPageIndex = util.renderIndex(book, page, updatedModel)
  newPageIndex = system.pathForFile(newPageIndex, system.TemporaryDirectory)

  local plugin_path = system.pathForFile(kwikGlobal.PATH, system.ResourceDirectory)
  root, newPageIndex, newIndex, plugin_path = formatPaths(root, newPageIndex, newIndex, plugin_path)
  --
  return executeScript(
    "create_page.",
    {dst = root, book = book, page = page, newIndex = newIndex, newPageIndex = newPageIndex, plugin=plugin_path, weight = weight}
  )
end

function M.renamePage(book, page, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  -- assets/images/page1
  -- commands/page1
  -- components/page1

  -- index.lua gsub
  local newFile = system.pathForFile("App/"..book.."/index.lua", system.TemporaryDirectory)
  local path = system.pathForFile("App/" .. book .. "/index.lua", system.ResourceDirectory)
  local contents
  local file = io.open(path, "r")
  if file then
    contents = file:read("*a")
    io.close(file)
    file = nil
  end

  -- print('"' .. page .. '"', '"' .. newName .. '"', contents)
  contents = contents:gsub('"' .. page .. '"', '"' .. newName .. '"')

  local nfile = io.open(newFile, "w+")
  if nfile then
    contents = nfile:write(contents)
    io.close(nfile)
    nfile = nil
  end

  root, newFile = formatPaths(root, newFile)

  return executeScript("rename_page.", {dst = root, book = book, page = page, newName = newName, newIndex = newFile})
end

function M.copyPage(book, page, newName, _dst)
  local root = _dst or Solar2DPath
  -- assets/images/page1
  -- commands/page1
  -- components/page1

  -- index.lua gsub
  local newIndex = system.pathForFile("App/"..book.."/index.lua", system.TemporaryDirectory)
  local scenes = require("App." .. book .. ".index")
  local model = {}
  for i, v in next, scenes do
    table.insert(model, v)
    if v == page then
      table.insert(model,newName)
    end
  end
  -- if copied to a different book
  if #scenes == #model then
    table.insert(model,newName)
  end
  --
  local path = system.pathForFile(kwikGlobal.PATH.."template/index.lua", system.ResourceDirectory)
  local file, errorString = io.open(path, "r")
  if not file then
    print("ERROR: " .. errorString)
  else
    local contents = file:read("*a")
    io.close(file)
    output = lustache:render(contents, {pages=model})
    output = output:gsub("&#39;", '"')
    output = output:gsub("&#x2F;", "/")

    local nfile = io.open(newIndex, "w+")
    if nfile then
      contents = nfile:write(output)
      io.close(nfile)
      nfile = nil
    end
  end

  root, newIndex = formatPaths(root, newIndex)

  return executeScript("copy_page.", {dst = root, book = book, page = page, newName = newName, newIndex = newIndex})
end

function M.removePages(book, pages, _dst)
  local root = _dst or Solar2DPath

  local newIndex = system.pathForFile("App/"..book.."/index.lua", system.TemporaryDirectory)
  local scenes = require("App." .. book .. ".index")
  local newScenes = {}
  for i, v in next, scenes do
    local isDelete = false
    for ii, vv in next, pages do
      if vv == v then
        -- print("let's delete",vv)
        isDelete = true
        break
      end
    end
    if not isDelete then
      -- print(v)
      table.insert(newScenes,v)
    end
  end

  local path = system.pathForFile(kwikGlobal.PATH.."template/index.lua", system.ResourceDirectory)
  local file, errorString = io.open(path, "r")
    if not file then
    print("ERROR: " .. errorString)
  else
    local contents = file:read("*a")
    io.close(file)
    local output = lustache:render(contents, {pages = newScenes})
    output = output:gsub("&#39;", '"')
    output = output:gsub("&#x2F;", "/")

    local nfile = io.open(newIndex, "w+")
    if nfile then
      contents = nfile:write(output)
      io.close(nfile)
      nfile = nil
    end
  end

  local files = {}
  for i, page in next, pages do
    table.insert(files, "App/" .. book .. "/components/"..page)
    table.insert(files, "App/" .. book .. "/commands/"..page)
    table.insert(files, "App/" ..book.."/assets/images/"..page)
    table.insert(files, "App/" ..book.."/models/"..page)
  end
  --
  --
  local  root, commands = M.deleteFiles(files)
  newIndex = formatPaths(newIndex)

  --
  -- for undo
  --
  local model = {}
  for i, file in next, files do
    model[#model+1] = {file=file}
  end
  table.insert(model, {file = "App/"..book.."/index.lua"})
  local cmd, cmdFile = saveScript("undo_lua.", {dst = root, files = model})
  --
  return executeScript("delete_pages.", {dst = root, book = book, page = page, cmd = commands, newIndex = newIndex})

end

local function backupFiles(files, _dst)
  local root = _dst or Solar2DPath
  -- print("backupFiles", #files)
  --
  -- cp (system.TemporaryDirectory)copy_lua.command ( system.ResourceDirectory)../copy_lua.command
  -- cd (system.ResourceDirectory)..; source copy_lua.command
  --
  local entries = {}
  for i = 1, #files do
    -- print(files[i])
    if files[i] then
      local src = system.pathForFile(files[i], system.TemporaryDirectory)
      --local dst = system.pathForFile(nil, system.ResourceDirectory )
      local dir = util.getPath(files[i])
      local dst = files[i]
      if isWindows then
        dst = '"' .. dst:gsub("/", "\\") .. '"'
        entries[#entries + 1] = {file = dst}
      else
        src = src:gsub(" ", "\\ ")
        dst = dst:gsub(" ", "\\ ")
        dir = dir:gsub(" ", "\\ ")
        -- print ("cp "..tmp.." "..pathDst)
        entries[#entries + 1] = {file = dst}
      end
    end
  end
  if #entries > 0 then
    root = formatPaths(root)
    --
    local cmd, cmdFile = saveScript("undo_lua.", {dst = root, files = entries})
    ---
    executeScript("backup_lua.", {dst = root, files = entries})
  end
end

local function copyFiles(files, _dst)
  local root = _dst or Solar2DPath
  --
  -- cp (system.TemporaryDirectory)copy_lua.command ( system.ResourceDirectory)../copy_lua.command
  -- cd (system.ResourceDirectory)..; source copy_lua.command
  --
  local commands = {}
  for i = 1, #files do
    -- print(files[i])
    local src = system.pathForFile(files[i], system.TemporaryDirectory)
    --local dst = system.pathForFile(nil, system.ResourceDirectory )
    local dir = util.getPath(files[i])
    local dst = files[i]
    local tmp
    if isWindows then
      local dirPath = dst:gsub("/", "\\")
      local dirFolder = util.getPath(dirPath)

      -- Create a single command that creates directory structure recursively
      -- The /s option in md (mkdir) creates all intermediate directories if they don't exist
      if dirFolder and dirFolder ~= "" then
        commands[#commands + 1] = "if not exist \"" .. dirFolder .. "\" md \"" .. dirFolder .. "\" 2>nul"
      end

      tmp =  '"' .. src .. '"  "' .. dst..'"'
      tmp = "copy " ..tmp:gsub("/", "\\")
      commands[#commands + 1] = tmp
    else
      src = src:gsub(" ", "\\ ")
      dst = dst:gsub(" ", "\\ ")
      dir = dir:gsub(" ", "\\ ")
      tmp = "mkdir -p " .. dir .. ";cp " .. src .. " " .. dst
      -- tmp = tmp:gsub('/','')

      -- print ("cp "..tmp.." "..pathDst)
      commands[#commands + 1] = tmp
    end
  end
  --
  root = formatPaths(root)
  return root, commands
end

function M.createLayer(book, page, index, layer, _props)
  local files = {}
  local scene = require("App." .. book .. ".components." .. page .. ".index")
  local updatedModel = util.createIndexModel(scene.model)
  local entry = {}
  entry[layer] = {}
  --
  table.insert(updatedModel.layers, index, entry)
  --
  local props =
    _props or
    {name = layer, shape = "rect", x = display.contentCenterX, y = display.contentCenterY, width = 100, height = 100}
  local controller = require(kwikGlobal.ROOT.."editor.controller.index")
  --
  files[#files + 1] = controller:renderIndex(book, page, updatedModel)
  files[#files + 1] = controller:saveIndex(book, page, layer, nil, updatedModel)
  -- save lua
  files[#files + 1] = controller:render(book, page, layer, "layers", "shape", props)
  -- save json
  files[#files + 1] = controller:save(book, page, layer, nil, props)
  ---
  local  root, commands = copyFiles(files)
  return executeScript("copy_lua.", {dst = root, cmd = commands})
end

function M.createLayerWithClass(book, page, layer, class, _dst)
end

local function renameInIndex(book, page, oldName, newName, _dst)
  local newFile = system.pathForFile("App/" ..book.. "/components/"..page.."/index.lua", system.TemporaryDirectory)
  local path    = system.pathForFile("App/" ..book.. "/components/"..page.."/index.lua", system.ResourceDirectory)
  local contents
  local file = io.open(path, "r")
  if file then
    contents = file:read("*a")
    io.close(file)
    file = nil
  end

  -- print('"' .. oldName .. '"', '"' .. newName .. '"', contents)
  --
  -- name in index.lua, use gsub
  --
  -- contents = contents:gsub('"' .. oldName .. '"', '"' .. newName .. '"')
  contents = contents:gsub(oldName, newName)
  --
  util.mkdir("App", book, "components", page)
--
  local nfile = io.open(newFile, "w+")
  if nfile then
    contents = nfile:write(contents)
    io.close(nfile)
    nfile = nil
  end

  newFile = formatPaths(newFile)
  return newFile
end

function M.renameLayer(book, page, layer, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = renameInIndex(book, page, layer, newName, _dst)
  --
  -- layer.lua and layer_xxx.lua
  --
  local classEntries = {}
  local scene = require("App." .. book .. ".components." .. page .. ".index")
  local model = util.selectFromIndexModel(scene.model, {layer})

  if model and model.value then
    for k, v in pairs(model.value) do
      -- print(k, v)
      if k == "class" then
        for i, class in next, v do
          classEntries[#classEntries+1] = class
          -- print(class)
        end
      end
    end
  end

  root = formatPaths(root)

  return executeScript(
    "rename_layer.",
    {dst = root, book = book, page = page, layer = layer, newName = newName, newIndex = newFile, class = classEntries}
  )
end

function M.renameAudio(book, page, type, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = renameInIndex(book, page, oldName, newName, _dst)
  local subclass = "short"
  if type =="audio/long" then
    subclass = "long"
  end
  root = formatPaths(root)
  return executeScript(
    "rename_audio.",
    {dst = root, book = book, page = page, audio =oldName, newName = newName, newIndex = newFile, subclass = subclass}
  )
end

function M.renameGroup(book, page, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = renameInIndex(book, page, oldName, newName, _dst)
  root = formatPaths(root)
  return executeScript(
    "rename_group.",
    {dst = root, book = book, page = page, group =oldName, newName = newName, newIndex = newFile}
  )
end

function M.renameTimer(book, page, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = renameInIndex(book, page, oldName, newName, _dst)
  root = formatPaths(root)
  return executeScript(
    "rename_timer.",
    {dst = root, book = book, page = page, timer =oldName, newName = newName, newIndex = newFile}
  )
end

function M.renameJoint(book, page, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = renameInIndex(book, page, oldName, newName, _dst)
  root = formatPaths(root)
  return executeScript(
    "rename_joint.",
    {dst = root, book = book, page = page, joint =oldName, newName = newName, newIndex = newFile}
  )
end

function M.renameVarialble(book, page, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = renameInIndex(book, page, oldName, newName, _dst)
  root = formatPaths(root)
  return executeScript(
    "rename_variable.",
    {dst = root, book = book, page = page, variable =oldName, newName = newName, newIndex = newFile}
  )
end

function M.deleteBook(book, _dst)
  local root = _dst or Solar2DPath
  local newFile = system.pathForFile("main.lua", system.TemporaryDirectory)
  local path    = system.pathForFile("main.lua", system.ResourceDirectory)
  local contents
  local file = io.open(path, "r")
  if file then
    contents = file:read("*a")
    io.close(file)
    file = nil
  end

  -- print('"' .. oldName .. '"', '"' .. newName .. '"', contents)
  --
  -- name in index.lua, use gsub
  --
  contents = contents:gsub('"' .. oldName .. '"', '"' .. newName .. '"')
  --
  local nfile = io.open(newFile, "w+")
  if nfile then
    contents = nfile:write(contents)
    io.close(nfile)
    nfile = nil
  end
  root, newFile = formatPaths(root, newFile)
  return executeScript(
    "delete_book.",
    {dst = root, book = book}
  )
end


function M.renameBook(book, page, oldName, newName, _dst)
  local root = _dst or Solar2DPath
  local newFile = system.pathForFile("main.lua", system.TemporaryDirectory)
  local path    = system.pathForFile("main.lua", system.ResourceDirectory)
  local contents
  local file = io.open(path, "r")
  if file then
    contents = file:read("*a")
    io.close(file)
    file = nil
  end

  -- print('"' .. oldName .. '"', '"' .. newName .. '"', contents)
  --
  -- name in index.lua, use gsub
  --
  contents = contents:gsub('"' .. oldName .. '"', '"' .. newName .. '"')
  --
  local nfile = io.open(newFile, "w+")
  if nfile then
    contents = nfile:write(contents)
    io.close(nfile)
    nfile = nil
  end
  root, newFile = formatPaths(root, newFile)
  return executeScript(
    "rename_book.",
    {dst = root, book = book, newName = newName, newMain = newFile}
  )
end

--------------------------------------------------------
-- this publish () is for timer & group with own save()
--  append is a function implemented in the local save function
--
--     props.updatedModel= util.createIndexModel(props.UI.scene.model)
--     props.append = function(value, index)
--       local dst = props.updatedModel.components.timers or {}
--       if index then
--          dst[index] = value
--       else
--          dst[#dst + 1] = value
--       end
--     end
--
--
local function getModelFrom(args)
  local ret = {name=nil, properties={}}
  local selected = args.selected or {} -- args.selectbox.selection
  local append = args.append -- args.updatedModel.components.timers or {}
  local isNew = args.isNew

  ret.class = args.class
  ret.layer = args.layer
  ret.actions = args.actions

  -- local model = {
  --   index = selected.index
  -- }
  --
  -- TODO
  --

  ret.name = args.name or args.newName

  ---[[
  for k, entries in pairs(args.props ) do
    -- print("", k, type(entries))
    if k =="properties" then
      for i, v in next, entries do
        if type(v) ~= "table" then
          return print("Error properties are not like {{name=, v=}}")
        end
        if v.name == "_name" then
          ret.name = v.value
        elseif v.name == "_type" then
          ret.properties.type = v.value
        elseif v.name == "_target" then
          ret.properties.target = v.value
        elseif v.name == "_file" then
          ret.properties.file = v.value
        else
          if v.value == "" then
            ret.properties[v.name] = "NIL"
          else
            if v.name then
              ret.properties[v.name] = v.value
            end
          end
        end
      end
    else
      ret[k] = entries
    end
  end
  --
  -- props.actionName
  -- props.actionName = actionbox.selectedTextLabel
  --
  -- TODO check if name is not duplicated or not
  ---
  -- Append the new entry to components.{timers, variables ...} in index.lua
  ret.index = selected.index
  if append and ret.name then
    if isNew or selected.index == nil then
      append(ret.name)
    else
      append(ret.name, ret.index)
    end
    --
  end
--]]
  return ret
end

local function saveSelection(book, page, selections)
  -- Data (string) to write
  local saveData = {book = book, page = page, selections = selections}

  -- Path for the file to write
  local path = system.pathForFile("kwik.json", system.ApplicationSupportDirectory)

  -- Open the file handle
  local file, errorString = io.open(path, "w")

  if not file then
    -- Error occurred; output the cause
    print("ERROR: " .. errorString)
  else
    -- Write data to file
    file:write(json.encode(saveData))
    -- Close the file handle
    io.close(file)
  end

  file = nil
end

local pageTools = table:mySet {"page", "timer", "group", "variable"}
local classWithAssets = table:mySet {"audio", "video", "sprite", "particles", "www", "thumbnail", "font"}
--
function M.publish(UI, args, controller, decoded)
  local book = args.book or UI.editor.currentBook
  local page = args.page
  local updatedModel = args.updatedModel
  local layer = args.layer or UI.editor.currentLayer
  local class = args.class -- timer
  local suffx = args.suffix
  --local actionbox = args.actionbox
  -- local name = args.name -- args.selected.timer
  --
  -- print(args.model)
  local model  -- getModelFrom uses args.props.properties
  if args.props.properties  and #args.props.properties > 0 then
    model = getModelFrom(args)
  else
    model = args.model  or args.props
  end
  ---
  -- local _dump = util.copyTable(model)
  -- print(json.encode(_dump))
  -- print(json.prettify(model))

  local files = {}
  --
  if UI.editor.currentActionForSave  then
    local name, actions, controller = UI.editor.currentActionForSave()
    table.insert(updatedModel.commands, name)
    files[#files+1] = controller:render(book, page, name, actions)
    -- save json
    files[#files+1] = controller:save(book, page, name, {name=name, actions = actions})
    UI.editor.currentActionForSave = nil
  end
  --
  files[#files + 1] = util.renderIndex(book, page, updatedModel)
  files[#files + 1] = util.saveIndex(book, page, layer, class, updatedModel)
  --
  if pageTools[class] then
    -- local classFolder = class
    -- save lua
    files[#files + 1] = controller:renderPage(book, page, class, model.name, model)
    -- save json
    files[#files + 1] = controller:save(book, page, class, model.name, model)
  else
    --
    --  'shape' class will be avairable and expected here for creating a new layer if isNew
    --  for modifying a layer model will have a class value as 'image' when created by UXP plugin.
    --
    local classFolder = args.class and UI.editor:getClassFolderName(args.class) or nil
    -- print(classFolder)
    -- save lua
    -- print("@@@", model.name)
    files[#files + 1] = controller:render(book, page, layer, classFolder, class, model, suffix)
    -- save json
    files[#files + 1] = controller:save(book, page, layer, classFolder, decoded or model, suffix) -- decoded will be nil
    -- save asset
    if classWithAssets[class] then
      files[#files + 1] = controller:renderAssets(book, page, layer, classFolder, class, model)
    end
  end
    -- save the lastSelection
  saveSelection(book, page, {{name = layer, class = class, suffix=suffix}})
  -- publish
  backupFiles(files)
  --
  local  root, commands = copyFiles(files)
  return executeScript("copy_lua.", {dst = root, cmd = commands})
end

function M.publishForSelections(UI, args, controller, decoded)
  --
  --[[
  print("---args.props----")
  for k, v in pairs(args.props) do print("", k, v) end
  if args.actions then
    print("---args.actions----")
    for k, v in pairs(args.actions) do print("", k, v) end
    end
  print("---decoded----")
  for k, v in pairs(decoded) do print("", k, v) end
  --]]

  local files = {}
  local class = (args.class or "layer"):lower()
  local classFolder = UI.editor:getClassFolderName(class)
  local suffix = args.suffix or ""
  -------------
  local book = args.book or UI.editor.currentBook
  local page = args.page or UI.page
  local layer = args.layer or UI.editor.currentLayer or args.props.properties.target

  -- print("publishForSelections", book, page, layer, class, suffix)
  -- print("", "classFolder="..classFolder)

  -- print(json.encode(args))
  local model  -- getModelFrom uses args.props.properties
  if args.props.properties and #args.props.properties > 0 then
    model = getModelFrom(args)
  else
    model = args.model  or args.props
  end
  --
  model.class = class
  -- print("---model----", model)
  -- for k, v in pairs(model) do print("", k, v) end
  -- if model.properties then
  --   for k, v in pairs(model.properties) do print("properties", k, v) end
  -- end
  -- if model.actions then
  --   for k, v in pairs(model.actions) do print("actions", k, v) end
  -- end

  ---------
  --- Update components/pageX/index.lua model/pageX/index.json
  local scene = require("App." .. book .. ".components." .. page .. ".index")
  local updatedModel = scene.model
  -- print(json.encode(updatedModel))
  local selections = UI.editor.selections or {}
  if #selections == 0 and UI.editor.currentLayer:len() == 0 then
    -- cueentLayer is not set when user selecting an asset like particle, and use activeProp to set the target
    -- print(UI.editor.selections, UI.editor.currentLayer:len(), UI.editor.currentClass)
    local target =  model.properties.target or model.properties._target
    if target == nil or target:len() == 0 then
       native.showAlert( "alert", "Please select a layer or _target for creating a component")
      return false
    else
      selections =  {{text=target, class =UI.editor.currentClass, layer=target, suffix = UI.editor.currentSuffix }}
    end
  else
    -- selections = {{text=UI.editor.currentLayer, class =UI.editor.currentClass, layer=UI.editor.currentLayer }}
    -- print(json.prettify(selections))
  end
  -- print("@@@@", layer)
  for i, obj in next, selections do
    if obj.parentObj then
      -- class has been set, so the layer == "witch/en/button"
      layer = util.getLayerPath(obj)
    else
      layer = obj.layer or obj.name
    end
    model.layer = layer
    model.name = obj.layer or obj.name
    -- print("@@@@", layer, model.layer)
    local groupType =  model.properties and (model.properties._type or model.properties.type) or nil
    updatedModel = util.updateIndexModel(updatedModel, model.layer, class, groupType)
    -- print(json.prettify(updatedModel))

    --- save json
    -----------
    -- print(book, page, model.layer, classFolder, args.index)
    if model.index then
      decoded[model.index] = model
    else
      decoded = model
    end
    -- decoded[model.index].properties = model.properties
    -- decoded[model.index].actionName = model.actionName
    -- decoded[model.index].name=model.name
    --
    -- print(json.prettify(model))
    -- save lua
    files[#files + 1] = controller:render(book, page, model.layer, classFolder, class, model, suffix)
    -- save json
    files[#files + 1] = controller:save(book, page, model.layer, classFolder, decoded, suffix)
    -- save asset
    if classWithAssets[class] then
      files[#files + 1] = controller:renderAssets(book, page, model.layer, classFolder, class, model)
    end
  end
  ---
  -- print(json.encode(updatedModel))

  local renderdModel = util.createIndexModel(updatedModel)
  -- print("------------------------------")
  -- print(json.prettify(renderdModel))

  --
  if UI.editor.currentActionForSave  then
    local name, actions, controller = UI.editor.currentActionForSave()
    table.insert(renderdModel.commands, name)
    files[#files+1] = controller:render(book, page, name, actions)
    -- save json
    files[#files+1] = controller:save(book, page, name, {name=name, actions = actions})
    UI.editor.currentActionForSave = nil
  end

  files[#files + 1] = controller:renderIndex(book, page, renderdModel)
  files[#files + 1] = controller:saveIndex(book, page, nil, nil, renderdModel)
  --
  saveSelection(book, page, selections)
  ----------
  backupFiles(files)
  --
  local  root, commands = copyFiles(files)
  return executeScript("copy_lua.", {dst = root, cmd = commands})
end

function M.delete_(UI)
  for i, obj in next, UI.editor.selections do
    local class, name
    for k, v in pairs(pageTools) do
      name = obj[k]
      if name ~= nil then
        class = k
        -- print("", k, name)
        break
      end
    end
    if name == nil then
      print("", obj.layer, obj.class)
      name = obj.layer
      class = obj.class
    else
      -- as audio imer, variable,
      -- print("", class, name)
    end
    ---
    -- removeFromIndex, deleteFile
  end
end

function M.delete(files)
  local  root, commands = M.deleteFiles(files)
  return executeScript("delete_lua.", {dst = root, cmd = commands})
end

function M.getScript()
  return currentScript
end

----
function M.openEditorByPath(_path)
  local path =
    system.pathForFile(_path, system.ResourceDirectory)
  local cmd = "code " .. path
  os.execute(cmd)
end

function M.openEditorForCommand(book, page, name)
  local path =
    system.pathForFile("App/" .. book .. "/commands/" .. page .. "/" .. name .. ".lua", system.ResourceDirectory)
  local cmd = "code " .. path
  os.execute(cmd)
end

function M.openEditorForAudio(book, page, name, subclass)
  local path =
    system.pathForFile("App/" .. book .. "/components/" .. page .. "/audios/"..subclass.."/" .. name .. ".lua", system.ResourceDirectory)
  local cmd = "code " .. path
  os.execute(cmd)
end

-- type == audios, groups, page, timers, variables
function M.openEditor(book, page, type, name)
  local path =
    system.pathForFile(
    "App/" .. book .. "/components/" .. page .. "/" .. type .. "/" .. name .. ".lua",
    system.ResourceDirectory
  )
  local cmd = "code " .. path
  os.execute(cmd)
end

function M.openEditorForLayer(book, page, layer, class, type)
  -- print("openEditorForLayer", book, page, layer, class, type)
  local path = system.pathForFile("App/" .. book, system.ResourceDirectory)
  if class and class:len() > 3 and class ~= layer then
    if type == "group" then
      path = path .. "/components/" .. page .. "/groups/" .. layer .. "_" .. class .. ".lua"
    else
      path = path .. "/components/" .. page .. "/layers/" .. layer .. "_" .. class .. ".lua"
    end
  elseif layer == "index" then
    path = path .. "/components/" .. page .. "/index.lua"
  else
    if type == "group" then
      path = path .. "/components/" .. page .. "/groups/" .. layer .. ".lua"
    elseif type == "timer" then
     path = path .. "/components/" .. page .. "/timers/" .. layer .. ".lua"
    elseif type == "variable" then
      path = path .. "/components/" .. page .. "/variables/" .. layer .. ".lua"
    elseif type == "joint" then
      path = path .. "/components/" .. page .. "/joints/" .. layer .. ".lua"
      else
      path = path .. "/components/" .. page .. "/layers/" .. layer .. ".lua"
    end
  end
  --
  -- local url = "vscode://file/" .. path
  -- if ( system.canOpenURL( url ) ) then
  --     system.openURL( url )
  -- else
  --     print( "WARNING: Facebook app is not installed!" )
  -- end
  --
  local cmd = "code " .. path
  os.execute(cmd)
end

function M.openFinder(book, folder)
  local path = system.pathForFile("App/" .. book .. "/assets/" .. folder, system.ResourceDirectory)
  local cmd = "open " .. path
  os.execute(cmd)
end

local function deleteFiles(files, _dst)
  local root = _dst or Solar2DPath
  --
  -- cp (system.TemporaryDirectory)copy_lua.command ( system.ResourceDirectory)../copy_lua.command
  -- cd (system.ResourceDirectory)..; source copy_lua.command
  --
  local commands = {}
  for i = 1, #files do
    -- print(files[i])
    --local src = system.pathForFile(files[i], system.TemporaryDirectory)
    local src = system.pathForFile(files[i], system.ResourceDirectory )
    local dir = util.getPath(files[i])
    local dst = files[i]
    local tmp
    if isWindows then
      tmp =  src .. " " .. src..".bak"
      tmp = "move " ..'"' .. tmp:gsub("/", "\\") .. '"'
      commands[#commands + 1] = tmp
    elseif src then
      src = src:gsub(" ", "\\ ")
      dst = dst:gsub(" ", "\\ ")
      dir = dir:gsub(" ", "\\ ")
      tmp = "mv " .. src .." "..src..".bak"
      -- tmp = "mkdir -p " .. dir .. ";cp " .. src .. " " .. dst
      -- tmp = tmp:gsub('/','')

      -- print (tmp)
      commands[#commands + 1] = tmp
    end
  end

  root = formatPaths(root)
  return root, commands
end

function M.executeCopyFiles(files, _dst)
  local dst, commands = copyFiles(files, _dst)
  executeScript("copy_lua.", {dst = dst, cmd = commands})
end

function M.deleteFiles(files, _dst)
  return deleteFiles(files, _dst)
end

M.copyFiles = copyFiles
M.backupFiles = backupFiles
M.saveSelection = saveSelection

return M
