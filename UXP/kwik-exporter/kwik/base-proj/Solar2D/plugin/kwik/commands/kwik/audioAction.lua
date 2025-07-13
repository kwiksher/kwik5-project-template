local M = {}
local audioMod = require("components.kwik.page_audio")
--
function M:record(UI, duration, filename, alpha, autoPlay)
  local recordedInstance = {name = filename, type="recorded",
    properties = {
      autoPlay = autoPlay,
      channel = 31,
      delay = 0,
      filename = filename,
      folder = "long",
      fadein = 0,
      loops = 0
    }}
  audioMod.set(recordedInstance)
  --
  local filePath = system.pathForFile(filename, system.ApplicationSupportDirectory )
  local recorder = media.newRecording(filePath)
  UI.sceneGroup.alpha = alpha
  recorder:startRecording( )
  local recordingClosure = function(event )
    recorder:stopRecording()
    UI.sceneGroup.alpha = 1
    local file = io.open(filePath, "r")
    if file then
       io.close(file)
       UI.audios[filename] = recordedInstance
       recordedInstance.audioHandle = audio.loadStream( filename, system.ApplicationSupportDirectory )
    end
    if recordedInstance.properties.autoPlay then
      recordedInstance.audioChannel = audio.play(recordedInstance.audioHandle)
    end
   end
   if UI.timers["recTimer"] then
    timer.cancel(UI.timers["recTimer"])
   end
   UI.timers["recTimer"] = timer.performWithDelay(duration, recordingClosure )
   -- audio.stop(31)
   -- audio.dispose(allAudios.playback)
   -- allAudios.playback = nil
end
--
function M:muteUnmute()
  if (audio.getVolume() == 0.0) then
     audio.setVolume(1.0)
  else
     audio.setVolume(0.0)
  end
end
--
function M:play(UI, target, _channel, _delay, _loops, _fadein, _volume, _listener)
  local props= target.properties
  local channel = _channel or props.channel
  local delay = _delay or props.delay
  local loops = _loops or props.loops
  local fadein = _fadein or props.fadein
  local volume = _volume or props.volume
  local listener = function()
      local eventName = _listener or self.actions.onComplete
      UI.scene:dispatchEvent({name=eventName, audio=self.name })
  end
  -- local listener = listener
  local myClosure = function()
    local options
    if fadein > 0 then
      options = {channel=channel, loops = loops, fadein = fadein, onComplete = listener }
    else
      options = {channel=channel, loops = loops,  onComplete = listener }
    end
    audio.setVolume(volume, {channel=channel} )
    target.audioChannel = audio.play(target.audioHandle, options)
  end
  if delay == 0 then
    myClosure()
  else
    target.timerStash = timer.performWithDelay(delay,
      myClosure, 1)
  end
end
--
function M:rewind( target)
  if target.folder == "long" then
    audio.rewind( target.audioHandle )
  else
    audio.rewind( target.audioChannel )
  end
end
--
function M:pause(target)
  audio.pause( target.audioChannel )
end
--
function M:stop(target)
  local audioHandle = target.audioHandle
  if target.folder == "long" then
    audio.rewind( target.audioHandle )
  else
    audio.rewind( target.audioChannel )
  end
  audio.stop( target.audioChannel )
end
--
function M:resume(target)
  audio.resume( target.audioChannel )
end
--
function M:setVolume(target, volume)
  audio.setVolume(volume, target.audioChannel)
end

function M:setMasterVolume(volume)
  audio.setVolume(volume)
end


function M:fade(target, duration, volume)
  audio.fade{channel = target.audioChannel, time=duration ,volume = volume}
end

function M:fadeOut(target, duration)
  audio.fadeOut{channel = target.audioChannel, time=duration }
end
--
return M