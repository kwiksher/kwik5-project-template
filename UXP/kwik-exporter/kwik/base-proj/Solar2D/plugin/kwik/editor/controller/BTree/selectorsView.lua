local M = {}
local bt = require("btree")
local tree = require("selectorsTree")
local util = require(kwikGlobal.ROOT.."lib.util")

--
local nodes = {
  "select book",
  "select page",
  "select layer",
  "--",
  "select props",
  "add component",
  "modify component",
  "delete component",
  "--",
  "select animation",
  "select replacements",
  "select interactions",
  "select physics",
  "--",
  "copy",
  "paste",
  "hide",
  "preview",
  "save",
  "cancel"
}

local option, newText =
  util.newTextFactory {
  x = 300,
  y = 100,
  width = 150,
  height = 60,
  -- fontSize = 24,
  setFillColor = 1
}

local group = display.newGroup()

function M:create(BTree)
  local row = 1
  local column = 1
  local initY = 50

  local function conditionNode(name)
    return BTree.tree.conditions.items[name]
  end

  local function actionNode(name)
    return BTree.tree.actions.items[name]
  end

  for i = 1, #nodes do
    option.text = nodes[i]
    option.y = row * (option.height + 10) + initY
    row = row + 1
    if nodes[i] == "--" then
      option.x = option.x + option.width + 48 * 2
      row = 1
      column = column + 1
      if column == 3 then
        initY = initY + group.contentBounds.yMax
        option.x = 100
        column = 1
      end
    else
      -- print(group.contentBounds.yMax)
      local rect = display.newRect(option.x, option.y, option.width, option.height)
      rect:setFillColor(1, 0, 0)
      local obj = newText(option)
      obj.rect = rect
      --
      obj.conditionNode = conditionNode(option.text)
      if obj.conditionNode then
        -- for k, v in pairs(obj.conditionNode[1]) do print(k, v) end
        obj.conditionNode[1].viewObj = obj
      end
      --
      obj.actionNode = actionNode(option.text)
      if obj.actionNode then
        -- for k, v in pairs(obj.actionNode[1]) do print(k, v) end
        obj.actionNode[1].viewObj = obj
      end
      --
      function obj:tick(e)
        -- print("listener")
        -- print("", self.text, e.isActive, e.wasActive, e.status  )
        if e.isActive then
          if e.status == bt.RUNNING then
            self.rect:setFillColor(0, 0, 1)
          elseif e.status == bt.SUCCESS then
            self.rect:setFillColor(0, 1, 0)
          else
            self.rect:setFillColor(1, 0.5, 0)
          end
        else
          self.rect:setFillColor(1, 0, 0)
        end
      end
      --
      obj:addEventListener("tick", obj)
      --
      obj:addEventListener(
        "tap",
        function(e)
          if e.target.conditionNode then
            tree:setConditionStatus(e.target.text, bt.SUCCESS)
          end

          if e.target.actionNode then
            if e.target.text == "cancel" then
              -- print("# Cacel #")
              local parent = e.target.actionNode[1].parent
              -- for k, v in pairs(parent) do print("", k, v) end
              --
              for i = 1, #parent.children do
                --parent.children[i]:setStatus(bt.FAILED)
                parent.children[i]:setActive(false)
              end
              --
              local condNode = parent.parent.children[1]
              -- print("", "----")
              -- for k, v in pairs(condNode) do print("", k, v) end
              --
              tree:setConditionStatus(condNode.name, bt.FAILED)
            else
              tree:setActionStatus(e.target.text, bt.SUCCESS)
              timer.performWithDelay(
                1000,
                function()
                  tree:setActionStatus(e.target.text, bt.RUNNING)
                end
              )
            end
          end
        end
      )
      --
      --
      group:insert(obj.rect)
      group:insert(obj)
    end
  end
end

return M
