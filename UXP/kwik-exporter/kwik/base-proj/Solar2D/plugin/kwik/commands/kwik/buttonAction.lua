-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--		obj:showHide("objB", false)
function _M:enableDisableButton(obj, toggle, enable)
   if toggles then
        obj.enabled = not obj.eabled
    else
        if enable then
              obj.enabled = true
        else
              obj.enabled = false
        end
  end
end
return _M