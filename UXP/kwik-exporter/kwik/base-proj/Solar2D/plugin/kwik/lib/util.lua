local exports = {}

local lustache = require("lustache")
local json     = require("json")

local lfs = require( "lfs" )

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"

function exports.pwd(path)
  return path:match("(.-)[^%.]+$")
end

function exports.root(path)
  local parent = exports.pwd(path)
  return parent:sub(1, parent:len()-1):match("(.-)[^%.]+$")
end


function exports.pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end


function exports.PATH (path)
	local ret = path
	if isWindows then
			ret = ret:gsub('/','\\')
	end
	return ret
end

function exports.isFile(name)
	if type(name)~="string" then return false end
	if not exports.isDir(name) then
			return os.rename(name,name) and true or false
			-- note that the short evaluation is to
			-- return false instead of a possible nil
	end
	return false
end

function exports.isFileOrDir(name)
	if type(name)~="string" then return false end
	return os.rename(name, name) and true or false
end

function exports.isDir(name)
	if type(name)~="string" then return false end
	local cd = lfs.currentdir()
	local is = lfs.chdir(name) and true or false
	lfs.chdir(cd)
	return is
end
--------
---
function exports.jsonFile(filename )
  local path = system.pathForFile(filename, system.ResourceDirectory )
  local contents
  local file = io.open( path, "r" )
  if file then
     contents = file:read("*a")
     io.close(file)
     file = nil
  end
  return contents
end

function exports.renderer (tmpltPath, outPath, model)
	--- .lua
	local file, errorString = io.open( tmpltPath..".lua", "r" )
	if not file then
		print( "File error: " .. errorString )
	else
		local contents = file:read( "*a" )
		io.close( file )
		local output = lustache:render(contents, model)

		local scenePath = outPath:gsub("models/", "")
		local file, errorString = io.open( scenePath..".lua", "w+" )
		if not file then
			print( "File error: " .. errorString )
		else
			output = string.gsub(output, "\r\n", "\n")
			file:write( output )
			io.close( file )
		end
	end
	-- .json
	local file, errorString = io.open( outPath..".json", "w+" )
	if not file then
		print( "File error: " .. errorString )
	else
		local output = json.encode(model)
		file:write( output )
		io.close( file )
	end
end

-- Calculates anchor points
function exports.repositionAnchor(object, newAnchorX, newAnchorY)
    local origX = object.x;
    local origY = object.y
    if object.repositionDone == nil then
        object.repositionDone = true;
        if newAnchorX ~= 0.5 or newAnchorY ~= 0.5 then
            local width = object.width;
            local height = object.height
            local xCoord = width * (newAnchorX - .5)
            local yCoord = height * (newAnchorY - .5)
            object.x = origX + xCoord;
            object.y = origY + yCoord
            object.oriX = object.x;
            object.oriY = object.y
        end
    end
end

function exports.readWeight(path)
  local weight = 0
  --local path = _path.."/"..file
         -- Open the file handle
  local file, errorString = io.open( path, "r" )

  if not file then
      -- Error occurred; output the cause
      print( "File error: " .. errorString )
  else
      -- Output lines
      for line in file:lines() do
          if line:find(".weight") then
              local pos = line:find("=")
              weight = line:sub(pos + 1)
             -- print( line, weight )
              break
          end
      end
      -- Close the file handle
      io.close( file )
  end
  file = nil
  return tonumber(weight) or 0
end

function exports.newLineswithWeight(_path, file, weight)
  local weight = 0
  local path = _path.."/"..file
         -- Open the file handle
  local file, errorString = io.open( path, "r" )
  if not file then
      -- Error occurred; output the cause
      print( "File error: " .. errorString )
  else
     local lines = file:lines()
      -- Output lines
      for i, line in next, lines do
          if line:find(".weight") then
              lines[i] = "$.weight="..weight
             -- print( line, weight )
              io.close( file )
              return lines
          end
      end
      table.insert(lines, 1, "$.weight="..weight)
      io.close( file )
      -- Close the file handle
      return lines
  end
  return nil
end

function exports.getLayer(UI, name)
  for i, v in next, UI.layers do
    if v.name == name then
      return v
    end
  end
end

