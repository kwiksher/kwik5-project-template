local M = {}

local App = require("Application")
--
-- local allAudios = {}
--
function M:init(UI)
end

function M:create(UI)
  -- print("create page audio", self.properties.filename)
  local props = self.properties
  local filename
  self.UI = UI
  --
  --
  if self.audioHandle == nil and props.filename and props.filename:len() > 0 then
    if props.folder then
      filename = props.folder .. "/" .. props.filename
    elseif self.language then
      filename = App.getProps().lang .. "/" .. props.filename
    end
    --
    if props.folder == "long" then
      self.loader = audio.loadStream
    else
      self.loader = audio.loadSound
    end
    --
    local path = App.getProps().audioDir .. filename
    --
    self.audioHandle = self.loader(path, App.getProps().systemDir)
    --
    if self.type == "global" then
      local app = App.get()
      app.audios[self.name] = self
    else
      UI.audios[self.name] = self
    end
  -- TODO autoPlay pages
  -- local a = audio.getDuration( self.audioHandle );
  -- if a > UI.allAudios.kAutoPlay  then
  --   UI.allAudios.kAutoPlay = a
  -- end
  else
    print("Warning audio filename is missing", self.name)
  end
  --
end

function M:play()
  local props = self.properties
  --local options = {channel = props.channel}
  audio.setVolume(props.volume or 8, self.audioHandle)
  --
  optios = {channel = props.channel, loops = props.loops, fadein = props.fadein, onComplete =
   function()
    self.UI.scene:dispatchEvent({name=self.actions.onComplete, audio=self.name })
   end
 }
  self.audioChannel = audio.play(self.audioHandle, options)
end

function M:didShow(UI)
  local props = self.properties
  if self.audioHandle == nil then
    return
  end
  --
  if props.autoPlay then
    if props.delay then
      self.timerStash =
        timer.performWithDelay(
        props.delay,
        function()
          self:play()
        end,
        1
      )
    else
      self:play()
    end
  end
end

function M:didHide(UI)
  local props = self.properties
  if self.audioHandle == nil then
    return
  end
  if not props.retain then
    if audio.isChannelActive(props.channel) then
      audio.stop(props.channel)
    end
  end
  if self.timerStash then
    timer.cancel(self.timerStash)
    self.timerStash = nil
  end
end
--
function M:destroy(UI)
  local props = self.properties
  if self.audioHandle == nil then
    return
  end
  if not props.retain then
    audio.dispose(self.audioHandle)
    self.audioHandle = nil
  end
end

function M:getAudio(UI)
  local props = self.properties
  local filename
  if self.audioHandle == nil then
    if self.language then
      filename = App.getProps().lang .. "/" .. props.filename
    end

    local path = App.getProps().audioDir .. props.filename
    if props.folder then
      path = App.getProps().audioDir .. props.folder .. "/" .. props.filename
    end
    self.audioHandle = self.loader(path, App.getProps().systemDir)
  end
  --
  return self
end

function M:rewind()
  local props = self.properties
  if self.folder == "long" then
    audio.rewind(self.audioHandle)
  else
    audio.rewind(self.audioChannel)
  end
end
--
function M:pause()
  audio.pause(target.audioChannel)
end
--
function M:stop()
  local props = self.properties
  if self.folder == "long" then
    audio.rewind(self.audioHandle)
  else
    audio.rewind(self.audioChannel)
  end
  audio.stop(self.audioChannel)
end
--
function M:resume()
  audio.resume(self.audioChannel)
end
--
function M:setVolume(vvol)
  audio.setVolume(vvol, self.audioChannel)
end

function M:muteUnmute()
  local props = self.properties
  if (audio.getVolume() == 0.0) then
    audio.setVolume(props.volume, self.audioChannel)
  else
    audio.setVolume(0.0, self.audioChannel)
  end
end

M.set = function(instance)
  if type(instance.properties.channel) ~= "number" then
    instance.properties.channel = 1
  end
  return setmetatable(instance, {__index = M})
end

return M
