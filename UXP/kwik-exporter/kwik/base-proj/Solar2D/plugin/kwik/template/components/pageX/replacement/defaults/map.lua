local M = {
  name = "map0",
  class="map",
  properties = {
    target = NIL,
    mapType         = "standard", -- standard, satellite, hybrid
    latituite       = 37.331692,
    longtitude      = -122.030456,
    isScrollEnabled = true,
    isZoomEnabled   = true,
    marker = {
      enabled    = true,
      latituite  = 37.331692,
      longtitude = -122.030456,
      title      = "title",
      subtitle   = "subtitle",
    },
  },
}

return M