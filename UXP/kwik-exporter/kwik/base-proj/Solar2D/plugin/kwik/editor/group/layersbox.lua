local current = ...
local parent = current:match("(.-)[^%.]+$")
local root = parent:sub(1, parent:len()-1):match("(.-)[^%.]+$")

local M = require(root.."parts.linkboxMulti")

--
-- self.x, self.y are initialized in group/index.lua
--
function M:create(UI)

  -- if self.group == nil then
    self.group = display.newGroup()
    if self.triangle == nil then
      self.triangle = shapes.triangle.equi( self.x, self.y, 10 )
      self.triangle:rotate(180)
      self.triangle:setFillColor(1,1,0)
      self.triangle.alpha = 0
      self.triangle.tap = function(event)
        print("triangle tap")
        return true
      end
      --
      self.triangle:addEventListener("tap", self.triangle)
      self.group:insert(self.triangle)
    else
      self.triangle.x = self.x
      self.triangle.y = self.y
    end
    --
    self.triangle.isVisible = false
    --UI.editor.viewStore.triangle = self.triangle
    -- print("@@@@@@@@ layersbox @@@@@@@@@")
    --UI.editor.viewStore:insert(self.group)
  -- end

  UI.editor.layerJsonStore:listen(
    function(foo, fooValue)
      --print(debug.traceback())
      --self:init()
      self:hide()
      -- print("### setValue")
      self:setValue(fooValue.layers ) --  selectedValue, selectedIndex
      --
      if self.scrollView then
        self.scrollView:setSize(self.width*1.5, self.height*#self.objs)
        self.scrollView:toFront()
        self.scrollView:scrollToPosition{y=0}
        self.scrollView.y = self.y + self.height*#self.objs/2
      end
      --
      self:show()

    end)
end

function M:setValue(layers)
--  print(debug.traceback())
  local UI = self.UI
  local book = UI.editor.currentBook or App.get().name
  local page = UI.editor.currentPage or UI.page

  -- self.layers = util.read(book, page)
  --local class = "layers" -- typeMap[self.type]

  --print(debug.traceback())
  -- for k, v in pairs(layers[1]) do
  --   print(k, v)
  -- end
  -- -- --
  self.value             = selectedValue
  self.selection       = nil
  self.objs           = {}
  ---
  -- for k, v in pairs(self.layers) do print(k, #v) end

  if layers then
    self.layers = layers
    self:createTable(UI, layers, nil, nil)
  else
    print("error no model:")
  end
end

function M:reload()
  self:hide()
  self:destroy()
  -- print("### setValue")
  self:setValue(self.layers ) --  selectedValue, selectedIndex
  --
  self.scrollView:setSize(self.width*1.5, self.height*#self.objs)
  self.scrollView:toFront()
  self.scrollView:scrollToPosition{y=0}
  self.scrollView.y = self.y + self.height*#self.objs/2
  --
  self:show()

end

local instance = require(root.."parts.linkbox").new(M)

return instance
