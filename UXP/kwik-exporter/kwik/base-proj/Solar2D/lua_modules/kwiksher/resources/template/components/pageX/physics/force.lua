local M = {
  name = "{{layer}}",
  class="force",
  properties = {
    {{#properties}}
    body = "{[layer]}",
    event = "{{event}}",
    isInitial = {{isInitial}},
    isImpluse = {{isImpluse}},
    type = "{{type}}", -- push, none
    xForce = {{xForce}},
    yForce = {{yForce}},
    {{/properties}}
  }
}

return require("components.kwik.layer_physicsForce").set(M)
