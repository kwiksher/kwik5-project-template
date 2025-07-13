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
--
local customManager = require(parent.."controller.customManager")
local layerManager = require(parent.."controller.toolLayerManager")

--
function M:process(request)
  --app = harness.run("src")
  local ret = nil
  local args = util.split(request._path, "/")
  if #args == 1 then
    print("args[1]=", args[1])
    if args[1] == "unittest" then
      require(kwikGlobal.ROOT.."editor.index"):runTest()
    elseif args[1] ==  "app" then
      harness:dispatchEevnt("editor.selector.selectApp")
      -- local fooStore = nanostores.createStore()
      -- fooStore:set("ar")
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
      local books = nanostores.getValue(harness.UI.editor.bookStore)
      if books == nil then
        harness:dispatchEevnt("editor.selector.selectApp")
      end
      -- print("args[2]=", args[2])
      --harness:dispatchEevnt("editor.selector.selectBook", {book=args[2]})
      harness.bookTable.commandHandler({book=args[1]}, nil,  true)
      ret = nanostores.getValue(harness.UI.editor.pageStore)
    end
  elseif #args == 2 then

    if args[1] == "components" and args[2] == "custom" then
      ret = customManager.get()
    else
      --harness:dispatchEevnt("editor.selector.selectPage", {page=args[2]})
      harness.pageTable.commandHandler({page=args[2]},nil,  true)
      harness.selectors.componentSelector:show()
      harness.selectors.componentSelector:onClick(true,  "layerTable")
      ret = nanostores.getValue(harness.UI.editor.layerStore)


    end
    --
    -- for Transition2
    -- app = harness.gotoScene(path, args[2])
  else
    -- #args >= 3 means
    --
    -- /bookX/pageX/layerX
    ret = layerManager.get(args)

  end
  if type(ret) == 'table' then
    print("doGet", json.encode(ret))
    return  json.encode(ret)
  else
    return ret -- books
  end
end

return M