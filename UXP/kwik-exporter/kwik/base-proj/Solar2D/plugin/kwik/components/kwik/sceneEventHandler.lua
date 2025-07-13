local Class = {}
--
function Class:setMod(class, layer, suffix)
  local fileName = layer
  if class then
    fileName = layer .."_"..class
  end
  if suffix then
    fileName = fileName..suffix
  end
  --print("components."..self.page.."."..fileName)
  self.mod = require(kwikGlobal.ROOT.."components."..self.UI.page.."."..fileName)
end
--
function Class:_init(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.init then
    self.mod:init(self.UI)
  end
end
--
local typesForPageCurl = {
  button=true, image=true, filter=true
}
--
function Class:_create(class, layer, suffix)
  self:setMod(class, layer, suffix)
  -- dummy is pageCurl UI creation
  if self.mod.create and (self.dummy == nil or typesForPageCurl[class])  then
    self.mod:create(self.UI)
  end
end
--
function Class:_willShow(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.willShow then
    self.mod:willShow(self.UI)
  end
end
--
function Class:_willHide(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.willHide then
    self.mod:willHide(self.UI)
  end
end
--
function Class:_didShow(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.didShow then
    self.mod:didShow(self.UI)
  end
end
--
function Class:_didHide(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.didHide then
    self.mod:didHide(self.UI)
  end
end
--
function Class:_destroy(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.destroy then
    self.mod:destroy(self.UI)
  end
end
--
function Class:_resume(class, layer, suffix)
  self:setMod(class, layer, suffix)
  if self.mod.resume then
    self.mod:resume(self.UI)
  end
end
--
Class.new = function(_UI)
  local handler = {UI=_UI}
	return setmetatable(handler, {__index=Class})
end
--
return Class