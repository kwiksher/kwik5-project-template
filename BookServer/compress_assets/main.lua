-- copyright 2022, kwiksher
--
local command = require("compress_assets")
--
command.setServerFolder("bookshop", "BookServer")
--
local books = {
    {project = "bookFree", serverFolder = "bookFree"},
    {project = "bookOne", serverFolder = "bookOne"},
}

local onLineImages = {
  {project = "bookFree", serverFolder = "bookFree", image = "assets/images/page1/bg@4x.png"},
  {project = "bookOne", serverFolder = "bookOne", image = "assets/images/page1/bg@4x.png"},
}
--
-- for instance update the video assets in page1
--[[
--
local project      = "Book02"
local serverFolder = "book02"
local page         = 1
local type         = "images"
    -- please set one of the following types
    -- "audios"
    -- "read2me"
    -- "PNGs"
    -- "sprites"
    -- "particles"
    -- "WWW"
    -- "thumbnails"
    -- "images"
    -- "shared"

command.updateAsset(project, serverFolder, page, type)
-- ]]

--
-- Handler that gets notified when the alert closes
local function compressAll()
    -- for all the pages in a project
    --
    for i=1, #books do
        local book = books[i]
        command.compress(book.project, book.serverFolder)
    end

    -- thumbnail image in server, it is copied from page1, bg layer
    --
    -- for i=1, #onLineImages do
    --     local book = onLineImages[i]
    --     command.setOnlineImage(book.project, book.serverFolder, book.image)
    -- end
end
---
local function onComplete( event )
    if ( event.action == "clicked" ) then
        local i = event.index
        if ( i == 1 ) then
            compressAll()
            native.showAlert( "Kwik", "Done", { "OK" },
            function()
              native.requestExit()
            end )
        elseif ( i == 2 ) then
            command.updateAsset(project, serverFolder, page, type)
            native.showAlert( "Kwik", "Done", { "OK" },
            function()
              native.requestExit()
            end )
        elseif ( i == 3 ) then
            print("cancelled")
            native.requestExit()
        end
    end
end

-- Show alert with two buttons
local alert = native.showAlert( "Kwik", "Compress assets?", { "All", "One asset only", "Cancel" }, onComplete )

