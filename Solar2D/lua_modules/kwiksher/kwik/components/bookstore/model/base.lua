local M = {}
--
local IAP             = require(kwikGlobal.ROOT.."components.bookstore.controller.IAP")
--
M.bookShelfType  = 1 --{none = -1, pages = 0, embedded = 1, tmplt=2}
--
M.debug     = true
----------------------------------
-- M.URL = nil means simple IAP store without network download like Kwik3 IAP
-- downloadBtn, savingTxt won'T be used. You don't need to create them.
--
M.URL           = "http://localhost:8080/books/"
M.downloadable  = true
M.backgroundImg = "bg.png"
----------
----------
--
function M:initPages(_lang)
  self.downloadable = self.URL ~= nil
  --
  local lang                = _lang or ""
  self.LIBRARY_PAGE         = self.LIBRARY_PAGES[lang]
  self.DIALOG_PAGE          = self.DIALOG_PAGES[lang]
  self.purchaseAlertMessage = self.purchaseAlertMessages[lang]
  self.restoreAlertMessage  = self.restoreAlertMessages[lang]
  self.downloadErrorMessage = self.downloadErrorMessages[lang]
  self.catalogue            = self:createCatalog()
  self.info                 = self.descriptions[lang]
  self.title                = self.titles[lang]
end

function M:createCatalog()
  local ret = {products={}, inventoryItems = {}}
  for k, v in pairs(self.books) do
    local product = {
      productNames = { apple=v.productNames.apple, google=v.productNames.google,
        amazon=v.productNames.amazon},
      productType  = "non-consumable",
      onPurchase   = function() IAP.setInventoryValue("unlock_"..v.name) end,
      onRefund     = function() IAP.removeFromInventory("unlock_"..v.name) end,
    }
    ret.products[k] = product
    ret.inventoryItems["unlock_"..v.name] ={ productType="non-consumable" }
  end
  return ret
end

--
--
M.getPageNum = function(book)
    local pNum = M.books[book].startPage
    pNum = pNum:sub(16)
    return pNum
end
--
--
M.getPageName = function (book)
    local pNum = M.books[book].dir
    pNum = pNum:sub(16)
    return "views.page0"..pNum.."Scene"
end
--
--
M.getPageInfo = function (book)
    print(book)
    local pNum = M.books[book].info
    if string.len(pNum) > 0 then
        return "views.page0"..pNum.."Scene"
    else
        return nil
    end
end
--
return M