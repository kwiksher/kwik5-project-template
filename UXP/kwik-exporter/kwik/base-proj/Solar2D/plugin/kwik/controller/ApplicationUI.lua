local M = {}

--local Application = require("Application")
local handlerCommon = require(kwikGlobal.ROOT.."controller.commonComponentHandler")
local handlerScene = require(kwikGlobal.ROOT.."controller.sceneHandler")
local handlerComponent = require(kwikGlobal.ROOT.."controller.componentHandler")
local handlerComponentLocal = require(kwikGlobal.ROOT.."controller.componentLocalHandler")
--
local uiHandler = require("App.uiHandler")
local bookstore = require("App.bookstore")

function M.create(scene, model)
    local UI = {}
    UI.scene            = scene
    UI.sceneGroup       = display.newGroup()
    UI.commmonHandler = handlerCommon.new(UI)
    UI.sceneHandler = handlerScene.new(UI)
    UI.componentHandler = handlerComponent.new(UI)
    UI.componentLocalHandler = handlerComponentLocal.new(UI)
    --UI.currentBook       = model.appName
    --print("0000000000000000", UI.currentBook)
    UI.page              = model.page
    UI.curPage           = model.pageNum
    -- All components on a table
    UI.props = {}  -- this is appProps. This is set when scene.book01.index is created in ApplicationContext.lua
    UI.layers = {}
    -- All audio files on a table
    UI.audios           = {}
    UI.videos           = {}
    UI.audios.kAutoPlay = 0
    UI.animations       = {}
    UI.dynamictexts      = {}
    UI.variables        = {}
    UI.groups           = {}
    UI.joints           = {}
    UI.timers           = {}
    UI.tSearch          = nil
    UI.lang             = ""
    UI.langClassDelegate = true

    ---
    function UI:dispatchEvent(params)
      params.name = self.page .."."..params.name
     self.scene.app:dispatchEvent(params)
    end
    ---
    --UI.numberOfPages         = #Application.scenes -- number of pages in the project
    --
    function UI:setLanguge()
      if self.props.lang == nil then self.props.lang = "" end
      -- Language switch
      --if (self.props.lang == "en") then self.tSearch = self.taben end
      -- Language switch
      --if (self.props.lang == "jp") then self.tSearch = self.tabjp end
      self.lang = self.props.lang
      -- print("setLanguage", self.lang, self)
    end

    function UI:getNameByLang(name)
      if self.langClassDelegate then
        local t = name:split("/")
        return t[1].."/".. self.lang
      end
      return name
    end

    function UI:getNameClassByLang(name)
      if self.langClassDelegate then
        local t = name:split("/")
        return t[1].."/".. self.lang..t[2]:sub(3)
      end
      return name
    end

    function UI:getAnimation(name)
      -- print(self:getNameClassByLang(name))
      return self.animations[self:getNameClassByLang(name)]
    end

    function UI:getVariable(name)
      return self.variables[name]
    end

    function UI:setVariable(name, value)
      self.variables[name] = value
    end


    local function callComponentsLayersHandler(models, handler, funcName)
        -- print("callComponentsLayersHandler")
        local json = require("json")
        -- print(json.prettify(models))
        local function iterator(handler, parent, layers, path, isLang)
            --print("callComponentsLayersHandler", #layers)
            local classEntries = {}
            if type(layers) == "table" then
                local parentPath = path or ""
                local firstEntry = {}
                for i = 1, #layers do  -- { {childOne = {}}, {childTwo={class={"linear"}}, {childThree = {{childFour={}}}} }
                    local layer = layers[i]
                    for name, value in pairs(layer) do  --
                        --  print("", name)
                        --  print("", "type", type(value), #value)
                        if type(value)=="table" and #value > 0 then
                          if funcName == "_init" then
                            handler[funcName](handler, nil,
                                            parentPath .. name .. ".index", false, value) -- value is array of children
                          else
                            handler[funcName](handler, nil,
                                            parentPath .. name .. ".index", false)
                          end

                          --
                          -- {index = { class = "lang"}, {ch1={}}, {ch2={}}, {ch3={}}}
                          local isLang = nil
                          if value.class then -- let's delegate
                            for k, class in pairs(value.class) do
                              -- print("", class, parentPath .. name)
                              -- table.insert(classEntries, {
                              --   class = class,
                              --   path = parentPath .. name  -- see sceneHandler.lua, it splits to load layer_linear.lua by split('.')
                              --  })
                               if class == "lang" then
                                isLang = true
                                print("@@@@ isLang", UI.lang)
                                if UI.lang == nil or UI.lang == "" then
                                  native.showAlert("Waning", "main.lua needs a default lang code like 'en'")
                                end
                               end
                              -- handler[funcName](handler, class, parentPath .. name..".index", false)
                            end
                          end

                          local ret = iterator(handler, name, value, -- value is array of children
                                                  parentPath .. name .. ".",  isLang)

                          -- for j = 1, #ret do
                          --     handler[funcName](handler, ret[j].class, ret[j].path, false)
                          -- end
                        elseif isLang then
                          -- print("@@", name, UI.lang)
                          if i==1 then
                            firstEntry.name = name
                            firstEntry.class = value.class
                          end
                          --
                          if UI.lang ==name then
                            --print("@@", UI.lang, parentPath .. name)
                            handler[funcName](handler, nil, parentPath .. name, false)
                            if UI.langClassDelegate and firstEntry.class then
                              for i, class in next, firstEntry.class do
                                -- print("",class, parentPath..firstEntry.name)
                                handler[funcName](handler, class, parentPath .. firstEntry.name, false)
                              end
                            elseif value.class and value.class:len() > 0  then
                              for i, class in next, value.class do
                                handler[funcName](handler, class, parentPath .. name, false)
                              end
                            end
                          end
                        else

                          local isIndex = function (value)
                            for k, v in pairs(value) do
                              if k ~= "class" then
                                return true
                              end
                            end
                            return false
                          end
                          -- print("@@", isLang, parentPath .. name)
                          if isIndex(value) then
                            handler[funcName](handler, nil, parentPath .. name ..".index", false)
                          else
                            handler[funcName](handler, nil, parentPath .. name, false)
                          end
                          if value.class then
                            for k, class in pairs(value.class) do
                                -- print("", class, parentPath .. name)
                                if class:len() > 0 then
                                  table.insert(classEntries, {
                                      class = class,
                                      path = parentPath .. name  -- see sceneHandler.lua, it splits to load layer_linear.lua by split('.')
                                  })
                                  handler[funcName](handler, class, parentPath .. name, false)
                                end
                            end
                          end
                        end
                        -- print("", value, parent)
                    end
                end
            end
            return classEntries
        end
        local ret = iterator(handler, nil, models, nil)
        -- for j = 1, #ret do
        --     handler[funcName](handler, ret[j].class, ret[j].path, false)
        -- end
    end

    local function callComponentsHandler(models, handler, funcName)
        for class, entries in pairs(models) do
            -- print("", class, #entries) -- ex name:pages, entries:{"bookstore"}
            if class == "audios" then
              if entries.long then
              for k=1, #entries.long do
                handler[funcName](handler, "audios.long", entries.long[k], false)
              end
              end
              if entries.short then
                for k=1, #entries.short do
                  handler[funcName](handler, "audios.short", entries.short[k], false)
                end
              end
            elseif class =="groups" then
              for k=1, #entries do
                local group = entries[k]
                if type(group) == "table" then
                  for name, value in pairs(group) do  --
                    handler[funcName](handler, "groups", name, false)
                    if value.class then
                      for k, class in pairs(value.class) do
                          --print("", class, parentPath .. name)
                          if class:len() > 0 then
                            handler[funcName](handler, "groups", name.."_"..class, false)
                          end
                      end
                    end
                  end
                else
                  print("Warning", group)
                end
              end
            elseif (class ~="layers") then
              -- fonts? particles, sprites, videos
              for k=1, #entries do
                handler[funcName](handler, class, entries[k], false)
              end
            end
        end
    end

    local function callCommonComponentHandler(models, handler, funcName)
      for k=1, #models do
        handler[funcName](handler, nil, models[k], false)
      end
  end

    --[[
      main.lua
      -----
      local common = {commands = {"myEvent"}, components = {"myComponent"}}
      require(kwikGlobal.ROOT.."controller.index").bootstrap({name="book", sceneIndex = 1, position = {x=0, y=0}, common =common}) -- scenes.index
      ----

      this boostrap's props is attached to scene by scene:setProps in ApplicationContext.lua

      --]]


    function UI:init()
        -- print("ApplicationUI:init", self.lang, self)
        --for k, v in pairs( model.components) do print(k, v) end
        -- print ("---------------")
        callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_init")
        callComponentsHandler(model.components, self.componentLocalHandler, "_init")
        if self.scene.UI.props.common then
          callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_init")
        end
    end
    --
    function UI:create(params)
        uiHandler:init(self)
        -- self:_create("common", const.page_common, false)
        self:setLanguge()
        self:init()
        self.sceneEventParams = params
        callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_create")
        callComponentsHandler(model.components, self.componentLocalHandler, "_create")
        if self.scene.UI.props.common then
          callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_create")
        end
        uiHandler:create(self)
    end
    --
    function UI:willShow(params)
      -- self:_didShow("common", const.page_common, false)
      self.sceneEventParams = params
      callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_willShow")
      callComponentsHandler(model.components, self.componentLocalHandler, "_willShow")
      if self.scene.UI.props.common then
        callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_willShow")
      end
      uiHandler:willShow(self)
    end
    --
    function UI:didShow(params)
      -- self:_didShow("common", const.page_common, false)
      self.sceneEventParams = params
      callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_didShow")
      callComponentsHandler(model.components, self.componentLocalHandler, "_didShow")
      if self.scene.UI.props.common then
        callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_didShow")
      end
      if self.onComplete then
        -- for unit test, see suite_page1_group
        timer.performWithDelay(500, self.onComplete)
      end
      uiHandler:didShow(self)
    end
    function UI:willHide(params)
      -- self:_didShow("common", const.page_common, false)
      self.sceneEventParams = params
      callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_willHide")
      callComponentsHandler(model.components, self.componentLocalHandler, "_willHide")
      if self.scene.UI.props.common then
        callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_willHide")
      end
      uiHandler:willHide(self)
    end
    --
    function UI:didHide(params)
      self.sceneEventParams = params
      callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_didHide")
      callComponentsHandler(model.components, self.componentLocalHandler, "_didHide")
      if self.scene.UI.props.common then
        callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_didHide")
      end
      uiHandler:didHide(self)
    end
    --
    function UI:destroy(params)
      self.sceneEventParams = params
      callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_destroy")
      callComponentsHandler(model.components, self.componentLocalHandler, "_destroy")
      if self.scene.UI.props.common then
        callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_destroy")
      end
      uiHandler:destroy(self)
    end
    --
    function UI:touch(event) print("event.name: " .. event.name) end

    function UI:resume(params)
      uiHandler:resume(self)
        self.sceneEventParams = params
        callComponentsLayersHandler(model.components.layers, self.sceneHandler, "_resume")
        callComponentsHandler(model.components, self.componentLocalHandler, "_resume")
        if self.scene.UI.props.common then
          callCommonComponentHandler(self.scene.UI.props.common.components, self.commmonHandler, "_resume")
        end
    end
    --
    return UI
end

return M