local parent,root = newModule(...)

local M = {
  name = "{{layer}}",
  --
  class = "{{class}}",
    -- "Dissolve"
    -- "Path"
    -- "Linear"
    -- "Pulse"
    -- "Rotation"
    -- "Tremble"
    -- "Bounce"
    -- "Blink"
  --
}

M.obj = require(parent.."{{layer}}").obj

{{#layerOptions}}
M.layerOptions = {
  --
  referencePoint = "{{referencePoint}}",
    -- "Center"
    -- "TopLeft"
    -- "TopCenter"
    -- "TopRight"
    -- "CenterLeft"
    -- "CenterRight"
    -- "BottomLeft"
    -- "BottomLeft"
    -- "BottomRight"
  -- for text
  deltaX         = {{deltaX}},
  deltaY         = {{deltaY}},
}
{{/layerOptions}}
-- animationProps
M.properties = {
{{#properties}}
  type    = "{{type}}", -- group, page, sprite
  target = "{{target}}",
  autoPlay = {{autoPlay}},
  delay    = {{delay}},
  duration = {{duration}},
  loop     = {{loop}},
  reverse  = {{reverse}},
  resetAtEnd  = {{resetAtEnd}},
  --
  easing   = "{{easing}}",
  -- 'Linear'
  -- 'inOutExpo'
  -- 'inOutQuad'
  -- 'outExpo'
  -- 'outQuad'
  -- 'inExpo'
  -- 'inQuad'
  -- 'inBounce'
  -- 'outBounce'
  -- 'inOutBounce'
  -- 'inCircular'
  -- 'outCircular'
  -- 'inElastic'
  -- 'outElastic'
  -- 'inOutElastic'
  -- 'inBack'
  -- 'outBack'
  -- 'inOutBack'
  ------------
  -- flip
  xSwipe   = {{xSwipe}},
  ySwipe   = {{ySwipe}},
{{/properties}}
}
  --

{{#to}}
M.to = {
  x     = {{x}},
  y     = {{y}},
  --
  alpha = {{alpha}},

  yScale   = {{yScale}},
  xScale   = {{xScale}},
  rotation = {{rotation}},
}
{{/to}}
  -- more option

  -- action at the end of animation
M.actions = { onComplete = "{{actionName}}" }


{{#breadcrumb}}
M.breadcrumbs = {
    dispose  = {{dispose}},
    shape    = {{shape}},
    Color    = {{color}},
    interval = {{bInterval}},
    time     = {{time}},
    width  = {{width}},
    height = {{height}},
}
{{/breadcrumb}}

{{#path}}
if M.animation.Class == "path" then
	M.pathProps = {
    curve = 	{{pathCurve}},
    angle = {{angle}},
    newAngle = {{newAngle}},
  }
end
{{/path}}
---------------------------------------
--
local function onEndHandler (UI)
  if M.actionName and M.actionName:len() > 0  then
    Runtime:dispatchEvent({name=UI.page..M.actionName, event={}, UI=UI})
  end
end
--
function M:create(UI)
  if UI.langClassDelegate then
    local t = self.name:split("/")
    self.name = t[1].."/".. UI.lang
  end
  --
  if self.properties.type == "group" then
    self.obj = require(parent..self.properties.target).group
  else
    self.obj = UI.sceneGroup[self.name]
  end
  self:initAnimation(UI, self.obj, onEndHandler)
  self.animation = self:buildAnim(UI)
end
--
function M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  if self.properties.autoPlay then
    if self.animation.from then
      --self.animation.from:toBeginning()
      -- transition.to(obj, {x = obj.x + 100})
      -- local obj = sceneGroup["cat_face1"]

      self.animation.from:play()
      -- self.animation.from:pause()

    else
      --self.animation.to:toBeginning()
      self.animation.to:play()
    end
  end
end
--
function M:didHide(UI)
  if self.animation.from then
    self.animation.from:pause()
    -- self.animation.from:toBeginning()
   end
  if self.animation.to then
    self.animation.to:pause()
    -- self.animation.to:toBeginning()
  end
end

--
return require("components.kwik.layer_animation").set(M)