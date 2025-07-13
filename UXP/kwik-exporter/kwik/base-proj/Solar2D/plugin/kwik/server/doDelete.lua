local name = ...
local parent, root = newModule(name)
--
local M = {}

-- local pegasus = require(parent.."pegasus.init")
local harness = require(parent.."harness")
local json = require("json")
local yaml = require(parent..'yaml')
local util = require(kwikGlobal.ROOT.."editor.util")
local nanostores = require("nanostores.index")

function M:process(request)
  --app = harness.run("src")
  local ret = nil
  local args = util.split(request._path, "/")
  if #args == 1 then
    print("args[1]=", args[1])
    if args[1] ==  "app" then
      harness:dispatchEevnt("editor.selector.selectApp")
      -- local fooStore = nanostores.createStore()
      -- fooStore:set("bar")
      -- subscribing to changes
      -- fooStore:subscribe(function(foo, fooValue)
      --   print("Initial value from a subscription", fooValue)
      -- end)

      -- listen for changes without an initial value
      -- fooStore:listen(function(foo, fooValue)
      --   print("Change from a listener", fooValue)
      -- end)
      -- ret = nanostores.getValue(fooStore)
      ret = nanostores.getValue(harness.UI.editor.bookStore)
    else
      -- print("args[2]=", args[2])
      --harness:dispatchEevnt("editor.selector.selectBook", {book=args[2]})
      harness.bookTable:commandHandler({book=args[1]}, nil,  true)
      ret = nanostores.getValue(harness.UI.editor.pageStore)
    end
  elseif #args == 2 then
    --harness:dispatchEevnt("editor.selector.selectPage", {page=args[2]})
    harness.pageTable:commandHandler({page=args[2]},nil,  true)
    harness.selectors.componentSelector:show()
    harness.selectors.componentSelector:onClick(true,  "layerTable")
    ret = nanostores.getValue(harness.UI.editor.layerStore)
    --
    -- for Transition2
    -- app = harness.gotoScene(path, args[2])
  else
    -- #args >= 3 means
    --
    -- /bookX/pageX/layerX

    print("args[3]=", args[3])

    local layerTable = require(kwikGlobal.ROOT.."editor.parts.layerTable")
    for i=1, #layerTable.objs do
      local obj = layerTable.objs[i]
      if obj.layer == args[3] and obj.class == "" then
        print("####", i, obj.layer)
        harness:selectLayer(args[3])
        --
        local propsTable = require(kwikGlobal.ROOT.."editor.parts.propsTable")
        ret = {}
        ret.type = "layer"
        ret.props = propsTable:getValue()
        ret.class = {}
        if obj.classEntries then
          for j=1, #obj.classEntries do
            local classObj = obj.classEntries[j]
            table.insert(ret.class, classObj.class)
          end
        end
        --
        if args[4] ~= nil then
          --look for class
          for j=1, #obj.classEntries do
            local classObj = obj.classEntries[j]
            print("@@@", classObj.class, j) -- linear
            --local toolName = harness.UI.editor:getTool(classObj.class)
            if classObj.class == args[4] then
              classObj:touch({phase="ended"}) -- animation
              --
              -- how to fetch animation props
              --
              local tool = harness.UI.editor:getTool(args[4])
              ret.props = tool.controller:useClassEditorProps()
              ret.type = "class"
              break
            end
          end
          -- look for children
          if obj.childEntries and ret.type == "layer" then -- not find a class for arg[4]
            for j=1, #obj.childEntries do
              local childObj = obj.childEntries[j]
              if childObj.layer == args[4] then
                childObj:touch({phase="ended"}) -- animation
                --
                -- how to fetch animation props
                ret.type = "layer"
                --
                ret.props = propsTable:getValue()
                --
                -- we need recursively selecting class or child
                --
                ret.class = {}
                for j=1, #childObj.classEntries do
                  local classObj = childObj.classEntries[j]
                  table.insert(ret.class, classObj.class)
                end
                break
              end
            end
          end
        end
      end
    end

    -- /bookX/pageX/layerX/classX
    -- /bookX/pageX/layerX/childrenX
    --
    -- layer's children must be handled
    -- {
    --   type = "class", -- "layer"
    --   props = {},
    --   childern = {},
    --   classes = {}
    -- }
    -- ret = {}
  end
  if type(ret) == 'table' then
    print("doGet", json.encode(ret))
    return  json.encode(ret)
  else
    return ret -- books
  end
end

return M
