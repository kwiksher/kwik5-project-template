local M = {}
local json    = require('json')
local App = require("Application")
local apiLevel =  system.getInfo( "androidApiLevel" )  or 0
-- https://forums.solar2d.com/t/display-capturescreen-true-fails-on-android-13/356249/3
local needle = apiLevel >= 33
  and "android.permission.READ_MEDIA_IMAGES"
  or "android.permission.WRITE_EXTERNAL_STORAGE"
-- local needle = "Storage"
-- local needle = "android.permission-group.STORAGE"

-- Helper function that determines if a value is inside of a given table.
local function isValueInTable( haystack, needle )
    assert( type(haystack) == "table", "isValueInTable() : First parameter must be a table." )
    assert( needle ~= nil, "isValueInTable() : Second parameter must be not be nil." )
    for key, value in pairs( haystack ) do
        if ( value == needle ) then
            return true
        end
    end
    return false
end
-- Called when the user has granted or denied the requested permissions.
local function permissionsListener( event, deferred, needle )
    -- print( "permissionsListener( " .. json.prettify( event or {} ) .. " )" )
    if ( event.grantedAppPermissions ) then
        if ( not isValueInTable( event.grantedAppPermissions, needle ) ) then
            print( "request permissions failed for", needle )
            deferred:reject()
        else
            deferred:resolve()
        end
    else
      deferred:reject()
    end
end
function checkPermissions()
    local deferred = Deferred()
    if ( system.getInfo( "platform" ) == "android" and apiLevel >= 23 ) then
        local grantedPermissions = system.getInfo("grantedAppPermissions")
        if ( grantedPermissions ) then
           if ( not isValueInTable( grantedPermissions, needle ) ) then
                -- print( "Lacking storage permission!", needle )
                native.showPopup( "requestAppPermission", {
                  appPermission= needle,
                    rationaleTitle = "Storage Permission",
                    rationaleDescription = "Permission needed to save screenshots",
                    listener = function(event) permissionsListener(event, deferred, needle)  end

                 } )
            else
                deferred:resolve()
            end
        end
    else
        if  media.hasSource( media.PhotoLibrary ) then
            deferred:resolve()
        else
            deferred:reject()
        end
    end
    return deferred:promise()
end
---------------------
function M:init(UI)
  self.props = App.get().props
	if self.cam_shutter == nil then
	  self.cam_shutter = audio.loadSound(self.props.audioDir.."short/shutter.mp3", self.props.systemDir )
	end
end
--
function M:didShow(UI)
  self.sceneGroup = UI.sceneGroup
end
--
function M:take(title, pmsg, shutter, hideLayers, listener)
	checkPermissions()
    :done(function()
        if shutter then
          -- print("kwik", "screenshot", "audio.play")
            audio.play(self.cam_shutter, {channel=31})
        end
        if hideLayers then
          -- print("kwik", "hideLayers", #hideLayers)
            for i=1, #hideLayers do
              local layer = self.sceneGroup[hideLayers[i]]
              layer.alphaBeforeScreenshot = layer.alpha
              layer.alpha = 0
            end
        end
            --
        -- print("kwik", "screenshot", "display.captureScreen")
        local screenCap = display.captureScreen(true)

        -- First save to temporary directory
        local tempPath = system.pathForFile("screenshot.png", system.TemporaryDirectory)
        display.save(screenCap, {
            filename="screenshot.png",
            baseDir=system.TemporaryDirectory,
            captureByteColorFormat=true
        })

        -- Then add to photo gallery
        media.save(tempPath)
        local alert = native.showAlert(title, pmsg, { "OK" })

      --   media.save(tempPath, {
      --     mediaType="image",
      --     filename="KwikScreenshot_" .. os.date("%Y%m%d_%H%M%S"),
      --     baseDir=system.TemporaryDirectory,
      --     listener=function(event)
      --         if event.completed then
      --             print("Screenshot saved to photo gallery!")
      --         else
      --             print("Failed to save to photo gallery:", event.error)
      --         end

      --         -- Show confirmation after save attempt
      --         local alert = native.showAlert(title, pmsg, { "OK" })
      --     end
      -- })

        -- Remove the display object
        screenCap:removeSelf()

        if hideLayers then
          -- print("kwik", "showLayers")
            for i=1, #hideLayers do
              local layer = self.sceneGroup[hideLayers[i]]
              layer.alpha = layer.alphaBeforeScreenshot
            end
        end
    end)
	:fail(function()
	    -- print("kwik", "fail")
	    native.showAlert( "App", "Request permission is not granted on "..system.getInfo("model"), { "OK" } )
    end)
end
--
function M:didHide(UI)
	if self.cam_shutter then
		audio.stop(31)
	end
end
--
function M:destroy(UI)
		audio.dispose(self.cam_shutter)
		self.cam_shutter = nil
end
--
return M