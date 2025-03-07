local M = {
  name = "sprite",
  class = "sprite",
  properties = {
    sheetType  = "uniform-sized", -- TexturePacker, Animate
    filename = "imagesheet.png",
    sheetInfo = NIL,
    sheetContentWidth  = 376, -- same size or loaded from sheetInfo
    sheetContentHeight = 188, -- same size or loaded from sheetInfo
    numFrames          = 2,   -- same size or loaded from sheetInfo
    width              = 188, -- same size, disable for TP, Aniamte
    height             = 188, -- same size, disable for TP, Animate
  },
  sequenceData = {
    {
        name = "default",
        count = 2,
        loopCount = 0,
        loopDirection = "forward", -- reverse after last frame
        pause = false,
        start = 1,
        time = 1000,
    },
    {
      name = "test",
      frames = {1,2},
      loopCount = 0,
      loopDirection = "forward", -- reverse after last frame
      pause = false,
      time = 1000,
   }
  },
  actions = {
    actionName = "",
  }
    -- event.phase
      -- began
      -- ended
      -- bounce — The animation bounced from forward to backward while playing.
      -- loop — The animation looped from the beginning of the sequence.
      -- next - The animation played a subsequent frame that's not one of the above phases.
}

return M

--[[

http://kwiksher.com/doc/kwik_tutorial/animations/working_with_spritesheet/

https://github.com/CodeAndWeb/TexturePacker-Corona-ImageSheets

https://docs.coronalabs.com/guide/media/spriteAnimation/index.html#spriteobjects
  See frames or start&count

  {
    imageWidth = 220,
    imageHeight = 205,
    --
    options = {
      width = 188,
      height = 188,
      numFrames = 2,
      sheetContentWidth = 376,
      sheetContentHeight = 188
    },
    imageWidth = options.width,
    imageHeight = options.height,
    --
    sheet = graphics.newImageSheet(_K.spriteDir .. "butflysprite.png", _K.systemDir, options),
    sequence = {
      {
        name = "default",
        start = 1,
        count = 2,
        time = 1000,
        loopCount = 0,
        loopDirection = "forward"
      }
    }
  }


    -- sequences table
  local sequences_runningCat = {
      -- non-consecutive frames sequence
      {
          name = "fastRun",
          frames = { 1,3,5,7 },
          time = 400,
          loopCount = 0,
          loopDirection = "forward"
      }
  }

  local sheetInfo = require("spritesheet")

  local myImageSheet = graphics.newImageSheet( "spritesheet.png", sheetInfo:getSheet() )

  local sequenceData = {
				-- set up anmiation
                {
                	name="walk", 		-- name of the animation (used with setSequence)
                	sheet=myImageSheet, -- the image sheet
                	start=sheetInfo:getFrameIndex("capguy/walk/0001"), -- name of the first frame
                	count=8, 			-- number of frames
                	time=1000, 			-- speed
                	loopCount=0 		-- repeat
               	},
            }
--]]