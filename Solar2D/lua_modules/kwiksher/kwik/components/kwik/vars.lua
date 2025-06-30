-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _Class = {}
local json   = require("json")
local App              = require(kwikGlobal.ROOT.."controller.Application")
local app              = App.get()

-- for k, v in pairs(app.props) do print(k, v) end

--
-- Variable saving function
local path = system.pathForFile( app.props.appName.."kwkVars.json", app.props.DocumentsDir )
-- print(app.props.appName.."kwkVars.json", path)
local file = io.open( path, "r" )
if file then
    io.close(file)
    file = nil
else
   local file = io.open( path, "w+" )
   file:write("{{}}")
   io.close(file)
   file = nil
end
-- Json code for external variable loading
local jsonFile = function(filename )
   local path = system.pathForFile(filename, app.props.DocumentsDir )
   local contents
   local file = io.open( path, "r" )
   if file then
      contents = file:read("*a")
      io.close(file)
      file = nil
   end
   return contents
end
--
local kwkVar = json.decode( jsonFile(app.props.appName.."kwkVars.json") )
-- Check for saved variables
function _Class:kwkVarCheck(variable)
   kwkVar = json.decode( jsonFile(app.props.appName.."kwkVars.json") )
   local found = nil
   if kwkVar ~= nil then
      for i = 1, #kwkVar do
         if (variable == kwkVar[i].name) then
            found = kwkVar[i].value; break
         end
      end
   end
   return (found)
end
--save all permanent variables
function _Class:zeroesKwikVars() --restart the file to save variable content
	local path = system.pathForFile(app.props.appName.. "kwkVars.json", app.props.DocumentsDir )
	local contents
	local file = io.open( path, "w+b" )
	if file then
	   contents = file:write( "{{}}" )
	   io.close( file )	-- close the file after using it
       file = nil
	end
end

function _Class:saveKwikVars(toSave) --toSave is a table with contents
   local varTab={}
	--loop current kwkVar content (contains ALL variables saved)
	local found = nil
	local jsonString

	--checks if current file is empty or not
	local path = system.pathForFile(app.props.appName.. "kwkVars.json", app.props.DocumentsDir )
	local contents
	--check if file exists
	local file = io.open( path, "r" )
	if file then
	    --reads to check if original content is empty == {{}}
	    local test = file:read("*l")
		io.close( file )
		if test=="{{}}" or test == nil then
	       -- kwkVar.json is empty. Recreates the file with the new content
			local file = io.open( path, "w+" )
			varTab[1] = {["name"] = toSave[1],["value"] = toSave[2]}
			jsonString = json.encode( varTab )
			contents = file:write( jsonString )
			io.close( file )
		else
			--there are already variables saved in the kwkVars.json file
			local file = io.open( path, "w" )
			local ts = 0
			for i = 1,#kwkVar do
				if (toSave[1] == kwkVar[i].name) then
					kwkVar[i].value = toSave[2]
					varTab[i] = {["name"] = kwkVar[i].name,["value"] = kwkVar[i].value}
					ts = 1
			    else
					varTab[i] = {["name"] = kwkVar[i].name,["value"] = kwkVar[i].value}
				end
		    end
		    if (ts == 0) then --variable not in the file yet
		    	local x = #kwkVar
		    	x = x + 1
			    varTab[x] = {["name"] = toSave[1],["value"] = toSave[2]}
			end
		    jsonString = json.encode( varTab )
	    	contents = file:write( jsonString )
			io.close( file )
	    end
	else
		--re-creation scenario
		_Class.zeroesKwikVars()
	end
	kwkVar = json.decode( jsonFile(app.props.appName.. "kwkVars.json" ) )
end

return _Class