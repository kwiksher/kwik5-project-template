local M = {}
--
local pageCommand = require("components.bookstore.controller.pageCommand")
local model = require("components.bookstore.model.base")
--
model.debug = true
model.URL = "http://localhost:8080/bookshop/"
-- model.URL = nil means simple IAP store without network download
-- downloadBtn, savingTxt won'T be used. You don't need to create them.
----------
model.TOC           = "bookTOC"
model.LIBRARY_PAGES = {en = "components.library"}
model.DIALOG_PAGES  = {en = "components.dialog"}
--
model.name = "catalog01"
--
model.books = {
  bookFree = {
    name         = "bookFree",
    versions     = {},
    titles       = {en="bookOne"},
    descriptions = {en="desc"},
    isFree       = true,
    isOnlineImg  = true,
    isDownloadable = true,
    image        = "App/bookFree/assets/images/page1/bg.png",
    productNames = {apple = "bookFree", google = "bookFree", amazon = "bookFree"},
  },
  bookOne = {
    name         = "bookOne",
    versions     = {},
    titles       = {en="bookOne"},
    descriptions = {en="desc"},
    isFree       = false,
    isOnlineImg  = true, -- true
    isDownloadable = true, -- true
    image        = "App/bookOne/assets/images/page1/bg.png",
    productNames = {apple = "bookOne", google = "bookOne", amazon = "bookOne"},
  }
}
--
model.purchaseAlertMessages = {en="Your purchase was successful"}
model.restoreAlertMessages  = {en="Your items are being restored"}
model.downloadErrorMessages = {en="Check network alive to download the content"}
model.descriptions = {en=""}
model.titles = {en=""}

--
model.gotoSceneEffect = "slideRight"
model.showOverlayEffect = "slideBottom"

--
M.new = function()
  return pageCommand.newBookstore(model)
end
--
M.model = model
--
return M
