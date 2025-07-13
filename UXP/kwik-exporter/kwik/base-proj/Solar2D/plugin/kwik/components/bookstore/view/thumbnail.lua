local M = {}
--
local util = require(kwikGlobal.ROOT.."components.bookstore.view.thumbnailUtil")
--
local LABEL_NAME = "saved_"
--
function M.new(view, cmd, fsm, group)
  local instance = {
    CMD        = cmd,
    sceneGroup = group,
    model      = view.model
  }
  util:init(view, cmd, fsm, group)

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

  --
  function instance:setSceneGroup(group)
    self.sceneGroup = group
  end
  --
  function instance:create(filter)
    print("--- VIEW create ---")
    for k, book in pairs(self.model.books) do
      print(book.name)
      local obj = self.sceneGroup[book.name .. "Icon"]
      local label = self.sceneGroup[book.name .. "Banner"]
      if obj then
        util:setButton(obj, book, nil, label)
      else
        if book.versions then
          for i = 1, #book.versions do
            obj = self.sceneGroup[book.name .. "_" .. book.versions[i]]
            label = self.sceneGroup[book.name .. "_" .. book.versions[i] .. "_Banner"]
            --print(book.name .. "_"..book.versions[i])
            if obj and label then
              util:setButton(obj, book, book.versions[i], label)
            end
          end
        end
      end
    end
    --
    print("--- VIEW create --- end")
  end
  --
  --
  function instance:control()
    print("--- VIEW create control ---")
    for k, book in pairs(self.model.books) do
      --print("controlThumbnail",book.name)
      local obj = self.sceneGroup[book.name .. "Icon"]
      if obj then
        util:setButtonListener(obj, book)
      else
        if book.versions then
          for i = 1, #book.versions do
            obj = self.sceneGroup[book.name .. "_" .. book.versions[i]]
            if obj then
              util:setButtonListener(obj, book, book.versions[i])
            end
          end
        end
      end
    end
    if self.sceneGroup.restoreBtn then
      self.sceneGroup.restoreBtn:addEventListener("tap", self.CMD.restore)
    end
    if self.sceneGroup.hideOverlayBtn then
      self.sceneGroup.hideOverlayBtn:addEventListener("tap", self.CMD.hideOverlay)
    end
  end
  --
  function instance:refresh()
    print("VIEW refreshThumbnail")
    for k, book in pairs(self.model.books) do
      local obj = self.sceneGroup[book.name .. "Icon"]
      if obj then
        util:refreshButton(obj, book)
      else
        if book.versions then
          for i = 1, #book.versions do
            obj = self.sceneGroup[book.name .. "_" .. book.versions[i]]
            if obj then
              util:refreshButton(obj, book)
            end
          end
        end
      end
    end
  end
  --
  function instance:destroy()
    print("instance:destroyThumbnail")
    for k, book in pairs(self.model.books) do
      local obj = self.sceneGroup[book.name .. "Icon"]
      if obj then
        if obj.purchaseBtn then
          obj.purchaseBtn:removeEventListener("tap", obj.purchaseBtn)
        end
        obj:removeEventListener("tap", self.CMD.showOverlay)
        if obj.savedBtn then
          obj.savedBtn:removeEventListener("tap", self.CMD.gotoScene)
        end

        -- obj:removeEventListener("tap", self.CMD.gotoScene)
        util:removeButtonListener(obj, book)
      else
        if book.versions then
          for i = 1, #book.versions do
            obj = self.sceneGroup[book.name .. "_" .. book.versions[i]]
            if obj then
              util:removeButtonListener(obj, book, book.versions[i])
      end
          end
        end
      end
    end
    if self.sceneGroup.hideOverlayBtn then
      self.sceneGroup.hideOverlayBtn:removeEventListener("tap", self.CMD.hideOverlay)
    end
    if self.sceneGroup.restoreBtn then
      self.sceneGroup.restoreBtn:removeEventListener("tap", self.CMD.restore)
    end
    print("instance:destroyThumbnail", "exit")
  end
  ------

  return instance
end

return M
