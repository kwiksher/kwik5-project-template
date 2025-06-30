local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local bookName = "lingualSample" -- "bookTest01"
local pageName = "page2"
local listbox = require("editor.replacement.listbox")
local listPropsTable = require("editor.replacement.listPropsTable")

local helper = require("test.helper")
local classProps = require("editor.parts.classProps")
local assetTable = require("editor.asset.assetTable")
local listButtons = require("editor.replacement.listButtons")
local libUtil = require("lib.util")
local util = require("editor.util")
local json = require("json")
--local actionTable = require("editor.action.actionTable")
local actionbox = require("editor.parts.actionbox")
local actionTable = require("editor.action.actionTable")


function M.init(props)
  selectors = props.selectors
  UI = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.actionTable = actionTable
  helper.init(props)

end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  pageTable.commandHandler({page="page2"},nil,  true)
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true, "layerTable")
end

function M.setup()
end

function M.teardown()
end

-- https://stackoverflow.com/questions/66379488/pyttsx3-does-not-read-text-in-other-languages

function M.xtest_timecodes()
  local timecodes = require("lib.timecodes")
    -- Example usage
    local script1 = [[
    JOHN
    Hello, how are you?

    JANE
    I'm doing well, thank you for asking.

    JOHN
    That's great to hear!
    ]]

    -- https://ia.net/topics/ia-writer-fountain-template
  local script = [[
  NEO
  Wait. Who was it?
  Who was the man?

  She leans close, her lips almost touching his ear as she
  whispers.

  TRINITY
  You know who.

  She turns and he watches her melt into the shifting wall
  of bodies.

  A SOUND RISES steadily, growing out of the music,
  pressing in on Neo until it is all he can hear as we --

  CUT TO:

  INT. NEO'S APARTMENT

  The sound is an ALARM CLOCK, slowly dragging Neo to
  consciousness. He strains to read the clock face:
  9:15 A.M.

  NEO
  Shitshitshit.
  ]]


    local dialogue = timecodes.parse_fountain(script)
    local timecoded_dialogue = timecodes.generate(dialogue)

    local chars = {}
    for _, v in ipairs(timecoded_dialogue) do
      local character, line, _start, _end = unpack(v)
      if chars[character] == nil then
        chars[character] = {}
      end
      table.insert(chars[character], {_start, _end, line})
      -- print(string.format("%s (%s - %s): %s", character, _start, _end, line))
    end

    for k, v in pairs(chars) do
      print(k)
      for i, timecode in next, v do
        print("", timecode[1], timecode[2], timecode[3])
      end
    end
end


function M.xtest_edit_action()
  UI.editor.actionEditor.iconHander()

  actionTable.altDown = true
  helper.selectAction("flyAnim")
  actionTable.altDown = false

  -- select a command
  local commandsTable = require("editor.action.actionCommandTable")
  local obj = commandsTable.objs[1]
  commandsTable:singleClickEvent(obj)

  local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
  helper.clickProp(actionCommandPropsTable.objs, "_target")

  helper.selectLayer("witch/en", "linear")

  -- save manually

end


function M.xtest_new_sync()
  local obj = helper.selectLayer("father/en")

  helper.selectLayer("text1")
  helper.selectIcon("Replacements", "Sync")

  local textProps = require("editor.replacement.textProps")
  helper.clickProp(textProps.objs, "_filename")
  helper.selectAssetIcon("SyncText")
  helper.clickAsset(assetTable.objs, "en/my_father_is_nice.txt")

  local audioProps = require("editor.replacement.audioProps")
  helper.clickProp(audioProps.objs, "_filename")
  helper.selectAssetIcon("SyncText")
  helper.clickAsset(assetTable.objs, "en/my_father_is_nice.mp3")

  -- helper.setProp(classProps.objs, "autoPlay", false)
  --[[
  -- select text & audio
  ---- helper.clickProp(classProps.objs, "text")

  local actionbox = require("editor.parts.actionbox")
  local obj = actionbox.objs[1] -- onComplete
  obj:dispatchEvent({name="tap", target=obj})
  helper.clickAction("eventOne")



  local obj = helper.getObj(listbox.objs, "A")
  listbox.singleClickEvent(obj)

  helper.setProp(listPropsTable.objs, "dur", "1000")

  -- select an action
  helper.clickProp(listPropsTable.objs, "action")
  -- helper.clickProp(listPropsTable.objs, "action") -- why needs twice?
  helper.clickAction("eventTwo")

  helper.setProp(listPropsTable.objs, "dur", "1000")

  obj = helper.getObj(listButtons.objs, "Save")
  obj:tap()
--]]

end

function M.xtest_edit_button()
  layerTable.altDown = true
  local obj = helper.selectLayer("fly/en", "button")
  layerTable.altDown = false

  helper.clickProp(actionbox.objs, "onTap")
  objs = require("editor.parts.buttonContext").objs
  objs.Select.rect:tap()
  helper.clickAction("flyAnim")
end

function M.xtest_delete_button()
  if helper.hasObj(layerTable, "fly/en", "button") then
    helper.selectLayer("fly/en", "button", false) -- isRightClick
    helper.selectLayer("fly/en", "button", true) -- isRightClick
    -- then
    -- manially delete it
  end
