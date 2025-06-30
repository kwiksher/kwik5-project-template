local M = {}
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local editorUtil = require(kwikGlobal.ROOT.."editor.util")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local harness = require(parent .. "harness")
--
-- for audio, group, timer, varaible ..
--
function M.get(args)
  local ret = nil
  --
  print("args[3]=", args[3])
  local path = "editor.parts."..args[3].."Table"
  local componentTable = require(path)
  for i = 1, #componentTable.objs do
    local obj = componentTable.objs[i]
  end
  -- /bookX/pageX/audio

  return ret
end

--
local function save(book, page, layer, class, data, index, isNew)
end
--
local selectMap = {
  audios = {name="editor.selector.selectAudio"},
  timers = {name="editor.selector.selectTimer"},
  groups = {name="editor.selector.selectGroup"},
  variables = {name="editor.selector.selectVariable"},
}

local function findObj(name, editor)
  local id = editor.model.id
  local selectbox = editor.controller.selectbox
  for i=1, #selectbox.objs do
    local obj = selectbox.objs[i]
    if name == obj[id] then
      return obj
    end
  end
  return nil
end

local saveMap = {
  -- audio.controller.save
  audio =  {
    name = "editor.audio.save",
    selectbox = {selection = {audio="myaudio", subclass = "short", index = 1}},
    controls = {
      {name ="name", value = "myaudio"},
      {name ="type", value ="short"},
      {name ="filename", value ="myshort.mp3"}},
     omCompletebox = {selectedTextLabel = "myAction"},
     isNew = true,
  },
  -- timer.controller.save
  timer = {
    name = "editor.timer.save",
    selectbox = {selection = {timer="mytimer", index = 1}},
    controls = {
      {name = "name", value = "mytimer"},
      {name ="type", value ="short"},
      {name ="filename", value ="myshort.mp3"}
    },
    omCompletebox = {selectedTextLabel = "myAction"},
    isNew = true,
  }
}

function M.put(args, queries)
    -- /book/page01/audios/short
    -- /book/page01/audios/long
    -- /book/page01/timers/
    -- /book/page01/variables/
    -- /book/page01/page/
    local book = args[1]
    local page = args[2]
    local class = args[3]
    local name  = args[4]
    local subclass = nil
    if class == "audios" then
      subclass = args[4]
      name = args[5]
    end
    --[[ GUI
      local toolMap = {
        audios = require(kwikGlobal.ROOT.."editor.selector.audio.index"),
        timers = require(kwikGlobal.ROOT.."editor.selector.timer.index"),
        groups = require(kwikGlobal.ROOT.."editor.selector.group.index"),
        variables = require(kwikGlobal.ROOT.."editor.selector.variable.index"),
        timers = require(kwikGlobal.ROOT.."editor.selector.timer.index"),
      }
      --
      local tool = toolMap[class]
      local eventSelect = selectMap[class]
      eventSelect.UI = harness.UI
      eventSelect.book = book
      eventSelect.page = page
      eventSelect.class = class
      --- this will start an class tool, load .json of audios, groups, timers, variables into selectbox(xxxxTable)
      harness.UI.scene.app:dispatchEvent(eventSelect)
      -- now we can find an object from tool.controller.selectbox
      local obj = findObj(name, tool)
    --]]
    local eventSave = saveMap[class]
    local decoded = editorUtil.decode(book, page, class, {subclass=subclass})
    local function findEntry (name)
      local index = nil
      for i=1, #decoded do
        if decoded[i].name == name then
          return decoded[i]
        end
      end
      retrun {}
    end
    --
    local entry = findEntry(name)
    eventSave.isNew = #entry == 0
    -- merge with data
    if type(data) == 'table' then
      for k, v in pairs(data) do
        if data[k] then
          entry[k] = data[k]
        end
      end
    end
    -- convert it to array See baseProps.setValue
    local function setValue(entry)
      local props = {}
      for k, v in pairs(entry) do
        local prop = {name=k, value=v}
        props[#props+1] = prop
      end
      --
      local function compare(a,b)
        return a.name < b.name
      end
      --
      table.sort(props,compare)
      return props
    end
    ---
    eventSave.controls = setValue(entry)
    --
    harness.UI.scene.app:dispatchEvent(eventSave)
end
--
M.save = save
--
return M
