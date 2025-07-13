local M = {}
local current = ...
local parent = current:match("(.-)[^%.]+$")

local bt = require(parent..'btree')
local filename = kwikGlobal.PATH.."editor/controller/BTree/selectors.tree"

local function readTree()
  local path = system.pathForFile( filename, system.ResourceDirectory )
  -- print("@@@@",path)
  local file, errorString = io.open( path, "r" )
  if not file then
      print( "File error: " .. errorString )
  else
      local contents = file:read( "*a" )
      io.close( file )
      return contents
  end
  return nil
end

-- function M:handler(actionNode)
--   repeat
--       local switch = actionNode.name
--       local cond = switch == "eat"
--       if cond then
--           print(bt.getFriendlyStatus(
--               nil,
--               actionNode:status()
--           ))
--           if actionNode:active() then
--               print("Started eating...")
--               self.tree:setActionStatus("eat", bt.SUCCESS)
--           end
--           break
--       end
--   until true
-- end

local status

function M:init(handler)
  local data = readTree()
  -- local data = [[
  --   ?
  --   |   (select book)
  --   |   [load book]
  --   ]]
  if data then
    self.tree = bt.BehaviorTree:fromText(data)
    -- M.tree:onActionActivation(M.handler)
    if self.tree then
      self.tree:onActionActivation(function(__, actionNode)
        if actionNode:active() and actionNode:status() ==bt.RUNNING then
          -- print("onActionActivation", actionNode.name, actionNode:active(), actionNode:status())
          local ret = handler(actionNode.name, actionNode:status() ) or bt.FAILED
          --print("", actionNode.name, bt.getFriendlyStatus(nil, ret))
          self.tree:setActionStatus(actionNode.name, ret)
        end
      end)
      --
      --self.tree:setConditionStatus("select book", bt.FAILED)
      --
      --self.tree.root:tick()
      -- print("Initial root state:")
      status = self.tree.root:status()
      -- print("", bt.getFriendlyStatus( nil,status ))
      -- print("", "active", self.tree.root:active() )
      --
      -- self.tree.root:tick()
      --
      -- print("dump node: select book" )
      -- for k, v in pairs(self.tree.root.children[1].children[1]) do print("",k, v) end
      --print("dump node: load book" )
      --for k, v in pairs(self.tree.root.children[1].children[]) do print("",k, v) end
      -- print("dump : conditions" )
      -- for k, v in pairs(self.tree.conditions.items) do print("",k, v) end
      -- print("dump : actions" )
      -- for k, v in pairs(self.tree.actions.items) do print("",k, v) end
      --
      -- self.tree:setConditionStatus("press esc", bt.FAILED)

    else
      print("error in data")
    end
  end
  --
end

function M:setConditionStatus(cond, value, skip)
  -- (select book)
  --print("setConditionStatus", cond, bt.getFriendlyStatus(nil, value))
  self.tree:setConditionStatus(cond, value) --bt.SUCCESS
  if not skip then
   -- print("----------tick---------------")
    --self.tree.root:deactivate()
    self.tree.root:tick()
    --
    status = self.tree.root:status()
    --print("", "root", bt.getFriendlyStatus(nil, status))
  end
end


function M:setActionStatus(action, value, skip)

  self.tree:setActionStatus(action, value)
  if not skip then
    -- print("----------tick---------------")
    -- self.tree.root:deactivate()
    self.tree.root:tick()
  end

end

function M:tick()
  -- [load book]
  -- print("----------tick---------------")
  -- self.tree.root:deactivate()
  self.tree.root:tick()
  status = self.tree.root:status()
  --print("root status:", bt.getFriendlyStatus( nil, status ))
end
return M