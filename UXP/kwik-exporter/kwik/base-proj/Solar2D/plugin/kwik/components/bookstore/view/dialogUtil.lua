local M = {}

local marker = require(kwikGlobal.ROOT.."components.bookstore.view.marker")

function M:init(view, cmd, fsm, group)
  self.VIEW = view
  self.CMD = cmd
  self.sceneGroup = group
  self.fsm = fsm
end

function M:setDialogButton(obj, book, lang)
  print("setDialogButton", book.name, book.selectedVersion, book.isOnlineImg)

  self.VIEW.downloadGroup[book.name] = obj

  obj.lang = lang
  obj.versions = {}
  obj.labels   = {}
  obj.selectedBook = book.name
  obj.selectedVersion = book.selectedVersion
  obj.fsm = self.fsm

  --If the user has purchased the book before, change the obj
  obj.purchaseBtn = self.VIEW:copyDisplayObject(self.sceneGroup.purchaseBtn, nil, book, self.sceneGroup)
  obj.purchaseBtn.selectedBook = book.name
  if book.isDownloadable then
      obj.savingTxt = self.VIEW:copyDisplayObject(self.sceneGroup.savingTxt, nil, book, self.sceneGroup)
      obj.savedBtn = self.VIEW:copyDisplayObject(self.sceneGroup.savedBtn, nil, self.VIEW.book, self.sceneGroup)
      if book.versions == nil or #book.versions == 0 then
          obj.downloadBtn = self.VIEW:copyDisplayObject(self.sceneGroup.downloadBtn, nil, book, self.sceneGroup)
      end
  end
  --
  -- obj image then
  --
  if book.isOnlineImg then
    self.CMD:setButtonImage(obj, book.name, lang)
  else
      local src = self.sceneGroup[book.name.."Icon"] or self.sceneGroup[book.name.."_"..lang]
      if src then
          print(src.imagePath)
          obj.fill = {
              type = "image",
              filename = self.VIEW.imgDir .. src.imagePath,
              baseDir = self.VIEW.systemDir
          }
      end
  end
  obj.alpha = 1
  -- print("setDialogButton end")
end


function M:setControls(obj, _isFree)
  local isFree = _isFree or obj.book.isFree
  print("setVersionButtons", #obj.book.versions, isFree)
  obj.fsm = self.fsm

  if self.lang == "" then
    obj.selectedVersion = "en"
  else
      obj.selectedVersion = self.lang
  end
  if self.CMD.hasDownloaded(obj.selectedBook, obj.selectedVersion) then
      print("downloaded")
      function obj:tap(e)
          self.fsm.smc:clickImage(self.book, self.selectedVersion)
          return true
      end
      obj:addEventListener("tap", obj)
  else
      print("not downloaded yet")
      if isFree then
          obj.downloadBtn.book = obj.book
          obj.downloadBtn.selectedVersion = obj.selectedVersion
          function obj.downloadBtn:tap(e)
              self.fsm.smc:startDownload(self.book, self.selectedVersion)
              return true
          end
          obj.downloadBtn.alpha = 1
          obj.downloadBtn:addEventListener("tap", obj.downloadBtn)
      else
          function obj:tap(e)
              self.fsm.smc:startDownload(self.book, self.selectedVersion)
              return true
          end
          obj:addEventListener("tap", obj)
      end
  end

  if self.CMD.isUpdateAvailable(obj.book, obj.selectedVersion) then
      -- show downloadBtn
      --print("", "isUpdateAvailable")
      obj.downloadBtn.book = obj.book
      obj.downloadBtn.selectedVersion = obj.selectedVersion
      function obj.downloadBtn:tap(e)
          self.fsm.smc:startDownload(self.book, self.selectedVersion)
          return true
      end
      obj.downloadBtn.alpha = 1
      obj.downloadBtn:addEventListener("tap", obj.downloadBtn)
      --print(self.sceneGroup)
      --print ("", "marker.new", obj.downloadBtn, self.sceneGroup)
      marker.new(obj.downloadBtn, self.sceneGroup)
      --print("", "marker.new ended")
  end
end

function M:setControlsVersion(obj, _isFree)
  local isFree = _isFree or obj.book.isFree
  print("setVersionButtons", #obj.versions, isFree)
  obj.fsm = self.fsm
  for i = 1, #obj.versions do
      local versionBtn = obj.versions[i]
      local labelBtn   = obj.labels[i] or {}
      labelBtn.alpha = 0
      if versionBtn then
          if self.CMD.hasDownloaded(obj.book, versionBtn.selectedVersion) then
              print(versionBtn.selectedVersion .. "(saved)")
              function versionBtn:tap(e)
                  print("versionBtn tap for gotoScene")
                  --self.gotoScene
                  self.fsm.smc:clickImage(self.book, self.selectedVersion)
                  return true
              end
              versionBtn:addEventListener("tap", versionBtn)
              labelBtn.alpha = 1
          else
              print(versionBtn.selectedVersion .. "(not saved)")
              -- Runtime:dispatchEvent({name = "downloadManager:purchaseCompleted", target = book.versions[i]})
              function versionBtn:tap(e)
                  print("versionBtn tap for download")
                  self.fsm.smc:startDownload(self.book, self.selectedVersion)
                  return true
              end
              versionBtn:addEventListener("tap", versionBtn)
          end

          if self.CMD.isUpdateAvailable(obj.book, versionBtn.selectedVersion) then
              -- show downloadBtn
              function versionBtn:tap(e)
                  self.fsm.smc:startDownload(self.book, self.selectedVersion)
                  return true
              end
              versionBtn:addEventListener("tap", versionBtn)
              marker.new(versionBtn, self.sceneGroup)
          end

      else
          print("Error to find versionBtn")
      end

  end
end
--

return M