local M = {
  target     = NIL,
  type    = {{type}}, -- group, page, sprite
  animation  = false,
  delay      = 0,
  duration   = 1000,
  autoPlay   = true,
  loop       = 1,        -- 0 to play once
  easing     = "inQuad",
  reverse    = nil,
  resetAtEnd = nil,
  xSwipe     = nil,
  ySwipe     = nil,
  {{#composite}}
  composite = {
    name   = NIL,
    paint1 = NIL,
    paint2 = NIL,
    folder = NIL
  },
  {{/composite}}
  {{#filter}}
  filter = {
    name = NIL,
  } ,
  {{/filter}}
  {{#generator}}
  generator = {
    name = NIL,
  } ,
  {{/generator}}
  actions = {onComplete = NIL},
}
--
--
--
{{#bloom}}
M.filterTable["filter.bloom"] = {
    set = function(effect, value)
      if value then
        effect.levels.gamma             = value.levels.gamma
        effect.levels.black             = value.levels.black
        effect.levels.white             = value.levels.white
        effect.blur.vertical.blurSize   = value.blur.vertical.blurSize
        effect.blur.vertical.sigma      = value.blur.vertical.sigma
        effect.blur.horizontal.blurSize = value.blur.horizontal.blurSize
        effect.blur.horizontal.sigma    = value.blur.horizontal.sigma
        effect.add.alpha                = value.add.alpha
      else
        {{#filterFrom}}
        effect.levels.gamma             = {{levels_gamma}}
        effect.levels.black             = {{levels_black}}
        effect.levels.white             = {{levels_white}}
        effect.blur.vertical.blurSize   = {{blur_vertical_blurSize}}
        effect.blur.vertical.sigma      = {{blur_vertical_sigma}}
        effect.blur.horizontal.blurSize = {{blur_horizontal_blurSize}}
        effect.blur.horizontal.sigma    = {{blur_horizontal_sigma}}
        effect.add.alpha                = {{add_alpha}}
        {{/filterFrom}}
      end
    end,
    get = function()
        {{#filterTo}}
        local effect = {}
        effect.levels = {}
        effect.blur  = {vertical={}, horizontal = {}}
        effect.add = {}
        effect.levels.gamma             = {{levels_gamma}}
        effect.levels.black             = {{levels_black}}
        effect.levels.white             = {{levels_white}}
        effect.blur.vertical.blurSize   = {{blur_vertical_blurSize}}
        effect.blur.vertical.sigma      = {{blur_vertical_sigma}}
        effect.blur.horizontal.blurSize = {{blur_horizontal_blurSize}}
        effect.blur.horizontal.sigma    = {{blur_horizontal_sigma}}
        effect.add.alpha                = {{add_alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/bloom}}
--
{{#blur}}
M.filterTable["filter.blur"] = {
    set = function(effect, value)
    end,
    get = function()
        local effect = {}
        return effect
    end
}
{{/blur}}
--
{{#blurGaussian}}
M.filterTable["filter.blurGaussian"] = {
    set = function(effect, value)
      if value then
          effect.vertical.blurSize   = value.vertical.blurSize
          effect.vertical.sigma      = value.vertical.sigma
          effect.horizontal.blurSize = value.horizontal.blurSize
          effect.horizontal.sigma    = value.horizontal.sigma
      else
        {{#filterFrom}}
        effect.vertical.blurSize   = {{vertical_blurSize}}
        effect.vertical.sigma      = {{vertical_sigma}}
        effect.horizontal.blurSize = {{horizontal_blurSize}}
        effect.horizontal.sigma    = {{horizontal_sigma}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.vertical = {}
          effect.horizontal = {}
          effect.vertical.blurSize   = {{vertical_blurSize}}
          effect.vertical.sigma      = {{vertical_sigma}}
          effect.horizontal.blurSize = {{horizontal_blurSize}}
          effect.horizontal.sigma    = {{horizontal_sigma}}
        {{/filterTo}}
        return effect
    end
}
{{/blurGaussian}}
--
{{#blurHorizontal}}
M.filterTable["filter.blurHorizontal"] = {
    set = function(effect, value)
      if value then
          effect.blurSize   = value.blurSize
          effect.sigma      = value.sigma
      else
        {{#filterFrom}}
        effect.blurSize   = {{blurSize}}
        effect.sigma      = {{sigma}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.blurSize   = {{blurSize}}
          effect.sigma      = {{sigma}}
        {{/filterTo}}
        return effect
    end
}
{{/blurHorizontal}}
--
--
{{#blurVertical}}
M.filterTable["filter.blurVertical"] = {
    set = function(effect, value)
      if value then
          effect.blurSize   = value.blurSize
          effect.sigma      = value.sigma
      else
        {{#filterFrom}}
        effect.blurSize   = {{blurSize}}
        effect.sigma      = {{sigma}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.blurSize   = {{blurSize}}
          effect.sigma      = {{sigma}}
        {{/filterTo}}
        return effect
    end
}
{{/blurVertical}}
--
{{#brightness}}
M.filterTable["filter.brightness"] = {
    set = function(effect, value)
      if value then
          effect.intensity   = value.intensity
      else
        {{#filterFrom}}
        effect.intensity   = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity   = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/brightness}}
--
{{#bulge}}
M.filterTable["filter.bulge"] = {
    set = function(effect, value)
      if value then
          effect.intensity   = value.intensity
      else
        {{#filterFrom}}
        effect.intensity   = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity   = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/bulge}}
--
{{#chromaKey}}
M.filterTable["filter.chromaKey"] = {
    set = function(effect, value)
      if value then
          effect.sensitivity = value.sensitivity
          effect.smoothing   = value.smoothing
          effect.color       = value.color
      else
        {{#filterFrom}}
          effect.sensitivity = {{sensitivity}}
          effect.smoothing   = {{smoothing}}
          effect.color       = {
            {{color_0}},
            {{color_1}},
            {{color_2}}
          }
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.sensitivity = {{sensitivity}}
          effect.smoothing   = {{smoothing}}
          effect.color       = {
            {{color_0}},
            {{color_1}},
            {{color_2}}
          }
        {{/filterTo}}
        return effect
    end
}
{{/chromaKey}}
--
{{#colorChannelOffset}}
M.filterTable["filter.colorChannelOffset"] = {
    set = function(effect, value)
      if value then
          effect.yTexels = value.yTexels
          effect.xTexels = value.xTexels
      else
        {{#filterFrom}}
          effect.yTexels = {{yTexels}}
          effect.xTexels = {{xTexels}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.yTexels = {{yTexels}}
          effect.xTexels = {{xTexels}}
        {{/filterTo}}
        return effect
    end
}
{{/colorChannelOffset}}
--
{{#contrast}}
M.filterTable["filter.contrast"] = {
    set = function(effect, value)
      if value then
          effect.contrast = value.contrast
      else
        {{#filterFrom}}
          effect.contrast = {{contrast}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.contrast = {{contrast}}
        {{/filterTo}}
        return effect
    end
}
{{/contrast}}
--
{{#crosshatch}}
M.filterTable["filter.crosshatch"] = {
    set = function(effect, value)
      if value then
          effect.grain = value.grain
      else
        {{#filterFrom}}
          effect.grain = {{grain}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.grain = {{grain}}
        {{/filterTo}}
        return effect
    end
}
{{/crosshatch}}
--
{{#crystallize}}
M.filterTable["filter.crystallize"] = {
    set = function(effect, value)
      if value then
          effect.numTiles = value.numTiles
      else
        {{#filterFrom}}
          effect.numTiles = {{numTiles}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.numTiles = {{numTiles}}
        {{/filterTo}}
        return effect
    end
}
{{/crystallize}}
--
{{#desaturate}}
M.filterTable["filter.desaturate"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/desaturate}}
--
{{#dissolve}}
M.filterTable["filter.dissolve"] = {
    set = function(effect, value)
      if value then
          effect.threshold = value.threshold
      else
        {{#filterFrom}}
          effect.threshold = {{threshold}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.threshold = {{threshold}}
        {{/filterTo}}
        return effect
    end
}
{{/dissolve}}
--
{{#duotone}}
M.filterTable["filter.duotone"] = {
    set = function(effect, value)
      if value then
        effect.darkColor = value.darkColor
        -- effect.darkColor2 = value.darkColor2
        effect.lightColor = value.lightColor
        -- effect.lightColor2 = value.lightColor2
      else
        {{#filterFrom}}
        effect.darkColor = {
          {{darkColor_0}},
          {{darkColor_1}},
          {{darkColor_2}},
          {{darkColor_3}}
        }
        -- effect.darkColor2 = {
        --   {{darkColor2_0}},
        --   {{darkColor2_1}},
        --   {{darkColor2_2}},
        --   {{darkColor2_3}}
        -- }
        effect.lightColor = {
          {{lightColor_0}},
          {{lightColor_1}},
          {{lightColor_2}},
          {{lightColor_3}}
        }
        -- effect.lightColor2 = {
        --   {{lightColor2_0}},
        --   {{lightColor2_1}},
        --   {{lightColor2_2}},
        --   {{lightColor2_3}}
        -- }
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.darkColor = {
          {{darkColor_0}},
          {{darkColor_1}},
          {{darkColor_2}},
          {{darkColor_3}}
        }
        -- effect.darkColor2 = {
        --   {{darkColor2_0}},
        --   {{darkColor2_1}},
        --   {{darkColor2_2}},
        --   {{darkColor2_3}}
        -- }
        effect.lightColor = {
          {{lightColor_0}},
          {{lightColor_1}},
          {{lightColor_2}},
          {{lightColor_3}}
        }
        -- effect.lightColor2 = {
        --   {{lightColor2_0}},
        --   {{lightColor2_1}},
        --   {{lightColor2_2}},
        --   {{lightColor2_3}}
        -- }
        {{/filterTo}}
        return effect
    end
}
{{/duotone}}
--
{{#emboss}}
M.filterTable["filter.emboss"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/emboss}}
--
{{#exposure}}
M.filterTable["filter.exposure"] = {
    set = function(effect, value)
      if value then
          effect.exposure = value.exposure
      else
        {{#filterFrom}}
          effect.exposure = {{exposure}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.exposure = {{exposure}}
        {{/filterTo}}
        return effect
    end
}
{{/exposure}}
--
{{#frostedGlass}}
M.filterTable["filter.frostedGlass"] = {
    set = function(effect, value)
      if value then
          effect.scale = value.scale
      else
        {{#filterFrom}}
          effect.scale = {{scale}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.scale = {{scale}}
        {{/filterTo}}
        return effect
    end
}
{{/frostedGlass}}
--
{{#grayscale}}
M.filterTable["filter.grayscale"] = {
    set = function(effect, value)
    end,
    get = function()
          local effect = {}
        return effect
    end
}
{{/grayscale}}
--
{{#hue}}
M.filterTable["filter.hue"] = {
    set = function(effect, value)
      if value then
          effect.angle = value.angle
      else
        {{#filterFrom}}
          effect.angle = {{angle}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.angle = {{angle}}
        {{/filterTo}}
        return effect
    end
}
{{/hue}}
--
{{#invert}}
M.filterTable["filter.invert"] = {
    set = function(effect, value)
    end,
    get = function()
          local effect = {}
        return effect
    end
}
{{/invert}}
--
{{#iris}}
M.filterTable["filter.iris"] = {
    set = function(effect, value)
      if value then
          effect.smoothness = value.smoothness
          effect.aspectRatio = value.aspectRatio
          effect.center_0 = value.center_0
          effect.center_1 = value.center_0
          effect.aperture = value.aperture
      else
        {{#filterFrom}}
          effect.smoothness = {{smoothness}}
          effect.aspectRatio = {{aspectRatio}}
          effect.center_0 = {{center_0}}
          effect.center_1 = {{center_1}}
          effect.aperture = {{aperture}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.smoothness = {{smoothness}}
          effect.aspectRatio = {{aspectRatio}}
          effect.center_0 = {{center_0}}
          effect.center_1 = {{center_1}}
          effect.aperture = {{aperture}}
        {{/filterTo}}
        return effect
    end
}
{{/iris}}
--
{{#levels}}
M.filterTable["filter.levels"] = {
    set = function(effect, value)
      if value then
          effect.gamma = value.gamma
          effect.white = value.white
          effect.black = value.black
      else
        {{#filterFrom}}
          effect.gamma = {{gamma}}
          effect.white = {{white}}
          effect.black = {{black}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.gamma = {{gamma}}
          effect.white = {{white}}
          effect.black = {{black}}
        {{/filterTo}}
        return effect
    end
}
{{/levels}}
--
{{#linearWipe}}
M.filterTable["filter.linearWipe"] = {
    set = function(effect, value)
      if value then
          effect.progress = value.progress
          effect.smoothness = value.smoothness
          effect.direction_0 = value.direction_0
          effect.direction_1 = value.direction_1
      else
        {{#filterFrom}}
          effect.progress = {{progress}}
          effect.smoothness = {{smoothness}}
          effect.direction_0 = {{direction_0}}
          effect.direction_1 = {{direction_1}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.progress = {{progress}}
          effect.smoothness = {{smoothness}}
          effect.direction_0 = {{direction_0}}
          effect.direction_1 = {{direction_1}}
        {{/filterTo}}
        return effect
    end
}
{{/linearWipe}}
--
{{#median}}
M.filterTable["filter.median"] = {
    set = function(effect, value)
    end,
    get = function()
        local effect = {}
        return effect
    end
}
{{/median}}
--
{{#monotone}}
M.filterTable["filter.monotone"] = {
    set = function(effect, value)
      if value then
          effect.a = value.a
          effect.b = value.b
          effect.g = value.g
          effect.r = value.r
      else
        {{#filterFrom}}
          effect.a = {{a}}
          effect.b = {{b}}
          effect.g = {{g}}
          effect.r = {{r}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.a = {{a}}
          effect.b = {{b}}
          effect.g = {{g}}
          effect.r = {{r}}
        {{/filterTo}}
        return effect
    end
}
{{/monotone}}
--
{{#opTile}}
M.filterTable["filter.opTile"] = {
    set = function(effect, value)
      if value then
          effect.scale = value.scale
          effect.angle = value.angle
          effect.numPixels = value.numPixels
      else
        {{#filterFrom}}
          effect.scale = {{scale}}
          effect.angle = {{angle}}
          effect.numPixels = {{numPixels}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.scale = {{scale}}
          effect.angle = {{angle}}
          effect.numPixels = {{numPixels}}
        {{/filterTo}}
        return effect
    end
}
{{/opTile}}
--
{{#pixelate}}
M.filterTable["filter.pixelate"] = {
    set = function(effect, value)
      if value then
          effect.numPixels = value.numPixels
      else
        {{#filterFrom}}
          effect.numPixels = {{numPixels}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.numPixels = {{numPixels}}
        {{/filterTo}}
        return effect
    end
}
{{/pixelate}}
--
{{#polkaDots}}
M.filterTable["filter.polkaDots"] = {
    set = function(effect, value)
      if value then
          effect.aspectRatio = value.aspectRatio
          effect.dotRadius = value.dotRadius
          effect.numPixels = value.numPixels
      else
        {{#filterFrom}}
          effect.aspectRatio = {{aspectRatio}}
          effect.dotRadius = {{dotRadius}}
          effect.numPixels = {{numPixels}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.aspectRatio = {{aspectRatio}}
          effect.dotRadius = {{dotRadius}}
          effect.numPixels = {{numPixels}}
        {{/filterTo}}
        return effect
    end
}
{{/polkaDots}}
--
{{#posterize}}
M.filterTable["filter.posterize"] = {
    set = function(effect, value)
      if value then
          effect.colorsPerChannel = value.colorsPerChannel
      else
        {{#filterFrom}}
          effect.colorsPerChannel = {{colorsPerChannel}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.colorsPerChannel = {{colorsPerChannel}}
        {{/filterTo}}
        return effect
    end
}
{{/posterize}}
--
{{#radialWipe}}
M.filterTable["filter.radialWipe"] = {
    set = function(effect, value)
      if value then
          effect.smoothness = value.smoothness
          effect.progress = value.progress
          effect.center_0 = value.center_0
          effect.center_1 = value.center_0
          effect.axisOrientation = value.axisOrientation
      else
        {{#filterFrom}}
          effect.smoothness = {{smoothness}}
          effect.progress = {{progress}}
          effect.center_0 = {{center_0}}
          effect.center_1 = {{center_1}}
          effect.axisOrientation = {{axisOrientation}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.smoothness = {{smoothness}}
          effect.progress = {{progress}}
          effect.center_0 = {{center_0}}
          effect.center_1 = {{center_1}}
          effect.axisOrientation = {{axisOrientation}}
        {{/filterTo}}
        return effect
    end
}
{{/radialWipe}}
--
{{#saturate}}
M.filterTable["filter.saturate"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/saturate}}
--
{{#scatter}}
M.filterTable["filter.scatter"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/scatter}}
--
{{#sepia}}
M.filterTable["filter.sepia"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/sepia}}
--
{{#sharpenLuminance}}
M.filterTable["filter.sharpenLuminance"] = {
    set = function(effect, value)
      if value then
          effect.sharpness = value.sharpness
      else
        {{#filterFrom}}
          effect.sharpness = {{sharpness}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.sharpness = {{sharpness}}
        {{/filterTo}}
        return effect
    end
}
{{/sharpenLuminance}}
--
{{#sobel}}
M.filterTable["filter.sobel"] = {
    set = function(effect, value)
      if value then
      else
        {{#filterFrom}}
         {{/filterFrom}}
       end
    end,
    get = function()
        local effect = {}
        return effect
    end
}
{{/sobel}}
--
{{#straighten}}
M.filterTable["filter.straighten"] = {
    set = function(effect, value)
      if value then
          effect.height = value.height
          effect.angle = value.angle
          effect.width = value.width
      else
        {{#filterFrom}}
          effect.height = {{height}}
          effect.angle = {{angle}}
          effect.width = {{width}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.height = {{height}}
          effect.angle = {{angle}}
          effect.width = {{width}}
        {{/filterTo}}
        return effect
    end
}
{{/straighten}}
--
{{#swirl}}
M.filterTable["filter.swirl"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/swirl}}
--
{{#vignette}}
M.filterTable["filter.vignette"] = {
    set = function(effect, value)
      if value then
          effect.radius = value.radius
      else
        {{#filterFrom}}
          effect.radius = {{radius}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.radius = {{radius}}
        {{/filterTo}}
        return effect
    end
}
{{/vignette}}
--
{{#vignetteMask}}
M.filterTable["filter.vignetteMask"] = {
    set = function(effect, value)
      if value then
          effect.outerRadius = value.outerRadius
          effect.innerRadius = value.innerRadius
      else
        {{#filterFrom}}
          effect.outerRadius = {{outerRadius}}
          effect.innerRadius = {{innerRadius}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.outerRadius = {{outerRadius}}
          effect.innerRadius = {{innerRadius}}
        {{/filterTo}}
        return effect
    end
}
{{/vignetteMask}}
--
{{#wobble}}
M.filterTable["filter.wobble"] = {
    set = function(effect, value)
      if value then
          effect.amplitude = value.amplitude
      else
        {{#filterFrom}}
          effect.amplitude = {{amplitude}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.amplitude = {{amplitude}}
        {{/filterTo}}
        return effect
    end
}
{{/wobble}}
--
{{#woodCut}}
M.filterTable["filter.woodCut"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
        {{/filterTo}}
        return effect
    end
}
{{/woodCut}}
--
{{#zoomBlur}}
M.filterTable["filter.zoomBlur"] = {
    set = function(effect, value)
      if value then
          effect.intensity = value.intensity
          effect.u = value.u
          effect.v = value.v
      else
        {{#filterFrom}}
          effect.intensity = {{intensity}}
          effect.u = {{u}}
          effect.v = {{v}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.intensity = {{intensity}}
          effect.u = {{u}}
          effect.v = {{v}}
        {{/filterTo}}
        return effect
    end
}
{{/zoomBlur}}
--
{{#checkerboard}}
M.filterTable["generator.checkerboard"] = {
    set = function(effect, value)
      if value then
        effect.color1 = value.color1
        effect.color2 = value.color2
        effect.xStep  = value.xStep
        effect.yStep  = value.yStep
      else
        {{#filterFrom}}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.xStep  = {{xStep}}
        effect.yStep  = {{yStep}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.xStep  = {{xStep}}
        effect.yStep  = {{yStep}}
        {{/filterTo}}
        return effect
    end
}
{{/checkerboard}}
--
{{#lenticularHalo}}
M.filterTable["generator.lenticularHalo"] = {
    set = function(effect, value)
      if value then
        effect.seed  = value.seed
        effect.aspectRatio  = value.aspectRatio
        effect.posY  = value.posY
        effect.posX  = value.posX
      else
        {{#filterFrom}}
        effect.seed  = {{seed}}
        effect.aspectRatio  = {{aspectRatio}}
        effect.posY  = {{posY}}
        effect.posX  = {{posX}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.seed  = {{seed}}
        effect.aspectRatio  = {{aspectRatio}}
        effect.posY  = {{posY}}
        effect.posX  = {{posX}}
        {{/filterTo}}
        return effect
    end
}
{{/lenticularHalo}}
--
{{#linearGradient}}
M.filterTable["generator.linearGradient"] = {
    set = function(effect, value)
      if value then
        effect.color1 = value.color1
        effect.color2 = value.color2
        effect.position1 = value.position1
        effect.position2 = value.position2
      else
        {{#filterFrom}}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.position1 = {
          {{position1_0}},
          {{position1_1}},
        }
        effect.position2 = {
          {{position2_0}},
          {{position2_1}},
        }
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.position1 = {
          {{position1_0}},
          {{position1_1}},
        }
        effect.position2 = {
          {{position2_0}},
          {{position2_1}},
        }
        {{/filterTo}}
        return effect
    end
}
{{/linearGradient}}
--
{{#marchingAnts}}
M.filterTable["generator.marchingAnts"] = {
    set = function(effect, value)
    end,
    get = function()
        local effect = {}
        return effect
    end
}
{{/marchingAnts}}
--
{{#perlinNoise}}
M.filterTable["generator.perlinNoise"] = {
    set = function(effect, value)
      if value then
        effect.color1 = value.color1
        effect.color2 = value.color2
        effect.scale  = value.scale
      else
        {{#filterFrom}}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.scale  = {{scale}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.scale  = {{scale}}
        {{/filterTo}}
        return effect
    end
}
{{/perlinNoise}}
--
{{#radialGradient}}
M.filterTable["generator.radialGradient"] = {
    set = function(effect, value)
      if value then
        effect.color1 = value.color1
        effect.color2 = value.color2
        effect.center_and_radiuses = value.center_and_radiuses
        effect.aspectRatio = value.aspectRatio
      else
        {{#filterFrom}}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.center_and_radiuses = {
          {{center_and_radiuses_0}},
          {{center_and_radiuses_1}},
          {{center_and_radiuses_2}},
          {{center_and_radiuses_3}}
        }
        effect.aspectRatio ={{aspectRatio}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.color1 = {
          {{color1_0}},
          {{color1_1}},
          {{color1_2}},
          {{color1_3}}
        }
        effect.color2 = {
          {{color2_0}},
          {{color2_1}},
          {{color2_2}},
          {{color2_3}}
        }
        effect.center_and_radiuses = {
          {{center_and_radiuses_0}},
          {{center_and_radiuses_1}},
          {{center_and_radiuses_2}},
          {{center_and_radiuses_3}}
        }
        effect.aspectRatio = {{aspectRatio}}
        {{/filterTo}}
        return effect
    end
}
{{/radialGradient}}
--
{{#random}}
M.filterTable["generator.random"] = {
    set = function(effect, value)
    end,
    get = function()
        local effect = {}
        return effect
    end
}
{{/random}}
--
{{#stripes}}
M.filterTable["generator.stripes"] = {
    set = function(effect, value)
      if value then
        effect.periods = value.periods
        effect.angle = value.angle
        effect.translation = value.translation
      else
        {{#filterFrom}}
        effect.periods = {
          {{periods_0}},
          {{periods_1}},
          {{periods_2}},
          {{periods_3}}
        }
        effect.angle ={{angle}}
        effect.translation ={{translation}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.periods = {
          {{periods_0}},
          {{periods_1}},
          {{periods_2}},
          {{periods_3}}
        }
        effect.angle = {{angle}}
        effect.translation = {{translation}}
        {{/filterTo}}
        return effect
    end
}
{{/stripes}}
--
{{#sunbeams}}
M.filterTable["generator.sunbeams"] = {
    set = function(effect, value)
      if value then
        effect.seed = value.seed
        effect.aspectRatio = value.aspectRatio
        effect.posY = value.posY
        effect.posX = value.posX

      else
        {{#filterFrom}}
        effect.seed ={{seed}}
        effect.aspectRatio ={{aspectRatio}}
        effect.posY ={{posY}}
        effect.posX ={{posX}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
        effect.seed = {{seed}}
        effect.aspectRatio = {{aspectRatio}}
        effect.posY = {{posY}}
        effect.posX = {{posX}}
        {{/filterTo}}
        return effect
    end
}
{{/sunbeams}}
--
{{#add}}
M.filterTable["composite.add"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/add}}
--
{{#average}}
M.filterTable["composite.average"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/average}}
--
{{#colorBurn}}
M.filterTable["composite.colorBurn"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/colorBurn}}
--
{{#colorDodge}}
M.filterTable["composite.colorDodge"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/colorDodge}}
--
{{#darken}}
M.filterTable["composite.darken"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/darken}}
--
{{#difference}}
M.filterTable["composite.difference"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/difference}}
--
{{#exclusion}}
M.filterTable["composite.exclusion"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/exclusion}}
--
{{#glow}}
M.filterTable["composite.glow"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/glow}}
--
{{#hardLight}}
M.filterTable["composite.hardLight"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/hardLight}}
--
{{#hardMix}}
M.filterTable["composite.hardMix"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/hardMix}}
--
{{#lighten}}
M.filterTable["composite.lighten"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/lighten}}
--
{{#linearLight}}
M.filterTable["composite.linearLight"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/linearLight}}
--
{{#multiply}}
M.filterTable["composite.multiply"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/multiply}}
--
{{#negation}}
M.filterTable["composite.negation"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/negation}}
--
{{#normalMapWith1DirLight}}
M.filterTable["composite.normalMapWith1DirLight"] = {
    set = function(effect, value)
      if value then
          effect.dirLightDirection = value.dirLightDirection
          effect.dirLightColor = value.dirLightColor
          effect.ambientLightIntensity = value.ambientLightIntensity
        else
        {{#filterFrom}}
          effect.dirLightDirection ={
            {{dirLightDirection_0}},
            {{dirLightDirection_1}},
            {{dirLightDirection_2}}
          }
          effect.dirLightColor = {
             {{dirLightColor_0}},
             {{dirLightColor_1}},
             {{dirLightColor_2}},
             {{dirLightColor_3}}
           }
          effect.ambientLightIntensity = {{ambientLightIntensity}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
        local effect = {}
        effect.dirLightDirection=  {}
        effect.dirLightColor    =  {}
        effect.dirLightDirection ={
          {{dirLightDirection_0}},
          {{dirLightDirection_1}},
          {{dirLightDirection_2}}
        }
        effect.dirLightColor = {
           {{dirLightColor_0}},
           {{dirLightColor_1}},
           {{dirLightColor_2}},
           {{dirLightColor_3}}
         }
        effect.ambientLightIntensity = {{ambientLightIntensity}}
        {{/filterTo}}
        return effect
    end
}
{{/normalMapWith1DirLight}}
--
{{#normalMapWith1PointLight}}
M.filterTable["composite.normalMapWith1PointLight"] = {
    set = function(effect, value)
      if value then
          effect.pointLightPos = value.pointLightPos
          effect.pointLightColor = value.pointLightColor
          effect.ambientLightIntensity = value.ambientLightIntensity
          effect.attenuationFactors = value.attenuationFactors

      else
        {{#filterFrom}}
          effect.pointLightPos ={
            {{pointLightPos_0}},
            {{pointLightPos_1}},
            {{pointLightPos_2}}
          }
          effect.pointLightColor = {
             {{pointLightColor_0}},
             {{pointLightColor_1}},
             {{pointLightColor_2}},
             {{pointLightColor_3}}
           }
          effect.ambientLightIntensity = {{ambientLightIntensity}}
          effect.attenuationFactors = {
            {{attenuationFactors_0}},
            {{attenuationFactors_1}},
            {{attenuationFactors_2}},
          }
         {{/filterFrom}}
       end
    end,
    get = function(param)
        {{#filterTo}}
        local effect = {}
        effect.pointLightPos      =  {}
        effect.pointLightColor    =  {}
        effect.attenuationFactors = {}
        effect.pointLightPos ={
          {{pointLightPos_0}},
          {{pointLightPos_1}},
          {{pointLightPos_2}}
        }
        effect.pointLightColor = {
           {{pointLightColor_0}},
           {{pointLightColor_1}},
           {{pointLightColor_2}},
           {{pointLightColor_3}}
         }
        effect.ambientLightIntensity = {{ambientLightIntensity}}
        effect.attenuationFactors = {
          {{attenuationFactors_0}},
          {{attenuationFactors_1}},
          {{attenuationFactors_2}},
        }
        {{/filterTo}}
        return effect
    end
}
{{/normalMapWith1PointLight}}
--
{{#overlay}}
M.filterTable["composite.overlay"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/overlay}}
--
{{#phoenix}}
M.filterTable["composite.phoenix"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/phoenix}}
--
{{#pinLight}}
M.filterTable["composite.pinLight"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/pinLight}}
--
{{#screen}}
M.filterTable["composite.screen"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/screen}}
--
{{#softLight}}
M.filterTable["composite.softLight"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/softLight}}
--
{{#subtract}}
M.filterTable["composite.subtract"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/subtract}}
--
{{#vividLight}}
M.filterTable["composite.vividLight"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/vividLight}}

{{#reflec}}
M.filterTable["composite.reflect"] = {
    set = function(effect, value)
      if value then
          effect.alpha    = value.alpha
      else
        {{#filterFrom}}
          effect.alpha    = {{alpha}}
         {{/filterFrom}}
       end
    end,
    get = function()
        {{#filterTo}}
          local effect = {}
          effect.alpha    = {{alpha}}
        {{/filterTo}}
        return effect
    end
}
{{/reflec}}

return M

