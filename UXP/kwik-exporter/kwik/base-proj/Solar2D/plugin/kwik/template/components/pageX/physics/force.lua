local M = {
  name = NIL,
  class="force",
  properties = {
    {{#properties}}
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
