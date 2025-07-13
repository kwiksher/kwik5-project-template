local name = ...
local parent = name:match("(.-)[^%.]+$")

local json = require( "json" )
local lustache = require (parent.."lustache")
local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or 
                 archInfo == "IA64" or archInfo == "ARM"                 

local M = {
  template={
    name="template_",
    path="template",
    latestName = "",
    url = "",
    label = "template"
  },
  editor={
    name="editor_",
    path="editor",
    latestName = "",
    url = "",
    label = "editor"
  },
  exporter={
    name="exporter_",
    path="kwik-exporter",
    latestName = "",
    url = "",
    label = "exporter",
    rootFolder = "/../UXP"
  },
  framework = {
    name="framework_",
    path=".",
    folders = {
      "assets",
      "commands",
      "components",
      "controller",
      "extlib",
      "lib",
    },
    latestName = "",
    url = "",
    label="framework"
  },

  API="https://api.github.com/repos/kwiksher/kwik5tmplt/releases/latest",
  token="",
  version = "",
  latestVersion = "",
  params = {}
}

local path = system.pathForFile(kwikGlobal.PATH.."installer/.env", system.ResourceDirectory)
local file, errorString = io.open(path, "r")
if not file then
  print("ERROR: github token is missing in .env")
  return nil
else
  local contents = file:read("*a")
  M.token = contents:match('token="([^"]+)"')
  io.close(file)
end

local headers = {}
headers["Content-Type"] = "application/json"
headers["Authorization"] = "token "..M.token
--
M.params.headers = headers
--
function M:init()
    local filename = system.pathForFile( "kwkversion.json", system.ApplicationSupportDirectory )
    if filename then
      local decoded, pos, msg = json.decodeFile( filename )
      if decoded then
        self.template = decoded.template
        self.editor = decoded.editor
        self.framework = decoded.framework
        self.version = decoded.version
      end
    end
 end

local function saveScript(filename, model)
  local ext = "command"
  if isWindows then
    ext = "bat"
  end
  --
  local path = system.pathForFile(kwikGlobal.PATH.."installer/" .. filename .. ext .. ".tmplt", system.ResourceDirectory)
  local file, errorString = io.open(path, "r")
  local cmd = filename .. ext -- create_book.command
  local cmdFile

  if not file then
    print("ERROR: " .. errorString)
  else
    local contents = file:read("*a")
    io.close(file)
    output = lustache:render(contents, model)
    output = output:gsub("&#39;", '"')
    output = output:gsub("&#x2F;", "/")

    local path = system.pathForFile(cmd, system.TemporaryDirectory)
    --print(path)
    local file, errorString = io.open(path, "w+")
    if not file then
      print("ERROR: " .. errorString)
    else
      output = string.gsub(output, "\r\n", "\n")
      file:write(output)
      io.close(file)
    end
    if isWindows then
      cmdFile = '"' .. path:gsub("/", "\\") .. '"'
    else
      cmdFile = path:gsub(" ", "\\ ")
    end
  end

  return cmd, cmdFile
end

local function executeScript(filename, model)
  timer.performWithDelay( 500, function ()
    local cmd, cmdFile = saveScript(filename, model)
    if isWindows then
      -- print("copy " .. cmdFile .. " " .. system.pathForFile("", system.ResourceDirectory))
      os.execute("copy " .. cmdFile .. " " .. system.pathForFile(kwikGlobal.PATH.."installer", system.ResourceDirectory))
      os.execute("cd " .. system.pathForFile(kwikGlobal.PATH.."installer", system.ResourceDirectory) .. " & start cmd /k call " .. cmd)
    else
      -- print("cd " .. system.pathForFile("../", system.ResourceDirectory) .. "; source " .. cmd)
      os.execute("cp " .. cmdFile .. " " .. system.pathForFile(kwikGlobal.PATH.."installer", system.ResourceDirectory))
      os.execute("cd " .. system.pathForFile(kwikGlobal.PATH.."installer", system.ResourceDirectory) .. "; source " .. cmd)
    end
    return cmd
  end )
end

function M:save(commands)
  self.template.name = self.template.latestName
  self.editor.name   = self.editor.latestName
  self.framework.name = self.framework.latestName
  self.exporter.name = self.exporter.latestName
  self.version = self.latestVersion

   local output = json.encode{template = self.template, editor = self.editor, framework=self.framework, version = self.version, exporter = self.exporter}
    local path = system.pathForFile("kwkversion.json", system.ApplicationSupportDirectory )
    local file, errorString = io.open( path, "w" )
    file:write(output)
    io.close( file )

  if #commands > 0 then
    executeScript("copy_lua.", {dst="..", cmd=commands})
  end
end

return M
