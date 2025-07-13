local name = ...
local parent, root = newModule(name)
--
local M = {}
local pegasus = require(parent.."pegasus.init")
local harness = require(parent.."harness")
local json = require("json")
local yaml = require(parent..'yaml')
--local util = require(kwikGlobal.ROOT.."editor.util")
--local nanostores = require("nanostores.index")

local doPost = require(parent.."doPost")
local doGet = require(parent.."doGet")
local doPut = require(parent.."doPut")
local doDelete = require(parent.."doDelete")

local app

local parsers = {
  lua = function(data)
    if data  then
      print(data)
      local f = loadstring(data)
      local status, arg = pcall(f)
      if status then
        return json.encode(arg) or "true"
      else
        local pos = arg:find("stack traceback")
        if pos then
          return arg:sub(1, pos-1)
        else
          return arg
        end
      end
      -- return loadstring('return '.. data)()
    end
	end,
	yaml = function(data)
		return yaml.eval(data)
	end,
	json = function(data)
		return json.decode(data)
	end
}

--
-- To ensure proper functionality, each layer and each nested layer (child of a layer group)
-- must have a unique name. Duplicate names may cause errors or unexpected behavior.
--
-- For doGet allows to use a layer' parent name. It only supports one parent level.
--  for instacnes,
--      /book/page/parent/layer
--
--  the syntax parent/parent/layer is not supported

--  GET /book/page/layer is a normal syntax, parent/layser is optional syntax for clarification to fetch the properteis of a layer
--
-- for class
--  GET /book/page/layer/class
--  GET /book/page/parent/layer/class
--
-- POST does not allow 'parent' because to create/modify a class, 'parent/layer' syntax conflicts with layer/class
-- each layer has a unique name, we can reference a layer for POST
--
--   POST /book/page/layer/class
--


local path = system.pathForFile(kwikGlobal.PATH.."/server/docs", system.ResouceDirectory)
local server = pegasus:new({
	port='9090',
	location=path
})

function M.run (params)
  -- harness:init("../../../sample-projects", params)
  if not M.isRunning then
    harness:init("App", params)
    --
    server:start(function (request, response)
      print "It's running..."
      print(request._method, request._path)
      local ret, error = nil
      if request._method == "POST" then
        if request._path == "/hprint" then
          local data = request:post()
          if type(data) == "string" then
            local _type = request._headers["content-type"]:sub(string.len("application/") + 1)
            ret = parsers[_type](data)
            print(ret)
          end
        else
          ret = doPost:process(request, parsers)
        end

      elseif request._method == "GET" then
        ret = doGet:process(request)
      elseif request._method == "PUT" then
        ret = doPut:process(request, parsers)
      elseif request._method == "DELETE" then
        ret = doDelete:process(request)
      end
      if ret == nil then
        -- response:write("Done"..request._path)
        response:write("null")
      else
        response:write(ret)
      end
    end)
  end
  M.isRunning = true
end

return M
