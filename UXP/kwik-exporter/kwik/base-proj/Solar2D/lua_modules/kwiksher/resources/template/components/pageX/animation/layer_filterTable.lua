local M = {
  to = NIL,
  from = NIL,
  filterTable = {}
}

--
function M:set(name, effect, value)
  -- print(name, effect, value)
  -- for k, v in pairs(self.from) do print(k, v) end
  self.filterTable[name].set(effect, value or self.from)
end

function M:get(name, effect, value)
  self.filterTable[name].get(value or self.to)
end

--
M.filterTable["filter.bloom"] = {
  set = function(effect, value)
    if value then
      effect.levels = {}
      effect.blur = {vertical = {}, horizontal = {}}
      effect.add = {}
      effect.levels.gamma = value.levels_gamma
      effect.levels.black = value.levels_black
      effect.levels.white = value.levels_white
      effect.blur.vertical.blurSize = value.blur_vertical_blurSize
      effect.blur.vertical.sigma = value.blur_vertical_sigma
      effect.blur.horizontal.blurSize = value.blur_horizontal_blurSize
      effect.blur.horizontal.sigma = value.blur_horizontal_sigma
      effect.add.alpha = value.add_alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.levels = {}
    effect.blur = {vertical = {}, horizontal = {}}
    effect.add = {}
    effect.levels.gamma = value.levels_gamma
    effect.levels.black = value.levels_black
    effect.levels.white = value.levels_white
    effect.blur.vertical.blurSize = value.blur_vertical_blurSize
    effect.blur.vertical.sigma = value.blur_vertical_sigma
    effect.blur.horizontal.blurSize = value.blur_horizontal_blurSize
    effect.blur.horizontal.sigma = value.blur_horizontal_sigma
    effect.add.alpha = value.add_alpha
    return effect
  end
}
--
M.filterTable["filter.blur"] = {
  set = function(effect, value)
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["filter.blurGaussian"] = {
  set = function(effect, value)
    if value then
      effect.vertical.blurSize = value.vertical_blurSize
      effect.vertical.sigma = value.vertical_sigma
      effect.horizontal.blurSize = value.horizontal_blurSize
      effect.horizontal.sigma = value.horizontal_sigma
    end
  end,
  get = function(value)
    local effect = {}
    effect.vertical = {}
    effect.horizontal = {}
    effect.vertical.blurSize = value.vertical_blurSize
    effect.vertical.sigma = value.vertical_sigma
    effect.horizontal.blurSize = value.horizontal_blurSize
    effect.horizontal.sigma = value.horizontal_sigma
    return effect
  end
}
M.filterTable["filter.blurHorizontal"] = {
  set = function(effect, value)
    if value then
      effect.blurSize = value.blurSize
      effect.sigma = value.sigma
    end
  end,
  get = function(value)
    local effect = {}
    effect.blurSize = value.blurSize
    effect.sigma = value.sigma
    return effect
  end
}
--
--
M.filterTable["filter.blurVertical"] = {
  set = function(effect, value)
    if value then
      effect.blurSize = value.blurSize
      effect.sigma = value.sigma
    end
  end,
  get = function(value)
    local effect = {}
    effect.blurSize = value.blurSize
    effect.sigma = value.sigma
    return effect
  end
}
--
M.filterTable["filter.brightness"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.bulge"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.chromaKey"] = {
  set = function(effect, value)
    if value then
      effect.sensitivity = value.sensitivity
      effect.smoothing = value.smoothing
      effect.color = value.color
    end
  end,
  get = function(value)
    local effect = {}
    effect.sensitivity = value.sensitivity
    effect.smoothing = value.smoothing
    effect.color = value.color
    return effect
  end
}
--
M.filterTable["filter.colorChannelOffset"] = {
  set = function(effect, value)
    if value then
      effect.yTexels = value.yTexels
      effect.xTexels = value.xTexels
    end
  end,
  get = function(value)
    local effect = {}
    effect.yTexels = value.yTexels
    effect.xTexels = value.xTexels
    return effect
  end
}
--
M.filterTable["filter.contrast"] = {
  set = function(effect, value)
    if value then
      effect.contrast = value.contrast
    end
  end,
  get = function(value)
    local effect = {}
    effect.contrast = value.contrast
    return effect
  end
}
--
M.filterTable["filter.crosshatch"] = {
  set = function(effect, value)
    if value then
      effect.grain = value.grain
    end
  end,
  get = function(value)
    local effect = {}
    effect.grain = value.grain
    return effect
  end
}
--
M.filterTable["filter.crystallize"] = {
  set = function(effect, value)
    if value then
      effect.numTiles = value.numTiles
    end
  end,
  get = function(value)
    local effect = {}
    effect.numTiles = value.numTiles
    return effect
  end
}
--
M.filterTable["filter.desaturate"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.dissolve"] = {
  set = function(effect, value)
    if value then
      effect.threshold = value.threshold
    end
  end,
  get = function(value)
    local effect = {}
    effect.threshold = value.threshold
    return effect
  end
}
--
M.filterTable["filter.duotone"] = {
  set = function(effect, value)
    if value then
      -- effect.lightColor2 = value.lightColor2
      effect.darkColor = value.darkColor
      -- effect.darkColor2 = value.darkColor2
      effect.lightColor = value.lightColor
    else
      -- effect.lightColor2 = {
      --   {{lightColor2_0}},
      --   {{lightColor2_1}},
      --   {{lightColor2_2}},
      --   {{lightColor2_3}}
      -- }
      -- effect.darkColor2 = {
      --   {{darkColor2_0}},
      --   {{darkColor2_1}},
      --   {{darkColor2_2}},
      --   {{darkColor2_3}}
      -- }
    end
  end,
  get = function(value)
    local effect = {}
    effect.darkColor = value.darkColor
    -- effect.darkColor2 = {
    --   {{darkColor2_0}},
    --   {{darkColor2_1}},
    --   {{darkColor2_2}},
    --   {{darkColor2_3}}
    -- }
    effect.lightColor = value.lightColor
    -- effect.lightColor2 = {
    --   {{lightColor2_0}},
    --   {{lightColor2_1}},
    --   {{lightColor2_2}},
    --   {{lightColor2_3}}
    -- }
    return effect
  end
}
--
M.filterTable["filter.emboss"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.exposure"] = {
  set = function(effect, value)
    if value then
      effect.exposure = value.exposure
    end
  end,
  get = function(value)
    local effect = {}
    effect.exposure = value.exposure
    return effect
  end
}
--
M.filterTable["filter.frostedGlass"] = {
  set = function(effect, value)
    if value then
      effect.scale = value.scale
    end
  end,
  get = function(value)
    local effect = {}
    effect.scale = value.scale
    return effect
  end
}
--
M.filterTable["filter.grayscale"] = {
  set = function(effect, value)
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["filter.hue"] = {
  set = function(effect, value)
    if value then
      effect.angle = value.angle
    end
  end,
  get = function(value)
    local effect = {}
    effect.angle = value.angle
    return effect
  end
}
--
M.filterTable["filter.invert"] = {
  set = function(effect, value)
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["filter.iris"] = {
  set = function(effect, value)
    if value then
      effect.smoothness = value.smoothness
      effect.aspectRatio = value.aspectRatio
      effect.center = value.center
      effect.aperture = value.aperture
    end
  end,
  get = function(value)
    local effect = {}
    effect.smoothness = value.smoothness
    effect.aspectRatio = value.aspectRatio
    effect.center = value.center
    effect.aperture = value.aperture
    return effect
  end
}
--
M.filterTable["filter.levels"] = {
  set = function(effect, value)
    if value then
      effect.gamma = value.gamma
      effect.white = value.white
      effect.black = value.black
    end
  end,
  get = function(value)
    local effect = {}
    effect.gamma = value.gamma
    effect.white = value.white
    effect.black = value.black
    return effect
  end
}
--
M.filterTable["filter.linearWipe"] = {
  set = function(effect, value)
    if value then
      effect.progress = value.progress
      effect.smoothness = value.smoothness
      effect.direction = value.direction
    end
  end,
  get = function(value)
    local effect = {}
    effect.progress = value.progress
    effect.smoothness = value.smoothness
    effect.direction = value.direction
    return effect
  end
}
--
M.filterTable["filter.median"] = {
  set = function(effect, value)
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["filter.monotone"] = {
  set = function(effect, value)
    if value then
      effect.a = value.a
      effect.b = value.b
      effect.g = value.g
      effect.r = value.r
    end
  end,
  get = function(value)
    local effect = {}
    effect.a = value.a
    effect.b = value.b
    effect.g = value.g
    effect.r = value.r
    return effect
  end
}
--
M.filterTable["filter.opTile"] = {
  set = function(effect, value)
    if value then
      effect.scale = value.scale
      effect.angle = value.angle
      effect.numPixels = value.numPixels
    end
  end,
  get = function(value)
    local effect = {}
    effect.scale = value.scale
    effect.angle = value.angle
    effect.numPixels = value.numPixels
    return effect
  end
}
--
M.filterTable["filter.pixelate"] = {
  set = function(effect, value)
    if value then
      effect.numPixels = value.numPixels
    end
  end,
  get = function(value)
    local effect = {}
    effect.numPixels = value.numPixels
    return effect
  end
}
--
M.filterTable["filter.polkaDots"] = {
  set = function(effect, value)
    if value then
      effect.aspectRatio = value.aspectRatio
      effect.dotRadius = value.dotRadius
      effect.numPixels = value.numPixels
    end
  end,
  get = function(value)
    local effect = {}
    effect.aspectRatio = value.aspectRatio
    effect.dotRadius = value.dotRadius
    effect.numPixels = value.numPixels
    return effect
  end
}
--
M.filterTable["filter.posterize"] = {
  set = function(effect, value)
    if value then
      effect.colorsPerChannel = value.colorsPerChannel
    end
  end,
  get = function(value)
    local effect = {}
    effect.colorsPerChannel = value.colorsPerChannel
    return effect
  end
}
--
M.filterTable["filter.radialWipe"] = {
  set = function(effect, value)
    if value then
      effect.smoothness = value.smoothness
      effect.progress = value.progress
      effect.center = value.center
      effect.axisOrientation = value.axisOrientation
    end
  end,
  get = function(value)
    local effect = {}
    effect.smoothness = value.smoothness
    effect.progress = value.progress
    effect.center = value.center
    effect.axisOrientation = value.axisOrientation
    return effect
  end
}
--
M.filterTable["filter.saturate"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.scatter"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.sepia"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.sharpenLuminance"] = {
  set = function(effect, value)
    if value then
      effect.sharpness = value.sharpness
    end
  end,
  get = function(value)
    local effect = {}
    effect.sharpness = value.sharpness
    return effect
  end
}
--
M.filterTable["filter.sobel"] = {
  set = function(effect, value)
    if value then
    end
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["filter.straighten"] = {
  set = function(effect, value)
    if value then
      effect.height = value.height
      effect.angle = value.angle
      effect.width = value.width
    end
  end,
  get = function(value)
    local effect = {}
    effect.height = value.height
    effect.angle = value.angle
    effect.width = value.width
    return effect
  end
}
--
M.filterTable["filter.swirl"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.vignette"] = {
  set = function(effect, value)
    if value then
      effect.radius = value.radius
    end
  end,
  get = function(value)
    local effect = {}
    effect.radius = value.radius
    return effect
  end
}
--
M.filterTable["filter.vignetteMask"] = {
  set = function(effect, value)
    if value then
      effect.outerRadius = value.outerRadius
      effect.innerRadius = value.innerRadius
    end
  end,
  get = function(value)
    local effect = {}
    effect.outerRadius = value.outerRadius
    effect.innerRadius = value.innerRadius
    return effect
  end
}
--
M.filterTable["filter.wobble"] = {
  set = function(effect, value)
    if value then
      effect.amplitude = value.amplitude
    end
  end,
  get = function(value)
    local effect = {}
    effect.amplitude = value.amplitude
    return effect
  end
}
--
M.filterTable["filter.woodCut"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    return effect
  end
}
--
M.filterTable["filter.zoomBlur"] = {
  set = function(effect, value)
    if value then
      effect.intensity = value.intensity
      effect.u = value.u
      effect.v = value.v
    end
  end,
  get = function(value)
    local effect = {}
    effect.intensity = value.intensity
    effect.u = value.u
    effect.v = value.v
    return effect
  end
}

M.filterTable["generator.checkerboard"] = {
  set = function(effect, value)
    if value then
      effect.color1 = value.color1
      effect.color2 = value.color2
      effect.xStep = value.xStep
      effect.yStep = value.yStep
      -- print("---@@@@----")
      -- printTable(value.color2)
    end
  end,
  get = function(value)
    local effect = {}
    effect.color1 = value.color1
    effect.color2 = value.color2
    effect.xStep = value.xStep
    effect.yStep = value.yStep
    return effect
  end
}
--
M.filterTable["generator.lenticularHalo"] = {
  set = function(effect, value)
    if value then
      effect.seed = value.seed
      effect.aspectRatio = value.aspectRatio
      effect.posY = value.posY
      effect.posX = value.posX
    end
  end,
  get = function(value)
    local effect = {}
    effect.seed = value.seed
    effect.aspectRatio = value.aspectRatio
    effect.posY = value.posY
    effect.posX = value.posX
    return effect
  end
}
--
M.filterTable["generator.linearGradient"] = {
  set = function(effect, value)
    if value then
      effect.color1 = value.color1
      effect.color2 = value.color2
      effect.position1 = value.position1
      effect.position2 = value.position2
    end
  end,
  get = function(value)
    local effect = {}
    effect.color1 = value.color1
    effect.color2 = value.color2
    effect.position1 = value.position1
    effect.position2 = value.position2
    return effect
  end
}
--
M.filterTable["generator.marchingAnts"] = {
  set = function(effect, value)
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["generator.perlinNoise"] = {
  set = function(effect, value)
    if value then
      effect.color1 = value.color1
      effect.color2 = value.color2
      effect.scale = value.scale
    end
  end,
  get = function(value)
    local effect = {}
    effect.color1 = value.color1
    effect.color2 = value.color2
    effect.scale = value.scale
    return effect
  end
}
--
M.filterTable["generator.radialGradient"] = {
  set = function(effect, value)
    if value then
      effect.color1 = value.color1
      effect.color2 = value.color2
      effect.center_and_radiuses = value.center_and_radiuses
      effect.aspectRatio = value.aspectRatio
    end
  end,
  get = function(value)
    local effect = {}
    effect.color1 = value.color1
    effect.color2 = value.color2
    effect.center_and_radiuses = value.center_and_radiuses
    effect.aspectRatio = value.aspectRatio
    return effect
  end
}
--
M.filterTable["generator.random"] = {
  set = function(effect, value)
  end,
  get = function(value)
    local effect = {}
    return effect
  end
}
--
M.filterTable["generator.stripes"] = {
  set = function(effect, value)
    if value then
      effect.periods = value.periods
      effect.angle = value.angle
      effect.translation = value.translation
    end
  end,
  get = function(value)
    local effect = {}
    effect.periods = value.periods
    effect.angle = value.angle
    effect.translation = value.translation
    return effect
  end
}
--
M.filterTable["generator.sunbeams"] = {
  set = function(effect, value)
    if value then
      effect.seed = value.seed
      effect.aspectRatio = value.aspectRatio
      effect.posY = value.posY
      effect.posX = value.posX
    end
  end,
  get = function(value)
    local effect = {}
    effect.seed = value.seed
    effect.aspectRatio = value.aspectRatio
    effect.posY = value.posY
    effect.posX = value.posX
    return effect
  end
}
--
M.filterTable["composite.add"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.average"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.colorBurn"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.colorDodge"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.darken"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.difference"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.exclusion"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.glow"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.hardLight"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.hardMix"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.lighten"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.linearLight"] = {
  set = function(effect, value)
    if value then
      -- print(value.alpha, type(value.alpha))
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.multiply"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.negation"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.normalMapWith1DirLight"] = {
  set = function(effect, value)
    if value then
      effect.dirLightDirection = value.dirLightDirection
      effect.dirLightColor = value.dirLightColor
      effect.ambientLightIntensity = value.ambientLightIntensity
    end
  end,
  get = function(value)
    local effect = {}
    effect.dirLightDirection = value.dirLightDirection
    effect.dirLightColor = value.dirLightColor
    effect.ambientLightIntensity = value.ambientLightIntensity
    return effect
  end
}
--
M.filterTable["composite.normalMapWith1PointLight"] = {
  set = function(effect, value)
    if value then
      effect.pointLightPos = value.pointLightPos
      effect.pointLightColor = value.pointLightColor
      effect.ambientLightIntensity = value.ambientLightIntensity
      effect.attenuationFactors = value.attenuationFactors
    end
  end,
  get = function(param)
    local effect = {}
    effect.pointLightPos = value.pointLightPos
    effect.pointLightColor = value.pointLightColor
    effect.ambientLightIntensity = value.ambientLightIntensity
    effect.attenuationFactors = value.attenuationFactors
    return effect
  end
}
--
M.filterTable["composite.overlay"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.phoenix"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.pinLight"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.screen"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.softLight"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.subtract"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}
--
M.filterTable["composite.vividLight"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}

M.filterTable["composite.reflect"] = {
  set = function(effect, value)
    if value then
      effect.alpha = value.alpha
    end
  end,
  get = function(value)
    local effect = {}
    effect.alpha = value.alpha
    return effect
  end
}

return M
