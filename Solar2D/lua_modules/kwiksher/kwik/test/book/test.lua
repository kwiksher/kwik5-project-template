local scene = require('controller.scene').new(sceneName, {
  name = "canvas",
  components = {
    layers = {
      {
        back = {  }

      },
      {
        butBlue = {     {
          A = {  }

        },
        {
          B = {  }

        },
        }

      },
      {
        butWhite = {  }
        , class={ "button" }
      },
    },
    audios = {  },
    groups = {  },
    timers = {  },
    variables = {  },
    others = {  }
  },
  commands = {   "blueBTN",  },
  onInit = function(scene) print("onInit") end
})
--
return scene