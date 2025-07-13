local exports = {}
exports.group = {}

function exports:message(choices, message)
  local text = message or "Press a button"
  native.showAlert("Kwik", text, {unpack(choices)}, self.onClick)
end

function exports:networkEvent(event)
  --print("view:networkEvent")
  --for k,v in pairs(event) do print("", k, v) end
  if (event.phase == "began") then
  elseif (event.phase == "progress") then
    --print("  " ..event.bytesTransferred, event.bytesEstimated)
    if self.spinnerText then
      self.spinnerText.text = "Downloading.." .. event.bytesTransferred .. "/" .. event.bytesEstimated
      self.spinnerRect:setFillColor(math.random(),math.random(),math.random(), 0.5)
    end
  elseif (event.phase == "ended") then
    if self.spinnerText then
      self.spinnerText.text = "Downloaded.." .. event.bytesTransferred .. "/" .. event.bytesEstimated
      self.spinnerRect:setFillColor(math.random(),math.random(),math.random(), 0.5)
    end
  end
end

function exports:zipEvent(event)
  --    for k,v in pairs(event) do print("", k, v) end
  if (event.phase == "began") then
  elseif (event.phase == "progress") then
    --  print(event.bytesTransferred, event.bytesEstimated)
    if self.spinnerText then
      self.spinnerText.text = "Uncompressing.." .. event.bytesTransferred .. "/" .. event.bytesEstimated
      self.spinnerRect:setFillColor(math.random(),math.random(),math.random(), 0.5)
    end
  elseif (event.phase == "ended") then
    if self.spinnerText then
      self.spinnerText.text = "Uncompressed.." .. event.bytesTransferred .. "/" .. event.bytesEstimated
      self.spinnerRect:setFillColor(math.random(),math.random(),math.random(), 0.5)
    end
  end
end

function exports:showError(next)
  native.showAlert("Kwik", "Error", {"Close"})
end

function exports:showOK(next)
  native.showAlert("Kwik", "Success", {"Close"}, next)
end

local posX = display.contentWidth - 200
local posY = 10

function exports:showVersions(assets)
  local frameworkVersion =
    display.newText(assets.framework.label .. ": " .. assets.framework.name, posX, posY + 10, native.systemFont, 16)
  frameworkVersion.align = "right"
  local editorVersion =
    display.newText(assets.editor.label .. ":" .. assets.editor.name, posX, posY + 40, native.systemFont, 16)
  editorVersion.align = "left"
  local templateVersion =
    display.newText(assets.template.label .. ":" .. assets.template.name, posX, posY + 70, native.systemFont, 16)
  templateVersion.aligh = "left"
  local exporterVersion =
    display.newText(assets.exporter.label .. ": " .. assets.exporter.name, posX, posY + 100, native.systemFont, 16)
  exporterVersion.align = "right"

  self.group.editorVersion = editorVersion
  self.group.templateVersion = templateVersion
  self.group.frameworkVersion = frameworkVersion
  self.group.exporterVersion = exporterVersion

  if assets.template.name ~= assets.template.latestName then
    templateVersion:setFillColor(1, 1, 0)
  end
  if assets.editor.name ~= assets.editor.latestName then
    editorVersion:setFillColor(1, 1, 0)
  end
  if assets.framework.name ~= assets.framework.latestName then
    frameworkVersion:setFillColor(1, 1, 0)
  end
  if assets.exporter.name ~= assets.exporter.latestName then
    exporterVersion:setFillColor(1, 1, 0)
  end
end

local spinner

function exports:showSpinner(text)
  local message = text or "Downloading ..."
  if not spinner then
    spinner = display.newGroup()
    local spinnerText = display.newText(message, 0, -20, native.systemFont, 18)
    spinnerText:setFillColor(0, 1, 0)
    local spinnerRect = display.newRect(0, 0, 35, 35)
    transition.to(spinnerRect, {time = 10000, rotation = 360, iterations = 999999, transition = easing.inOutQuad})
    --Create a group and add all these objects to it
    spinner:insert(spinnerText)
    spinner:insert(spinnerRect)
    spinner.x, spinner.y = display.contentCenterX, display.contentCenterY / 2
    self.spinnerText = spinnerText
    self.spinnerRect = spinnerRect
    self.spinnerRect:setFillColor(math.random(),math.random(),math.random(), 0.5)
  end
end

function exports:hideSpinner()
  if (spinner) then
    spinner:removeSelf()
    spinner = nil
  end
end

return exports
