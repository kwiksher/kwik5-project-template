local props = {
  name       = "group0_1",
  members   = {
    "GroupA.SubA.Triangle",
    "GroupA.Ellipse",
  },
  properties = {
    alpha = 1,
    xScale = 1,
    yScale = 1,
    rotation = 0,
    isLuaTable = false
  }
}
return require("components.kwik.page_group").set(props)
