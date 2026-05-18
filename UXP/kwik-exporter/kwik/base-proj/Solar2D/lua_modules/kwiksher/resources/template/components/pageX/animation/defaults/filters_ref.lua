local M = {
  -- https://docs.coronalabs.com/images/simulator/fx-base-church-comp.png
  --,
  {
    name = "filter.bloom",
    image1 = "fx-base-ocean.png",
    image2 = "fx-bloom.png"
  },
  {
    name = "filter.blur",
    image1 = "fx-base-statue.png",
    image2 = "fx-blur.png"
  },
  {
    name = "filter.blur-gaussian",
    image1 = "fx-base-statue.png",
    image2 = "fx-blurgaussian.png"
  },
  {
    name = "filter.blur-gaussian-linear",
    image1 = "fx-base-statue.png",
    image2 = "fx-blurlinear.png"
  },
  {
    name = "filter.blur-gaussian-linear-horizontal",
    image1 = "fx-base-cloth.png",
    image2 = "fx-blurlinearhorizontal.png"
  },
  {
    name = "filter.blur-gaussian-linear-vertical",
    image1 = "fx-base-cloth.png",
    image2 = "fx-blurlinearvertical.png"
  },
  {
    name = "filter.blur-horizontal",
    image1 = "fx-base-cloth.png",
    image2 = "fx-blurhorizontal.png"
  },
  {
    name = "filter.blur-vertical",
    image1 = "fx-base-cloth.png",
    image2 = "fx-blurvertical.png"
  },
  {
    name = "filter.brightness",
    image1 = "fx-base-ocean.png",
    image2 = "fx-brightness.png"
  },
  {
    name = "filter.bulge",
    image1 = "fx-base-church.png",
    image2 = "fx-bulge.png"
  },
  {
    name = "filter.chroma-key",
    image1 = "fx-base-cloth.png",
    image2 = "fx-chromakey.png"
  },
  {
    name = "filter.color-channel-offset",
    image1 = "fx-base-ocean.png",
    image2 = "fx-colorchanneloffset.png"
  },
  {
    name = "filter.color-matrix",
    image1 = "fx-base-ocean.png",
    image2 = "fx-colormatrix.png"
  },
  {
    name = "filter.color-polynomial",
    image1 = "fx-base-ocean.png",
    image2 = "fx-colorpolynomial.png"
  },
  {
    name = "filter.contrast",
    image1 = "fx-base-church.png",
    image2 = "fx-contrast.png"
  },
  {
    name = "filter.crosshatch",
    image1 = "fx-base-cloth.png",
    image2 = "fx-crosshatch.png"
  },
  {
    name = "filter.crystallize",
    image1 = "fx-base-statue.png",
    image2 = "fx-crystallize.png"
  },
  {
    name = "filter.desaturate",
    image1 = "fx-base-ocean.png",
    image2 = "fx-desaturate.png"
  },
  {
    name = "filter.dissolve",
    image1 = "fx-base-church.png",
    image2 = "fx-dissolve.png"
  },
  {
    name = "filter.duotone",
    image1 = "fx-base-flower-gray.png",
    image2 = "fx-duotone.png"
  },
  {
    name = "filter.emboss",
    image1 = "fx-base-cloth.png",
    image2 = "fx-emboss.png"
  },
  {
    name = "filter.exposure",
    image1 = "fx-base-ocean.png",
    image2 = "fx-exposure.png"
  },
  {
    name = "filter.frosted-glass",
    image1 = "fx-base-church.png",
    image2 = "fx-frostedglass.png"
  },
  {
    name = "filter.grayscale",
    image1 = "fx-base-flower.png",
    image2 = "fx-grayscale.png"
  },
  {
    name = "filter.hue",
    image1 = "fx-base-ocean.png",
    image2 = "fx-hue.png"
  },
  {
    name = "filter.invert",
    image1 = "fx-base-ocean.png",
    image2 = "fx-invert.png"
  },
  {
    name = "filter.iris",
    image1 = "fx-base-cloth.png",
    image2 = "fx-iris.png"
  },
  {
    name = "filter.levels",
    image1 = "fx-base-statue.png",
    image2 = "fx-levels.png"
  },
  {
    name = "filter.linear-wipe",
    image1 = "fx-base-cloth.png",
    image2 = "fx-linearwipe.png"
  },
  {
    name = "filter.median",
    image1 = "fx-base-ocean.png",
    image2 = "fx-median.png"
  },
  {
    name = "filter.monotone",
    image1 = "fx-base-church.png",
    image2 = "fx-monotone.png"
  },
  {
    name = "filter.op-tile",
    image1 = "fx-base-flower.png",
    image2 = "fx-optile.png"
  },
  {
    name = "filter.pixelate",
    image1 = "fx-base-statue.png",
    image2 = "fx-pixelate.png"
  },
  {
    name = "filter.polka-dots",
    image1 = "fx-base-ocean.png",
    image2 = "fx-polkadots.png"
  },
  {
    name = "filter.posterize",
    image1 = "fx-base-ocean.png",
    image2 = "fx-posterize.png"
  },
  {
    name = "filter.radial-wipe",
    image1 = "fx-base-ocean.png",
    image2 = "fx-radialwipe.png"
  },
  {
    name = "filter.saturate",
    image1 = "fx-base-flower.png",
    image2 = "fx-saturate.png"
  },
  {
    name = "filter.scatter",
    image1 = "fx-base-church.png",
    image2 = "fx-scatter.png"
  },
  {
    name = "filter.sepia",
    image1 = "fx-base-statue.png",
    image2 = "fx-sepia.png"
  },
  {
    name = "filter.sharpen-luminance",
    image1 = "fx-base-cloth.png",
    image2 = "fx-sharpenluminance.png"
  },
  {
    name = "filter.sobel",
    image1 = "fx-base-ocean.png",
    image2 = "fx-sobel.png"
  },
  {
    name = "filter.straighten",
    image1 = "fx-base-cloth.png",
    image2 = "fx-straighten.png"
  },
  {
    name = "filter.swirl",
    image1 = "fx-base-statue.png",
    image2 = "fx-swirl.png"
  },
  {
    name = "filter.vignette",
    image1 = "fx-base-church.png",
    image2 = "fx-vignette.png"
  },
  {
    name = "filter.vignette-mask",
    image1 = "fx-base-church.png",
    image2 = "fx-vignettemask.png"
  },
  {
    name = "filter.wobble",
    image1 = "fx-base-flower.png",
    image2 = "fx-wobble.png"
  },
  {
    name = "filter.wood-cut",
    image1 = "fx-base-church.png",
    image2 = "fx-woodcut.png"
  },
  {
    name = "filter.zoom-blur",
    image1 = "fx-base-cloth.png",
    image2 = "fx-zoomblur.png"
  },
  {
    name = "generator.checkerboard",
    image1 = "fx-checkerboard.png"
  },
  {
    name = "generator.lenticular-halo",
    image1 = "fx-lenticularhalo.png"
  },
  {
    name = "generator.linear-gradient",
    image1 = "fx-lineargradient.png"
  },
  {
    name = "generator.marching-ants",
    image1 = "fx-marchingants.png"
  },
  {
    name = "generator.perlin-noise",
    image1 = "fx-perlinnoise.png"
  },
  {
    name = "generator.radial-gradient",
    image1 = "fx-radialgradient.png"
  },
  {
    name = "generator.random",
    image1 = "fx-random.png"
  },
  {
    name = "generator.stripes",
    image1 = "fx-stripes.png"
  },
  {
    name = "generator.sunbeams",
    image1 = "fx-sunbeams.png"
  },
  {
    name = "composite.add",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-add.png"
  },
  {
    name = "composite.average",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-average.png"
  },
  {
    name = "composite.color-burn",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-colorburn.png"
  },
  {
    name = "composite.color-dodge",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-colordodge.png"
  },
  {
    name = "composite.darken",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-darken.png"
  },
  {
    name = "composite.difference",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-difference.png"
  },
  {
    name = "composite.exclusion",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-exclusion.png"
  },
  {
    name = "composite.glow",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-glow.png"
  },
  {
    name = "composite.hard-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-hardlight.png"
  },
  {
    name = "composite.hard-mix",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-hardmix.png"
  },
  {
    name = "composite.lighten",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-lighten.png"
  },
  {
    name = "composite.linear-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-linearlight.png"
  },
  {
    name = "composite.multiply",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-multiply.png"
  },
  {
    name = "composite.negation",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-negation.png"
  },
  {
    name = "composite.normal-map-with-1-dir-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-mapdirlight.png"
  },
  {
    name = "composite.normal-map-with-1-point-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-mappointlight.png"
  },
  {
    name = "composite.overlay",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-overlay.png"
  },
  {
    name = "composite.phoenix",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-phoenix.png"
  },
  {
    name = "composite.pin-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-pinlight.png"
  },
  {
    name = "composite.reflect",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-reflect.png"
  },
  {
    name = "composite.screen",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-screen.png"
  },
  {
    name = "composite.soft-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-softlight.png"
  },
  {
    name = "composite.subtract",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-subtract.png"
  },
  {
    name = "composite.vivid-light",
    image1 = "fx-base-church-comp.png",
    image2 = "fx-vividlight.png"
  }
}

local util = require("lib.util")

for i, v in next, M do
  local entries = util.split(v.name, "-")
  for ii, vv in next, entries do
    if ii > 1 then
      local first = vv:sub(1,1):upper()
      entries[ii] = first..vv:sub(2)
    end
  end
  M[i].name = table.concat( entries)
  -- print(M[i].name)
end

local function compare(a,b)
  return a.name < b.name
end
--
table.sort(M,compare)

return M
