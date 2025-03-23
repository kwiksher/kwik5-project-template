-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
local ActionCommand = {}
local _AC           = require("commands.kwik.actionCommand")
local _K            = require "Application"
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
		local obj        = params.obj
	{{#actions}}
		--
		{{#if}}
		if {{exp1}}  {{exp1Op}} {{exp1Comp}} {{exp2Cond}}  {{exp2}}  {{exp2Op}} {{exp2Comp}} then
		{{/if}}

		{{#else}}
		else
		{{/else}}

		{{#elseif}}
		elseif {{exp1}}  {{exp1Op}} {{exp1Comp}} {{exp2Cond}}  {{exp2}}  {{exp2Op}} {{exp2Comp}} then
		{{/elseif}}

		{{#end}}
		end
		{{/end}}

		{{#action.playAction}}
			_AC.Action:playAction(UI.page..".action_{{trigger}}", params)
		{{/action.playAction}}

		-- {{target}} = "{{layers}}" or obj or sceneGroup.{{name}}

		{{#animation.pauseAnimation}}
			_AC.Animation:pauseAnimation({{target}})
		{{/animation.pauseAnimation}}

		{{#animation.resumeAnimation}}
			_AC.Animation:resumeAnimation({{target}})
		{{/animation.resumeAnimation}}

		{{#animation.playAnimation}}
			_AC.Animation:playAnimation({{target}})
		{{/animation.playAnimation}}

		{{#button.enableDisableButton}}
			_AC.Button:enableDisableButton({{target}}, {{toggle}}, {{enable}})
		{{/button.enableDisableButton}}

		{{#filter.pauseFilter}}
		--{{layers}}
			_AC.Filter:pauseFilter({{target}})
		{{/filter.pauseFilter}}

		{{#filter.resumeFilter}}
		--{{layers}}
			_AC.Filter:resumeFilter({{target}})
		{{/filter.resumeFilter}}

		{{#filter.playFilter}}
		--{{layers}}
			_AC.Filter:playFilter({{target}})
		{{/filter.playFilter}}

		{{#filter.cancelFilter}}
		--{{layers}}
			_AC.Filter:cancelFilter({{target}})
		{{/filter.cancelFilter}}

		{{#app.rateApp}}
			_AC.App:rateApp("{{appID}}")
		{{/app.rateApp}}

		{{#audio.recordAudio}}
			_AC.Audio:recordAudio({{duration}}, "{{mmFile}}", {{malfa}}, sceneGroup, {{audiotype}}.allAudios)
		{{/audio.recordAudio}}

		{{#audio.muteUnmute}}
		 local videos = {
			{{#videos}}
				 {{target}},
			{{/videos}}
			}
			_AC.Audio:muteUnmute(videos)
		{{/audio.muteUnmute}}

		{{#audio.playAudio}}
			{{#trigger}}
			_AC.Audio:playAudio({{audiotype}}.allAudios.{{vaudio}}, {{vchan}}, {{vrepeat}}, {{vdelay}}, {{vloop}}, {{toFade}}, {{vvol}}, "{{tm}}", UI.page..".action_{{trigger}}", params)
			{{/trigger}}
			{{^trigger}}
			_AC.Audio:playAudio({{audiotype}}.allAudios.{{vaudio}}, {{vchan}}, {{vrepeat}}, {{vdelay}}, {{vloop}}, {{toFade}}, {{vvol}}, "{{tm}}" )
			{{/trigger}}
		{{/audio.playAudio}}

		{{#audio.rewindAudio}}
			_AC.Audio:rewindAudio({{audiotype}}.allAudios.{{vaudio}}, {{vchan}}, {{vrepeat}})
		{{/audio.rewindAudio}}

		{{#audio.pauseAudio}}
			_AC.Audio:pauseAudio({{audiotype}}.allAudios.{{vaudio}}, {{vchan}}, {{vrepeat}})
		{{/audio.pauseAudio}}

		{{#audio.stopAudio}}
			_AC.Audio:stopAudio({{audiotype}}.allAudios.{{vaudio}}, {{vchan}}, {{vrepeat}})
		{{/audio.stopAudio}}

		{{#audio.resumeAudio}}
			_AC.Audio:resumeAudio({{audiotype}}.allAudios.{{vaudio}}, {{vchan}}, {{vrepeat}})
		{{/audio.resumeAudio}}

		{{#audio.setVolume}}
			_AC.Audio:setVolume({{vvol}}, {{vchan}})
		{{/audio.setVolume}}

		{{#canvas.brushSize}}
			_AC.Canvas:brushSize(UI.canvas, {{size}}, {{alpha}})
		{{/canvas.brushSize}}

		{{#canvas.brushColor}}
			_AC.Canvas:brushColor(UI.canvas, {{color}})
		{{/canvas.brushColor}}

		{{#canvas.eraseCanvas}}
			_AC.Canvas:eraseCanvas(UI.canvas)
		{{/canvas.eraseCanvas}}

		{{#canvas.undo}}
			_AC.Canvas:undo(UI.canvas)
		{{/canvas.undo}}

		{{#canvas.redo}}
			_AC.Canvas:redo(UI.canvas)
		{{/canvas.redo}}

		{{#countdown.playCountDown}}
			_AC.Countdown:playCountDown({{target}}, {{ttime}}, UI.upTime_{{tname}}, UI)
		{{/countdown.playCountDown}}

		{{#external.externalCode}}
      UI.scene:dispatchEvent({name = "ext_{{triggerName}}", parent = params.event })
		{{/external.externalCode}}

		{{#image.editImage}}
			_AC.Image:editImage(sceneGroup.{{lay}}, {{mx}}, {{my}}, {{sw}}, {{sh}}, {{fh}}, {{fv}}, {{ro}})
		{{/image.editImage}}

		{{#language.setLanguage}}
			_AC.Lang:setLanguage("{{lang}}", {{reload}})
		{{/language.setLanguage}}

		{{#layerAct.showHide}}
			_K.trans.{{tm}} = _AC.Layer:showHide(sceneGroup.{{showLay}},  {{hides}}, {{toggles}}, {{time}}, {{delay}})
		{{/layerAct.showHide}}

		{{#layerAct.frontBack}}
			_AC.Layer:frontBack(sceneGroup.{{showLay}}, {{front}}, {{target}})
		{{/layerAct.frontBack}}

		{{#multiplier.playMultiplier}}
			_AC.Multiplier:playMultiplier({{target}})
		{{/multiplier.playMultiplier}}

		{{#multiplier.stopMultiplier}}
			_AC.Multiplier:stopMultiplier({{target}})
		{{/multiplier.stopMultiplier}}

		{{#page.autoPlay}}
      _K.kAutoPlay = {{autoPlaySec}}
 	    {{#goNext}}
	    	_AC.Page:autoPlay(UI.curPage)
	    {{/goNext}}
		{{/page.autoPlay}}

		{{#page.showHideNavigation}}
			_AC.Page:showHideNavigation({{target}});
		{{/page.showHideNavigation}}

		{{#page.reloadPage}}
			_AC.Page:reloadPage({{canvas}});
		{{/page.reloadPage}}

		{{#page.gotoPage}}
			_AC.Page:gotoPage({{pnum}}, "{{ptrans}}", {{delay}}, {{duration}});
		{{/page.gotoPage}}

		{{#particle.playParticle}}
			_AC.Particle:playParticle({{target}})
		{{/particle.playParticle}}

		{{#particle.stopParticle}}
			_AC.Particle:stopParticle({{target}})
		{{/particle.stopParticle}}

		{{#physics.applyForce}}
			{{target}}:applyForce( {{xfor}}, {{yfor}})
		{{/physics.applyForce}}

		{{#physics.bodyType}}
			_AC.Physics:bodyType({{target}}, "{{btype}}")
		{{/physics.bodyType}}

		{{#physics.invertGravity}}
			_AC.Physics:invertGravity({{target}}, {{xgra}})
		{{/physics.invertGravity}}

		{{#purchase.restorePurchase}}
			_AC.Purchase:restorePurchase()
		{{/purchase.restorePurchase}}

		{{#purchase.refoundPurchase}}
			_AC.Purchase:refoundPurchase()
		{{/purchase.refoundPurchase}}

		{{#purchase.buyProduct}}
			_AC.Purchase:buyProduct("{{product}}")
		{{/purchase.buyProduct}}

		{{#random.playRandom}}
			_AC.Random:playRandom("{{id}}", {
				{{#randArr}}
					"{{play}}",
				{{/randArr}}
				}, {{playRand}} ,  params)
		{{/random.playRandom}}

		{{#random.playRandomAnimation}}
			_AC.Random:playRandomAnimation("{{id}}", {
				{{#randArr}}
					"{{play}}",
				{{/randArr}}
				}, {{playOnce}}, params)
		{{/random.playRandomAnimation}}

		{{#readme.playReadMe}}
			_AC.Readme:playReadMe({{audiotype}}.allAudios.kwk_readMeFile, {{vchan}})
		{{/readme.playReadMe}}

		{{#readme.readMe}}
			_K.kwk_readMe = {{bReadme}}
			{{#goNext}}
			_AC.Readme:readMe(UI.curPage)
			{{/goNext}}
		{{/readme.readMe}}

		{{#readme.playSync}}
			{{^langSync}}
			_AC.Readme:playSync({{audiotype}}.{{audioSent}}, sceneGroup.{{line}}, sceneGroup.{{button}})
			{{/langSync}}
			{{#langSync}}
			_AC.Readme:playSync(UI.tSearch["{{dois}}"][4], UI.tSearch["{{dois}}"][5], sceneGroup.{{button}})
			{{/langSync}}
		{{/readme.playSync}}

		{{#screenshot.takeScreenShot}}
			_AC.Screenshot:takeScreenShot("{{ptit}}", "{{pmsg}}",  {{shutter}},
				{ {{#buttonArr}}
					"{{name}}",
				{{/buttonArr}} }

				)
		{{/screenshot.takeScreenShot}}

		{{#screenshot.screenRecording}}
			_AC.Screenshot:saveToFile({{delay}}, {{target}}, "{{filename}}",  {{numFrames}}	)
		{{/screenshot.screenRecording}}

		{{#sprite.playSprite}}
			_AC.Sprite:playSprite({{target}}, "{{vseq}}")
		{{/sprite.playSprite}}

		{{#sprite.pauseSprite}}
			_AC.Sprite:pauseSprite({{target}})
		{{/sprite.pauseSprite}}

		{{#timer.createTimer}}
			_AC.Timer:createTimer({{target}}, {{delay}}, UI.page..".action_{{trigger}}", {{loop}}, params)
		{{/timer.createTimer}}

		{{#timer.cancelTimer}}
			_AC.Timer:cancelTimer({{target}})
		{{/timer.cancelTimer}}

		{{#timer.resumeTimer}}
			_AC.Timer:resumeTimer({{target}})
		{{/timer.resumeTimer}}

		{{#timer.pauseTimer}}
			_AC.Timer:pauseTimer({{target}})
		{{/timer.pauseTimer}}

		{{#variables.restartTrackVars}}
			_AC.Var:restartTrackVars()
		{{/variables.restartTrackVars}}

		{{#variables.editVars}}
      UI.scene:dispatchEvent({name = "var_{{triggerName}}", parent = params.event })
		{{/variables.editVars}}

		{{#video.playVideo}}
			_AC.Video:playVideo({{target}})
		{{/video.playVideo}}

		{{#video.resumeVideo}}
			_AC.Video:resumeVideo({{target}})
		{{/video.resumeVideo}}

		{{#video.rewindVideo}}
			_AC.Video:rewindVideo({{target}})
		{{/video.rewindVideo}}

		{{#video.pauseVideo}}
			_AC.Video:pauseVideo({{target}})
		{{/video.pauseVideo}}

		{{#video.muteVideo}}
			local videos = {
			{{#videos}}
				 {{target}},
			{{/videos}}
			}
			_AC.Video:muteVideo({{target}}, videos)
		{{/video.muteVideo}}

		{{#video.unmuteVideo}}
			local videos = {
			{{#videos}}
				 {{target}},
			{{/videos}}
			}
			_AC.Video:unmuteVideo({{target}}, videos)
		{{/video.unmuteVideo}}

		{{#web.gotoURL}}
			_AC.Web:gotoURL("{{pLink}}")
		{{/web.gotoURL}}

	{{/actions}}
	end
	return setmetatable( command, {__index=_AC})
end
--
return ActionCommand