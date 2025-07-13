-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local _M = {}
--
function _M:playParticle(obj)
   obj:start()
end
--
function _M:stopParticle(obj)
    obj:stop()
end
--
return _M