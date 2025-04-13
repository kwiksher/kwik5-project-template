system.setTapDelay( 0.5 )

local restore = false
--restore = true
if restore then
  os.execute("cd " .. system.pathForFile("../", system.ResourceDirectory) .. "; source undo_lua.command")
  return
end

NIL = setmetatable({},{__tostring=function() return "nil" end})
NilCheck = function(v)
  if v == NIL then
    return nil
  else
    return v
  end
end

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local lldebugger = loadfile(os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH"))()
  lldebugger.start()
end

inspect = require("extlib.inspect")

local common = {
  commands = {"myEvent"},
  components = {
    -- "align",
    "myComponent",
    "thumbnailNavigation",
    "keyboardNavigation",
    "index" -- this loads editor!
  }
}

require("controller.index").bootstrap{
  name="{{book}}",
  edting = true,
  goPage = "{{page}}",
  language = "{{lang}}",
  position = {x=0, y=0},
  common = common} -- scenes.index

-- for product release
-- require("controller.index").bootstrap({name="{{book}}", edting = false, goPage = "{{page}}", position = {x=0, y=0}, common = common}) -- scenes.index
