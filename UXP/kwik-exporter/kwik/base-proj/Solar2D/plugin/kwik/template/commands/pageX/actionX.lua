local ActionCommand = {}
local AC           = require("commands.kwik.actionCommand")
--
-----------------------------
-----------------------------
function ActionCommand:new()
    local command = {}
    --
    function command:execute(params)
        local UI         = params.UI
        local sceneGroup = UI.sceneGroup
        local layers      = UI.layers
    local event      = params.event
    local obj        = event.target
    --
    -- local alert = native.showAlert("Alert", "Hello", { "OK" } )
    -- printKeys(event.target)
    -- local conditions = require("App." .. UI.book..".common.conditions")
    -- local expressions = require("App." .. UI.book.."common.expressions")
    --
  {{#actions}}
    {{#action}}
      {{#play}}
      -- Action: play
      AC.Action:play(UI, "{{target}}", "{{params}}")
      {{/play}}
      {{#playRandom}}
      AC.Action:playRandom(UI, {{playOnce}}, "{{filter}}")
      {{/playRandom}}
      {{#playSequential}}
      AC.Action:playSequential(UI, {{playOnce}}, "{{filter}}")
      {{/playSequential}}
    {{/action}}
    {{#animation}}
      {{#pause}}
        obj = UI.animations["{{target}}"]
        AC.Animation:pause(obj)
      {{/pause}}
      {{#resume}}
        obj = UI.animations["{{target}}"]
        AC.Animation:resume(obj)
      {{/resume}}
      {{#play}}
        obj = UI.animations["{{target}}"]
        AC.Animation:play(obj)
      {{/play}}
      {{#playRandom}}
      AC.Animation:playRandom(UI, {{playOnce}}, "{{filter}}")
      {{/playRandom}}
      {{#playSequential}}
      AC.Animation:playSequential(UI, {{playOnce}}, "{{filter}}")
      {{/playSequential}}
    {{/animation}}

    {{#audio}}
      {{#record}}
        obj = UI.audios["{{target}}"]
        AC.Audio:record(UI, {{duration}}, "{{filename}}", {{alpha}}, {{autoPlay}}, {{volume}}, "{{listener}}")
      {{/record}}
     {{#play}}
      obj = UI.audios["{{target}}"]
      AC.Audio:play(UI, obj, {{channel}}, {{delay}}, {{loops}}, {{fadein}}, {{volume}}, "{{listener}}")
     {{/play}}
      {{#muteUnmute}}
        AC.Audio:muteUnmute()
      {{/muteUnmute}}
      {{#rewind}}
      obj = UI.audios["{{target}}"]
      AC.Audio:rewind(obj)
      {{/rewind}}
      {{#pause}}
      obj = UI.audios["{{target}}"]
      AC.Audio:pause(obj)
      {{/pause}}
      {{#stop}}
      obj = UI.audios["{{target}}"]
      AC.Audio:stop(obj)
      {{/stop}}
      {{#resume}}
      obj = UI.audios["{{target}}"]
      AC.Audio:rewind(obj)
      {{/resume}}
      {{#setVolume}}
      obj = UI.audios["{{target}}"]
      AC.Audio:setVolume(obj, {{volume}})
      {{/setVolume}}
      {{#setMasterVolume}}
      obj = UI.audios["{{target}}"]
      AC.Audio:setMasterVolume({{volume}})
      {{/setMasterVolume}}
      {{#fade}}
      obj = UI.audios["{{target}}"]
      AC.Audio:fade(obj, {{duration}}, {{volume}})
      {{/fade}}
      {{#fadeOut}}
      obj = UI.audios["{{target}}"]
      AC.Audio:fadeOut(obj, {{duration}})
      {{/fadeOut}}
    {{/audio}}

    {{#button}}
      obj = UI.sceneGroup["{{target}}"]
      {{#onOff}}
       AC.Button:onOff(obj, {{enable}}, {{toggle}} ) -- enable, toggle
      {{/onOff}}
    {{/button}}

    {{#canvas}}
        {{#brush}}
        obj = UI.sceneGroup[UI.canvas]
        {{#color}}
         AC.Canvas:brushColor(obj, unpack(AC.color( {{color}} )) )
        {{/color}}
        {{#size}}
        AC.Canvas:brushSize(obj, {{size}}  )
        {{/size}}
        {{/brush}}
        {{#redo}}
              AC.Canvas:redo(obj)
        {{/redo}}
            {{#undo}}
              AC.Canvas:undo(obj)
            {{/undo}}
        {{#erase}}
              AC.Canvas:erase(obj)
            {{/erase}}
    {{/canvas}}

    {{#condition}}
      {{#__if}}
      if {{A1_}}  {{A2_Operand}} {{A3_}} {{AB_Condition}}  {{B1_}}  {{B2_Operand}} {{B3_}} then
      {{/__if}}

      {{#__if_}}
      if {{expression}} then
      {{/__if_}}

      {{#_else}}
      else
      {{/_else}}

      {{#_elseif}}
      elseif {{A1_}}  {{A2_Operand}} {{A3_}} {{AB_Condition}}  {{B1_}}  {{B2_Operand}} {{B3_}} then
        {{/_elseif}}

      {{#_elseif_}}
      elseif {{expression}} then
      {{/_elseif_}}

      {{#_end}}
      end
      {{/_end}}
    {{/condition}}

    {{#countdown}}
      {{#reset}}
      -- Countdown: play
      AC.Countdown:reset("{{target}}")
      {{/reset}}
      {{#play}}
      -- Countdown: play
      obj = UI.timers["{{target}}__counter"]
      AC.Countdown:play(obj)
      {{/play}}
      {{#stop}}
      -- Countdown: play
      obj = UI.timers["{{target}}__counter"]
      AC.Countdown:pause(obj)
      {{/stop}}
    {{/countdown}}

    {{#externalcode}}
      {{#code}}
      -- ExternalCode: code
      {{line}}
      {{/code}}
    {{/externalcode}}

    {{#filter}}
      {{#pause}}
      -- Filter: pause
      obj = UI.sceneGroup["{{target}}"]
      AC.Filter:pause(obj)
      {{/pause}}

      {{#resume}}
      -- Filter: resume
      obj = UI.sceneGroup["{{target}}"]
      AC.Filter:resume(obj)
      {{/resume}}

      {{#play}}
      -- Filter: play
      obj = UI.sceneGroup["{{target}}"]
      AC.Filter:play(obj)
      {{/play}}

      {{#cancel}}
      -- Filter: cancel
      obj = UI.sceneGroup["{{target}}"]
      AC.Filter:cancle(obj)
      {{/cancel}}
    {{/filter}}

    {{#image}}
      {{#edit}}
      -- Image: edit
      obj = UI.sceneGroup["{{target}}"]
      AC.Image:edit(obj, {{x}}, {{y}}, {{width}}, {{height}}, {{xScale}}, {{yScale}}, {{rotation}})
      {{/edit}}
    {{/image}}

    {{#language}}
      {{#set}}
      -- Language: name
      AC.Language:set(UI, "{{lang}}", {{reload}})
      {{/set}}

    {{/language}}

    {{#layer}}
     {{#showHide}}
     obj = UI.sceneGroup["{{target}}"]
      AC.Layer:showHide(obj,  {{hide}}, {{toggle}}, {{time}}, {{delay}})
     {{/showHide}}

     {{#frontBack}}
     obj = UI.sceneGroup["{{target}}"]
     AC.Layer:frontBack(obj, {{front}} )
     {{/frontBack}}
    {{/layer}}

    {{#loop}}
      {{#_while}}
        while  {{condition}} do
      {{/_while}}

      {{#_for_next}}
      for {{i_exp}}, {{v_exp}}, in next, {{t_exp}} do
      {{/_for_next}}

      {{#_for_pairs}}
      for {{k_exp}}, {{v_exp}}, in pairs( {{t_exp}} ) do
      {{/_for_pairs}}

      {{#_end}}
      end
      {{/_end}}

      {{#_repeat}}
        repeat
      {{/_repeat}}

      {{#_untl}}
        until( {{condition}} )
      {{/_until}}
    {{/loop}}

    {{#multiplier}}
      {{#play}}
      -- Multiplier: play
      obj = UI.timers["{{target}}__multiplier0"]
      AC.Multiplier:play(obj)
      obj = UI.timers["{{target}}__multiplier1"]
      AC.Multiplier:play(obj)
      {{/play}}

      {{#stop}}
      -- Multiplier: stop
      obj = UI.timers["{{target}}__multiplier0""]
      AC.Multiplier:stop(obj)
      obj = UI.timers["{{target}}__multiplier1""]
      AC.Multiplier:stop(obj)
      {{/stop}}
    {{/multiplier}}

    {{#page}}
      {{#autoPlay}}
      AC.Page:autoPlay({{effect}}, {{delay}}, {{duration}})
      {{/autoPlay}}
      {{#showHideNavigation}}
      AC.Page:showHideNavigation({{target}});
      {{/showHideNavigation}}
      {{#reloadPage}}
      AC.Page:reloadPage({{canvas}});
      {{/reloadPage}}
      {{#gotoPage}}
      AC.Page:gotoPage("{{pageName}}", "{{effect}}", {{delay}}, {{duration}});
      {{/gotoPage}}
      {{#reload}}
      -- Page: reload
      {{/reload}}
    {{/page}}

    {{#particles}}
      {{#play}}
      -- Particles: play
      obj = UI.sceneGroup["{{target}}"]
      AC.Partciles:play(obj)
      {{/play}}

      {{#stop}}
      -- Particles: stop
      obj = UI.sceneGroup["{{target}}"]
      AC.Partciles:stop(obj)
      {{/stop}}
    {{/particles}}

    {{#physics}}
      {{#applyForce}}
      -- Physics: applyForce
      obj = UI.sceneGroup["{{target}}"]
      AC.Physics:applyForce(obj, {{xForce}}, {{yForce}})
      {{/applyForce}}

      {{#bodyType}}
      -- Physics: bodyType
      obj = UI.sceneGroup["{{target}}"]
      AC.Physics:setBodyType(obj, {{type}})
      {{/bodyType}}

      {{#gravity}}
      -- Physics: gravity
      {{/gravity}}
    {{/physics}}

    {{#purchase}}
      {{#buy}}
      -- Purchase: buy
      AC.Purchase:buy("{{product}}")
      {{/buy}}

      {{#restore}}
      -- Purchase: restore
      AC.Purchase:restore()
      {{/restore}}
    {{/purchase}}

    {{#screenshot}}
      {{#take}}
      AC.Screenshot:take("{{title}}", "{{message}}",  {{shutter}},
        { {{#hideLayers}}
          "{{name}}",
        {{/hideLayers}} }
        )
      {{/take}}
    {{/screenshot}}

    {{#sprite}}
      {{#play}}
      -- Sprite: play
      obj = UI.sceneGroup["{{target}}_sprite"]
      AC.Sprite:play(obj, "{{sequence}}")
      {{/play}}

      {{#pause}}
      -- Sprite: pause
      obj = UI.sceneGroup["{{target}}_sprite"]
      AC.Sprite:pause(obj)
      {{/pause}}
    {{/sprite}}

    {{#syncAudioText}}
      {{#play}}
      -- SyncAudioText: play
      AC.SyncAudioText:play(obj)
      {{/play}}
    {{/syncAudioText}}

    {{#timer}}
      {{#create}}
      -- Timer: create
      AC.Timer:create(UI, "{{name}}", {{delay}}, {{loop}}, {{autoPlay}}, "{{onComplete}}")
      {{/create}}

      {{#cancel}}
      -- Timer: cancel
      obj = UI.timers["{{target}}"]
      AC.Timer:cancel(obj)
      {{/cancel}}

      {{#pause}}
      -- Timer: pause
      obj = UI.timers["{{target}}"]
      AC.Timer:pause(obj)
      {{/pause}}

      {{#resume}}
      -- Timer: resume
      obj = UI.timers["{{target}}"]
      AC.Timer:resume(obj)
      {{/resume}}
    {{/timer}}

    {{#variable}}
      {{#restartTrackVar}}
      AC.Var:restartTrackVars()
      {{/restartTrackVar}}
      {{#editVar}}
        if "{{type}}" == "function" then
          AC.Var:editVar(UI, "{{target}}", function(value) return {{value}} end)
        elseif "{{type}}" == "string" then
          AC.Var:editVar(UI, "{{target}}", "{{value}}")
        else
          AC.Var:editVar(UI, "{{target}}", tonumber({{value}}))
        end
      {{/editVar}}
    {{/variable}}

    {{#video}}
      {{#play}}
      -- Video: play
      obj = UI.videos["{{target}}"]
      AC.Video:play(obj)
      {{/play}}

      {{#pause}}
      -- Video: pause
      obj = UI.videos["{{target}}"]
      AC.Video:pause(obj)
      {{/pause}}

      {{#resume}}
      -- Video: resume
      obj = UI.videos["{{target}}"]
      AC.Video:resume(obj)
      {{/resume}}

      {{#rewind}}
      -- Video: rewind
      obj = UI.videos["{{target}}"]
      AC.Video:rewind(obj)
      {{/rewind}}

      {{#seek}}
      -- Video: seek
      obj = UI.videos["{{target}}"]
      AC.Video:seek(obj, {{seconds}})
      {{/seek}}

      {{#muteUnmute}}
      -- Video: muteUnmute
      AC.Video:muteUnMute(UI)
      {{/muteUnmute}}
    {{/video}}

    {{#web}}
      {{#goto}}
      -- Web: goto
      system.openURL({{url}})
      {{/goto}}
    {{/web}}
  {{/actions}}
    end
    return setmetatable( command, {__index=AC})
end
--
ActionCommand.model = [[
{{encoded}}
]]
--
return ActionCommand