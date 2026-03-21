local props = {
  name     = "{{name}}",
  properties = {
    {{#properties}}
    isAfter  = {{isAfter}},
    isLocal  = {{isLocal}}, -- or local
    isSave   = {{isSave}},
    value    = {{value}},
    valueType     = "{{valueType}}", -- table
    {{/properties}}
  }
}

return require("components.kwik.page_variable").set(props)
