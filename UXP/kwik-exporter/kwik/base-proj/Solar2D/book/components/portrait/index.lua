local sceneName = ...
--
local model = {
  --name = "",
  components = {
    layers = {
      {
        bg = {
        }
      },
      {
        copyright = {
        }
      },
      {
        GroupA = {     {
          SubA = {     {
            Triangle = {
              class={ "linear", }  }
          },

          }
        },
        {
          Ellipse = {
            class={ "button", }  }
        },

        }
      },
      {
        star = {
        }
      },
      {
        tree = {
        }
      },
      {
        hello = {
          class={ "sprite", }  }
      },
    },
    audios = {
      long={  }, short={ "Thunder",   }
    },
    groups = {
      {
        group0 = {
          class={ "linear","button", }  }
      },
    },
    timers = {  "timer1",  },
    variables = {  },
    joints    = {  },
    page = {  }
  },
  commands = {   "audioAction",   "playAnim",   "testAction",  },
  onInit = function(scene) print("onInit") end
}
local scene = require('controller.scene').new(sceneName, model)
--
return scene
