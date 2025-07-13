local model = {
  name = "Animations",
  icon = "toolAnim",
  tools = {
    {name = "Linear", icon = "animLinear"},
    {name = "Blink", icon = "animBlink"},
    {name = "Bounce", icon = "animBounce"},
    {name = "Filter", icon = "animFilter"},
    {name = "Path", icon = "animPath"},
    {name = "Pulse", icon = "animPulse"},
    {name = "Rotation", icon = "animRotation"},
    {name = "Shake", icon = "animShake"},
    {name = "Switch", icon = "animSwitch"}
  },
  id = "animation",
  props = {
    {name="autoPlay", value=true},
    {name="delay", value=0},
    {name="duration", value=3000},
    {name="loop", value=1},
    {name="reverse", value=false},
    {name="resetAtEnd", value=false},
    {name="easing", value=nil},
    {name="xSwipe", value=nil},
    {name="ySwipe", value=nil},
  },
  breadcrumbs = {
    {name = "dispose",value = true},
    {name = "shape" ,value = ""},
    {name = "color",value = {1, 0, 1}},
    {name = "interval",value = 300},
    {name = "time",value = 2000},
    {name = "width",value = 30},
    {name = "height",value = 3},
  },
  refrencePoint ={
    {name = "referencePoint", value="Center"},
    {name = "deltaX", value = 0},
    {name = "deltaY", value = 0}
  }
}
return model