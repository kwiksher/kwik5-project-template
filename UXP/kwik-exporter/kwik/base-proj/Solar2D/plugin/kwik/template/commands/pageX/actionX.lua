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

{{#actions}}
  {{#layer.showHide}}
  obj = UI.sceneGroup["{{target}}"]
   AC.Layer:showHide(obj,  {{hide}}, {{toggle}}, {{time}}, {{delay}})
  {{/layer.showHide}}

  {{#layer.frontBack}}
  obj = UI.sceneGroup["{{target}}"]
  AC.Layer:frontBack(obj, {{front}} )
  {{/layer.frontBack}}

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
  {{#loop}}
    {{#_while}}
      while  {{condition}} do
    {{/_while}}

    {{#_for_next}}
    for {{i_exp}}, {{v_exp}, in next, {{t_exp}} do
    {{/_for_next}}

    {{#_for_pairs}}
    for {{k_exp}}, {{v_exp}, in pairs( {{t_exp}} ) do
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
  {{#animation}}
    --
    -- target layer :sceneGroup[layerName]
    -- target animation : layer.animations[index]
    --
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
      AC.Animation:play(obj) --  {{index}}
    {{/play}}
  {{/animation}}
  {{#button}}
    obj = UI.sceneGroup["{{target}}"]
    {{#onOff}}
     AC.Button:onOff(obj, {{enable}}, {{toggle}} ) -- enable, toggle
    {{/onOff}}
  {{/button}}
  {{#screenshot}}
  {{#take}}
   AC.Screenshot:take("{{title}}", "{{message}}",  {{shutter}},
    { {{#hideLayers}}
      "{{name}}",
    {{/hideLayers}} }
    )
    {{/take}}
  {{/screenshot}}
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
  {{#variable.restartTrackVar}}
   AC.Var:restartTrackVars()
  {{/variable.restartTrackVar}}
  {{#variable.editVar}}
     if "{{type}}" == "function" then
      AC.Var:editVar(UI, "{{target}}", function(value) return {{value}} end)
     elseif "{{type}}" == "string" then
      AC.Var:editVar(UI, "{{target}}", "{{value}}")
     else
      AC.Var:editVar(UI, "{{target}}", tonumber({{value}}))
     end
   {{/variable.editVar}}

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