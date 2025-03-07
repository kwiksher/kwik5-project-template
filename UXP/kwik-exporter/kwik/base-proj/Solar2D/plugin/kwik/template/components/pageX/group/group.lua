local props = {
  name       = "{{name}}",
  members   = {
    {{#members}}
    "{{.}}",
    {{/members}}
  },
  properties = {
    {{#properties}}
    alpha = {{alpha}},
    xScale = {{xScale}},
    yScale = {{yScale}},
    rotation = {{rotation}},
    isLuaTable = false
    {{/properties}}
  }
}

return require("components.kwik.page_group").set(props)