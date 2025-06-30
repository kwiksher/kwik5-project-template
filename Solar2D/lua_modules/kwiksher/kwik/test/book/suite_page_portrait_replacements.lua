local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local bookName = "bookFree"
local pageName = "page_protrait"

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  UI.scene.app:dispatchEvent {
    name = "editor.selector.selectApp",
    UI = UI
  }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book=bookName}, nil,  true)
  pageTable.commandHandler({page=pageName},nil,  true)
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true,  "layerTable")


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

function M.xtest_select_layer_gotoBtn()
  local name = "gotoBtn"
  for i, entry in next,layerTable.objs do
    print("", i, entry.text)
    if entry.text == name then
      entry:touch({phase="ended"}) -- gotoBtn
      break
    end
  end
end

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

function M.test_select_layer_video()
  local name = "imageOne"
  for i, entry in next,layerTable.objs do
    print("", i, entry.text)
    if entry.text == name then
      for j, e in next, entry.classEntries do
        if e.text == "video" then
          print("", "touched", e.text)
          e:touch({phase="ended"})
          break
        end
      end
      break
    end
  end
  --
  -- local button = "save"
  -- local obj = require("editor.parts.buttons").objs[button]
  -- obj:tap()
end

function M.test_new_spritesheet()
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = "spritesheet", -- obj.class,
      -- toolbar = self,
      isNew = true
    }
  )
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


return M
