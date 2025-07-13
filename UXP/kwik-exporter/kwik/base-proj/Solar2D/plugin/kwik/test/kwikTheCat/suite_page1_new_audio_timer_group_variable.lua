local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local helper = require("test.helper")

local timerTable = require("editor.timer.timerTable")
local picker = require("editor.picker.name")
local actionbox = require("editor.parts.actionbox")
local actionboxButtonContext = require("editor.parts.buttonContext")


function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  helper.init(props)

end

local book = "book"
local page = "portrait"

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  selectors.componentSelector.iconHander()
  -- selectors.componentSelector:onClick(true,  "layerTable") --isVisible = true
end

function M.setup()
end

function M.teardown()
end

function M.xtest_new_audio()

  local controller = require("editor.controller.index")
  controller.view = {UI = UI}
  selectors.componentSelector:onClick(true,  "audioTable") --isVisible = true

  -- click the icon for creatign a new audio
  UI.scene.app:dispatchEvent {
    name = "editor.selector.selectAudio",
    UI = UI,
    class = "audio",
    isNew = true, --(name ~= "Trash-icon"),
    isDelete =false -- (name == "Trash-icon")
  }

  selectors.assetsSelector:show()
  selectors.assetsSelector:onClick(true, "audios") --isVisible = true
    -- local audio_index = 1
    -- local target = selectors.assetsSelector.objs[audio_index]
    -- print(target.text)
    -- target:dispatchEvent({name="tap", target=target})

  local assetTable = require("editor.asset.assetTable")
  assetTable.objs[2]:touch({phase="ended"})


  -- local fileInSandbox = controller:renderAssets(book, page)

  --[[
    selectors.componentSelector:onClick(true,  "audioTable")
  --]]


end

--[[
  function M.test_new_group()
    selectors.componentSelector:onClick(true,  "groupTable")
  end
--]]

function M.xtest_new_timer()
  selectors.componentSelector:onClick(true,  "timerTable")
  helper.clickIconObj(timerTable, "timers-icon")
  picker:continue("timer1")

  -- timer.performWithDelay(3000, function()
  --   helper.clickProp(actionbox.objs, "onComplete")
  --   helper.clickButton("New", actionboxButtonContext)
  -- end)

--  helper.selectActionGroup("Controls")
end

function M.test_select_timer()
  selectors.componentSelector:onClick(true,  "timerTable")
  -- helper.clickIconObj(timerTable, "timers-icon")
  -- picker:continue("timer1")
end
--[[
  function M.test_new_variable()
    selectors.componentSelector:onClick(true,  "variableTable")
  end
--]]

--[[
  function M.test_new_action()
    selectors.componentSelector:onClick(true,  "actionTable")
  end
--]]

--[[
  function M.test_cacnel()
    timer.performWithDelay(1000, function()
     local button = "cancel"
      local obj = require("editor.parts.buttons").objs[button]
      obj:tap()
    end)
  end
--]]

return M
