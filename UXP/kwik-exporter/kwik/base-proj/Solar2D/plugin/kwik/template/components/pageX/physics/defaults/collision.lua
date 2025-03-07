local M = {
  name = "",
  class="collision",
  properties = {
    isRemoveOther = true,
    isRemoveSelf = true,
    othersGroup = NIL
  },
  actions = { onCollision= "" },
  others = {}
}

return M