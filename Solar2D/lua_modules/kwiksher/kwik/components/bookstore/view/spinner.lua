local M = {}
local _W = display.contentWidth
local _H = display.contentHeight

function M.new (host)
    local obj = {}
    local spinner
    obj.host = host
    --
    function obj:show(host)
        if not spinner then
            spinner = display.newGroup()
            local hostName = host or obj.host or ""
            --Place a progress spinner on screen and tell the user the app is contating the store
            local spinnerBackground = display.newRect(0,0,360,600)
            spinnerBackground:setFillColor(1,1,1,0.75)
            --Spinner consumes all taps so the user cannot tap the purchase button twice
            spinnerBackground:addEventListener("tap", function() return true end)
            local spinnerText = display.newText("Contacting " .. hostName .. "...", 0, -20, native.systemFont, 18)
            spinnerText:setFillColor(0,0,0)
            --Add a little spinning rectangle
            local spinnerRect = display.newRect(0, 0,35,35)
            spinnerRect:setFillColor(0, 0)
            spinnerRect:setStrokeColor(1,1,1)
            spinnerRect.strokeWidth = 2
            transition.to(spinnerRect, { time=4000, rotation=360, iterations=999999, transition=easing.inOutQuad})
            --Create a group and add all these objects to it
            spinner:insert(spinnerBackground)
            spinner:insert(spinnerText)
            spinner:insert(spinnerRect)
            spinner.x, spinner.y = _W/2, _H/2
            spinner.spinnerText = spinnerText
        end
    end
    --
    function obj:remove()

        print("spinner.remove")
        if (spinner) then
            spinner:removeSelf()
            spinner=nil
        end
    end
    --
    function obj:setBytesTransferred(event)
        if ( event.bytesEstimated <= 0 ) then
            print( "Download progress: " .. event.bytesTransferred )
        else
            print( "Download progress: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
        end
        spinner.spinnerText.text = "bytes:" .. event.bytesTransferred.." estimated:"..event.bytesEstimated
    end

    function obj:updateText()
        if self.bookSize > 0 then
            local percent = self.size/self.bookSize
            local sec     = os.difftime( os.time(), self.startTime)
            local remain  = math.floor(sec * (1.0/percent))
            local time    = os.date("*t", remain)
            if time then
                spinner.spinnerText.text = math.floor(percent*100).." % (" ..self.size .."/" ..self.bookSize .." Mb) \nEstimated time of completion\n" ..time.min.." min "..time.sec .." sec"
            else
                print(self.size, self.bookSize, self.startTime)
            end
        end
    end

    return obj
end

return M