-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--		obj:showHide("objB", false)
function _M:showHide(obj, show, toggles, time, delay)
  local timer
   if delay > 0 or time > 0 then
     if toggles then
          if obj.alpha == 0 then
              timer = transition.to( obj, {alpha=obj.oldAlpha, time=time, delay=delay})
          else
              timer = transition.to( obj, {alpha=0, time=time, delay=delay})
          end
      else
          if show then
                local alpha = obj.oldAlpha > 0 and obj.oldAlpha or 1
                timer = transition.to( obj, {alpha=alpha, time=time, delay=delay})
                --print("obj.oldAlpha", obj.oldAlpha)
                --print("show", obj.alpha)
          else
                timer = transition.to( obj, {alpha=0, time=time, delay=delay})
                --print("hides", obj.alpha)
          end
    end
  else
     if toggles then
          if obj.alpha == 0 then
              local alpha = obj.oldAlpha > 0 and obj.oldAlpha or 1
              obj.alpha = alpha
          else
              obj.alpha = 0
          end
      else
          if show then
            local alpha = obj.oldAlpha > 0 and obj.oldAlpha or 1
            obj.alpha = alpha
         else
              obj.alpha = 0
         end
    end

  end
  return timer
end
--
function _M:frontBack(obj, front)
  if front then
    obj:toFront()
  else
    obj:toBack()
  end
end
return _M
