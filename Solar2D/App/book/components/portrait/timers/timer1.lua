local props = {
  name     = "timer1",
  properties = {
    delay     = 0,
    iterations = 1,
  },
  actions = {
  }
}
return require("components.kwik.page_timer").set(props)
