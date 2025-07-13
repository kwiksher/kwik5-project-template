local M = {}
---------------------
local app = require "controller.Application"
---------------------
-- local canvas
--
function M:setCanvas(obj)
  self.obj = obj --obj--display.newRect(0, 0, {{cw}}, {{ch}})
  -- self.x          = {{mX}}
  -- self.y          = {{mY}}
  -- self.alpha      = 0.01;
  -- print("canvas")
  self.name = "UI.canvas"
  -- brushSize                      = 10
  self.brushAlpha = 1
  self.lineTable = {}
  self.undone = {}

  self.obj:setFillColor(unpack(self.properties.canvasColor))
  -- sceneGroup:insert( self)
end
--
-- self code
function M:newLine(event)
  local lineTable = self.lineTable
  local linePoints = self.linePoints or {}
  local sceneGroup = self.UI.sceneGroup
  local obj = self.obj
  local index = 1
  local group = self.group
  local cR, cG, cB = self.properties.brushColor[1], self.properties.brushColor[2], self.properties.brushColor[3]
  local brushSize = self.properties.brushSize
  -- print("brushSize", brushSize)
  --
  local function drawLine()
    local line =
      display.newLine(
      linePoints[#linePoints - 1].x,
      linePoints[#linePoints - 1].y,
      linePoints[#linePoints].x,
      linePoints[#linePoints].y
    )
    local circle = display.newCircle(linePoints[#linePoints].x, linePoints[#linePoints].y, brushSize / 2)

    if (circle ~= nil and line ~= nil and group ~= nil) then
      -- print(cR, cG, cB)
      line:setStrokeColor(cR, cG, cB, self.brushAlpha)
      line.strokeWidth = brushSize
      group:insert(line)
      -- print(cR, cG, cB)
      circle:setFillColor(cR, cG, cB, self.brushAlpha)
      group:insert(circle)
      --
      if self.properties.outline then
        -- OUTLINE ON
        sceneGroup:insert(group)
        sceneGroup:remove(obj)
        sceneGroup:insert(obj)
        sceneGroup[self.name] = obj
      else
        -- OUTLINE OFF
        sceneGroup:insert(group)
      end
    else
      print("something wrong with drawing lines")
    end
  end
  --
  if event.phase == "began" then
    self.group = display.newGroup()
    index = #lineTable + 1
    lineTable[index] = self.group
    self.group:translate(-sceneGroup.x, -sceneGroup.y)
    --
    local circle = display.newCircle(event.x, event.y, brushSize * 0.5, 100)
    -- print(cR, cG, cB)
    circle:setFillColor(cR, cG, cB, self.brushAlpha)
    self.group:insert(circle)
    --
    if self.properties.outline then
      -- OUTLINE ON
      sceneGroup:insert(self.group)
      sceneGroup:remove(obj)
      sceneGroup:insert(obj)
      sceneGroup[self.name] = obj
    else
      -- OUTLINE OFF
      sceneGroup:insert(self.group)
    end

    self.linePoints = {}
    local pt = {}
    pt.x = event.x
    pt.y = event.y
    table.insert(self.linePoints, pt)
  elseif event.phase == "moved" then
    local pt = {}
    pt.x = event.x
    pt.y = event.y
    if (#linePoints == 0) then
      index = #lineTable + 1
      self.group = display.newGroup()
      self.group:translate(-sceneGroup.x, -sceneGroup.y)
      -- self.linePoints = {}
      table.insert(linePoints, pt)
    end
    if not (pt.x == linePoints[#linePoints].x and pt.y == linePoints[#linePoints].y) then
      table.insert(linePoints, pt)
      drawLine()
    end
  elseif event.phase == "ended" or "cancelled" then
  --  if self.properties.outline then
  --    self.linePoints = {}
  --  end
  end
  return true
end

--
function M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  self.linePoints = nil
  self.lineTable = {}
  local obj = self.obj
  --
  if obj == nil or UI.book == nil then return end
  --
  obj:addEventListener(
    "touch",
    function(event)
      self:newLine(event)
    end
  )
  --
  if self.properties.autoSave then
    -- Auto load previous paint in the canvas
    app.reloadCanvas = 1
    local path = system.pathForFile(UI.book .. "_canvas_" .. UI.page .. ".jpg", system.TemporaryDirectory)
    local fhd = io.open(path)
    if fhd then --file exists
      fhd:close()
      --
      local x, y, w, h, a = obj.x, obj.y, obj.width, obj.height, obj.alpha
      obj_asf = display.newImageRect(UI.book .. "_canvas_" .. UI.page .. ".jpg", system.TemporaryDirectory, w, h)
      obj_asf.x = x
      obj_asf.y = y
      obj_asf.alpha = a
      obj_asf.oldAlpha = a
      --
      -- why?
      -- display.remove(obj)
      sceneGroup:insert(obj_asf)
      -- sceneGroup:insert(obj)
      if self.properties.outline then
        -- obj = display.newImageRect(UI.props.imgDir .. self.imagePath, app.systemDir, w, h)
        -- obj.x = x
        -- obj.y = y
        -- obj.alpha = a
        -- obj.oldAlpha = a
        -- sceneGroup[self.name] = obj
        sceneGroup:remove(obj)
        sceneGroup:insert(obj)

        -- obj:addEventListener(
        --   "touch",
        --   function(event)
        --     self:newLine(event)
        --   end
        -- )
        -- self.obj = obj
      end
    end
  end
end
--
function M:willHide(UI)
  local sceneGroup = UI.sceneGroup
  local layer = UI.layer
  app.reloadCanvas = 0
  if self.lineTable then
    for index = 1, #self.lineTable do
      self.lineTable[index]:removeSelf()
      self.lineTable[index] = nil
    end
  end

  local obj = self.obj
  --
  obj:removeEventListener("touch")
end
--
function M:destroy(UI)
  local sceneGroup = UI.sceneGroup
  local layer = UI.layer
  -- Auto save paint in the canvas
  if app.reloadCanvas == 1 then
    local myCaptureImage = display.captureBounds(self.obj.contentBounds)
    myCaptureImage.x = display.contentWidth * 0.5
    myCaptureImage.y = display.contentHeight * 0.5
    -- print("kwik", "destroy capture",  UI.book .. "_canvas_" .. UI.page .. ".jpg")
    display.save(myCaptureImage, UI.book .. "_canvas_" .. UI.page .. ".jpg", system.TemporaryDirectory)
    myCaptureImage:removeSelf()
    myCaptureImage = nil
  else
    os.remove(system.pathForFile(UI.book .. "_canvas_" .. UI.page .. ".jpg", system.TemporaryDirectory))
  end
end

M.set = function(model)
  return setmetatable(model, {__index = M})
end
--
return M
