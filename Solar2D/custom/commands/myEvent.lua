local instance = require("plugin.kwik.commands.kwik.baseCommand").new(
  function (params)
    local e     = params.event
    local UI    = e.UI
    print("commands.myBookEvent")
  end
)
--
return instance
