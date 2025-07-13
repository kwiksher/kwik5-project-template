local M = {}
--
local cmd = require(kwikGlobal.ROOT.."components.bookstore.controller.command").new()
local app = require(kwikGlobal.ROOT.."controller.Application")
local thumbnail = require(kwikGlobal.ROOT.."components.bookstore.view.thumbnail")
local dialog = require(kwikGlobal.ROOT.."components.bookstore.view.dialog")
local _W = display.contentWidth
local _H = display.contentHeight
--

function M.getInstance(model)
  if model then
    M.model = model
    M.downloadGroup = {}
    M.versionGroup = {}
    M.book = nil
    M.model = model
  end
  if _instance == nil then
      local o = {}
      _instance = setmetatable(o, {__index = M})
  end
  return _instance
end

function M:copyDisplayObject(src, dst, id, group)
  print("copyDisplay object", self.imgDir,  src.imagePath, group)
  local obj = display.newImageRect(self.imgDir .. src.imagePath, self.systemDir, src.width, src.height)
  if obj == nil then
      print("copyDisplay object fail", id)
  end
  if dst then
      obj.x = dst.x + src.x - _W / 2
      obj.y = dst.y + src.y - _H / 2
  else
      obj.x = src.x
      obj.y = src.y
  end
  src.alpha = 0
  obj.alpha = 0
  obj.selectedBook = id
  group:insert(obj)
  obj.fsm = self.fsm
  return obj
end

  --
  function M.onDownloadError(selectedBook, message)
      -- CMD.downloadGroup[selectedBook].text.text="download error"
      native.showAlert(
          "Failed",
          self.model.downloadErrorMessage,
          {"Okay"},
          function()
              M.fsm:back()
          end
      )
  end

  function M:initDialog(group)
    self.dialog = dialog.new(self, self.CMD, self.fsm, group)
  end

  function M:init(group, props, fsm)
      --for k, v in pairs(props) do print(k, v) end
      self.props = props
      self.fsm = fsm
      self.lang = props.lang
      self.imgDir = props.imgDir
      self.systemDir = props.systemDir
      self.CMD = cmd
      self.model:initPages(app.lang)
      cmd:init(group, self.model, self.downloadGroup, fsm.callPurcahseComplete)
      self.thumbnail = thumbnail.new(self, cmd, fsm, group)
  end

return M
