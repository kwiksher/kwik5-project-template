local M = {}
--
function M:play(obj)
  if obj.player then -- png movieclip
    if obj.player.playing == nil then
      obj.player:play(
        {
          loop = obj.loop,
          onComplete = function()
            print("completed")
            if obj.videoListener then
              obj.videoListener({phase = "ended"})
            end
            obj.player:stop()
          end
        }
      )
    elseif obj.player.isPaused then
      obj.player:resume()
    end
  else
    obj:play()
  end
end
--
function M:pause(obj)
  if obj.player then -- png movieclip
    obj.player:pause()
  else
    obj:pause()
  end
end
--
function M:rewind(obj)
  if obj.player then -- png movieclip
    print("not supported yet")
  else
    obj:seek(0)
  end
end
--
function M:seek(obj, seconds)
  if obj.player then -- png movieclip
    print("not supported yet")
  else
    obj:seek(seconds)
  end
end
--
function M:muteUnmute(UI)
  for i, video in next, UI.videos do
    if video.isMuted then
      video.isMuted = false
    else
      video.isMuted = true
    end
  end
end
--
function M:mute(obj)
   obj.isMuted = true
end
--
function M:unmute(obj)
  obj.isMuted = false
end
--
return M
