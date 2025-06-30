-- Code created by Kwik - Copyright: kwiksher.com 2016, 2017, 2018
-- Version: 4.3.1
-- Project: Canvas
--
local dir = ...
local parent = dir:match("(.-)[^%.]+$")

require("index")
require("Deferred")
require("Callbacks")

string.split = function(str, sep)
  local out = {}
  for m in string.gmatch(str, "[^" .. sep .. "]+") do
    out[#out + 1] = m
  end
  return out
end

local util = require(kwikGlobal.ROOT.."lib.util")

local function newInstance(M, props, _layerProps)
  -- print(props.name)
  local instance = {}
  if props.name then
    instance.name = props.name
  end
  --
  -- if props.parent then
  --   if props.layerProps then
  --     instance.layerProps = props.layerProps
  --     instance.layerProps.name =  props.parent..".".._layerProps.name
  --   else
  --     instance.layerProps = {name = props.parent..".".._layerProps.name}
  --   end
  -- else
    if props.layerProps then
      instance.layerProps = props.layerProps
    -- elseif props.name then
    else
      instance.layerProps = {name = props.name}
    end
  -- end
  --
  -- print("$$$$$$$$$$$$$$$$")
  for k, v in pairs(_layerProps) do
    if instance.layerProps[k] == nil then
      -- print(k, v)
      instance.layerProps[k] = v
    end
  end
  return setmetatable(instance, {__index = M})
end

function newModule(name)
  local M = {}
  local parent = name:match("(.-)[^%.]+$")
  local root = parent:sub(1, parent:len()-1):match("(.-)[^%.]+$")
  M.name = name:sub(root:len()+1)
  local isLayers = M.name:find("layers.")
  if isLayers then
    M.name = M.name:sub(8)
  end
  local names = name:split(".")
  local last = names[#names]

  -- Handle the last segment to find the last underscore
  local reversedLast = last:reverse()
  local reversedPos = reversedLast:find("_")
  if reversedPos then
    local originalPos = #last - reversedPos + 1
    local classText = last:sub(originalPos)  -- Get the part after underscore (e.g., "class4suffix")

    -- Extract className and suffix using pattern matching
    local className, suffix = string.match(classText, "([^%d]+)(%d.*)")

    -- Store these in M
    M.className = className or classText  -- Default to classText if pattern fails
    M.suffix = suffix or ""              -- Empty string if no suffix found
    M.layerMod = parent .. last:sub(1, originalPos - 1)
  else
    M.className = last
    M.suffix = ""
    M.layerMod = parent .. last
  end

  M.newInstance = newInstance
  return parent, root, M
end

local AppContext = require(kwikGlobal.ROOT.."controller.ApplicationContext")
local composer = require("composer")
------------------------------------------------------
------------------------------------------------------
local M = {apps = {}}
--
function M:orientation(event) end
--
function M:whichViewToShowBasedOnOrientation()
    local t = self.lastKnownOrientation
    if t == "landscapeLeft" or t == "landscapeRight" then
    else
    end
end
--
function M:cancelAllTweens()
    local k, v
    for k, v in pairs(self.gt) do
        v:pause();
        v = nil;
        k = nil
    end
    self.gt = nil
    self.gt = {}
end
--
function M:cancelAllTimers()
    local k, v
    for k, v in pairs(self.timerStash) do
        timer.cancel(v)
        v = nil;
        k = nil
    end
    self.timerStash = nil
    self.timerStash = {}
end
--
function M:cancelAllTransitions()
    local k, v
    for k, v in pairs(self.trans) do
        transition.cancel(v)
        v = nil;
        k = nil
    end
    self.trans = nil
    self.trans = {}
end
--
function M.getPosition(x, y)
  local editorWidth, editorHeight = display.contentWidth - 480, display.contentHeight -320
  local mX = x and (x * 0.25 + editorWidth * 0.5) or 0
  local mY = y and (y * 0.25 + editorHeight * 0.5 ) or 0
  return mX, mY
end

function M.getCenter(x, y)
  local mX = x and (x + display.contentWidth * 0.5) or display.contentCenterX
  local mY = y and (y + display.contentHeight * 0.5) or display.contentCenterY
  return mX, mY
end


--[[
  if align == "left" then
    mX = mX - (display.safeActualContentWidth - w)/2
  elseif align == "right" then
    mX = mX + (display.safeActualContentWidth - w)/2
  elseif align == "top" then
    mY = mY - (display.safeActualContentHeight - h)/2
  elseif align == "bottom" then
    mY = mY + (display.safeActualContentHeight - h)/2
  elseif align == "topLeft" then
    mX = mX - (display.safeActualContentWidth - w)/2
    mY = mY - (display.safeActualContentHeight - h)/2
  elseif align == "topRight" then
    mX = mX + (display.safeActualContentWidth - w)/2
    mY = mY - (display.safeActualContentHeight - h)/2
  elseif align == "bottomLeft" then
    mX = mX - (display.safeActualContentWidth - w)/2
    mY = mY + (display.safeActualContentHeight - h)/2
  elseif align == "bottomRight" then
    mX = mX + (display.safeActualContentWidth - w)/2
    mY = mY + (display.safeActualContentHeight - h)/2
  end
  return mX, mY
--]]


function M.parseValue (value, newValue)
	if newValue then
		if value then
			return newValue
		else
			return nil
		end
	else
		return value
	end
end

function M.getByName(name)
  for i=1, #M.apps do
    if M.apps[i].props.appName ==  name then
      return M.apps[i]
    end
  end
  return nil
end

function M.get(index)
  if index then
      return M.apps[index]
  else
    return M.getByName(M.currentName)
  end
end

function M.getProps()
  return M.getByName(M.currentName).props
end

local useModelJSON = false

function M.loadPage(UI)
  --
  local bookName = UI.book
  local path =system.pathForFile( "App/"..bookName.."/models", system.ResourceDirectory)
  if useModelJSON and path then
    local success = lfs.chdir( path ) -- isDir works with current dir
    if success then
      local pages = {}
      for file in lfs.dir( path ) do
        if util.isDir(file) then
          -- print( "Found file: " .. file )
          -- set them to nanostores
          if file:len() > 3 and file ~='assets' then
            table.insert(pages, {name = file, path= util.PATH(path.."/"..file)})
          end
        end
      end
      print("loadPage", #pages)
      if #pages > 0 then
        UI.editor.pageStore:set{value = pages}
      end
    end
  else
    local sceneIndex = require( "App."..bookName..".index")
    if path == nil then
      print("# models folder is missing for", bookName)
      path = "App/"..bookName.."/models"
    end
    local success = lfs.chdir( path ) -- isDir works with current dir
    if success then
      local pages = {}
      for i, scene in next, sceneIndex do
          table.insert(pages, {name = scene, path= util.PATH(path.."/"..scene)})
      end
      if #pages > 0 then
        UI.editor.pageStore:set{value = pages}
      end
    end
  end

  -- assets
  UI.editor.assets = require(kwikGlobal.ROOT.."editor.asset.index").controller:read(bookName)
  UI.editor.assetStore:set{value = {decoded=UI.editor.assets}}
end

function M.getImageSuffix()
  local imageSuffix = display.imageSuffix
  local scale = imageSuffix=="@2x" and 2 or 1
  scale = imageSuffix == "@4x"  and 4 or scale
  return scale
end

function M.new(Props)
  local app = display.newGroup()
  app.classType = "App."..Props.appName..".index"
  app.currentView = nil
  app.currentViewName = nil
  app.props = Props
  app.name = Props.appName
  --
  app.variables = {}
  app.audios    = {}
  --
  M.apps[#M.apps+1] = app

  function app:getView(viewName)
    return self.context.Router[viewName]
  end
  -- viewName == "components"..page...".index"
  function app:showView(viewName, _options)
      -- print(debug.traceback())
      -- print("-------------- showView ------------------", self.props.appName.."."..viewName, ", currentViewName:", self.currentViewName)
      if self.scene and self.scene.UI.editor then
          for k, v in pairs(self.scene.UI.timers) do
            timer.cancel(v)
          end
          for k, v in pairs(self.scene.UI.animations) do
            if v.to then v.to:pause() end
            if v.from then v.from:pause() end
          end
          self.scene.UI.editor:destroy()
      end

      self.currentViewName = viewName
      local scene = self.context.Router[viewName]
      if scene == ni then
        print("ERROR showView "..self.props.appName, viewName, "not found in")
        for k, v in pairs(self.context.Router) do print("", k) end
        return
      end
      self.scene = scene
      --
      -- why dispathEvent is called twice? we prevent it by isActive as false
      --
      self.scene.isActive = false
      --
      --
      -- scene.app.currentViewName = viewName
      local options = _options or {}
      options.params = options.params or {time=0}
      scene.UI.page = scene.model.page
      scene.UI.book = app.name
      options.params.sceneProps = {app =scene.app, classType = scene.classType, UI = scene.UI, model=scene.model, getCommands = scene.getCommands}
      composer.gotoScene("App."..self.props.appName.."."..viewName, options)
  end
  --
  function app:autoPlay(delay, _options)
    local scene
    for i, v in next, app.props.scenes do
      if v == self.scene.UI.page then
          if i == #app.props.scenes then
          scene = app.props.scenes[1]
          else
          scene = app.props.scenes[i+1]
          end
          break
      end
    end
    app.autoPlayTimer = timer.performWithDelay(delay*1000, function()
        app:showView("components."..scene..".index", _options)
    end, -1)
  end
  --
  function app:autoPlayCancel()
    timer.cancel(app.autoPlayTimer)
  end

  --
  function app:showOverlay(viewName, _options)
    print("showView", viewName, ", currentViewName:", self.currentViewName)
    self.currentViewName = viewName
    local scene = self.context.Router[viewName]
    local options = _options or {}
    options.params = options.params or {}
    options.params.sceneProps = {app =scene.app, classType = scene.classType, UI = scene.UI, model=scene.model, getCommands = scene.getCommands}
    composer.showOverlay("App."..self.props.appName.."."..viewName, options)
  end
  --
  function app:trigger(viewName, params)
      if viewName == self.currentViewName then
          print("same scene")
          return true
      end
      self.currentViewName = viewName
      print("trigger", viewName)
      local scene = self.context.Router[viewName]
      scene.UI.page = scene.model.page
      -- if scene.view == nil then
        scene:dispatchEvent({name="init"})
        scene:dispatchEvent({name="create"})
      -- end
      scene:dispatchEvent({name="show", phase = "will"})
      scene:dispatchEvent({name="show", phase = "did"})
      scene:dispatchEvent({name="transition", params = self.props.position})
  end

  function app:init()
      -- app:addEventListener("onRobotlegsViewCreated", function(e) print("test") end)
    if self.context == nil then
      self.context = AppContext.new(self)
      self.context:init(app.props.scenes, app.props)

      if #self.props.scenes > 0 then
        if type(self.props.gotoPage) == "number" then
          self.startSceneName = "components." .. self.props.scenes[self.props.gotoPage]..".index"
        else
          self.startSceneName = "components." .. self.props.gotoPage..".index"
        end
        --
        self:dispatchEvent({name = "app.statsuBar", event = "init"})
        self:dispatchEvent({name = "app.droidHWKey", event = "init"})
        self:dispatchEvent({name = "app.memoryCheck", event = "init"})
        self:dispatchEvent({name = "app.statusBar", event = "init"})
        self:dispatchEvent({name = "app.suspend", event = "init"})
        --
        -- ApplicationMediator.onRegister shows the top page
        --
        self.useTrigger = false -- true app:trigger, false:app:showView (composer.gotoScene)
        self:dispatchEvent({name = "onRobotlegsViewCreated", target = self}) -- self == app, this sets mediator's viewInstance as app
      end
    elseif self.useTrigger then
      self:trigger(self.startSceneName, {})
    else
      self:showView(self.startSceneName, {})
    end
  end

  function app:getVariable(name)
    return self.variables[name]
  end

  function app:setVariable(name, value)
    self.variables[name] = value
  end

  -- if M.editor == nil then
  --   M.editor = require(kwikGlobal.ROOT.."editor.index")
  --   package.loaded[kwikGlobal.ROOT.."editor.index"] = M.editor
  -- end
-- editor.lastSelection = { book="book", page=app.props.gotoPage}

  app:addEventListener("onRobotlegsViewDidShow", function(event)
    -- printKeys(event.target)

    local UI = event.UI
    if UI and UI.props.editor then
      if M.editor then
        M.editor:didHide(UI)
        M.editor:destroy(UI)
      end
      M.editor = nil
      package.loaded[kwikGlobal.ROOT.."editor.index"]  = nil

      M.editor = require(kwikGlobal.ROOT.."editor.index")
      -- package.loaded["kwik.editor.index"] = M.editor

      --
      M.editor:init(UI)
      M.editor:create(UI)
      M.editor:didShow(UI)
      if app.fromEditor then
        M.editor:showPageView()
        app.fromEditor = false
      end
      -- print("-----loadPage------")
      M.loadPage(UI)
    end

  end)

  app:addEventListener("onRobotlegsViewDestroyed", function(event)
    print("----- destroyed------")
    -- this comes from scene:destroy, so maybe not called because the caller is solar2d composer.
  end)

  return app
end

M.getModel = function(layerName, imagePath, currentPage, dX, dY)
  local _dX = dX or 0
  local _dY = dY or 0
  local targetPage = currentPage
  local page = currentBookModel[targetPage]
  local layer = page[layerName]
  if layer == nil then layer = {x=0, y=0, width=0, height=0} end
  local _x, _y = App.ultimatePosition(layer.x + _dX, layer.y + _dY)
  local path = nil
  if imagePath then
      local i = string.find(imagePath, "/")
     path = "p"..targetPage..string.sub(imagePath, i)
  end
  return _x, _y, layer.width/4, layer.height/4, path
end

--
return M
