local M = {}
local json = require("json")
local path = system.pathForFile("clipboard.json", system.TemporaryDirectory)
--
function M:save(data)
  --
  local file, errorString = io.open(path, "w")
  if not file then
    print("ERROR: " .. errorString)
  else
    local contents = json.encode(data)
    file:write(contents)
    io.close(file)
  end
end

function M:read()
  local contents = "{}"
  local file, errorString = io.open(path, "r")
  if not file then
    print("ERROR: " .. errorString)
  else
    contents = file:read("*a")
    io.close(file)
  end
  return json.decode(contents)
end

return M