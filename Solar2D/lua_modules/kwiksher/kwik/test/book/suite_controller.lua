local M = {}

function _suite_setup()
	controller = require "editor.controller.index"
  files = {}
  updatedScene = nil
end

function _setup()
  book = "book"
  page = "page1"
  tool = "interaction"
  layer = "butWhite"  -- Update scenes.components.layers.butWhite with the props
  class = "button"
  props = {name="helloBTN", class="button", kind="tap", actionName = "onClick", over="helloOver", btaps = 1, mask=""}
  scene = {
    name = "canvas",
    components = {
      layers = {
          {  back={
                            } },
          {  butBlue={ class={"button"}, {A={}}, {B={class={"animation"}}}
                             } },
          {  butWhite={
                            } },
      },
      audios = {  },
      groups = {  },
      timers = {  },
      variables = {  },
      others = {  }
     },
    commands = { "blueBTN" },
    onInit = function(scene) print("onInit") end
  }
end

function M.teardown()
end

function M.suite_setup()
end

function M.setup()
end


function M.test_sceneCollection()
  local composer = require("composer")
  local name = "sceneCollection"
  local collection = require("controller.sceneCollection").new()
  composer.gotoScene( "sceneCollection",  {effect = "flip", time = 1000})
end

function xtest_render()
	local dst = controller:render(book, page, layer, tool, class, props)
	assert_string(dst, "fail")
  --
  local path = system.pathForFile(dst, system.TemporaryDirectory )
  local file = io.open( path, "r" )
  assert_userdata(file, "fail")
  files[#files + 1] = dst
end

function xtest_1_save()
  local dst = controller:save(book, page, layer,tool, nil, props )
	assert_string(dst, "fail")
  --
  local path = system.pathForFile(dst, system.TemporaryDirectory )
  local file = io.open( path, "r" )
  assert_userdata(file, "fail")
  files[#files + 1] = dst
end

function xtest_2_updateIndexModel()
  local util = require("editor.util")
  local json = require("json")
  local updated = util.createIndexModel(scene, layer, class)
  -- for k, v in pairs(updated.components.layers[2].layers[1]) do print(k, v) end
  --  print("###",json.encode(updated))
  updatedScene = updated
  -- print("###", updatedScene)

  --  print("##",json.encode(updated), updated.components.layers[3].butWhite.class[1])
  -- assert_true(updated.components.layers[3].class[1] == "button")
end

function xtest_2_renderIndex()
  print("###", updatedScene)
	local dst = controller:renderIndex(book, page, layer, tool, class,updatedScene)
	assert_string(dst, "fail")
  --
  local path = system.pathForFile(dst, system.TemporaryDirectory )
  local file = io.open( path, "r" )
  assert_userdata(file, "fail")
  files[#files + 1] = dst
end

function xtest_3_saveIndex()
  local dst = controller:saveIndex(book, page, layer, class, scene )
	assert_string(dst, "fail")
  --
  local path = system.pathForFile(dst, system.TemporaryDirectory )
  local file = io.open( path, "r" )
  assert_userdata(file, "fail")
  files[#files + 1] = dst
end

function xtest_4_copyFiles()
  local commands = require("editor.scripts.commands")
  print(#files)
  assert_true(#files == 4, "fail")
  commands.copyFiles(files, "tmp")
end

function xtest_selectFromIndexModel()
  local util = require("editor.util")
  util.selectFromIndexModel(scene, {"butBlue"})
  -- util.selectFromIndexModel(scene, {"butBlue", "button"})
  -- util.selectFromIndexModel(scene, {"butBlue", "A"})
  -- util.selectFromIndexModel(scene, {"butBlue", "B"})
  -- util.selectFromIndexModel(scene, {"butBlue", "B", "animation"})
end

function xtest_4_renamePage()
  local commands = require("editor.scripts.commands")
  commands.renamePage("book", "page1", "page01")
  native.requestExit() -- this prevents from infinitly looping of simulator reloading
end

function xtest_4_copyPage()
  local commands = require("editor.scripts.commands")
  commands.copyPage("book", "page1", "page01")
  native.requestExit() -- this prevents from infinitly looping of simulator reloading
end

function xtest_createLayer()
  local commands = require("editor.scripts.commands")
  commands.createLayer("book", "page1", 1, "layerOne")
end

return M