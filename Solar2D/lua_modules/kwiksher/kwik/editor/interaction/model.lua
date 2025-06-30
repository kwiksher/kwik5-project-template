local model = {
    name = "Interactions",
    icon = "toolInter",
    tools = {
      {name = "Button", icon = "intButton"},
      {name = "Canvas", icon = "intCanvas"},
      {name = "Drag", icon = "intDrag"},
      {name = "Pinch", icon = "intPinch"},
      {name = "Parallax", icon = "intParallax"},
      {name = "Scroll", icon = "intScroll"},
      {name = "Spin", icon = "intSpin"},
      {name = "Shake", icon = "intShake"},
      {name = "Swipe", icon = "intSwipe"}
    },
    id = "interaction",
    props = {
      {name="name", value="NAME"},
      {name="delay", value=0},
      {name="duration", value=3000},
    }
  }
return model