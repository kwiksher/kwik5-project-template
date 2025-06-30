local M = {
  -- text   = {},
  -- speakerIcon = true,
  -- padding = {{elpad}}/4,
  -- ---
  -- fontSize = {{elFontSize}}/4,
  -- x = {{mX}},
  -- y = {{mY}},
  -- --
  -- name = {{elaudio}},
  -- folder = nil,
  -- language = nil,
  -- delay = {{eldelay}},
  -- --
  -- volume = {{avol}},
  -- trigger = {{sbut}},
  -- --
  -- font         = {{elFont}},
  -- fontColor    = { {{elFontColor}} },
  -- fontSize     = {{elFontSize}}/4,
  -- fontColorHi  = { {{elColorHi}} },
  -- fadeDuration = {{afade}},
  -- wordTouch    = {{elTouch}},
  -- readDir      = "{{rightLeft}}",
  -- sentenceDir  = {{elTouchFolder}}, -- wordTouch
  -- channel      = {{vchan}},
}

local App = require "Application"
local syncSound = require("syncSound")
local libUtil = require(kwikGlobal.ROOT.."lib.util")

-- linefeed (RL)
-- elContent     = elContent.replace(/\r/g,'\-r ') //adds the newline
-- var txt       = elContent.replace(/\r/g,' ');

function M:setHandler()
  local lines = {}
  if self.line == nil then return end
  for i=1, #self.line do
    local line = self.line[i]
    -- local _value = {
    --   start = rows[i].start, -- {{start}},
    --   out = rows[i].out,  -- {{out}},
    --   dur = rows[i].dur, -- {{dur}},
    --   name = rows[i].name, -- "{{name}}",
    --   file = rows[i].file, -- "{{file}}",
    --   newline = rows[i].newline, -- false/true,
    -- }

    if line.action and line.action:len() > 0 then
      lines[#lines+1] = {name=line.name,start = line.start*1000, out=line.out*1000,
      file = line.file, dur = line.dur, trigger =
        function(event)
        -- for k,v in pairs(event) do print(k, v) end
        -- print("", event.name, event.action)
        self.UI:dispatchEvent({name=event.action, params=event})
      end
      }
    else
      lines[#lines+1] = {name=line.name,start = line.start*1000, out=line.out*1000,
        file = line.file, dur = line.dur, newline=line.newline}
    end
    ---
  end
  return lines
end

function M:newIcon (UI)
  local sceneGroup  = UI.sceneGroup

  -- local x, y = App.getPosition(self.x + 15, self.y-30)
  local x, y = self.x + 15, self.y-30

  -- x = display.contentCenterX
  -- y = display.contentCenterY
  local audioImage = "kAudio.png"
  local audioImageHi = "kAudio.png"
  local speakW, speakH = 60/4, 60/4
  local obj =  display.newImageRect( App.getProps().imgDir.. audioImage, App.getProps().systemDir, speakW, speakH);
  obj.x = x
  obj.y = y
  obj.oriX = x
  obj.oriY = y
  -- obj:scale(10,10)

  --Not show if multilanguage?
  --speakerIcon.alpha = 0
  sceneGroup:insert(obj)
  self.speakerObj = obj
end

local function readLineTxt(folder, filename)
end

--
function M:init(UI)
  -- print(self.audioProps.filename, UI.lang)
  if UI.langClassDelegate then
    --
    -- print(self.properties.target)
    local filename = self.audioProps.filename:gsub("mp3", "txt")
    local sentenceDirPath = "App/"..UI.book.."/assets/audios/"..self.textProps.sentenceDir
    if UI.lang:len() > 0 then
      self.properties.target = UI:getNameByLang(self.properties.target or "")
      self.audioProps.filename = libUtil.swapLangPrefix(self.audioProps.filename, UI.lang) -- en/my_father_is_nice.mp3
    -- print(self.audioProps.filename)
      self.textProps.sentenceDir = libUtil.swapLangPrefix(self.textProps.sentenceDir,UI.lang)  --  en/my_father_is_nice
      --
      filename = libUtil.swapLangPrefix(filename, UI.lang)
      sentenceDirPath =  libUtil.swapLangPrefix(sentenceDirPath, UI.lang)

    end
    -- print(self.textProps.sentenceDir)
    ---
    local path = "App/" .. UI.book.."/assets/audios/"..filename
    -- print("@@@", path)
    -- print("@@@", sentenceDirPath)
    self.line = libUtil.readSyncText(path,sentenceDirPath )
  end

  -- if self.language then
  --   self.line =self.language and  self.language[UI.lang]
  -- end
  --
  self.value = self:setHandler(self.line)
  --
end