function exports.split(str, sep)
  local out = {}
  for m in string.gmatch(str, "[^" .. sep .. "]+") do
    out[#out + 1] = m
  end
  return out
end


function exports.swapLangSuffix(name, lang)
  local t =name:split("/")
  return  t[1].."/".. lang
end

function exports.swapLangPrefix(name, lang)
  local t = name:split("/")
  -- print(name, t[1], t[2])
  return "sync/"..lang.."/".. t[3]
end

function exports.readSyncText(path, sentenceDirPath)
  local fullPath = system.pathForFile(path, system.ResourceDirectory)
  local file = io.open(fullPath, "r")
  if not file then
      print("Error opening file: " .. fullPath)
      return {}
  end

  local contents = file:read("*a")
  io.close(file)

  -- Remove carriage returns
  contents = contents:gsub("\r", "")
  -- Insert newline markers before every timestamp group.
  -- This assumes that each row starts with a number like "0.185760"
  contents = contents:gsub("(%d+%.%d+)[\t%s]+(%d+%.%d+)[\t%s]+", "\n%1\t%2\t")
  -- Remove any leading newline
  contents = contents:gsub("^%s*\n", "")

  local data = {}

  for line in contents:gmatch("([^\n]+)") do
    line = line:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
    local startTime, endTime, text = line:match("^([%d%.]+)[\t%s]+([%d%.]+)[\t%s]+(.*)$")
    if startTime and endTime and text then
      local newline = false
      if text:find("/n") then
        newline = true
        text = text:gsub("/n", "")
      end
      table.insert(data, {
        start = string.format("%.3f", tonumber(startTime)),
        out = string.format("%.3f", tonumber(endTime)),
        name = text,
        file = text:lower()..".mp3",
        action = "",
        newline = newline
      })
      -- print("Parsed: " .. startTime .. " - " .. endTime .. " - " .. text)
    else
      print("Invalid line format: '" .. line .. "'")
    end
  end

  -- print("Total parsed entries: " .. #data)
  for i, v in ipairs(data) do
    if system.pathForFile(sentenceDirPath.."/"..v.file, system.ResourceDirectory) == nil then
      print("checking each mp3 for each word. You may ignore Warning above for", sentenceDirPath.."/"..v.file)
      v.file = ""
    end
  end

  return data
end

----------------------------------
--
local function newText(option)
  local obj = display.newText(option)
  obj:setFillColor(0)
  return obj
end

local appFont
if ( "android" == system.getInfo( "platform" ) or isWindows ) then
  appFont = native.systemFont
else
  -- appFont = "HelveticaNeue-Light"
  appFont = "HelveticaNeue"
end
---
function exports.newTextFactory(_option) -- this is global
  local option = {
    text = "",
    x    = 0,
    y    = 0,
    width    = 0,
    height   = 20,
    font     = appFont,
    fontSize = 10,
    align    = "left"
  }
  if _option then
    for k,v in pairs(_option) do
      option[k] = v
    end
    if _option.anchorX then
      return option, function(option)
        local obj = display.newText(option)
        obj:setFillColor(0)
        obj.anchorX = _option.anchorX
        return obj
      end
    elseif _option.setFillColor then
      return option, function(option)
        local obj = display.newText(option)
        obj:setFillColor(_ootion.setFillColor)
        return obj
      end
    end
  end
  return option, newText
end

function exports.newTextField(option)
  		-- Create native text field
      local textField = native.newTextField( option.x, option.y, option.width, option.height )
      textField.font = native.newFont( appFont,option.fontSize )
      --textField:resizeFontToFitHeight()
      --textField:setReturnKey( "done" )
      --textField.placeholder = "Enter text"
      textField:addEventListener( "userInput", function()
        -- print("userInput")
      end )
      --native.setKeyboardFocus( textField )
      if type(option.text) == "string" then
        textField.text = option.text
      else
        textField.text = ""
        -- print(debug.traceback("textField.text is not a string"))
      end
      if option.parent then
        option.parent:insert(textField)
      end
      return textField
end

function exports.download(url, filename, dir)
  local function networkListener( event )
    if ( event.isError ) then
        print( "Network error - download failed: ", event.response )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        print( "Displaying response image file" )
        -- myImage = display.newImage( event.response.filename, event.response.baseDirectory, 60, 40 )
        -- myImage.alpha = 0
        -- transition.to( myImage, { alpha=1.0 } )
    end
  end

  local params = {}
  params.progress = true

  network.download(
    url,
    "GET",
    networkListener,
    params,
    filename,
    dir or system.TemporaryDirectory
  )
end


-- https://stackoverflow.com/questions/7526223/how-do-i-know-if-a-table-is-an-array

local function isArray(t)
  return #t > 0 and next(t, #t) == nil
end

function exports.flattenKeys(_parentKey, v)
  -- print(_parentKey)
  local ret = {}
  local parentKey = _parentKey or ""
  if type(v) == "table" then
    for key, value in pairs(v) do
      if type(value) ~="table" or isArray(value) then
        if key ~="_proxy" then
          flatten_key = parentKey .."_"..key
          ret[flatten_key] = value
        end
      elseif (key~="target" and key~="UI" and key ~= "__index" and key~="_class" and key ~="_functionListeners" and key~="_tableListeners" and key~="_proxy" and kye ~="screenHandler") then
        local _ret = exports.flattenKeys(parentKey .."_"..key, value)
        for kk, vv in pairs(_ret) do
          ret[kk] = vv
        end
      else
        ret[parentKey .."_"..key] = value
      end
    end
  else
    ret[parentKey] = v
  end
  return ret
end

exports.isArray = isArray


function exports.toBoolean(str)
  if type(str) == 'boolean' then
      return str
  end
  return str and string.lower(str) == "true" and true or false
end

function exports.toNumber (var)
  if type(var) == "string" then
    print("1")
    return tonumber(var)
  elseif type(var) == "table" then
    return 0
  end
  print("2", type(var))
  return tonumber(var)
end

local function compare(a,b)
  return a.name < b.name
end

function exports.sortProps(tbl)
  table.sort(tbl,compare)
end



--/Users/ymmtny/Documents/GitHub/kwik5/sandbox/Ps/react-uxp-styles/Project/Solar2D/templates/components/layer_props.lua
--/Users/ymmtny/Documents/GitHub/kwik5/sandbox/Ps/react-uxp-styles/Project/Solar2D/src/App/../templates/components/layer_props.lua: No such file or directory
return exports