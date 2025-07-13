local M = {}
--
local util = require(kwikGlobal.ROOT.."components.bookstore.view.dialogUtil")
local marker = require(kwikGlobal.ROOT.."components.bookstore.view.marker")
--
---------------------------------------------------
--
local LABEL_NAME = "saved_"
--
function M.new(view, cmd, fsm, group)
  local instance = {
    CMD        = cmd,
    VIEW       = view,
    model      = view.model,
    fsm        = fsm,
    sceneGroup = group
  }
  --
  util:init(view, cmd, fsm, group)

  for k, v in pairs(group) do print(k) end

  if view.model.URL and group then
    if group.savingTxt then
        group.savingTxt.alpha = 0
    end
    if group.savedBtn then
        group.savedBtn.alpha = 0
    end
    if group.downloadBtn then
        group.downloadBtn.alpha = 0
    end
  end

  ---
  -- function instance:setSceneGroup(group)
  --   self.sceneGroup = group
  --   -- for k, v in pairs(group) do print(k) end
  --   util:init(self.VIEW, cmd, group)
  -- end
  -- --
  ---
  function instance:create(book, isPurchased, isDownloaded)
    print("instance:createDialog", book.name)
    -- init
    for k, v in pairs(self.model.books) do
      if self.sceneGroup[v.name .. "Icon"] then
        self.sceneGroup[v.name .. "Icon"].alpha = 0
      end
      for i = 1, #v.versions do
        local obj = self.sceneGroup[v.name .. "_" .. v.versions[i]]
        if obj then
          obj.alpha = 0
        end
      end
    end
    --
    self.book = book
    self.book.isPurchased = isPurchased
    self.book.isDownloaded = isDownloaded
    local obj = self.sceneGroup[book.name .. "Icon"] or self.sceneGroup[book.name .. "_" .. book.selectedVersion]
    if obj then
      util:setDialogButton(obj, book, book.selectedVersion)
    end
    --
    for i = 1, #book.versions do
      local iconLayer = self.sceneGroup[book.name .. "_" .. book.versions[i]] or {}
      iconLayer.alpha = 0
      if book.versions[i] == book.selectedVersion then
        iconLayer.alpha = 1
      end

      if self.sceneGroup["version_" .. book.versions[i]] and string.len(book.versions[i]) > 1 then
        local versionBtn = self.VIEW:copyDisplayObject( self.sceneGroup["version_" .. book.versions[i]],
          nil,
          book.name .. self.book.versions[i],
          self.sceneGroup
        )

        versionBtn.alpha = 1
        versionBtn.book = book
        versionBtn.selectedBook = book.name
        versionBtn.selectedVersion = book.versions[i]
        table.insert(obj.versions, versionBtn)
        self.versionGroup[book.name .. book.versions[i]] = versionBtn
        --
        -- labels
        local labelBtn = self.sceneGroup[LABEL_NAME .. book.versions[i]]
        labelBtn.alpha = 0
        table.insert(obj.labels, labelBtn)
      end
    end
    --
    if book.isDownloadable and #book.versions == 0 then
      obj.downloadBtn = self.VIEW:copyDisplayObject(self.sceneGroup.downloadBtn, nil, book.name, self.sceneGroup)
    end
    print("instance:createDialog end")
  end
  --
  --
  function instance:control()
    print("instance:control")
    local book = self.book
    local obj = self.sceneGroup[book.name .. "Icon"] or self.sceneGroup[book.name .. "_" .. book.selectedVersion]
    if obj == nil then print("", "Error") return end
    obj.book = book
    if book.isFree or book.isPurchased then
      if #book.versions == 0 then
        --
        -- util:setControls(obj, book.isFree)
        --
        if book.isDownloaded or not book.isDownlodable then
          function obj:tap(e)
            print("clickImage")
            self.fsm.smc:clickImage(self.book)
            return true
          end
          obj:addEventListener("tap", obj)
          -- obj.savedBtn.alpha = 1
          -- obj.savedBtn:addEventListener(
          --   "tap",
          --   function(e)
          --     self.fsm.smc:clickImage(self.book)
          --   end
          -- )
        end
        --
        if book.isDownloadable and (not book.isDownloaded) or self.CMD.isUpdateAvailable(book) then
          function obj.downloadBtn:tap(e)
            print("free book to be downloaded", self.book.name)
            self.fsm.smc:startDownload(self.book)
            return true
          end
          obj.downloadBtn.alpha = 1
          obj.downloadBtn.book = book
          obj.downloadBtn:addEventListener("tap", obj.downloadBtn)
          marker.new(obj.downloadBtn, self.sceneGroup)
        end
      else
        util:setControlsVersion(obj, book.isFree)
      end
    else
      print(book.name .. "(not purchased)")
      --Otherwise add a tap listener to the obj that unlocks the book
      obj.purchaseBtn.alpha = 1
      function obj.purchaseBtn:tap(e)
        print("tap purchaseBtn", self.selectedBook, e.target.selectedBook)
        self.fsm.smc:clickPurchase(self.selectedBook, true)
        return true
      end
      obj.purchaseBtn:addEventListener("tap", obj.purchaseBtn)
      --
      if #book.versions==0 then
        for i = 1, #obj.versions do
          local versionBtn = obj.versions[i]
          if versionBtn then
            function versionBtn:tap(e)
              --self.self.CMD.startDownloadVersion
              self.fsm.smc:clickPurchase(self.selectedBook, true)
              return true
            end
            versionBtn:addEventListener("tap", versionBtn)
          end
        end
      end
    end

    --
    print("hideOverlayBtn", self.sceneGroup.hideOverlayBtn)
    if self.sceneGroup.hideOverlayBtn then
      self.sceneGroup.hideOverlayBtn.fsm = self.fsm
      function self.sceneGroup.hideOverlayBtn:tap(e)
        self.fsm.smc:clickCloseDialog()
        return true
      end
      self.sceneGroup.hideOverlayBtn:addEventListener("tap", self.sceneGroup.hideOverlayBtn)
    end

    if self.sceneGroup.infoTxt then
      self.sceneGroup.infoTxt.text = self.model.books[book.name].info
      self.sceneGroup.infoTxt.x = self.sceneGroup.infoTxt.oriX
      self.sceneGroup.infoTxt.y = self.sceneGroup.infoTxt.oriY
      self.sceneGroup.infoTxt.anchorX = 0.5
      self.sceneGroup.infoTxt.anchorY = 0.5
    end
  end
  --
  --
  function instance:update(selectedBook)
    print("dilaog:updateDialog", selectedBook)
    local obj = self.VIEW.downloadGroup[selectedBook]
    --self.book  = selectedBook
    -- obj.text.text=selectedBook.."(saved)"
    if #obj.book.versions == 0 then
      if obj.book.isDownloadable then
        obj.savingTxt.alpha = 0
        obj.savedBtn.alpha = 1
        obj.downloadBtn.alpha = 0
        obj.purchaseBtn.alpha = 0
        if obj.tap  then
          obj.downloadBtn:removeEventListener("tap", obj)
        end
      end
      if obj.updateMark then
        obj.updateMark.alpha = 0
      end
      function obj:tap(e)
        self.fsm.smc:clickImage(self.book)
        return true
      end
      obj:addEventListener("tap", obj)
    else
      -- local versions = self.model.books[selectedBook].versions
      -- for k, v in pairs(versions) do print(k, v) end
      -- for i=1, #versions do
      --     local versionBtn = self.versionGroup[selectedBook..versions[i]]
      --     print(selectedBook..versions[i],versionBtn)
      --     if versionBtn then
      --         if versionBtn.tap then
      --                 print("removeEventListener")
      --             versionBtn:removeEventListener("tap", versionBtn)
      --         end
      --         function versionBtn:tap(e)
      --                 self.fsm.smc:clickImage(self.book, self.selectedVersion)
      --         end
      --         versionBtn:addEventListener("tap", versionBtn)
      --         self.versionGroup[selectedBook..versions[i]] = nil
      --     end
      -- end
      print(1)
      if obj.book.isDownloadable then
        if obj.savingTxt then
          obj.savingTxt.alpha = 0
        end
        if obj.savedBtn then
          obj.savedBtn.alpha = 1
        end
        if obj.downloadBtn then
          obj.downloadBtn.alpha = 0
        end
        if obj.purchaseBtn then
          obj.purchaseBtn.alpha = 0
        end
      end

      if obj.updateMark then
        obj.updateMark.alpha = 0
      end
      -- not found. It means it is a version obj
      util:setVersionButtons(obj)
      print("dilaog:updateDialog end")
    end
  end
  --
  function instance:destroy()
  end
  --
  function instance:refresh()
    self.CMD:init(self)
    for k, book in pairs(self.model.books) do
      local obj = self.sceneGroup[book.name .. "Icon"]
      if obj then
        print("-------- refresh ---------", self, obj)
        self.VIEW.downloadGroup[book.name] = obj
        obj.purchaseBtn.alpha = 0
        if book.isDownloadable then
          if obj.savingTxt then
            obj.savingTxt.alpha = 0
          end
          if obj.savedBtn then
            obj.savedBtn.alpha = 0
          end
          if obj.downloadBtn then
            obj.downloadBtn.alpha = 0
          end
        end
      --
      end
    end
  end
  --
  return instance
end

return M
