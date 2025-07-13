local M ={
  audios = {class = "audio",   modify = require(kwikGlobal.ROOT.."editor.audio.audioTable").commandHandler, icons = {"addAudio", "trash"}, tool="selectAudio"},
  videos = {class = "video",   modify = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands").commandHandlerClass, icons={"repVideo", "trash"}, tool="selectTool"},
  particles = {class = "particles",   modify = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands").commandHandlerClass, icons={"repParticles", "trash"}, tool="selectTool"},
  sprites = {class = "sprite", modify = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands").commandHandlerClass, icons={"repSprite", "trash"}, tool="selectTool"},
  syncs = {class = "sync",     modify = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands").commandHandlerClass, icons={"repSync", "trash"}, tool="selectTool"},

}

return M
