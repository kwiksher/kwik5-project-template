local sceneName = ...
--
local scene = require('controller.scene').new(sceneName, {
    -- name = "{{name}}",
    layers = {
        {{#layers}}
          {  {{name}}={
                {{>recursive}}
            } },
        {{/layers}}
    },
    components = {
      {{#components}}
      audios = { {{#audios}}{{name}}={}, {{/audios}} },
      groups = { {{#groups}}{{name}}={}, {{/groups}} },
      timers = { {{#timers}}{{name}}={}, {{/timers}} },
      variables = { {{#variables}}{{name}}={}, {{/variables}} },
      others = { {{#others}}{{name}}={}, {{/others}} }
      {{/components}}
     },
    commands = { {{#commands}}  "{{.}}", {{/commands}} },
    onInit = function(scene) print("onInit") end
})
--
return scene
