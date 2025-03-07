local name = ...
local parent,root = newModule(name)

local M = {
  name = "{{layer}}", -- {{name}}
  layer = "{{name}}",
  class = "sync",
  folder = "sync",
  properties = {
    {{#properties}}
    target       = "{{target}}",
    autoPlay     = {{autoPlay}},
    delay        = {{delay}},
    fadeDuration = {{fadeDuration}},
    speakerIcon = {{speakerIcon}},
    wordTouch   = {{wordTouch}},
    {{/properties}}
  },
  audioProps = {
    {{#audioProps}}
    filename    = "{{filename}}",
    channel      = {{channel}},
    volume      = {{volume}},
    {{/audioProps}}
  },
  textProps = {
    {{#textProps}}
    folder       = nil,
    font         = "{{font}}",
    fontColor   = { {{fontColor}} },
    fontColorHi = { {{fontColorHi}} },
    fontSize    = {{fontSize}},
    language    = "{{language}}",
    padding     = {{padding}},
    readDir     = "{{readDir}}",
    sentenceDir = "{{sentenceDir}}", -- wordTouch
    {{/textProps}}
  },
  actions = {onComplete = "{{onComplete}}"},

}

M.line = {
  {{#line}}
  {
    name = "{{name}}",
    out = {{out}},
    start = {{start}},
    file = "{{file}}",
    action = "{{action}}",
    dur = {{dur}}
  },
  {{/line}}
}
--
return require("components.kwik.layer_sync").set(M)

--[[
local M = {
  name = "alphabet",
  filename = "alphabet.mp3",
  type = "sync",
  autoPlay = true,
  channel = 2
}

M.line = {
  { start =  0, out = 1000, dur = 0, name = "A", file = "a.mp3", action = "onComplete"},
  { start =  1000, out = 2000, dur = 0, name = "B", file = "b.mp3", action = "onComplete"},
  { start =  2000, out = 3000, dur = 0, name = "C", file = "c.mp3", action = "onComplete"},
}

M.x            = 39
M.y            = 300
M.padding      = 10
-- M.font         = nil
M.fontSize     = 36
M.fontColor    = {1,1,1}
M.fontColorHi  = {1,1,0}
M.fadeDuration = 0
M.wordTouch    = true
M.sentenceDir  = "alphabet" -- wordTouch
M.readDir      = "leftToRight"
M.channel      = 1
M.layer        = "alphabet"
--
-- M.volume = 10
-- M.delay  = nil
--]]
