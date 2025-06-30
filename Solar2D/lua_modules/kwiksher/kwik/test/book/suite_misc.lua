local M = {}

function M.init(props)
end

function M.suite_setup()
end

function M.setup()
end

function M.teardown()
end

function M.test_util()
  local util = require("editor.util")
  local scene = require("App.mybook.components.page1.index")
  local model = util.selectFromIndexModel(scene.model, {"bg10"})
  printTable(model.value.class)

  for k, v in pairs(model.value) do
    print(k, v)
    if k == "class" then
      for i, class in next, v do
        --classEntries[#classEntries+1] = class
        print(class)
      end
    end
  end


end

local wildcard= require("wildcard")

-- https://www.domoticz.com/forum/viewtopic.php?t=29900
-- '*' wildcard for 0 or more chars.
-- '?' wildcard for 1 char
-- Not possible to combine single char wildcard(s) "?" with multi char wildcard(s) "*"
function M.xtest_wtildCardedString()
  local test = "/page1/test.png"
  print(wildcard.matchesWildCardedString(test, '?page1*')) -- false
  print(wildcard.matchesWildCardedString(test, '*page*'))
  print(wildcard.matchesWildCardedString(test, '*.png'))
  print(wildcard.matchesWildCardedString(test, '/page1/*.png'))
  print(wildcard.matchesWildCardedString(test, '/page?/tes?.png'))

  --[[
  text
    https://forums.solar2d.com/t/text-formatting-additions/355107/17
    Unity and loved Text Mesh Pro
    truetype_sample.zip

  Wildcards (?, *) in lua are . and .*. Correct if condition:

    ```
    if name = string.match(name, '^Bob.*$') then
      return 0
    end
    ```

  https://www.domoticz.com/forum/viewtopic.php?t=29900
  '*' wildcard for 0 or more chars.
  '?' wildcard for 1 char
  ```
  local function matchesWildCardedString(stringToMatch, wildCardedString)
    local magicalChars  =  '[^%w%s~{\\}:&(/)<>,?@#|_^*$]'  -- Lua 'magical chars'
    local regExpression = ('^' .. wildCardedString:gsub("[%^$]",".")) -- make it a valid regexpression

    if wildCardedString:find('*') and wildCardedString:find('?') then
        dz.log('Not possible to combine single char wildcard(s) "?" with multi char wildcard(s) "*"',dz.LOG_ERROR)
        return false
    elseif wildCardedString:find('*') then -- a * wild-card was used
        wildCardedString = (regExpression:gsub("*", ".*") .. '$'):gsub(magicalChars,'.') -- replace * with .* (Lua for zero or more of any char)
    elseif wildCardedString:find('?') then -- a ? wild-card was used
        wildCardedString = (regExpression:gsub("?", ".") .. '$'):gsub(magicalChars,'.') -- replace ? with . (Lua for single any char)
    end

    return stringToMatch:match(wildCardedString) == stringToMatch
  end

  if matchesWildCardedString(item.name, 'doorsensor*') then
    print("found")
   end
  ```

  https://stackoverflow.com/questions/21433672/lua-pattern-to-match-the-path
  --]]

end

return M


