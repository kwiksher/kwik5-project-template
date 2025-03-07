local M = {
  loop = true,
  rewind = true,
  isLocal = true,
  url = "",
  autoPlay = true,
  onCompelete = "action_{{elTrigger}}"
}
--
M.singleNames = {"PagePrevM", "PageNextM"}
--
local layerProps = require(parent.."{{layer}}")
--
M.x = layerProps.x
M.y = layerProps.y
--
return require("components.kwik.layer_video").new(M)
