# Key Event Manager Refactoring

## Overview
Refactored the key event handling system to use a centralized `keyEventManager` instead of having multiple direct `Runtime:addEventListener("key", ...)` calls throughout the editor files.

## Benefits
1. **Single Event Listener**: Only one `Runtime:addEventListener` for key events
2. **Priority System**: Handlers can be assigned priorities to control execution order
3. **Automatic Cleanup**: Prevents memory leaks from orphaned event listeners
4. **Centralized Management**: Easy to debug and maintain key event handling
5. **Event Propagation Control**: Higher priority handlers can stop event propagation

## Files Modified

### Created
- `lua_modules/kwiksher/kwik/editor/keyEventManager.lua` - Centralized key event manager

### Refactored Files

#### Completed Refactoring ✅
1. `lua_modules/kwiksher/kwik/editor/parts/baseButtons.lua`
2. `lua_modules/kwiksher/kwik/editor/action/actionCommandButtons.lua`
3. `lua_modules/kwiksher/kwik/editor/action/actionCommandTable.lua`
4. `lua_modules/kwiksher/kwik/editor/action/actionTable.lua`
5. `lua_modules/kwiksher/kwik/editor/group/layersTable.lua`
6. `lua_modules/kwiksher/kwik/editor/shape/rectTool.lua`
7. `lua_modules/kwiksher/kwik/editor/shape/index.lua`
8. `lua_modules/kwiksher/kwik/editor/replacement/listButtons.lua`
9. `lua_modules/kwiksher/kwik/editor/picker/eyedropper.lua`
10. `lua_modules/kwiksher/kwik/editor/physics/classProps.lua`
11. `lua_modules/kwiksher/kwik/editor/parts/linkboxMulti.lua`
12. `lua_modules/kwiksher/kwik/editor/parts/buttons.lua`
13. `lua_modules/kwiksher/kwik/editor/parts/buttonContext.lua`
14. `lua_modules/kwiksher/kwik/editor/parts/baseTable.lua`
15. `lua_modules/kwiksher/kwik/editor/action/buttons.lua`

**Total Files Refactored: 15**

## Usage Pattern

### Before
```lua
self.onKeyEvent = function(event)
  -- handle event
  return true/false
end
Runtime:addEventListener("key", self.onKeyEvent)
-- Later...
Runtime:removeEventListener("key", self.onKeyEvent)
```

### After
```lua
local keyEventManager = require("editor.keyEventManager")

self.onKeyEvent = function(event)
  -- handle event
  return true/false
end
keyEventManager.register("uniqueHandlerId", self.onKeyEvent, priority)
-- Later...
keyEventManager.unregister("uniqueHandlerId")
```

## Handler IDs Used

### Static Handler IDs
- `"baseButtons_" .. self.commandClass` - for baseButtons instances
- `"actionCommandButtons"` - for action command buttons
- `"actionCommandTable"` - for action command table
- `"actionTable"` - for action table
- `"layersTable"` - for layers table
- `"rectTool"` - for rectangle drawing tool
- `"shapeDrawRect"` - for shape drawing rectangle function
- `"shapeDrawText"` - for shape drawing text function
- `"replacementListButtons"` - for replacement list buttons
- `"eyedropper"` - for color picker eyedropper tool
- `"physicsClassProps"` - for physics class properties
- `"linkboxMulti"` - for multi-selection linkbox
- `"actionButtons"` - for action buttons (commented)

### Dynamic Handler IDs (with fallbacks)
- `"partsButtons_" .. (self.id or "default")` - for parts buttons with instance ID
- `"buttonContext_" .. (self.name or "default")` - for button context with name
- `"baseTable_" .. (self.name or "default")` - for base table with name

## Priority Levels
- `1` - All refactored handlers use priority 1
- `0` - Default priority for other handlers

Higher priority handlers are called first and can prevent lower priority handlers from receiving events by returning `true`.

## Final Status

🎉 **REFACTORING COMPLETE**: All files in the editor folder that previously used direct Runtime key event listeners have been successfully refactored to use the centralized `keyEventManager` system.

### Verification
- ✅ No direct `Runtime:addEventListener("key", ...)` calls remain in editor files
- ✅ No direct `Runtime:removeEventListener("key", ...)` calls remain in editor files
- ✅ All files properly import `keyEventManager`
- ✅ All handlers use unique IDs to prevent conflicts
- ✅ Syntax validation completed for all refactored files
