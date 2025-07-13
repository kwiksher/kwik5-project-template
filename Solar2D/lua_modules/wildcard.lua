local exports = {}
--
function exports.matchesWildCardedString(stringToMatch, wildCardedString)
  -- print(wildCardedString)
  local magicalChars  =  '[^%w%s~{\\}:&(/)<>,?@#|_^*$]'  -- Lua 'magical chars'
  local regExpression = ('^' .. wildCardedString:gsub("[%^$]",".")) -- make it a valid regexpression

  if wildCardedString:find('*') and wildCardedString:find('?') then
      print('Not possible to combine single char wildcard(s) "?" with multi char wildcard(s) "*"')
      return false
  elseif wildCardedString:find('*') then -- a * wild-card was used
      wildCardedString = (regExpression:gsub("*", ".*") .. '$'):gsub(magicalChars,'.') -- replace * with .* (Lua for zero or more of any char)
  elseif wildCardedString:find('?') then -- a ? wild-card was used
      wildCardedString = (regExpression:gsub("?", ".") .. '$'):gsub(magicalChars,'.') -- replace ? with . (Lua for single any char)
  end

  return stringToMatch:match(wildCardedString) == stringToMatch
end

return exports