-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
local _K            = require "Application"
--
function _M:brushSize(canvas, psize, pal)
  if canvas == nil then print ("no canvas") return end
  canvas.properties.brushSize = psize
  canvas.brushAlpha = pal or 1
end
--
function _M:brushColor( canvas, r, g, b, a)
  if r then
    if canvas == nil then print ("no canvas") return end
    canvas.properties.brushColor = {r, g, b, a}
  end
end
--
function _M:erase(canvas)
  if canvas == nil then print ("no canvas") return end
  _K.reloadCanvas = 0
  local lineTable = canvas.lineTable
  for i=1, #lineTable do
     lineTable[i]:removeSelf(); lineTable[i] = nil
  end
  canvas.undone   = {}
  canvas.lineTable = {}
end
--
function _M:undo(canvas)
  if canvas == nil then print ("no canvas") return end
  local lineTable = canvas.lineTable
  local undone    = canvas.undone

  if #lineTable>0 then
      local n = #lineTable
      local stroke = lineTable[n]
      table.remove(lineTable, n)
      lineTable[n] = nil
      undone[#undone+1] = stroke
      stroke.isVisible = false
   end
end
--
function _M:redo(canvas)
  if canvas == nil then print ("no canvas") return end
  local lineTable = canvas.lineTable
  local undone    = canvas.undone

 if #undone>0 then
     local n = #undone
     local stroke = undone[n]
     table.remove(undone, n)
     undone[n] = nil
     lineTable[#lineTable+1] = stroke
     stroke.isVisible = true
  end
end
--
return _M