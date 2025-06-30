
local M = {}

local root = system.pathForFile("", system.ResouceDirectory)
-- local projRoot = "../SampleCode"
local projRoot = "App"

local projPath, project

function M:init(path, params)
	projRoot = path

  self.selectors = params.selectors
  self.UI        = params.UI
  self.bookTable = params.bookTable
  self.pageTable = params.pageTable
  self.layerTable = params.layerTable

end

M.run = function(projectName, src)
	project = projectName
    --
	projPath = projRoot.."/"..project:gsub('%.', '/')
	print(projPath)
	-- package.path = root..projRoot .."/?.lua;"..package.path
	package.path = root..projPath.."/?.lua;"..package.path
    --
	local app = require(project.."."..src)
	return app
end

function M:gotoScene(projectName, src)
	project = projectName
    --
	projPath = projRoot.."/"..project:gsub('%.', '/')
	print(projPath)
	-- package.path = root..projRoot .."/?.lua;"..package.path
	package.path = root..projPath.."/?.lua;"..package.path
    --
  local composer = require("composer")
	composer.gotoScene(project.."."..src)
  return composer.getScene(project.."."..src)
end

function M:dispatchEevnt(eventName, args)
  -- selectApp
  --   returns books
  local params = {
    name = eventName,
    UI = self.UI
  }
  if args then
    for k, v in pairs(args) do
      params[k] = v
    end
  end
  self.UI.scene.app:dispatchEvent(params)
  --
end

function M:selectLayer(name)
--local name = "title"
  for i, entry in next, self.layerTable.objs do
    if entry.text == name then
      print("@selectLayer", i, entry.text)
      entry:touch({phase="ended"}) -- layer props
      break
    end
  end
end

M.execute = function(ProjectName)
	local name = ProjectName:gsub("%.", "/")
	local cmd = 'open -n "corona://open?url=file:///'..root..projRoot..'/'..name..'/'..'&skin=iPadMini"'
	os.execute(cmd)
end

-- print(package.path)

--[[
local function fillFunc(self, options)
	if options.filename then
		options.filename = projPath .."/"..options.filename
	elseif options.paint1 then
		options.paint1.filename = projPath .."/"..options.paint1.filename
		options.paint2.filename = projPath .."/"..options.paint2.filename
	end
	self.fill = options
end

local newCircle_func = display.newCircle
display.newCircle = function(...)
	local obj = newCircle_func(...)
	obj.fillFunc = fillFunc
	return obj
end

local newRect_func = display.newRect
display.newRect = function(...)
	local obj = newRect_func(...)
	obj.fillFunc = fillFunc
	return obj
end

local newPolygon_func = display.newPolygon
display.newPolygon = function(...)
	local obj = newPolygon_func(...)
	obj.fillFunc = fillFunc
	return obj
end

local newImage_func = display.newImage
display.newImage = function(...)
	local args = {...}
	print("newImage")
	for i=1, #args do print("", args[i]) end
	if args[1] == nil and args[2] == nil then return nil end
	if type(args[1]) == "string" then
		if #args ==  3 then
			return newImage_func(projPath .."/"..args[1], args[2],args[3])
		else
			return newImage_func(projPath .."/"..args[1], args[2],args[3], args[4])
		end
    else
		return newImage_func(args[1], projPath .."/"..args[2],args[3], args[4])
	end
end

local newImageRect_func = display.newImageRect
display.newImageRect = function(...)
	local args = {...}
	print("newImageRect")
	for i=1, #args do print("", args[i]) end
	if #args == 3 then
		return newImageRect_func(projPath .."/"..args[1], args[2], args[3])
	elseif type(args[2]) == 'string' then
		print("",projPath .."/"..args[2])
		return newImageRect_func(args[1], projPath .."/"..args[2], args[3], args[4])
	else
		return newImageRect_func(...)
	end
end

local newRoundedRect_func = display.newRoundedRect
display.newRoundedRect = function(...)
	local obj = newRoundedRect_func(...)
	obj.fillFunc = fillFunc
	return obj
end

local newImageSheet_func = graphics.newImageSheet
graphics.newImageSheet = function(... )
	local args = {...}
	print("newImageSheet")
	for k, v in pairs(args) do print("", k,v) end
	if args[1]:find("widget_theme") ~= nil then
		return newImageSheet_func(...)
	else
		return newImageSheet_func(projPath .."/"..args[1], args[2])
	end
end

local pathForFile_func =  system.pathForFile
system.pathForFile = function(filename, baseDir)
	if baseDir == system.ResourceDirectory then
		return pathForFile_func(projPath .."/"..filename, baseDir)
	else
		return pathForFile_func(filename, baseDir)
	end
end

local newEmitter_func =  display.newEmitter
display.newEmitter = function(params)
	params.textureFileName = projPath .."/"..params.textureFileName
	return newEmitter_func(params)
end

local newMask_func = graphics.newMask
graphics.newMask = function(filename)
	return newMask_func(projPath .."/"..filename)
end

local loadStream_func = audio.loadStream
audio.loadStream = function(filename, baseDir)
	if baseDir then
		return loadStream_func(filename, baseDir)
	else
	return loadStream_func(projPath .."/"..filename)
	end
end

local loadSound_func = audio.loadSound
audio.loadSound = function(filename, baseDir)
	if baseDir then
		return loadSound_func(filename, baseDir)
	else
	return loadSound_func(projPath .."/"..filename)
	end
end

local physics = require("physics")
local newParticleSystem_func = physics.newParticleSystem
physics.newParticleSystem = function(params)
	params.filename = projPath .."/"..params.filename
	return newParticleSystem_func(params)
end
--]]

---
-- https://forums.solar2d.com/t/sharing-code-between-projects/338881/19
---

return M