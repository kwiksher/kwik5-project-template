local M = {}
--
package.loaded["statemap"] = require(kwikGlobal.ROOT.."components.bookstore.smc.statemap")
local composer        = require("composer")
local IAP             = require(kwikGlobal.ROOT.."components.bookstore.controller.IAP")
local downloadManager = require(kwikGlobal.ROOT.."components.bookstore.controller.downloadManager")
local json            = require("json")
--
local App             = nil
local model           = nil
local fsm             = nil

---[[

--
-- local type = {pages = 0, embedded = 1, tmplt=2}
---------------------------------------------------
--
local currentBookModel = nil
local currentBook    = nil
M.currentPage          = 1
M.numberOfPages             = 1 -- referneced from page_swipe.lua
--
local function getPageNum(num)
  return num
end
M.getPageNum = getPageNum
--
local function readPageJson(name, version)
    local jsonFile = function(filename )
       local path = system.pathForFile(filename, system.ApplicationSupportDirectory)
       print(path)
       local contents
       local file = io.open( path, "r" )
       if file then
          contents = file:read("*a")
          --print (contents)
          io.close(file)
          file = nil
       end
       return contents
    end
    local _ver = version or ""
    currentBook = name.._ver
    currentBookModel =  json.decode( jsonFile(name.._ver.."/model.json") )
    -- for k, v in pairs(currentBookModel) do
    --     for l, m in pairs(v) do print(l, m) end
    -- end
    M.numberOfPages = #currentBookModel
end
--
M.readPageJson = readPageJson
--
--
----------------------------------
local setSystemDir = {}
--
M.init =function(_model)
  model = _model
  print("-------pageCommand.init----", model.TOC)
  if model.TOC == nil then
    print(debug.traceback())
  end
  fsm = require(kwikGlobal.ROOT.."components.bookstore.smc.bookstoreFSM").getInstance(_model)
  App = require(kwikGlobal.ROOT.."controller.Application")
  M.app = App.get()
  if M.app then
    print("pageCommand init appName", M.app.name)
    M.scenes = M.app.props.scenes
  end
end
--
M.setDir = function(pageNum)
    return true
end
--
-- pages, embedded, tmplt
--
M.gotoTOC = function()
  fsm:exit()
  print("gotoTOC", model.TOC)
  Runtime:dispatchEvent({name="changeThisMug", appName=model.TOC, page=2})
end

M.showView = function(page, options)
    App.get():showView( "components." .. page .. ".index", options)
end

-- type.embedded and type.tmplt
M.gotoNextScene = function()
  local scenes = M.scenes
  local app = M.app
  local getNext = function()
    for i = 1, #scenes do
      local sceneName = "components." .. scenes[i] .. ".index"
      if sceneName == app.currentViewName then
        if i == #scenes then
          return "components." .. scenes[1] .. ".index"
        end
        return "components." .. scenes[i + 1] .. ".index"
      end
    end
    return app.currentViewName
  end
  app:showView(getNext(), {effect = "slideLeft"})
end
-- type.embedded and type.tmplt
M.gotoPreviousScene = function()
  local scenes = M.scenes
  local app = M.app
  local getPrevious = function()
    for i = 1, #scenes do
      local sceneName = "components." .. scenes[i] .. ".index"
      if sceneName == app.currentViewName then
        if i == 1 then
          return "components." .. scenes[#scenes] .. ".index"
        end
        return "components." .. scenes[i - 1] .. ".index"
      end
    end
    return app.currentViewName
  end
  app:showView(getPrevious(), {effect = "slideRight"})
end
-- type.embedded and type.tmplt
M.gotoBook = function(book, page, version)
    local _ver = version or ""
    fsm:exit()
    Runtime:dispatchEvent({name="changeThisMug", appName=book.._ver, page=page})
end
-- type.embedded and type.tmplt
M.gotoNextBook = function(version)
  currentBook = App.currentName
  print("gotoNextBook", currentBook)
    local k, v, nextItem= nil, nil, nil
    local _ver = version or ""
    for k, v in pairs(model.books) do
      if k == currentBook then
        nextItem = next(model.books, k) or next(model.books, nil)
        break
      end
    end
    if nextItem then
        local book = model.books[nextItem]
        if book.isDownloadable and not downloadManager.hasDownloaded(book, _ver) then
            Runtime:dispatchEvent({name="changeThisMug", appName=model.TOC})
        else
          Runtime:dispatchEvent({name="changeThisMug", appName=book.name.._ver})
        end
        -- fsm:exit()
    else
        fsm:exit()
        Runtime:dispatchEvent({name="changeThisMug", appName=model.TOC})
    end
end
-- type.embedded and type.tmplt
M.gotoPreviousBook = function(version)
  local _ver = version or ""
  currentBook = App.currentName
  print("gotoPreviousBook", currentBook)
    local k, v, previousItem = nil, nil, nil
    for k, v in pairs(model.books) do
      if k == currentBook then
        if previousItem then
          break
        end
      end
      previousItem = k
    end
    if previousItem then
        local book = model.books[previousItem]
        if book.isDownloadable and not downloadManager.hasDownloaded(book, _ver) then
            -- fsm:exit()
            Runtime:dispatchEvent({name="changeThisMug", appName=model.TOC})
        else
          Runtime:dispatchEvent({name="changeThisMug", appName=book.name.._ver})
        end
    else
      fsm:exit()
      Runtime:dispatchEvent({name="changeThisMug", appName=model.TOC})
    end
end

function M.hasDownloaded(book, ver)
    IAP:init(model.name, model.catalogue, nil, nil, model.debug)
    if (IAP.getInventoryValue("unlock_"..book)==true) then
        if downloadManager.hasDownloaded(book, ver) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function M.isPageReady(num)
    return true
end

function M.gotoScene(event, version)
    local book =  model.books[event.target.selectedBook]
    print("UI.gotoScene ".. book.name, version)
    local _ver = version or ""
    -- fsm:exit()
    Runtime:dispatchEvent({name="changeThisMug", appName=book.name.._ver})
    return true
end


M.newBookstore = function (_model)
  local instance = {}
  model = _model
  print("newBookstore", _model.TOC)
  instance.view = require ( "components.bookstore.view.index" ).getInstance(_model)
  instance.fsm = require ( "components.bookstore.smc.bookstoreFSM" ).getInstance(_model)
  --
  function instance:init(sceneGroup, props)
    print("-------bookstore init -------------")
    self.view:init(sceneGroup, props, self.fsm)
    self.fsm:init(self.view) -- isDialog=false, view = bookstore.view
  end
  --
  function instance:initDialog(sceneGroup)
    print("-------bookstore initDialog -------------")
    self.view:initDialog(sceneGroup) -- isDialog = true
    --self.fsm:initDialog(self.view) -- isDialog=false, view = bookstore.view
  end
  --
  function instance:setSceneGroup(sceneGroup)
    self.view.thumbnail:setSceneGroup(sceneGroup)
  end
  --
  function instance:destroy()
    self.fsm:destroy()
  end
  return instance
end
--]]

return M