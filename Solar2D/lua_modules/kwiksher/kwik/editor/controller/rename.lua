local name = ...
local parent, root = newModule(name)
local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")
local picker = require(kwikGlobal.ROOT.."editor.picker.name")
local confirmation = require(kwikGlobal.ROOT.."editor.picker.confirmation")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or 
                 archInfo == "IA64" or archInfo == "ARM"                 

--
local function getListener(props, selections)
  -- print("@@", props.layer, props.class, props.target, props.selections)
  if selections and #selections > 1 then
    return nil, nil
  elseif props then
    if props.book then
      -- print("rename book")
      return props.book, "book", scripts.renameBook
    elseif props.page then
      -- print("rename page", props.page)
      return props.page, "page", scripts.renamePage
    elseif props.audio then
      -- print("rename audio", props.audio, props.type)
      return props.audio, "audio/" .. props.type, scripts.renameAudio
    elseif props.layer and props.group  == true  then
      return props.layer, "group", scripts.renameGroup -- because groupTable is inherting layerTable
    elseif props.class =="timers"  then
      return props.target, "timer", scripts.renameTimer
    elseif props.class == "joints" then
      return props.target, "joint", scripts.renameJoint
    elseif props.class == "variables"  then
      return props.target, "variable", scripts.renameVariable
    elseif props.layer then
      -- print("rename layer")
      return props.layer, "layer", scripts.renameLayer
    else
      -- print(props.class, selections[1].text)
      -- print(props.class, selections[1].text, selections[1][props.class])
    end
  end
  return
end
--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    --
    local oldValue, _type, script = getListener(params.props, UI.editor.selections)
    --
    if _type == "book" and isWindows then
      script(UI.book, UI.page, oldValue, "") -- renname book in Windows not work so open explorer
    elseif _type then
      local function listener(value)
        -- print("newValue=", value)
        if value and value == "Continue" and picker.obj.field.text:len() > 0 then
          if params.props.audio then
            script(UI.book, UI.page, params.props.type, oldValue, picker.obj.field.text) -- _dst == Solar2D
          else
            script(UI.book, UI.page, oldValue, picker.obj.field.text) -- _dst == Solar2D
          end
        else
          -- print("user cancel")
        end
        confirmation:destroy()
        picker:destroy()
      end
      confirmation:create(listener, "Press Continue to rename " .. oldValue, nil)
      picker:create(nil, "Please input a " .. _type .. " name")
      picker.obj.text = ""
    else
      -- print("error no type")
    end
  end
)
--
return instance
