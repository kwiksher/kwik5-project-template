local M = {}
--
function M:restore()
	local IAP = require("components.store.IAP")
	IAP.restore()
end
--
function M:refund()
 --Add code for refund
end
--
function M:buy(product)
	local IAP = require("components.store.IAP")
	if IAP.canMakePurchases() then
			local event = {target={selectedPurchase=product}}
			IAP.buyEpisode(event)
	  -- store.purchase(product)
	else
	  native.showAlert("Alert", "Store purchases are not available, please try again later",  { "OK" } )
	end
end
--
return M