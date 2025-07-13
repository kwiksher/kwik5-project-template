local _Class = {}

local cmd = require(kwikGlobal.ROOT.."components.bookstore.controller.command").new()
local downloadManager = require(kwikGlobal.ROOT.."components.bookstore.controller.downloadManager")
local IAP = require(kwikGlobal.ROOT.."components.bookstore.controller.IAP")
local composer = require("composer")

local _instance = nil

function _Class.getInstance(model)
  if model then
    _Class.model = model
  end
    if _instance == nil then
        local o = {}
        o.smc = require(kwikGlobal.ROOT.."components.bookstore.smc.bookstore_sm"):new {owner = o}
        _instance = setmetatable(o, {__index = _Class})
    end

    return _instance
end

function _Class:destroy()
    --cmd:dispose()
    --self.view:destroy()
end
------------------------------
--- INIT state
---
function _Class:initModel()
end
------------------------------
-- Downloading State
--
function _Class:startDownload(book, version)
    if book then
        -- print("smc startDownload id=", id.name, version)
        self.fromDialog = true -- downlaoding a version must be from dialog
        cmd.startDownload(book.name, version)
    else
        print("Error smc:startDownload id is null")
        print(debug.traceback())

        --cmd.startDownload()
    end
end

function _Class:unzip(id)
    -- obsolete
end

function _Class:queue(id)
end

------------------------------
-- Downloaded
--
function _Class:updateDialog(id, version)
  print("--- updateDialog ---")
    self.view.dialog:update(id, version)
end

------------------------------
-- ThumnailDisplayed state
--
function _Class:createThumbnail(filter)
    print("== smc createThumbnail ==", self.view)
    --for k,v in pairs(self.view) do print("", k, v) end
    self.view.thumbnail:create(filter)
    self.view.thumbnail:control()
    print("== smc createThumbnail ==", "end")
end

function _Class:destroyThumbnail()
    print("== smc destroyThumbnail ==")
    cmd:dispose()
    self.view.dialog.destroy()
end

function _Class:removeEventListener()
    Runtime:removeEventListener("hideOverlay", self.smc.onClose)
end
------------------------------
-- DisplayingDialog state
--
function _Class:isBookPurchased(book)
    print("smc isBookPurchased", book.isFree, book.isDownloadable)
    self.book = book
    local isPurchased = book.isFree or (IAP.getInventoryValue("unlock_" .. book.name) == true)
    local isDownloaded = (not book.isDownloadable) or downloadManager.hasDownloaded(book)
    print("", "isDownloaded", isDownloaded)
    if book.isFree then
        if book.isDownloadable and isDownloaded and not downloadManager.isUpdateAvailable(book) then
            print("", "isUpdateAvailable", false)
            timer.performWithDelay(
                100,
                function()
                    self.smc:onClose()
                    self.smc:gotoBook(book)
                end
            )
        else
            local event = {
                target = {
                    book = book,
                    selectedBook = book.name,
                    isPurchased = book.isFree ,
                    isDownloaded = isDownloaded
                }
            }
            if cmd.showOverlay(event) then
                timer.performWithDelay(
                    100,
                    function()
                        self.smc:createDialog(book, book.isFree , isDownloaded)
                    end
                )
            end
        end
    else
        -- Runtime:addEventListener("hideOverlay", self.smc.onClose)
        local event = {
            target = {
                book = book,
                selectedBook = book.name,
                isPurchased = isPurchased,
                isDownloaded = isDownloaded
            }
        }
        if cmd.showOverlay(event) then
            timer.performWithDelay(
                100,
                function()
                    self.smc:createDialog(book, isPurchased, isDownloaded)
                end
            )
        else
            print("", "---------- not overlay -------- ")
            if isPurchased then
                timer.performWithDelay(
                    100,
                    function()
                        self.smc:onClose()
                        self.smc:gotoBook(book)
                    end
                )
            else
                print("", "not purchased")
                timer.performWithDelay(
                    100,
                    function()
                        self.smc:onClose()
                    end
                )
            end
        end
    end
end

------------------------------
-- BookPurchased/BookNotPurchased
--
function _Class:onCreateDialog(id, isPurchased, isDownloaded)
    print("smc onCreateDialog", self.view.dialog)
    self.view.dialog:create(id, isPurchased, isDownloaded)
    self.view.dialog:control()
    self.fromDialog = true
    local book = id
    timer.performWithDelay(
        100,
        function()
            if isPurchased then
                self.smc:showDialogPurchased()
                --print("showDialogPurchased end")
                if not isDownloaded then
                    if #book.versions == 0 and not book.isFree then
                        --print("onCreateDialog onRestore ", book.name)
                        self.smc:onRestore(book)
                    end
                end
            else
                --print("showDialogNotPurchased")
                self.smc:showDialogNotPurchased()
            end
        end
    )
