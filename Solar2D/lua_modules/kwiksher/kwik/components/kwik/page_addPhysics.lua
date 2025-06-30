-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
---------------------
---------------------
function _M:localPos(UI)
    local sceneGroup  = UI.scene.view
    local layer       = UI.layer
end
--
function _M:didShow()
    physics.start(true)
end
--
function _M:toDispose()
    physics.pause()
end
--
function _M:willHide()
end

--
function _M:localVars()
end
--
return _M