local name = ...
local parent, root = newModule(name)
--
local M = {}

-- local pegasus = require(parent.."pegasus.init")
local harness = require(parent.."harness")
local json = require("json")
local yaml = require(parent..'yaml')
local util = require(kwikGlobal.ROOT.."editor.util")
-- local nanostores = require("nanostores.index")

function M:process(request, parsers)
	local data = request:post()
  local args = util.split(request._path, "/")
  print(request._path)
  if request._path == "/hprint" then
  end
  -- command=preview or save
  for k, v in pairs(request.querystring) do print(k, v) end
	--print(data)
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
		--
    print("#args", #args)
    if #args == 1 then
      print("args[1]=", args[1])
      if args[1] ==  "app" then
        -- modify app settings
      else
        local book=args[1]
        -- modify book props
      end
    elseif #args == 2 then
      local page=args[2]
        -- modify page props
    elseif args[1] == "components" and args[2] == "custom" then
      if #args == 2 then
      else
        local class = args[3]
      end
    else
      -- #args >= 3 means
      --
      -- /bookX/pageX/layerX
      print("args[3]=", args[3])
      local layerTable = require(kwikGlobal.ROOT.."editor.parts.layerTable")
      for i=1, #layerTable.objs do
        local obj = layerTable.objs[i]
        if obj.layer == args[3] and obj.class == "" then
          print("matched", i, obj.layer)
          local layer = args[3]
          --
          if #args == 3 then
            -- modify layer props
          elseif  #args == 4 then
            local isClassFound = false
            ----
            local function findFrom(obj, class)
              if obj.classEntries then
                --look for class
                for j=1, #obj.classEntries do
                  local classObj = obj.classEntries[j]
                  if classObj.class == class then
                    -- modify or create class
                    classObj.index = j
                    return classObj
                  end
                end
              end
              return nil
            end
            ----
            local classObj = findFrom(obj, args[4])
            if classObj  then
              classObj:touch({phase="ended"}) -- animation
              --
              -- how to fetch animation props
              --
              local tool = harness.UI.editor:getTool(args[4])
              local props = tool.controller:useClassEditorProps()
              -- merge with post's data
              for k, v in pairs(data) do
                if data[k] then
                  props[k] = data[k]
                end
              end
              tool.controller:setValue(props, classObj.index)
            else
              --
              -- create a new class
              --   for a custom class i.e. transition2 uses a generic tool
              --
              harness.UI.scene.app:dispatchEvent{
                  name = "editor.selector.selectTool",
                  UI = harness.UI,
                  class = args[4], -- obj.class,
                  isNew = true
                }
            end
          end
          --
          -- save or preivew
          --
        end
      end
    end
	elseif (type(data)=="table") then
		for k, v in pairs(data) do print(k, v) end
	end
end

return M