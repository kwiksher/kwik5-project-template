---------------------------------------------------------------------------------------
-- Dronebot
-- Mike Gieson (www.gieson.com)
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.
---------------------------------------------------------------------------------------


local retObj = display.newGroup()
local basefont = "HelveticaNeue"
local basefontBold = "HelveticaNeue-Bold"

local refTopLeft = display.TopLeftReferencePoint

local fontMetricsComp_y = 2.3

local textblockSize = 16
local textblockFont = basefontBold
local textblockColor = {200/255, 200/255, 200/255}

-- ----------------- Single --------------------
local textblock = display.newText("3:16", 0, fontMetricsComp_y, textblockFont, textblockSize )
--textblock:setReferencePoint(display.TopLeftReferencePoint)
textblock.align = "left"
--textblock:setReferencePoint(display.CenterReferencePoint)
textblock:setTextColor( textblockColor[1], textblockColor[2], textblockColor[3] )

-- Box
local bkgdbox = display.newRoundedRect(0, 0, 70, textblockSize*2, 6)
local bkgdboxColor = {50/255, 50/255, 50/255}
bkgdbox:setFillColor( bkgdboxColor[1], bkgdboxColor[2], bkgdboxColor[3] )

local outlineColor = {100/255, 100/255, 100/255}
bkgdbox.strokeWidth = 1
bkgdbox:setStrokeColor( outlineColor[1], outlineColor[2], outlineColor[3] )
--bkgdbox:setReferencePoint(refTopLeft)

-- ----------------- Multi Line ---------------------
local textblockMulti = display.newText("3:16", 10, fontMetricsComp_y, 72, 52, textblockFont, textblockSize )
--textblockMulti:setReferencePoint(display.TopLeftReferencePoint)
textblockMulti.align = "left"
--textblockMulti:setReferencePoint(display.CenterReferencePoint)
textblockMulti:setTextColor( textblockColor[1], textblockColor[2], textblockColor[3] )

local bkgdboxMulti = display.newRoundedRect(0, 0, 80, textblockSize*3.6, 6)
bkgdboxMulti:setFillColor( bkgdboxColor[1], bkgdboxColor[2], bkgdboxColor[3] )
bkgdboxMulti.strokeWidth = 1
bkgdboxMulti:setStrokeColor( outlineColor[1], outlineColor[2], outlineColor[3] )
--bkgdboxMulti:setReferencePoint(refTopLeft)
-- ---------------------------------------------------

local offsetMargin = 0
local bkgdboxOffsetX = offsetMargin + (bkgdbox.width * 0.25)
local bkgdboxOffsetY = bkgdbox.height + offsetMargin
local bkgdboxHalfW = bkgdbox.width * 0.5

bkgdboxMulti:translate(textblock.width+15, 0)

retObj:insert(bkgdbox)
retObj:insert(textblock)
retObj:insert(bkgdboxMulti)
retObj:insert(textblockMulti)

retObj.isVisible = false


retObj.textblock = textblock
retObj.textblockMulti = textblockMulti

local digits = 2
local shift = 10 ^ digits
local floor = math.floor

local editText = {}
local editTextXpos = 0


function retObj:pos(theX, theY)
	retObj.x = math.max(0, theX - bkgdboxOffsetX)
	retObj.y = math.max(0, theY - bkgdboxOffsetY)
end

function retObj:text(theText)
	--local result = floor( theText*shift + 0.5 ) / shift
	--local result = floor( theText*shift + 0.5 ) / shift
	editText.text = theText
	editText.x = editTextXpos
	----textblock:setReferencePoint(refTopLeft)
end

local transitionTime = 500
local function transitionKillerOn( obj )
	transition.cancel(obj)
	obj = nil
end

local function transitionKillerOf( obj )
	transition.cancel(obj)
	obj = nil
	retObj.isVisible = false
end

function retObj:on(theX, theY, useMulti)
	if useMulti == true then
		textblockMulti.isVisible = true
		bkgdboxMulti.isVisible = true

		textblock.isVisible = false
		bkgdbox.isVisible = false

		editText = textblockMulti
		editTextXpos = 50

	else
		textblock.isVisible = true
		bkgdbox.isVisible = true

		textblockMulti.isVisible = false
		bkgdboxMulti.isVisible = false

		editText = textblock
		editTextXpos = bkgdboxHalfW
	end
	retObj:pos(theX, theY)
	retObj.isVisible = true
	transition.to( retObj, { time=transitionTime*0.5, alpha=1.0, onComplete=transitionKillerOn })
	retObj:toFront()
end

function retObj:off()
	transition.to( retObj, { time=transitionTime, alpha=0.0, onComplete=transitionKillerOff })

end

return retObj