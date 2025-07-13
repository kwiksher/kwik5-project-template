local current = ...
local parent = current:match("(.-)[^%.]+$")
local root = parent:sub(1, parent:len()-1):match("(.-)[^%.]+$")
--
local json = require("json")


local layersbox     = require(root.."layersbox")
local layersTable   = require(root.."layersTable")
local propsTable    = require(root.."propsTable")
local buttons       = require(root.."buttons")

local M ={}

-------
-- I/F
--
local function useGroupProps(UI)
  -- print("useGroupProps")
  local props = {
    name = "",
    layersTable = {}
  }
  props.name = propsTable.name
  --
  local layers, currentTable= layersTable:getValue()
  for i=1, #layers do
    --print("", properties[i].name, type(properties[i].value))
    props.layersTable[#props.layersTable + 1 ] = layers[i]
  end
  --
  props.layersbox = layersbox:getValue()
  props.currentTable = currentTable
  print("## layersbox, layersTable, currentTable",#props.layersbox,  #props.layersTable, #props.currentTable)
  return props
end

M.useGroupProps = useGroupProps

-- this handler should be called from selectbox to set one of animtations user selected
-- local function groupHandler(decoded, index, template)
--   if decoded == nil then print("## Error groupHandler ##") return end
--   if not template then
--     layersbox:setValue(decoded[index].from)
--     layersTable:setValue(decoded[index].to)
--   else
--     layersbox:setValue(decoded.from)
--     layersTable:setValue(decoded.to)
--   end
-- end

-- layersbox.groupHandler = function(decoded, index)
--   groupHandler(decoded, index)
--   M:redraw()
-- end
--
layersbox.useGroupProps = useGroupProps

-- layersTable.groupHandler = function(decoded, index)
--   groupHandler(decoded, index)
--   M:redraw()
-- end
--
layersTable.useGroupProps = useGroupProps

function M:toggle ()
  buttons:toggle()
  propsTable:toggle()
  layersbox:toggle()
  layersTable:toggle()
end

function M:show ()
  propsTable:show()
  layersbox:show()
  layersTable:show()
  buttons:show()
  if layersbox.triangle then
    layersbox.triangle.isVisible = false
  end
end

function M:hide ()
  propsTable:hide()
  layersbox:hide()
  layersTable:hide()
  buttons:hide()
end

function M:redraw()

  layersbox:didHide(self.view.UI)
  layersTable:didHideow(self.view.UI)

  layersbox:destroy(self.view.UI)
  layersTable:destroy(self.view.UI)

  layersbox:create(self.view.UI)
  layersTable:create(self.view.UI)

  layersbox:didShow(self.view.UI)
  layersTable:didShow(self.view.UI)

  self.view.UI.editor.groupEditor:toFront()

end
--[[

function M:save(book, page, group, decoded)
  local groupName =  group or "index"
  local path = page .."/"..groupName.."_group.json"
  local path = system.pathForFile( "App/"..book.."/models/"..page .."/"..groupName.."_group.json", system.ResourceDirectory)

  local file, errorString = io.open( path, "w" )
   if not file then
      -- Error occurred; output the cause
      print( "File error: " .. errorString )
      return false
  else
      -- Write encoded JSON data to file
      file:write( json.encode( decoded ) )
      -- Close the file handle
      io.close( file )
      return true
  end
end

function M:read(book, page, group, isNew, tool)
  print("read", page, group, isNew, tool)
  if isNew then
  -- create a new group
  -- read the template
  local path = "editor.defaults.group"
  print(path)
  local template = require(path)
  print("", json.encode(template))

  local decoded -- TODO
  groupHandler(template, nil, true)
  self:redraw()

else
    local groupName = layer or "index"
    local path      = page .."/"..groupName.."_group.json"
    local path      = system.pathForFile( "App/"..book.."/models/"..page .."/"..groupName.."_group.json", system.ResourceDirectory)
    local decoded,   pos, msg = json.decodeFile( path )
    if not decoded then
        print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
    else
        print( "File successfully decoded!" )
    end
    groupHandler(decoded, 1)
    self:redraw()
  end
end

--]]


return M