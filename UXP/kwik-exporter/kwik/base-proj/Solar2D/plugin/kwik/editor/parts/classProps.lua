local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new()
-- local PNG = require("png")
---------------------------
M.name = "classProps"

local Layer_Class = table:mySet {"variable"}
M.onTapLayerSet = table:mySet {"_target", "over", "mask", "dropArea", "_filename", "sheetInfo", "to"}
M.onTapActionSet = table:mySet {"onComplete"}
M.onTapPosXYSet = table:mySet {"x", "y"}
--
function M:setActiveProp(layer, class, suffix)
  -- print("activeProp", self.class, class, self.activeProp, layer)
  local name = self.activeProp
  local value = layer
  local UI = self.UI

  if class and class ~= "variable" then
    value = layer .. "_" .. class
    if suffix then
      value = layer .. "_" .. class..suffix
    end
  end
  --
  if self.activeProp == "sheetInfo" then
    local modPath, sheetType
    for i, obj in next, self.objs do
      if obj.text == "sheetInfo" then
        local filename = layer:gsub(".png", ".lua")
        local path = system.pathForFile("App/" .. UI.book .. "/assets/" .. filename, system.ResourceDirectory)
        if path == nil then
          filename = layer:gsub(".png", ".json")
          path = system.pathForFile("App/" .. UI.book .. "/assets/" .. filename, system.ResourceDirectory)
          sheetType = "Animate"
        else
          modPath = "App/" .. UI.book .. "/assets/" .. filename
          -- print("@@@@@@@@@@@", modPath)
          modPath = modPath:gsub("/", ".")
          modPath = modPath:gsub(".lua", "")
          sheetType = "TexturePacker"
        end
        ---
        if path then
          obj.field.text = filename
        else
          obj.field.text = ""
          sheetType = "uniform-sized"
        end
      elseif not obj.text == "_target" then
        obj.field.text = ""
      end
    end
    --
    self:getObj("_filename").field.text = layer
    self:getObj("sheetType").field.text = sheetType
    --
    if modPath then
      -- print("####", modPath)
      local sheetInfo = require(modPath)
      self:getObj("numFrames").field.text = #sheetInfo.frames
    end
    --
    self:showThumnail(self.activeProp, layer, self.class)
  elseif self.class == "video" and name == "url" then
    local obj = self:getObj(name)
    obj.field.text = value
  else
    --
    -- check
    --
    -- animation.play, animation.pause, animation.resume
    local isValid = function(class)
      if Layer_Class[self.activeProp] then
        return self.activeProp == class
      elseif self.onTapLayerSet[self.activeProp] then
        return class == nil
      end
    end

    --
    if isValid(class) then
      ---
      local obj = self:getObj(name)
      obj.field.text = value
      if name == "_filename" and self.class == "sprite" then
        local w, h = self:showThumnail(self.activeProp, layer, self.class)
        self:updateSheetInfo(w, h)
      -- local sheetOptions = {
      --   width = 50,
      --   height = 50,
      --   numFrames = 64,
      --   sheetContentWidth = 800,
      --   sheetContentHeight = 200
      -- }
      -- print("@@@@", UI.editor.currentClass)
        return true -- this makes the table hide
      end
      return true
    else
      -- TBI show popup
    end
  end
  --
end

function M:getObj(name)
  for i, v in next, self.objs do
    -- print("", name, v.text)
    if v.text == name then
      return v
    end
  end
end

function M:updateSheetInfo(sheetContentWidth, sheetContentHeight, modPath)
  -- print("@@@@@ updateSheetInfo", sheetContentWidth, sheetContentHeight)
  if sheetContentWidth then
    self:getObj("sheetContentWidth").field.text = sheetContentWidth
    self:getObj("sheetContentHeight").field.text = sheetContentHeight

    local numFrames = tonumber(self:getObj("numFrames").field.text) or 1
    local ratio = sheetContentWidth / sheetContentHeight

    if ratio > 0 then
      local width = sheetContentWidth / (numFrames / ratio)
      local height = sheetContentHeight / ratio
      self:getObj("_width").field.text = math.floor(width)
      self:getObj("_height").field.text = math.floor(height)
    else
      ratio = sheetContentWidth / sheetContentHeight
      local width = sheetContentWidth / ratio
      local height = sheetContentHeight / (numFrames / ratio)
      self:getObj("_width").field.text = math.floor(width)
      self:getObj("_height").field.text = math.floor(height)
    end
  end
end

function M:showThumnail(name, value, class)
  if self.showThumnailObj then
    self.showThumnailObj:removeSelf()
    self.showThumnailObj = nil
  end
  --
  local path = "App/" .. self.UI.book .. "/assets/" .. value
  local obj = display.newImage(self.group, path)
  if obj then
    local w, h = obj.width, obj.height
    local scaleW = 200 / w
    local scaleH = 200 / h
    if scaleW > scaleH then
      obj:scale(scaleH, scaleH)
      obj.y = display.contentCenterY
    else
      obj:scale(scaleW, scaleW)
      obj.y = display.contentCenterY
    end
    obj.x = display.contentCenterX + 350
    self.showThumnailObj = obj

    -- local function printProg(line, totalLine)
    --   print(line .. " of " .. totalLine)
    -- end

    -- local function getPixelStr(pixel)
    --     return string.format("R: %d, G: %d, B: %d, A: %d", pixel.R, pixel.G, pixel.B, pixel.A)
    -- end

    -- local _path = system.pathForFile(path, system.ResourceDirectory)
    -- print("getPNGSize", width, height)
    -- local width, height = PNG.getPNGSize(_path)

    return w, h
  end
end
--
return M
