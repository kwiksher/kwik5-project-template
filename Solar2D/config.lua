local aspectRatio = display.pixelHeight / display.pixelWidth
application = {
   content = {
     width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
     height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
      -- width = 320,
      -- height = 480,
      scale = "adaptive", -- "letterBox",
      fps = 30,
      imageSuffix = {
         ["@2x"] = 1.5,
         ["@4x"] = 3.0,
      },
   },
   license =
        {
            google =
            {
                key = "Please set your google license key",
            },
        },
 }