function M:create(UI)
  local sceneGroup  = UI.sceneGroup

  if self.audioProps == nil then return end
  --
  local path =  App.getProps().audioDir..self.audioProps.filename
  if self.language then
    -- if self.folder then
    --   path = App.getProps().audioDir..UI.lang.."/"..self.folder.."/"..self.audioProps.filename
    -- else
      path = App.getProps().audioDir..UI.lang..self.audioProps.filename
    -- end
  else
    -- if self.folder then
      path = App.getProps().audioDir..self.audioProps.filename
    -- end
  end

  --
  -- print(path)
  self.audioHandle =  audio.loadStream(path , App.getProps().systemDir)
  if self.audioHandle == nil then
    print("Error autio not found", path)
    return
  end

  -- local x,y = App.getPosition(self.x, self.y)
  -- print("@@@@@", self.properties.target)
  local target = sceneGroup[self.properties.target]
  if target==nil then
    print("Error", self.properties.target)
    return
  end
  local x,y = target.x - target.width/2, target.y - target.height/2

  -- need this?
  -- if self.speakerIcon then
  --   x = x + elpad*2
  -- end

  if self.speakerIcon then
    self:newIcon(UI)
  end

  local button =  UI.sceneGroup[self.properties.target]
  if button == nil then
    print("Error no object", self.properties.target)
    return
  end
  button.x = x
  button.y = y
  button.isVisible = false


  local lang = ""
  if self.language then
    lang = UI.lang or ""
  end

  local font = self.textProps.font
  if font== nil or font:len() == 0 then
    font =  native.systemFont
  end
  --
  self.talkButton, self.syncObj = syncSound.addSentence{
      x            = x,
      y            = y,
      padding      = self.textProps.padding,
      sentence     = self.audioHandle,
      volume       = self.audioProps.volume,
      line         = self.value,
      button       = self.speakerObj or button,
      font         = font,
      fontColor    = self.textProps.fontColor,
      fontSize     = self.textProps.fontSize,
      fontColorHi  = self.textProps.fontColorHi,
      fadeDuration = self.properties.fadeDuration,
      wordTouch    = self.properties.wordTouch,
      readDir      = self.textProps.readDir,
      sentenceDir  = self.textProps.sentenceDir,
      channel      = self.audioProps.channel,
      lang         = lang
  }


  sceneGroup:insert(self.syncObj)
  sceneGroup[self.layer] = self.syncObj
  --

  UI.audios[self.name] = self

end

function M:play()
  syncSound.saySentence{
    sentence= self.audioHandle,
    line=self.value,
    button=self.talkButton,
    filename = self.audioProps.filename }
end
--
function M:didShow(UI)
  local sceneGroup  = UI.sceneGroup
  -- print("saySentence", self.properties.autoPlay, self.talkButton)
  if self.properties.autoPlay and self.talkButton then
     local delay = tonumber(self.properties.delay) or 0
      self.timerStash = timer.performWithDelay( delay,
        function()
          syncSound.saySentence{
          sentence= self.audioHandle,
          line=self.value,
          button=self.talkButton }
      end)
    end
  self.UI = UI
  if self.wordTouch and self.talkButton then
    syncSound.addEventListener(self.talkButton.words)
  end
end

function M:didHide(UI)
  if self.timerStash then
    timer.cancel(self.timerStash )
  end
  --
  self.timerStash = nil1
  --
  for k, v in pairs (syncSound.timerStash) do
    timer.cancel(v)
  end
  syncSound.timerStash = {}
  if self.wordTouch and self.talkButton then
    syncSound.removeEventListener(self.talkButton.words)
  end
end
--
function M:destroy()
end

function M:rewind()
  audio.rewind(self.audioHandle)
end
--
function M:pause()
  local audioChannel = syncSound.audioChannels[self.audioProps.filename]
  audio.pause(audioChannel)
end
--
function M:stop()
  local audioChannel = syncSound.audioChannels[self.audioProps.filename]
  audio.rewind(self.audioHandle)
  audio.stop(audioChannel)
end
--
function M:resume()
  local audioChannel = syncSound.audioChannels[self.audioProps.filename]
  audio.resume(audioChannel)
end
--
function M:setVolume(vvol)
  local audioChannel = syncSound.audioChannels[self.audioProps.filename]
  audio.setVolume(vvol, audioChannel)
end

function M:muteUnmute()
  local audioChannel = syncSound.audioChannels[self.audioProps.filename]
  local props = self.properties
  if (audio.getVolume() == 0.0) then
    audio.setVolume(props.volume, audioChannel)
  else
    audio.setVolume(0.0, audioChannel)
  end
end


M.set = function(instance)
	return setmetatable(instance, {__index=M})
end

--
return M