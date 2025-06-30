local M = {}
--
local widget = require("widget")
local app = require "Application"


--
function M:createButton(UI)
  local sceneGroup = UI.sceneGroup
  local layerName = self.properties.target
  local obj = sceneGroup[layerName]
  local props = self.properties
  -- print(self.properties.target, props.eventType)
  if props.type ~= "group" and props.eventType == "touch"   then
      local function onReleaseHandler(event)
         print("onReleaseHandler")
          if event.target.enabled == nil or event.target.enabled then
              event.target.type = "touch"
              if self.TV then
                  if event.target.isKey then
                      UI.scene:dispatchEven{name = self.actions.onTap, event = event}
                  end
              else
                  -- print("###", self.actions.onTap)
                  UI.scene:dispatchEvent{name = self.actions.onTap, event = event}
              end
          end
      end

      -- local path1 = system.pathForFile( UI.props.imgDir ..self.layerProps.imagePath, system.ResourceDirectory)
      -- local path2 = system.pathForFile( UI.props.imgDir ..UI.page.."/"..props.over..".png", system.ResourceDirectory)

      local path1 =  UI.props.imgDir ..UI.page.."/"..self.layerProps.name.."."..self.layerProps.type
      local path2
      if type(props.over) == "string" and props.over ~="NIL" then
        path2 = UI.props.imgDir ..UI.page.."/"..props.over..".png"
      end

      -- print(path1)
      -- print(path2)

      if path1 then
        -- print("------- widget.newButton")
        local posX, posY = obj.x, obj.y
        local alpha = obj.alpha
        obj.alpha = 0 -- remove?

        obj =
            widget.newButton {
            id          = self.name,
            defaultFile = path1,
            overFile    = path2,
            width       = self.layerProps.imageWidth,
            height      = self.layerProps.imageHeight,
            onRelease   = onReleaseHandler,
            baseDir     =  system.ResourceDirectory, -- UI.props.systemDir
        }
        --
        if obj == nil then
          print ("@@@@ Error create widget @@@@", path1, path2)
        end
        obj.x, obj.y  = posX, posY
        obj.alpha = alpha
        sceneGroup:insert(obj)
        sceneGroup[self.name] = obj
        obj.on = onReleaseHandler
      else
          print ("@@@@ Error@@@@", path1, path2)
      end
  end
    --
    -- kwik5/templates/Solar2D/scenes/pageXXX/images/image_renderer.lua
    --   for instance  obj.enterFrame = infinityBack
    --
    --   setImage(obj, model) then
    --

  if props.mask:len() > 0 and props.mask~="NIL" then
      local path = system.pathForFile(  UI.props.imgDir ..UI.page.. "/"..props.mask..".png", system.ResourceDirectory)
      if path then
        -- print( UI.props.imgDir ..UI.page.. "/"..props.mask)
        local mask = graphics.newMask( UI.props.imgDir ..UI.page.."/".. props.mask..".png", UI.props.systemDir)
        obj:setMask(mask)
      end
  end

  local sceneGroup = UI.sceneGroup
  local layers = UI.layers

  if self.buyProductHide then
    local storeModel = require(kwikGlobal.ROOT.."components.store.model")
    local IAP = require(kwikGlobal.ROOT.."components.store.IAP")
    local view = require(kwikGlobal.ROOT.."components.store.view").new()

      -- Page properties
      view:init(sceneGroup, layers)
      IAP:init(
          storeModel.catalogue,
          view.restoreAlert,
          view.purchaseAlert,
          function(e)
              print("IAP cancelled")
          end,
          storeModel.debug
      )
  end

  return obj
end

function M:init()
end
--
--

function M:addEventListener(UI)
    local sceneGroup = UI.sceneGroup
    local layers = UI.layers
    local props = self.properties
    local actions = self.actions
    local layerName = props.target

    -- Tap
    if props.eventType  == "tap" and props.btaps and sceneGroup[layerName] then
      -- print("addEventListener forbtaps", layerName, props.btaps)
        --
        local obj = sceneGroup[layerName]
        local eventName = actions.onTap
        -- print(layerName, obj)
        if obj.tap == nil then
          function obj:tap(event)
            -- print("tap")
            event.UI = UI
            if props.enabled or props.enabled == nil then
              if props.btaps and event.numTaps then
                if event.numTaps == props.btaps then
                  -- print("tap", eventName)
                    UI.scene:dispatchEvent({name=eventName, event = event})
                end
              else
                -- print("###", eventName)
                    UI.scene:dispatchEvent({name=eventName, event = event})
              end
            end
          end
        end
        -- print("@@@addEventListener")
        obj:addEventListener("tap",obj)
    end
    --
    if props.buyProductHide then
      local IAP = require(kwikGlobal.ROOT.."components.store.IAP")
        --Hide button if purchase was already made
        if IAP.getInventoryValue("unlock_" .. props.product) then
            --This page was purchased, do not show the BUY button
            sceneGroup[layerName].alpha = 0
        end
    end
end
--
function M:removeEventListener(UI)
    local layers = UI.layers
    local sceneGroup = UI.sceneGroup
    local props = self.properties
    local layerName = props.target
    -- Tap
    if props.btaps and sceneGroup[layerName] then
      local obj = sceneGroup[layerName]
      obj:removeEventListener("tap", obj)
    end
end
--
function M:destroy(UI)
end

M.set = function(model)
  return setmetatable( model, {__index=M})
end

--
return M
