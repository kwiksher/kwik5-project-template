local props = {
  name     = "{{name}}",
  properties = {
    delay     = {{delay}},
    iterations = {{iterations}},
  },
  actions = {
    actionName    = "{{actionName}}",
  }
}

return require("components.kwik.page_timer").set(props)
