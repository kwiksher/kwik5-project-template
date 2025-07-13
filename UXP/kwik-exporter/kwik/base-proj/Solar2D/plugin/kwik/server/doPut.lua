local name = ...
local parent, root = newModule(name)
--
local M = {}

-- local pegasus = require(parent.."pegasus.init")
local harness = require(parent.."harness")
local json = require("json")
local yaml = require(parent..'yaml')
local util = require(kwikGlobal.ROOT.."editor.util")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
-- local nanostores = require("nanostores.index")
local customManager = require(parent.."controller.customManager")
local layerManager = require(parent.."controller.toolLayerManager")
--

--
function M:process(request, parsers)
  local ret
	local data = request:put()
  local args = util.split(request._path, "/")
  local queries = {}
  -- command=preview or save
  for k, v in pairs(request.querystring) do
    print(k, v)
    queries[k] = v
  end
	print(data)
	if type(data) == "string" then
		local _type = request._headers["content-type"]:sub(string.len("application/") + 1)
		print(_type)
		local value = parsers[_type](data)
    if type(value) == 'table' then
      --
      print("-----")
      for k, v in pairs(value) do print(k, v) end
      -- for k, v in pairs(value[1]) do print(k, v) end
      print("-----")
      -- for k, v in pairs(value[2]) do print(k, v) end
    else
      print(value)
    end
  end
	-- elseif (type(data)=="table") then
	-- 	for k, v in pairs(data) do print(k, v) end
-- end
--
  print("#args", #args)
  if #args == 1 then
    print("args[1]=", args[1])
    if args[1] ==  "app" then
      -- create app settings
    else
      local book=args[1]
      -- create book props
      -- base-proj/Solar2D/App/bookX will be copied to App/args[1] folder
      ret = scripts.createBook(book)
    end
  elseif #args == 2 then
    local page=args[2]
    -- create page props
    scripts.createPage(args[1], args[2])
  elseif args[1] == "components" and args[2] == "custom" then
    ret =  customManager.put(args[3])
  else
    ret = layerManager.put(args, queries)
  end
  return ret
end

return M