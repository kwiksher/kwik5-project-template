local M = {}
local json  = require ("json")
require("transitionfilter")

function M:getCompositePaint()
  local UI = self.UI
  local folder = UI.props.imgDir
  if self.composite.folder then
    folder = "App/"..UI.book.."/assets/"..self.composite.folder.."/"
  end
  local path1 = system.pathForFile(folder..self.composite.paint1)
  local path2 = system.pathForFile(folder..self.composite.paint2)
  if path1 ==nil or path2 == nil then
    print("### Error: composite paint1 or paint2", path1, path2)
    return
  end
  local compositePaint = {
    type="composite",
    paint1={ type="image", filename=folder..self.composite.paint1, baseDir=UI.props.systemDir },
    paint2={ type="image", filename=folder..self.composite.paint2, baseDir=UI.props.systemDir }
    -- paint1={ type="image", filename="assets/images/filters/fx-base-church.png", baseDir=UI.props.systemDir },
    -- paint2={ type="image", filename="assets/images/filters/fx-base-texture.png", baseDir=UI.props.systemDir },
  }
  return compositePaint
end
--
function M:applyFilterTable(obj)
  local UI = self.UI
  if obj then
     if self.composite then
      obj.fill = self:getCompositePaint()
      obj.fill.effect = self.effect -- "composite.add"
      self.filterTable:set(self.effect, obj.fill.effect)
      --obj.fill.effect.alpha = 0.9
     else
      self.filterTable:set(self.effect, obj.fill.effect)
     end

-- obj.fill.effect.levels.white = 0.8
-- obj.fill.effect.levels.black = 0.4
-- obj.fill.effect.levels.gamma = 1
      -- effect.color1 = { 0.8, 0, 0.2, 1 }
      -- effect.color2 = { 0.2, 0.2, 0.2, 1 }
      -- effect.xStep = 8
      -- effect.yStep = 8

      -- print(json.encode(effect.color1))
      -- print(json.encode(effect.color2))
      -- print(effect.xStep)
      -- print(effect.yStep)

  else
    local param = {}
    if self.properties.animation then
      param.effect = self.effect
      param.filterTable = self.filterTable
      param.time   = self.properties.duration
      param.delay  = self.properties.delay/1000
      param.loop = self.properties.loop
      -- param.effectTo = filterTable[name].get()
      -- param.effectFrom = {}
      -- filterTable[name].set(param.effectFrom)
      param.onComplete = function()
        if type(self.actions.onComplete) == "string" then
          Runtime:dispatchEvent({name=UI.page..self.actions.onComplete, event={}, UI=UI})
        end
      end
     if self.composite then
      param.alpha = self.filterTable.to.alpha
     end
    end
    -- printTable(param)
    return param
  end
end
--
function M:init()
end
--
function M:create(UI)
  local layer       = UI.layer
  local sceneGroup = UI.sceneGroup
  local obj = sceneGroup[self.layer]
  self.UI = UI

  if obj == nil then return end

  if self.filter then
    self.effect = "filter."..self.filter.effect
  elseif self.generator then
    self.effect = "generator."..self.generator.effect
  else
    self.effect = "composite."..self.composite.effect
  end
  --
  -- print("self.animation", self.properties.animation)
  if self.properties.animation then
    obj:addEventListener( "playFilterAnim", function()
      if not self.autoPlay then
        --
        if self.filter then
          obj.fill.effect = self.effect
          self:applyFilterTable(obj)
        elseif self.generator then
          if self.effect == "generator.marchingAnts" then
            obj.strokeWidth = 2
            obj.stroke.effect = self.effect
          else
            obj.fill.effect = self.effect
          end
          self:applyFilterTable(obj)
        else -- composite

          obj.fill = self:getCompositePaint()
          obj.fill.effect = self.effect
          --
          self:applyFilterTable(obj)
        end
      end
      transition.kwikFilter(obj, self:applyFilterTable(nil) )
    end)
  end
end
--
function M:didShow(UI)
  local sceneGroup = UI.sceneGroup
  local obj = sceneGroup[self.layer]
  local animation = type(self.properties.animation) == "string" and self.properties.animation == "true" or self.properties.animation
  --
  --
  if self.properties.autoPlay then
    if self.filter then
      obj.fill.effect = self.effect
      self:applyFilterTable(obj)
      -- print(animation, type(animation))
      if animation then
        -- printKeys(self.properties)
        local params = self:applyFilterTable(nil)
        transition.kwikFilter(obj, params )
      end
    elseif self.generator then
      if self.generator.name == "generator.marchingAnts" then
        obj.strokeWidth = 2
        obj.stroke.effect = self.effect
      else
        obj.fill.effect = self.effect
      end
      self:applyFilterTable(obj)
      if animation then
        transition.kwikFilter(obj, self:applyFilterTable(nil) )
      end
    else -- composite
      local folder = UI.props.imgDir
      if self.composite.folder then
        folder = "App/"..UI.book.. "/assets/"..self.composite.folder.."/"
      end
      -- local compositePaint = {
      --     type="composite",
      --     paint1={ type="image", filename=folder..self.composite.paint1, baseDir=UI.props.systemDir },
      --     paint2={ type="image", filename=folder..self.composite.paint2, baseDir=UI.props.systemDir }
      -- }
      -- obj.fill = compositePaint
      -- obj.fill.effect = self.effect

      if self.composite.name == "composite.normalMapWith1PointLight" or self.composite.name == "composite.normalMapWith1DirLight" then
        self:applyFilterTable(obj)
        if animation then
            transition.kwikFilter(obj, self:applyFilterTable(nil) )
        end
      else
        self:applyFilterTable(obj)
        if animation then
            -- -- print(" ---- transition.to -----")
            -- local param = self:applyFilterTable(nil)
            -- printTable(param)
            --transition.to(obj, param )
            --transition.to(obj, {filter ={effect={alpha=0.5}}} )
            transition.kwikFilter(obj, self:applyFilterTable(nil) )

        end
      end
    end
  end
end
--
function M:destroy()
end

M.set = function(props)
  -- for k, v in pairs(props) do print(k, v) end
  local layer_filterTable = require(kwikGlobal.RESOUCES.."template.components.pageX.animation.layer_filterTable")
  local instance = setmetatable( {to=props.to, from=props.from}, {__index=layer_filterTable} )
  props.filterTable = instance
  return setmetatable(props, {__index = M})
end

return M