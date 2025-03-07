local sceneName = ...
--
local scene = require('controller.scene').new(sceneName, {
    --name = "{{name}}",
    components = {
      layers = {
          {{#layers}}
           {{>recursive}}
           {{/layers}}
          },
      audios = {
        {{#audios}}
          long={ {{#long}} "{{.}}", {{/long}} }, short={ {{#short}}"{{.}}", {{/short}}  }
        {{/audios}}
      },
      groups = {
        {{#groups}}
        {{>recursive}}
        {{/groups}}
      },
      timers = { {{#timers}} "{{.}}", {{/timers}} },
      variables = { {{#variables}} "{{.}}", {{/variables}} },
      joints    = { {{#joints}} "{{.}}", {{/joints}} },
      page = { {{#page}}"{{.}}", {{/page}} }
    },
    commands = { {{#events}}  "{{.}}", {{/events}} },
    onInit = function(scene) print("onInit") end
})
--
return scene