end

function _Class:destroyDialog()
    print("smc destroyDialog")
    self.view.dialog:destroy()
    composer.hideOverlay("fade", 400)
    self.fromDialog = false
end

function _Class:gotoScene(book, version)
    print("smc gotoScene", book.name, version)
    local _version = version
    if #book.versions > 0 and version == nil then
        local app = require(kwikGlobal.ROOT.."controller.Application")
        _version = app.lang
    end
    local event = {target = {book = book, selectedBook = book.name}}
    composer.hideOverlay("fade", 100)
    self.fromDialog = false
    timer.performWithDelay(
        300,
        function()
            --print("#############")
            cmd.gotoScene(event, _version)
        end
    )
    -- Runtime:dispachEvent("hideOverlay")
end

------------------------------
-- IAPBadger
--

function _Class:purchase(id, fromDialog)
    print("smc purchase", id, fromDialog)
    self.fromDialog = fromDialog
    IAP.buyBook({target = {selectedBook = id}})
end

function _Class:refreshDialog(isDownloaded)
    print("refreshDialog", isDownloaded)
    -- if isDownloaded then
    --     self.view.dialog:update()
    -- end
end

function _Class:refreshThumbnail()
    print("smc refreshThumbnail")
    self.view.thumbnail:refresh()
end
------------------------------
-- BookDisplayed
--
function _Class:onEntryBookDisplayed()
end

function _Class:onExitBookDisplayed()
    -- addEventListner ("tap", self.smc:showThumbnail() )
end

function _Class:exit()
    print("-------- exit ------------")
    self.smc:exit()
end

------------------------------
--
--
function _Class.callPurcahseComplete(selectedBook, version)
  local self = _Class.getInstance()
  if self.fromDialog then
      self.smc:showDialogPurchased() --selectedBook, version
      self.fromDialog = false
      print("onPurchaseComplete fromDialog")
  else
      self.smc:backThumbnail()
      self.fromThumbnail = false
  end
end

function _Class.onDownloadComplete(selectedBook, version)
    local self = _Class.getInstance()
    self.smc:onSuccess()
    if self.fromDialog then
        self.smc:fromDialog(selectedBook, version)
        self.fromDialog = false
        print("onDownloadComplete fromDialog")
    else
        self.smc:backThumbnail()
        self.fromThumbnail = false
    end
end

function _Class.onDownloadError(selectedBook, message)
    local self = _Class.getInstance()
    if self.fromDialog then
        --self.smc:fromDialog(selectedBook)
        self.smc:onFailure()
        self.fromDialog = false
    else
        self.smc:backThumbnail()
        self.fromThumbnail = false
    end
    self.view.onDownloadError(selectedBook, message)
end
--
-- purchase and restore call this purchaseListener
-- and IAP.lua also fires command:purcahseComplted wth purchase/restore
--
function _Class.purchaseListener(product)
    local self = _Class.getInstance()
    local book = self.model.books[product]
    if #book.versions == 0 and book.isDownloadable then
        self.smc:startDownload(book)
    else
        self.smc:showDialogPurchased()
        self.view.dialog:update(product)
    end
end

function _Class.failedListener()
    local self = _Class.getInstance()
    print("page02", "failedListener", self.fromDialog)
    if self.fromDialog then
        self.smc:onPurchaseCancel()
    else
        self.smc:backThumbnail()
    end
end
--
function _Class:init(view)
    print("========= smc init ===============", self.model, view)
    self.view = view
    local filter = {}
    --cmd:init(view)
    IAP:init(
        self.model.name,
        self.model.catalogue,
        view.restoreAlert,
        function(product)
            self.purchaseListener(product)
            view.purchaseAlert()
        end,
        self.failedListener,
        self.model.debug
    )
    downloadManager.init(self.model, self.onDownloadComplete, self.onDownloadError) --
    self.smc:enterStartState()
    if (system.getInfo("environment") == "simulator") then
       self.smc:setDebugFlag(true)
    end
    if downloadManager.isDownloadQueue() then
        self.fromThumbnail = true
        self.smc:onDownloadQueue()
    else
        self.smc:showThumbnail(filter)
    end
end

function _Class:initDialog(view)
  print("========= smc init Dialog ===============")
  self.view = view
  -- mydebug.print()
  if self.model.currentBook.isPurchased then
      self.smc:showDialogPurchased()
  else
      self.smc:showDialogNotPurchased()
  end
end

function _Class:resume()
    print("smc resume")
    self.view:refresh(true)
end

return _Class
