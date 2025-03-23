local props = {
  name     = "{{name}}",
  properties = {
    {{#properties}}
    delay     = {{delay}},
    iterations = {{iterations}},
    {{/properties}}
  },
  actions = {
    {{#actions}}
    onComplete    = "{{onComplete}}",
    {{/actions}}
  }
}

return require("components.kwik.page_timer").set(props)
