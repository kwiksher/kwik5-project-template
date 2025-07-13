local M = {}
M.name = ...
M.weight = 1
---
local mui = require("materialui.mui")
local mouseHover = require("sg.btn.mouseHover") -- the plugin is activated by default.

local prevHover, hoverObj

local onMouseHover = function(event)
  -- print(event.target.hoverText)
  if hoverObj == nil and prevHover ~= event.target.hoverText then
    local textOptions = {
      --   parent = group,
      text = event.target.hoverText,
      x = event.target.x + 10,
       --display.contentCenterX,
      y = event.y ,
      width = event.target.hoverText:len() * 10,
      font = native.systemFont,
      fontSize = 12,
      align = "left" -- Alignment parameter
    }
    hoverObj = display.newText(textOptions)
    hoverObj:setFillColor(0, 0.5, 1)
    prevHover = event.target.text
    hoverObj.anchorX = 0
    timer.performWithDelay(
      500,
      function()
        hoverObj:removeSelf()
        hoverObj = nil
      end
    )
  end
  --for k, v in pairs (event.target) do print(k ,v ) end
end

function M:create(Props)
  mui.createRectButton {
    parent = mui.getParent(),
    name = Props.name,
    text = Props.text or "",
    x = Props.x or display.contentCenterX,
    y = Props.y or display.contentCenterY,
    width = Props.width or 30,
    height = Props.height or 30,
    fontSize = Props.fontSize or 30,
    iconSize = Props.iconSize or 16,
    fillColor = {0, 0, 0},
    textAlign = "center",
    iconAlign ="center",
    state = {
      value = "on",
      off = {
        textColor = {0, 0, 0, 1},
        fillColor = {0.25, 0.75, 1, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon[1] .. ".png"
      },
      on = {
        textColor = {0, 0, 0, 1},
        fillColor = {.8, .8, .8, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon[2] .. ".png"
      },
      disabled = {
        -- textColor = {.3, .3, .3, 1},
        -- fillColor = {0.3, 0.3, 0.3, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon[3] .. ".png"
      }
    },
    callBack = Props.listener -- do not like wheel picker on native device.
  }
  local obj = mui.getWidgetBaseObject(Props.name)
  --obj:addEventListener("mouseHover", onMouseHover)
  obj.anchorY = 0
  obj.name = Props.name
  obj.callBack = Props.listener
  obj.muiOptions = {name= Props.name}

  return obj
end

function M:destroy(name)
  mui.removeRectButton(name)
end

function M:createImage(Props)
  mui.createRectButton {
    parent =  Props.parent or mui.getParent(),
    name = Props.name,
    text = Props.text or "",
    x = Props.x or display.contentCenterX,
    y = Props.y or display.contentCenterY,
    width = Props.width or 16,
    rectWidth = 100,
    height = Props.height or 16,
    fontSize = Props.fontSize or 16,
    iconSize = Props.iconSize or 16,
    fillColor = {0, 0, 0},
    textAlign = "center",
    iconAlign = Props.iconAlign or "left",
    state = {
      value = "on",
      off = {
        textColor = {0, 0, 0, 1},
        fillColor = {1, 1, 1, 1}, --fillColor = {0.25, 0.75, 1, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon .. "_over.png"
      },
      on = {
        textColor = {0, 0, 0, 1},
        fillColor = Props.fillColor or {.8, .8, .8, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon .. "Color.png"
      },
      disabled = {
        textColor = {.3, .3, .3, 1},
        fillColor = {0.3, 0.3, 0.3, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon .. ".png"
      }
    },
    callBack = Props.listener -- do not like wheel picker on native device.
  }
  local obj = mui.getWidgetBaseObject(Props.name)
  obj.name = Props.name
  --obj:addEventListener("mouseHover", onMouseHover)
  obj.anchorY = 0
  obj.callBack = Props.listener
  obj.muiOptions = {name= Props.name}

  return obj
end

function M:createToolImage(Props)
  mui.createRectButton {
    parent = Props.parent or mui.getParent(),
    name = Props.name,
    text = Props.text or "",
    x = Props.x or display.contentCenterX,
    y = Props.y or display.contentCenterY,
    width = Props.width or 30,
    rectWidth = 100,
    height = Props.height or 30,
    fontSize = Props.width or 30, -- this fontSize is also applied to the image size
    iconSize = Props.iconSize or 16,
    fillColor = {0, 0, 0},
    textAlign = "center",
    iconAlign ="center",
    state = {
      value = "on",
      off = {
        textColor = {0, 0, 0, 1},
        fillColor = {0.25, 0.75, 1, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon .. ".png"
      },
      on = {
        textColor = {0, 0, 0, 1},
        fillColor = {1, 1, 1, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon .. "Color_over.png"
      },
      disabled = {
        textColor = {.3, .3, .3, 1},
        fillColor = {0.3, 0.3, 0.3, 1},
        iconImage = kwikGlobal.PATH.."../resources/images/icons/" .. Props.icon .. "_over.png"
      }
    },
    callBack = Props.listener -- do not like wheel picker on native device.
  }
  local obj = mui.getWidgetBaseObject(Props.name)
  obj.hoverText = Props.hoverText
  obj.anchorY = 0
  obj:addEventListener("mouseHover", onMouseHover)
  obj.callBack = Props.listener
  obj.muiOptions = {name= Props.name}
  return obj
end

M.new = function()
  local instance = {}
  return setmetatable(instance, {__index = M})
end
--
return M