end

function M.xtest_delete_flyOver()
  if helper.hasObj(layerTable, "flyOver", "lang") then
    helper.selectLayer("flyOver", "lang", false) -- isRightClick
    helper.selectLayer("flyOver", "lang", true) -- isRightClick
    -- local actionButtonContext = require("editor.parts.actionButtonContext")
    --
    -- then delete it manually
  end
end

function M.xtest_updateIndexModel()
  local book = "lingualSample"
  local page = "page2"
  local layer = "witch/en"
  local obj = helper.selectLayer("witch/en", "linear")
  local scene = require("App." .. book .. ".components." .. page .. ".index")
  local updatedModel = scene.model
  assert(layer, obj.parentObj.layer.."/"..layer)

  updatedModel = util.updateIndexModel(updatedModel, layer, class)
  --print(json.prettify(updatedModel))

  local renderdModel = util.createIndexModel(updatedModel)

  -- controler.renderIndex is wrapping util.renderIndex
  -- local controller = require("editor.controller.index")

  local file = util.renderIndex(book, page, renderdModel)
  --print(file)
   print(json.prettify(renderdModel))

end

function M.xtest_select_en_anim()
  layerTable.altDown = true
  helper.selectLayer("witch/en", "linear")
  layerTable.altDown = false
end

function M.xtest_read_timecode()
  local textProps  = require("editor.replacement.textProps")
  textProps:read("App/book/assets/audios/sync/alphabet.txt")
end

function M.xtest_select_sync()
  layerTable.altDown = true
  helper.selectLayer("text1", "sync")
  layerTable.altDown = false
end


function M.xtest_new_sync_select_listbox()

  helper.selectLayer("text1")
  helper.selectIcon("Replacements", "Sync")

  local obj = helper.getObj(listbox.objs, "A")
  listbox.singleClickEvent(obj)

  helper.setProp(listPropsTable.objs, "dur", "1000")


end

function M.xtest_new_sync_add_save()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "sync", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )

  UI.scene.app:dispatchEvent(
    {
      name = "editor.replacement.list.add",
      UI = UI,
      type = "line", -- for sync,
      index = 3 -- number of entries
    }
  )

  local listPropsTable = require("editor.replacement.listPropsTable")
  -- name props
  listPropsTable.objs[1].field.text = "myName"
  -- start
  listPropsTable.objs[2].field.text = "3000"

  UI.scene.app:dispatchEvent(
    {
      name = "editor.replacement.list.save",
      UI = UI,
      class = "sync", -- obj.class,
      index = 4
    }
  )
end




function M.xtest_decode64_words()
  local json = require("json")
  local mime = require("mime")
  local path = "server/tests/outputRedirection.json"
  local data = json.decode(libUtil.jsonFile(path))
  local alignment = data.alignment
  local normalized_alignment = data.normalized_alignment

  print(#alignment.characters, normalized_alignment.characters)
  local wordEntries = {}
  local word  = ""
  local s, e = 0, 0
  for i, v in next, alignment.characters do
    word = word ..v
    if v == " " or v =="\n" then
      e = alignment.character_end_times_seconds[i]
      wordEntries[#wordEntries + 1] = {word=word, startTime=s, endTime =e}
      local t = word:gsub("\n", "\\n")
      print(s, e, t)
      word = ""
      s = alignment.character_end_times_seconds[i+1]
    end
  end
  local dst = system.pathForFile( "myAudio.txt", system.DocumentsDirectory )
  -- Open the file handle
  local file, errorString = io.open( dst, "w+" )
  if not file then
      print( "File error: " .. errorString )
  else
      for i, v in next, wordEntries do
        local text = v.word:gsub("\n", "\\n")
        file:write(string.format("%.3f %.3f %s \n",  v.startTime, v.endTime, text ))
      end
      io.close( file )
  end

  -- character_start_times_seconds
  -- character_end_times_seconds
end


function M.xtest_decode64_mp3()
  local json = require("json")
  local mime = require("mime")
  local path = "server/tests/outputRedirection.json"
  local data = json.decode(jsonFile(path))
  local bin = mime.unb64(data.audio_base64)
  local dst = system.pathForFile( "myAudio_jp_wakati.mp3", system.DocumentsDirectory )
    -- Open the file handle
  local file, errorString = io.open( dst, "wb+" )
  if not file then
      print( "File error: " .. errorString )
  else
      file:write( bin )
      io.close( file )
  end
end

function M.xtest_loadAudio()
  local myAudio = audio.loadStream( "myAudio_jp.mp3", system.DocumentsDirectory )
  local options =
  {
      channel = 1,
      loops = -1,
      duration = 30000,
      fadein = 5000,
      onComplete = function() print("onComplete") end
  }
  audio.play(myAudio, options)

end

function M.xtest_loadAudio()
  local myAudio = audio.loadStream( "App/book/assets/audios/sync/ElevenLabs_jp_wakati.mp3")
  local options =
  {
      channel = 1,
      loops = -1,
      duration = 30000,
      fadein = 5000,
      onComplete = function() print("onComplete") end
  }
  audio.play(myAudio, options)

end

return M
