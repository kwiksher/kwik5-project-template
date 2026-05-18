local original_require = require

-- TODO load once and set it for package.loaded[]

-- require = function(...)
--   local modName = ...
--   -- modName = modName:gsub("com.gieson", "com.gieson")
--   -- modName = modName:gsub("Tools", "com.gieson.Tools")
--   -- modName = modName:gsub("TouchHandlerObj", "com.gieson.TouchHandlerObj")
--   modName = modName:gsub("materialui", "materialui")
--   modName = modName:gsub("nanostores.index", "nanostores.nanostores")
--   modName = modName:gsub("lib.clean%-stores", "nanostores.lib.clean-stores")
--   modName = modName:gsub("lib.create%-derived", "nanostores.lib.create-derived")
--   modName = modName:gsub("lib.create%-map", "nanostores.lib.create-map")
--   modName = modName:gsub("lib.create%-store", "nanostores.lib.create-store")
--   modName = modName:gsub("lib.define%-map", "nanostores.lib.define-map")
--   modName = modName:gsub("lib.effect", "nanostores.lib.effect")
--   modName = modName:gsub("lib.get%-value", "nanostores.lib.get-value")
--   modName = modName:gsub("lib.keep%-active", "nanostores.lib.keep-active")
--   modName = modName:gsub("lib.lualib_bundle", "nanostores.lib.lualib_bundle")
--   modName = modName:gsub("lib.update", "nanostores.lib.update")
--   return original_require(modName)
-- end

--dmc = require("dmc_utils")
