local M = {
  name = "parallax",
  class="parallax",
  properties = {
    target = NIL,
    type   = NIL,
    isActive = true,
    dpx = 0.5,
    dpy = 0.5,
  },
  actions = {
    onBack = NIL,
    onForward = NIL,
  }
}

return M