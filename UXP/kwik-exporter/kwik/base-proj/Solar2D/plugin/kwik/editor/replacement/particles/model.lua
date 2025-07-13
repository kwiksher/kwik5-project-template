local model = {
  name = "Animations",
  icon = "toolAnim",
  tools = {
    {name = "Blink", icon = "animBlink"},
    {name = "Bounce", icon = "animBounce"},
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
  }
}
return model