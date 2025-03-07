local M = {
  name = "",
  class="parallax",
  properties = {
    target = NIL,
    isActive = true,
    dampX = true,
    dampY = true,
    dpx = 0.5,
    dpy = 0.5,
  },
  actions = {
    onBack = NIL,
    onForward = NIL,
  }
}

return M