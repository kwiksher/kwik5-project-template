local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local bookName = "book" -- "bookTest01"
local pageName = "page1"
local listbox = require("editor.replacement.listbox")
local listPropsTable = require("editor.replacement.listPropsTable")

local helper = require("test.helper")
local classProps = require("editor.parts.classProps")
local assetTable = require("editor.asset.assetTable")
local listButtons = require("editor.replacement.listButtons")

function M.init(props)
  selectors = props.selectors
  UI = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  -- bookTable.commandHandler({book=bookName}, nil,  true)
  -- pageTable.commandHandler({page=pageName},nil,  true)
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true, "layerTable")
end

function M.setup()
end

function M.teardown()
end

-- video
--  spritesheet
--  particles
--  canvas
--  sync

function M.xtest_new_video()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "video", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )
end

function M.xtest_new_spritesheet()
  local function steps()
    helper.selectLayer("starfish")
    helper.selectIcon("Replacements", "Sprite")

    coroutine.yield()

    helper.clickProp(classProps.objs, "_filename")
    helper.clickAsset(assetTable.objs, "sprites/SpriteTiles/sprites.png")
    helper.setProp(classProps.objs, "numFrames", 64)
    -- this calculates w, h of sprite
    helper.clickProp(classProps.objs, "_filename")

    coroutine.yield()

    local obj = helper.getObj(listbox.objs, "default")
    listbox.singleClickEvent(obj)

    coroutine.yield()

    -- local rnd = math.random(1, 16)
    local rnd = 1
    helper.setProp(listPropsTable.objs, "start", (rnd * 4) - 3)
    helper.setProp(listPropsTable.objs, "count", 4)
    helper.setProp(listPropsTable.objs, "time", 600)
    helper.setProp(listPropsTable.objs, "loopCount", "")

    coroutine.yield()

    --
    rnd = string.format("%02d", rnd)
    helper.setProp(listPropsTable.objs, "name", "tile_" .. rnd)

    coroutine.yield()

    obj = helper.getObj(listButtons.objs, "Preview")
    obj:tap()

    coroutine.yield()

    -- obj = helper.getObj(listButtons.objs, "Save")
    -- obj:tap()
  end

  local co = coroutine.create(steps)
  timer.performWithDelay(
    1000,
    function()
      coroutine.resume(co)
    end,
    7
  )
end

function M.xtest_new_spritesheet_sheetInfo_Animate()
  local cnt = 0

  local function steps()
    helper.selectLayer("starfish")
    helper.selectIcon("Replacements", "Sprite")

    coroutine.yield()

    helper.clickProp(classProps.objs, "sheetInfo")
    helper.clickAsset(assetTable.objs, "sprites/girlBicyle.png")
    --helper.setProp(classProps.objs, "numFrames", 64)
    -- this calculates w, h of sprite
    --helper.clickProp(classProps.objs, "_filename")
    coroutine.yield()

    local obj = helper.getObj(listbox.objs, "default")
    listbox.singleClickEvent(obj)

    coroutine.yield()

    -- local rnd = math.random( 1,16 )
    -- helper.setProp(listPropsTable.objs, "start",  (rnd * 4) - 3)
    helper.setProp(listPropsTable.objs, "count", 48)

    coroutine.yield()

    -- helper.setProp(listPropsTable.objs, "time", 600)
    helper.setProp(listPropsTable.objs, "loopCount", "")

    coroutine.yield()
    -- --
    -- rnd = string.format( "%02d", rnd )
    -- helper.setProp(listPropsTable.objs, "name", "tile_"..rnd)

    obj = helper.getObj(listButtons.objs, "Preview")
    -- obj = helper.getObj(listButtons.objs, "Save")
    obj:tap()
  end

  local co = coroutine.create(steps)

  timer.performWithDelay(
    1000,
    function()
      coroutine.resume(co)
    end,
    6
  )
end

function M.xtest_new_spritesheet_sheetInfo()
  helper.selectLayer("starfish")
  helper.selectIcon("Replacements", "Sprite")

  helper.clickProp(classProps.objs, "sheetInfo")
  helper.clickAsset(assetTable.objs, "sprites/slots.png")
  --helper.setProp(classProps.objs, "numFrames", 64)
  -- this calculates w, h of sprite
  --helper.clickProp(classProps.objs, "_filename")

  local obj = helper.getObj(listbox.objs, "default")
  listbox.singleClickEvent(obj)

  -- local rnd = math.random( 1,16 )
  -- helper.setProp(listPropsTable.objs, "start",  (rnd * 4) - 3)
  helper.setProp(listPropsTable.objs, "count", 16)
  -- helper.setProp(listPropsTable.objs, "time", 600)
  -- helper.setProp(listPropsTable.objs, "loopCount", "")
  -- --
  -- rnd = string.format( "%02d", rnd )
  -- helper.setProp(listPropsTable.objs, "name", "tile_"..rnd)

  --obj = helper.getObj(listButtons.objs, "Preview")
  obj = helper.getObj(listButtons.objs, "Save")
  obj:tap()

  local controller = require("editor.replacement.controller.index")
  local props = controller:useClassEditorProps(UI)
end

---[[
function M.xtest_new_sync()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "sync", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )
end
--]]

---[[
function M.xtest_new_sync_add_save()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "sync", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )

  UI.scene.app:dispatchEvent(
    {
      name = "editor.replacement.list.add",
      UI = UI,
      type = "line", -- for sync,
      index = 3 -- number of entries
    }
  )

  local listPropsTable = require("editor.replacement.listPropsTable")
  -- name props
  listPropsTable.objs[1].field.text = "myName"
  -- start
  listPropsTable.objs[2].field.text = "3000"

  UI.scene.app:dispatchEvent(
    {
      name = "editor.replacement.list.save",
      UI = UI,
      class = "sync", -- obj.class,
      index = 4
    }
  )
end
--]]

---[[
function M.xtest_new_canvas()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "canvas", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )
end
--]]

---[[
function M.xtest_new_particles()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "particles", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )
end
--]]

function M.xtest_util()
  local json = require("json")
  local scene = {
    components = {
      layers = {
        {
          back = {}
        },
        {butBlue = {class = {"button"}}},
        {
          groupOne = {}
        }
      },
      audios = {},
      groups = {
        {groupC = {}}
      },
      timers = {},
      variables = {},
      others = {}
    },
    commands = {"blueBTN"},
    onInit = function(scene)
      print("onInit")
    end
  }

  local util = require("editor.util")
  local updatedModel = util.updateIndexModel(scene, "back", "sprite")
  print(json.encode(updatedModel))

  local renderdModel = util.createIndexModel(updatedModel)
  print(json.encode(renderdModel))

  local controller = require("editor.controller.index")
  controller:renderIndex("book", "page1", renderdModel)
end

return M
