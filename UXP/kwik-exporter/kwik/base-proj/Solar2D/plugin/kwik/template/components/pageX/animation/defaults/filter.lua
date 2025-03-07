local M = {
  name = "filter",
  class = "Filter",
  properties ={
    target     = NIL,
    type    = NIL, -- group, page, sprite
    animation  = false,
    delay      = 0,
    duration   = 1000,
    autoPlay   = true,
    loop       = 1,        -- 0 to play once
    easing     = "inQuad",
    reverse    = nil,
    resetAtEnd = nil,
  },
  -- composite = {
  --   effect   = "composite.normalMapWith1PointLight",
  --   type      = "composite"
  --   paint1 = "image01.png",
  --   paint2 = "texture.png",
  --   folder = NIL,
  -- },
  filter = {
    effect = "bloom",
    type   = "filter"

  } ,
  -- generator = {
  --   effect = "checkerboard",
  --   type   = "generator"
  -- } ,
  actions = {onComplete = NIL},
}
--
M.filterTable = {}
--

local getFilterParams = require("editor.animation.filterProps").getFilterParams

--
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
      end
    end,
    get = function()
        if M.effect == nil then
          local params = getFilterParams("filter.bloom")
          local effect = {}
          effect.levels = {}
          effect.blur  = {vertical={}, horizontal = {}}
          effect.add = {}
          effect.levels.gamma             = params.levels.gamma
          effect.levels.black             = params.levels.black
          effect.levels.white             = params.levels.white
          effect.blur.vertical.blurSize   = params.blur.vertical.blurSize
          effect.blur.vertical.sigma      = params.blur.vertical.sigma
          effect.blur.horizontal.blurSize = params.blur.horizontal.blurSize
          effect.blur.horizontal.sigma    = params.blur.horizontal.sigma
          effect.add.alpha                = params.add.alpha
          M.effect = effect
        end
        return M.effect
    end
}

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
      if M.effect == nil then
        local params = getFilterParams("composite.normalMapWith1PointLight")
        local effect = {}
        effect.pointLightPos      =  {}
        effect.pointLightColor    =  {}
        effect.attenuationFactors = {}
        effect.pointLightPos ={
          params.pointLightPos[1],
          params.pointLightPos[2],
          params.pointLightPos[3]
        }
        effect.pointLightColor = {
           params.pointLightColor[1],
           params.pointLightColor[2],
           params.pointLightColor[3],
           params.pointLightColor[4]
         }
        effect.ambientLightIntensity = params.ambientLightIntensity
        effect.attenuationFactors = {
          params.attenuationFactors[1],
          params.attenuationFactors[2],
          params.attenuationFactors[3],
        }
        M.effect = effect
      end
      return M.effect
    end
}

M.filterTable["generator.checkerboard"] = {
  set = function(effect, value)
    if value then
      effect.color1 = value.color1
      effect.color2 = value.color2
      effect.xStep  = value.xStep
      effect.yStep  = value.yStep
     end
  end,
  get = function()
    if M.effect == nil then
      local params = getFilterParams("generator.checkerboard")
        local effect = {}
      effect.color1 = {
        params.color1[1],
        params.color1[2],
        params.color1[3],
        params.color1[4]
      }
      effect.color2 = {
        params.color2[1],
        params.color2[2],
        params.color2[3],
        params.color2[4]
      }
      effect.xStep  = params.xStep
      effect.yStep  = params.yStep
      M.effect = effect
    end
    return M.effect
  end
}

M.filter.params = M.filterTable[M.filter.type.."."..M.filter.effect].get()
return M