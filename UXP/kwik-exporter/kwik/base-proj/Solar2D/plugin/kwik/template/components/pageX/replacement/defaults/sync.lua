local M = {
  name = "alphabet",
  class = "sync",
  folder = "audios/sync",
  properties = {
    autoPlay     = true,
    delay        = NIL,
    fadeDuration = 1000,
    speakerIcon  = true,
    wordTouch    = true
  },
  actions = {onComplete = ""},
  audioProps = {
    filename = "alphabet.mp3",
    channel = 2,
    volume      = 10,
    folder = nil,
  },
  textProps = {
    filename        = "alphabet.txt",
    -- folder       = nil,
    font         = NIL,
    fontColor   = { 0,0,1 },
    fontColorHi = { 1, 1, 0 },
    fontSize    = 36,
    language    = NIL,
    padding     = 10,
    readDir     = "leftToRight",
    sentenceDir = "alphabet", -- wordTouch
  }
}

M.line = {
  { start =  0, out = 1000, dur = 0, name = "A", file = "a.mp3", action = "onTouch"},
  { start =  1000, out = 2000, dur = 0, name = "B", file = "b.mp3", action = "onTouch"},
  { start =  2000, out = 3000, dur = 0, name = "C", file = "c.mp3", action = "onTouch"},
}

-- M.x            = 39
-- M.y            = 300
-- M.layer        = "alphabet"

return M