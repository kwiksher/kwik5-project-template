local M = {}

local marker = require(kwikGlobal.ROOT.."components.bookstore.view.marker")

function M:init(view, cmd, fsm, group)
  self.CMD = cmd
  self.VIEW = view
  self.sceneGroup = group
  self.fsm   = fsm
end

function M:setButton(obj, book, lang, label)
  obj.selectedBook = book.name
  obj.lang = lang
  self.VIEW.downloadGroup[book.name] = obj
  --If the user has purchased the book before, change the obj
  obj.purchaseBtn = self.VIEW:copyDisplayObject(self.sceneGroup.purchaseBtn, obj, book.name, self.sceneGroup)
    if obj.isDownloadable then
      obj.downloadBtn =
          self.VIEW:copyDisplayObject(self.sceneGroup.downloadBtn, obj, book.name, self.sceneGroup)
      obj.savingTxt = self.VIEW:copyDisplayObject(self.sceneGroup.savingTxt, obj, book.name, self.sceneGroup)
  end
  obj.savedBtn = self.VIEW:copyDisplayObject(self.sceneGroup.savedBtn, obj, book.name, self.sceneGroup)
  if book.isFree then
      obj.purchaseBtn.alpha = 0
  end
  --
  -- obj image
  --
  if book.isOnlineImg then
      self.CMD:setButtonImage(obj, book.name, lang)
  end
  if obj.isDownloadable and self.CMD.isUpdateAvailable(book) then
      marker.new(obj, self.sceneGroup)
  end
  --
  -- label
  --
  if label then
      self.CMD:setButtonImage(label, book.name, lang)
  end
end

function M:setButtonListener(obj, book, version)
  obj.book = book
  obj.fsm = self.fsm
  obj.book.selectedVersion = version

  -- Not work this transition because BookPurchased state is necessay to goto a book version
  -- function obj:tap(e)
  --     self.VIEW.fsm:gotoScene(self.VIEW.book, self.lang)
  -- end

  -- if book.versions == nil or #book.versions == 0 then
  function obj:tap(e)
      self.fsm.smc:clickImage(self.book)
      return true
  end
  obj:addEventListener("tap", obj)
  -- else
  -- button:addEventListener("tap", button)
  -- end
  --
end

function M:removeButtonListener(obj, book, version)
  obj:removeEventListener("tap", obj)
end

function M:refreshButton (obj, book)
  obj.purchaseBtn.alpha = 0
  obj.downloadBtn = 0
  obj.savedBtn.alpha = 0
  if cmd.hasDownloaded(book) then
      obj.purchaseBtn.alpha = 0
      obj.downloadBtn = 0
      obj.savedBtn.alpha = 1
  else
      obj.purchaseBtn.alpha = 1
      obj.downloadBtn = 0
      obj.savedBtn.alpha = 0
  end

  if cmd.isUpdateAvailable(book) then
      if obj.updateMark then
          obj.updateMark.alpha = 1
      else
       marker.new(obj, self.sceneGroup)
      end
  else
      if obj.updateMark then
          obj.updateMark.alpha = 0
      end
  end
end
--

return M