local M = {}
--
local IAP = require(kwikGlobal.ROOT.."components.bookstore.controller.IAP")
local downloadManager = require(kwikGlobal.ROOT.."components.bookstore.controller.downloadManager")
local composer = require("composer")
local pageCommand = require(kwikGlobal.ROOT.."components.bookstore.controller.pageCommand")

local model = nil
local downloadGroup = nil
local callPurchaseComplete = nil

local App = require(kwikGlobal.ROOT.."controller.Application")

function M.new()
  local CMD = {}
  --print("commands.new", CMD)
  --
  function CMD:init(_sceneGroup, _model, _downloadGroup, _callPurchaseComplete)
    print("CMD:inti", _model)
    self.sceneGroup = _sceneGroup
    downloadGroup = _downloadGroup
    callPurchaseComplete = _callPurchaseComplete
    model = _model
    pageCommand.init(_model)
  end
  -- Called when the scene's view does not exist:

  function CMD.startDownload(id, version)
    downloadManager.startDownload(id, version)
  end

  function CMD:dispose()
    print("------------------CMD:dispose")
    -- Runtime:removeEventListener("command:purchaseCompleted", self.onPurchaseComplete)
    -- for i=1, #CMD.buttons do
    --     CMD.buttons[i]:removeEventListener("tap", CMD.gotoScene)
    -- end
  end

  function CMD.gotoScene(event, version)
    print("CMD.gotoScene")
    pageCommand.gotoScene(event, version)
  end
  --
  function CMD.showOverlay(event)
    print("--- showOverlay---")
    local book = event.target.book
    local options = {
      isModal = true,
      effect = model.showOverlayEffect,
      time = 200,
      params = {selectedBook = book.name}
    }
    local page = model.DIALOG_PAGE..".index"
    if page then
      model.currentBook = {name = book.name, isPurchased = event.target.isPurchased}
      local app = App.getByName("bookTOC")
      app:showOverlay(page, options)
      print("--- done showOverlay---")
      return true
    else
      return false
    end
  end

  function CMD.hideOverlay()
    print("CMD.hideOverlay")
    composer.hideOverlay("fade", 400)
    return true
  end

  function CMD.restore(event)
    for k, book in pairs(model.books) do
      local obj = CMD.sceneGroup[book.name .. "Icon"]
      if obj then
        obj:removeEventListener("tap", CMD.gotoScene)
        obj.savedBtn:removeEventListener("tap", CMD.gotoScene)
      end
    end
    IAP.restorePurchases(event)
  end

  function CMD:setButtonImage(obj, name, version)
    downloadManager.setButtonImage(obj, name, version)
  end

  function CMD.hasDownloaded(book, version)
    return downloadManager.hasDownloaded(book, version)
  end

  function CMD.isUpdateAvailable(book, version)
    return downloadManager.isUpdateAvailable(book, version)
  end

  function CMD.isPurchased(book)
    return book.isFree or (IAP.getInventoryValue("unlock_" .. book.name) == true)
  end

  function CMD.buyBook(e)
    IAP.buyBook(e)
  end

  function CMD.onPurchase(name)
    IAP.buyBook({target = {selectedBook = name}})
  end

  function CMD.onDownload(book)
    downloadManager.startDownload(book)
  end

  function CMD.onSaved(name)
    if downloadManager.hasDownloaded(book) then
      pageCommand.gotoScene({target = {selectedBook = book.name}})
    end
  end
  return CMD
end

-- it will be called from the purchaseListener and the restoreListener functions
function M.onPurchaseComplete(event)
  local selectedBook = event.product
  local obj = downloadGroup[selectedBook]
  print("CMD onPurchaseComplete", selectedBook)
  --
  if obj and obj.purchaseBtn.removeEventListener then
    obj.purchaseBtn:removeEventListener("tap", IAP.buyBook)
    --
    if (event.actionType == "purchase") then
      -- obj.text.text="saving"
      if not obj.book.isDownloadable then
        callPurchaseComplete(event.product)
      elseif #obj.book.versions == 0 then
          print("startDownload")
          downloadManager.startDownload(event.product, obj.lang)
      else
         print("user can download a version now")
      end
    elseif (event.actionType == "restore") then
      -- restore
      --obj.text.text="press to download"
      if not obj.book.isDownloadable then
        callPurchaseComplete(event.product)
      elseif #obj.book.versions == 0 then
        if not obj.tap then
          function obj:tap(event)
            local selectedBook = event.target.selectedBook
            downloadManager.startDownload(selectedBook)
            return true
          end
          obj.downloadBtn:addEventListener("tap", obj)
        end
      else
        print("user can download a version now")
     end
   end
  end
end

Runtime:addEventListener("command:purchaseCompleted", M.onPurchaseComplete)

return M
