```lua
local sceneName = ...
--
local model = {
  --name = "",
  components = {
    layers = {
      {
        background = {
        }
      },
      {
        bg = {
        }
      },
      {
        copyright = {
        }
      },
      {
        GroupA = {
        }
      },
      {
        star = {
           }
      },
      {
        hello = {
        }
      },
    },
    audios = {
    },
    groups = {
    },
    timers = {  },
    variables = {  },
    joints    = {  },
    page = {  }
  },
  commands = {  },
  onInit = function(scene)  end
}
local scene = require('controller.scene').new(sceneName, model)
--
return scene

```
