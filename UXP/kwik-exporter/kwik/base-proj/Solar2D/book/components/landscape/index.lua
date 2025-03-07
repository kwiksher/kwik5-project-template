local sceneName = ...
--
local scene =
  require("controller.scene").new(
  sceneName,
  {
    --name = "landscape",
    components = {
      layers = {
        {
          background = {
            class = {}
          }
        },
        {
          bg = {
            class = {}
          }
        },
        {
          copyright = {
            class = {}
          }
        },
        {
          GroupA = {
            class = {}
          }
        },
        {
          star = {
            class = {}
          }
        },
        {
          hello = {
            class = {}
          }
        }
      },
      audios = {},
      groups = {},
      timers = {},
      variables = {},
      joints = {},
      page = {}
    },
    commands = {},
    onInit = function(scene)
      --print("onInit")
    end
  }
)
--
return scene
