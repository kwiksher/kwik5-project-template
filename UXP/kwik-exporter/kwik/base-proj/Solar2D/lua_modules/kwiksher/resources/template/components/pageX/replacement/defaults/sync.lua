local M = {
  name = "sync0",
  class = "sync",
  folder = "audios/sync",
  properties = {
    target = NIL,
    autoPlay     = true,
    backgroundRectAlpha = 0.4,
    backgroundRectColor = {1, 1, 1},
    delay        = 0,
    fadeDuration = 1000,
    langClassDelegate = false,
    speakerIcon  = true,
    speakerIconColor = {0,0,1},
    wordTouch    = false
  },
  actions = {onComplete = ""},
  audioProps = {
    filename = "sync/sentence.mp3",
    channel = 2,
    volume  = 10,
    folder = nil,
  },
  textProps = {
    filename        = "sync/sentence.txt",
    -- folder       = nil,
    font         = NIL,
    fontColor   = { 0,0,1 },
    fontColorHi = { 1, 1, 0 },
    fontSize    = 24,
    language    = NIL,
    padding     = 10,
    readDir     = "leftToRight",
    sentenceDir = "sync/sentence", -- wordTouch
  }
}

M.line = {
  { start =  0, out = 1000, dur = 0, name = "A", file = "a.mp3", action = "onTouch", newline=false},
  { start =  1000, out = 2000, dur = 0, name = "B", file = "b.mp3", action = "onTouch", newline=false},
  { start =  2000, out = 3000, dur = 0, name = "C", file = "c.mp3", action = "onTouch", newline=false},
}

-- M.x            = 39
-- M.y            = 300
-- M.layer        = "alphabet"

return M