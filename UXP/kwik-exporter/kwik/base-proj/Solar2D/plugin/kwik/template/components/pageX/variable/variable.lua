local props = {
  name     = "{{name}}",
  properties = {
    {{#properties}}
    isAfter  = {{isAfter}},
    isLocal  = {{isLocal}}, -- or local
    type     = "{{type}}", -- table
    isSave   = {{isSave}},
    value    = {{value}}
    {{/properties}}
  }
}

return require("components.kwik.page_variable").set(props)
