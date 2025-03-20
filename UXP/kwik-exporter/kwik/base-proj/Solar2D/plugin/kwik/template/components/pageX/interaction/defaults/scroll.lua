local M = {
  name = "scroll",
  class="scroll",
  properties = {
    target = NIL,
    type   = NIL,
    isActive = true,
    area = "object", -- page, paragraph, manual
    width = NIL,
    height = NIL,
    top = NIL,
    left = NIL,
    scrollWith = NIL,
    scrollHeight = NIL
  }
}

return M