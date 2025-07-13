--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports

local FAILED = 0
local SUCCESS = 1
local RUNNING = 2
local FALLBACK = "fallback"
local SEQUENCE = "sequence"
local PARALLEL = "parallel"
local ACTION = "action"
local CONDITION = "condition"

local function __TS__StringTrim(self)
  local result = string.gsub(self, "^[%s ﻿]*(.-)[%s ﻿]*$", "%1")
  return result
end

local function __TS__StringSubstr(self, from, length)
  if from ~= from then
    from = 0
  end
  if length ~= nil then
    if length ~= length or length <= 0 then
      return ""
    end
    length = length + from
  end
  if from >= 0 then
    from = from + 1
  end
  return string.sub(self, from, length)
end

local function __TS__StringSubstring(self, start, ____end)
  if ____end ~= ____end then
    ____end = 0
  end
  if ____end ~= nil and start > ____end then
    start, ____end = ____end, start
  end
  if start >= 0 then
    start = start + 1
  else
    start = 1
  end
  if ____end ~= nil and ____end < 0 then
    ____end = 0
  end
  return string.sub(self, start, ____end)
end

local __TS__Match = string.match

local __TS__ParseInt
do
  local parseIntBasePattern = "0123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTvVwWxXyYzZ"
  function __TS__ParseInt(numberString, base)
    if base == nil then
      base = 10
      local hexMatch = __TS__Match(numberString, "^%s*-?0[xX]")
      if hexMatch then
        base = 16
        local ____TS__Match_result__0_0
        if __TS__Match(hexMatch, "-") then
          ____TS__Match_result__0_0 = "-" .. __TS__StringSubstr(numberString, #hexMatch)
        else
          ____TS__Match_result__0_0 = __TS__StringSubstr(numberString, #hexMatch)
        end
        numberString = ____TS__Match_result__0_0
      end
    end
    if base < 2 or base > 36 then
      return 0 / 0
    end
    local ____temp_1
    if base <= 10 then
      ____temp_1 = __TS__StringSubstring(parseIntBasePattern, 0, base)
    else
      ____temp_1 = __TS__StringSubstr(parseIntBasePattern, 0, 10 + 2 * (base - 10))
    end
    local allowedDigits = ____temp_1
    local pattern = ("^%s*(-?[" .. allowedDigits) .. "]*)"
    local number = tonumber(__TS__Match(numberString, pattern), base)
    if number == nil then
      return 0 / 0
    end
    if number >= 0 then
      return math.floor(number)
    else
      return math.ceil(number)
    end
  end
end

local function __TS__Class(self)
  local c = {prototype = {}}
  c.prototype.__index = c.prototype
  c.prototype.constructor = c
  return c
end

local function __TS__New(target, ...)
  local instance = setmetatable({}, target.prototype)
  instance:____constructor(...)
  return instance
end

local function __TS__ClassExtends(target, base)
  target.____super = base
  local staticMetatable = setmetatable({__index = base}, base)
  setmetatable(target, staticMetatable)
  local baseMetatable = getmetatable(base)
  if baseMetatable then
    if type(baseMetatable.__index) == "function" then
      staticMetatable.__index = baseMetatable.__index
    end
    if type(baseMetatable.__newindex) == "function" then
      staticMetatable.__newindex = baseMetatable.__newindex
    end
  end
  setmetatable(target.prototype, base.prototype)
  if type(base.prototype.__index) == "function" then
    target.prototype.__index = base.prototype.__index
  end
  if type(base.prototype.__newindex) == "function" then
    target.prototype.__newindex = base.prototype.__newindex
  end
  if type(base.prototype.__tostring) == "function" then
    target.prototype.__tostring = base.prototype.__tostring
  end
end

local __TS__Symbol, Symbol
do
  local symbolMetatable = {
    __tostring = function(self)
      return ("Symbol(" .. (self.description or "")) .. ")"
    end
  }
  function __TS__Symbol(description)
    return setmetatable({description = description}, symbolMetatable)
  end
  Symbol = {
    iterator = __TS__Symbol("Symbol.iterator"),
    hasInstance = __TS__Symbol("Symbol.hasInstance"),
    species = __TS__Symbol("Symbol.species"),
    toStringTag = __TS__Symbol("Symbol.toStringTag")
  }
end

local __TS__Iterator
do
  local function iteratorGeneratorStep(self)
    local co = self.____coroutine
    local status, value = coroutine.resume(co)
    if not status then
      error(value, 0)
    end
    if coroutine.status(co) == "dead" then
      return
    end
    return true, value
  end
  local function iteratorIteratorStep(self)
    local result = self:next()
    if result.done then
      return
    end
    return true, result.value
  end
  local function iteratorStringStep(self, index)
    index = index + 1
    if index > #self then
      return
    end
    return index, string.sub(self, index, index)
  end
  function __TS__Iterator(iterable)
    if type(iterable) == "string" then
      return iteratorStringStep, iterable, 0
    elseif iterable.____coroutine ~= nil then
      return iteratorGeneratorStep, iterable
    elseif iterable[Symbol.iterator] then
      local iterator = iterable[Symbol.iterator](iterable)
      return iteratorIteratorStep, iterator
    else
      return ipairs(iterable)
    end
  end
end

local Map
do
  Map = __TS__Class()
  Map.name = "Map"
  function Map.prototype.____constructor(self, entries)
    self[Symbol.toStringTag] = "Map"
    self.items = {}
    self.size = 0
    self.nextKey = {}
    self.previousKey = {}
    if entries == nil then
      return
    end
    local iterable = entries
    if iterable[Symbol.iterator] then
      local iterator = iterable[Symbol.iterator](iterable)
      while true do
        local result = iterator:next()
        if result.done then
          break
        end
        local value = result.value
        self:set(value[1], value[2])
      end
    else
      local array = entries
      for ____, kvp in ipairs(array) do
        self:set(kvp[1], kvp[2])
      end
    end
  end
  function Map.prototype.clear(self)
    self.items = {}
    self.nextKey = {}
    self.previousKey = {}
    self.firstKey = nil
    self.lastKey = nil
    self.size = 0
  end
  function Map.prototype.delete(self, key)
    local contains = self:has(key)
    if contains then
      self.size = self.size - 1
      local next = self.nextKey[key]
      local previous = self.previousKey[key]
      if next and previous then
        self.nextKey[previous] = next
        self.previousKey[next] = previous
      elseif next then
        self.firstKey = next
        self.previousKey[next] = nil
      elseif previous then
        self.lastKey = previous
        self.nextKey[previous] = nil
      else
        self.firstKey = nil
        self.lastKey = nil
      end
      self.nextKey[key] = nil
      self.previousKey[key] = nil
    end
    self.items[key] = nil
    return contains
  end
  function Map.prototype.forEach(self, callback)
    for ____, key in __TS__Iterator(self:keys()) do
      callback(nil, self.items[key], key, self)
    end
  end
  function Map.prototype.get(self, key)
    return self.items[key]
  end
  function Map.prototype.has(self, key)
    return self.nextKey[key] ~= nil or self.lastKey == key
  end
  function Map.prototype.set(self, key, value)
    local isNewValue = not self:has(key)
    if isNewValue then
      self.size = self.size + 1
    end
    self.items[key] = value
    if self.firstKey == nil then
      self.firstKey = key
      self.lastKey = key
    elseif isNewValue then
      self.nextKey[self.lastKey] = key
      self.previousKey[key] = self.lastKey
      self.lastKey = key
    end
    return self
  end
  Map.prototype[Symbol.iterator] = function(self)
    return self:entries()
  end
  function Map.prototype.entries(self)
    local items = self.items
    local nextKey = self.nextKey
    local key = self.firstKey
    return {
      [Symbol.iterator] = function(self)
        return self
      end,
      next = function(self)
        local result = {done = not key, value = {key, items[key]}}
        key = nextKey[key]
        return result
      end
    }
  end
  function Map.prototype.keys(self)
    local nextKey = self.nextKey
    local key = self.firstKey
    return {
      [Symbol.iterator] = function(self)
        return self
      end,
      next = function(self)
        local result = {done = not key, value = key}
        key = nextKey[key]
        return result
      end
    }
  end
  function Map.prototype.values(self)
    local items = self.items
    local nextKey = self.nextKey
    local key = self.firstKey
    return {
      [Symbol.iterator] = function(self)
        return self
      end,
      next = function(self)
        local result = {done = not key, value = items[key]}
        key = nextKey[key]
        return result
      end
    }
  end
  Map[Symbol.species] = Map
end

local function __TS__InstanceOf(obj, classTbl)
  if type(classTbl) ~= "table" then
    error("Right-hand side of 'instanceof' is not an object", 0)
  end
  if classTbl[Symbol.hasInstance] ~= nil then
    return not (not classTbl[Symbol.hasInstance](classTbl, obj))
  end
  if type(obj) == "table" then
    local luaClass = obj.constructor
    while luaClass ~= nil do
      if luaClass == classTbl then
        return true
      end
      luaClass = luaClass.____super
    end
  end
  return false
end

local function __TS__StringIncludes(self, searchString, position)
  if not position then
    position = 1
  else
    position = position + 1
  end
  local index = string.find(self, searchString, position, true)
  return index ~= nil
end

local Error, RangeError, ReferenceError, SyntaxError, TypeError, URIError
do
  local function getErrorStack(self, constructor)
    local level = 1
    while true do
      local info = debug.getinfo(level, "f")
      level = level + 1
      if not info then
        level = 1
        break
      elseif info.func == constructor then
        break
      end
    end
    if __TS__StringIncludes(_VERSION, "Lua 5.0") then
      return debug.traceback(("[Level " .. tostring(level)) .. "]")
    else
      return debug.traceback(nil, level)
    end
  end
  local function wrapErrorToString(self, getDescription)
    return function(self)
      local description = getDescription(self)
      local caller = debug.getinfo(3, "f")
      local isClassicLua = __TS__StringIncludes(_VERSION, "Lua 5.0") or _VERSION == "Lua 5.1"
      if isClassicLua or caller and caller.func ~= error then
        return description
      else
        return (tostring(description) .. "\n") .. self.stack
      end
    end
  end
  local function initErrorClass(self, Type, name)
    Type.name = name
    return setmetatable(
      Type,
      {__call = function(____, _self, message)
          return __TS__New(Type, message)
        end}
    )
  end
  local ____initErrorClass_2 = initErrorClass
  local ____class_0 = __TS__Class()
  ____class_0.name = ""
  function ____class_0.prototype.____constructor(self, message)
    if message == nil then
      message = ""
    end
    self.message = message
    self.name = "Error"
    self.stack = getErrorStack(nil, self.constructor.new)
    local metatable = getmetatable(self)
    if not metatable.__errorToStringPatched then
      metatable.__errorToStringPatched = true
      metatable.__tostring = wrapErrorToString(nil, metatable.__tostring)
    end
  end
  function ____class_0.prototype.__tostring(self)
    local ____temp_1
    if self.message ~= "" then
      ____temp_1 = (self.name .. ": ") .. self.message
    else
      ____temp_1 = self.name
    end
    return ____temp_1
  end
  Error = ____initErrorClass_2(nil, ____class_0, "Error")
  local function createErrorClass(self, name)
    local ____initErrorClass_4 = initErrorClass
    local ____class_3 = __TS__Class()
    ____class_3.name = ____class_3.name
    __TS__ClassExtends(____class_3, Error)
    function ____class_3.prototype.____constructor(self, ...)
      ____class_3.____super.prototype.____constructor(self, ...)
      self.name = name
    end
    return ____initErrorClass_4(nil, ____class_3, name)
  end
  RangeError = createErrorClass(nil, "RangeError")
  ReferenceError = createErrorClass(nil, "ReferenceError")
  SyntaxError = createErrorClass(nil, "SyntaxError")
  TypeError = createErrorClass(nil, "TypeError")
  URIError = createErrorClass(nil, "URIError")
end

-- End of Lua Library inline imports
function expect(self, what, have)
  return ((("Expecting '" .. tostring(what)) .. "', have '") .. tostring(have)) .. "'"
end
--- Parses _sequence_ node from current position in the buffer
--
-- @param buf behavior tree model
-- @param i current index
-- @returns tuple with adjusted current parsing index and error message or null
function parseSequence(self, buf, i)
  if i <= buf:len() then
    local ch = string.sub(buf, i, i)
    if ch == ">" then
      i = i + 1
      return {i, nil}
    else
      return {
        i,
        expect(nil, ">", ch)
      }
    end
  else
    return {
      i,
      expect(nil, ">", "EOF")
    }
  end
end
--- Parses _condition_ node from current position in the buffer
--
-- @param buf input buffer
-- @param i position in input buffer
-- @returns tuple with adjusted current parsing index, actual string and expected string
function parseCondition(self, buf, i)
  local cond = ""
  while i <= buf:len() do
    local ch = string.sub(buf, i, i)
    i = i + 1
    if ch == ")" then
      --print("@@@@@@@@@@",i,cond, __TS__StringTrim(cond))
      return {
        i,
        __TS__StringTrim(cond),
        nil
      }
    else
      cond = table.concat({cond, ch})
    end
  end
  return {
    i,
    cond,
    expect(nil, ")", "EOF")
  }
end
--- Parses _action_ node from current position in the buffer
--
-- @param buf input buffer
-- @param i position in input buffer
-- @returns tuple with adjusted current parsing index, actual string and expected string
function parseAction(self, buf, i)
  local action = ""
  while i <= buf:len() do
    local ch = string.sub(buf, i, i)
    i = i + 1
    if ch == "]" then
      return {
        i,
        __TS__StringTrim(action),
        nil
      }
    else
      action = table.concat({action, ch})
    end
  end
  return {
    i,
    action,
    expect(nil, "]", "EOF")
  }
end
--- Parses _parallel_ node from current position in the buffer
--
-- @param buf input buffer
-- @param i position in input buffer
-- @returns tuple with parallel success branch count, adjusted current parsing index and error message or undefined
function parseParallel(self, buf, i)
  local numBuf = ""
  --print("parseParallel")
  while i <= buf:len() do
    local ch = string.sub(buf, i, i)
    local m = ch:match("%d+")
    --print("", m)
    if m and m:len() == 1 then
      numBuf = numBuf .. tostring(ch)
    else
      break
    end
    i = i + 1
  end
  if numBuf == "" then
    return {0, i, "Expecting number after parallel node."}
  end
  local num = __TS__ParseInt(numBuf)
  if num == 0 then
    return {0, i, "Parallel node must allow at least one child."}
  end
  return {num, i, nil}
end
--- Creates fallback node.
--
-- @param children
function fallback(self, children)
  if children == nil then
    children = {}
  end
  return __TS__New(Fallback, children)
end
--- Creates fallback node.
--
-- @param children
function sequence(self, children)
  if children == nil then
    children = {}
  end
  return __TS__New(Sequence, children or ({}))
end
--- Creates fallback node.
--
-- @param successCount minimal number of children necessary for the state to be SUCCESS
-- @param children
function parallel(self, successCount, children)
  if children == nil then
    children = {}
  end
  return __TS__New(Parallel, successCount, children)
end
--- Creates action node.
--
-- @param name action name
-- @param onActivation action activation callback
-- @param status node status
function action(self, name, onActivation, status)
  --print("@@@", name, onActionActivation, status)
  if onActivation == nil then
    onActivation = nil
  end
  if status == nil then
    status = RUNNING
  end
  return __TS__New(Action, name, onActivation, status)
end
--- Creates condition.
--
-- @param name condition name
-- @param hasNot condition negation flag
-- @param status initial condition status
function condition(self, name, hasNot, status)
  if status == nil then
    status = FAILED
  end
  return __TS__New(Condition, name, hasNot, status)
end
--- Parser
--
-- @param buf behavior tree as text
-- @returns
function parse(self, buf)
  local indent = 0
  local line = 1
  local notPending = false
  local i = 1
  ---
  -- @type {Node[]} nodes in the current tree branch
  local nodes = {nil}
  ---
  -- @param node tree node being pushed to current tree branch
  -- @returns error or `null`
  local function pushNode(self, node)
    if indent == 0 and nodes[indent + 1] then
      return ("More than one root node or node '" .. tostring(node.name)) .. "' has wrong indentation."
    end
    if indent > 0 then
      local parent = nodes[indent]
      if not parent then
        return tostring(node.name) .. " node has no parent (wrong indentation level)"
      end
      if parent.children then
        parent.children[#parent.children + 1] = node
        nodes[indent + 1] = node
        node.parent = parent
      else
        return tostring(parent.kind) .. " node can't have child nodes"
      end
    else
      nodes[indent + 1] = node
    end
    indent = indent + 1
    return nil
  end
  local function onError(self, err)
    print("Error", line, err)
    --return __TS__New(BehaviorTree, nil, line, err)
  end
  while i <= buf:len() do
    local ch = string.sub(buf, i, i)
    --print(i, ch)
    local notNow = false
    i = i + 1
    repeat
      local ____switch98 = ch
      local err
      local ____cond98 = ____switch98 == " " or ____switch98 == "\t"
      if ____cond98 then
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "\r"
      if ____cond98 then
        do
          if i <= buf:len() and ch == "\n" then
            i = i + 1
          end
          line = line + 1
          indent = 0
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "\n"
      if ____cond98 then
        do
          line = line + 1
          indent = 0
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "|"
      if ____cond98 then
        do
          indent = indent + 1
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "!"
      if ____cond98 then
        do
          if notPending then
            notPending = false
          else
            notNow = true
            notPending = true
          end
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "="
      if ____cond98 then
        do
          local num, n, err = unpack(parseParallel(nil, buf, i))
          if err then
            return onError(nil, err)
          end
          i = n
          local p = parallel(nil, num)
          local e = pushNode(nil, p)
          if e then
            return onError(nil, e)
          end
        end
        break
      end
      --print("#####", ____switch98)
      ____cond98 = ____cond98 or ____switch98 == "?"
      if ____cond98 then
        do
          local err = pushNode(nil, fallback(nil))
          if err then
            return onError(nil, err)
          end
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "-"
      if ____cond98 then
        do
          local n, err = unpack(parseSequence(nil, buf, i))
          if err then
            return onError(nil, err)
          end
          i = n
          local e = pushNode(nil, sequence(nil))
          if e then
            return onError(nil, e)
          end
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "("
      if ____cond98 then
        do
          local n, name, err = unpack(parseCondition(nil, buf, i))
          if err then
            return onError(nil, err)
          end
          i = n
          local c = condition(nil, name, notPending)
          if notPending then
            notPending = false
          end
          local e = pushNode(nil, c)
          if e then
            return onError(nil, e)
          end
        end
        break
      end
      ____cond98 = ____cond98 or ____switch98 == "["
      if ____cond98 then
        do
          local n, name, err = unpack(parseAction(nil, buf, i))
          if err then
            return onError(nil, err)
          end
          i = n
          local a = action(nil, name)
          local e = pushNode(nil, a)
          if e then
            return onError(nil, e)
          end
        end
        break
      end
      do
        err = ("Expecting '|', '-', '!', '[', or '(' but have '" .. tostring(ch)) .. "'"
        return onError(nil, err)
      end
    until true
    if not notNow and notPending then
      local err = "Not operator can only be applied to conditions"
      return onError(nil, err)
    end
    notNow = false
  end
  if not nodes[1] then
    local e = "Tree must have at least one node but has none"
    return onError(nil, e)
  end
  --print("@@@@@@", nodes[1])
  return __TS__New(BehaviorTree, nodes[1], line, nil)
end
---
-- @param map map to insert to
-- @param key map key
-- @param value value to insert for the given _key_
function addToArrayMap(self, map, key, value)
  -- print("addToArrayMap", key, value)
  if map:has(key) then
    -- print("", "map has key")
    -- map:get(key):push(value)
    table.insert(map:get(key), value)
  else
    map:set(key, {value})
  end
end

local Node = __TS__Class()
Node.name = "Node"

function Node.prototype.____constructor(self, name, kind, children)
  if children == nil then
    children = nil
  end
  self.name = name
  self.kind = kind
  self.children = children or nil
  self._active = false
  self.wasActive = false
  self.nodeStatus = FAILED
  self.hasNot = false
end
function Node.prototype.status(self)
  if self.hasNot then
    repeat
      local ____switch25 = self.nodeStatus
      local ____cond25 = ____switch25 == SUCCESS
      if ____cond25 then
        return FAILED
      end
      ____cond25 = ____cond25 or ____switch25 == FAILED
      if ____cond25 then
        return SUCCESS
      end
    until true
  end
  return self.nodeStatus
end
function Node.prototype.setStatus(self, newStatus)
  self.nodeStatus = newStatus
end
function Node.prototype.active(self)
  return self._active
end
function Node.prototype.setActive(self, isActive)
  local previouslyActive = self._active
  self._active = isActive
  if previouslyActive and not isActive then
    self.wasActive = true
  end
  if self.viewObj then
    self.viewObj:dispatchEvent {name = "tick", node=self.name, isActive = isActive, wasActive = self.wasActive, status = self:status()}
  end
end
function Node.prototype.tick(self)
  -- print("tick Node")
  self:setActive(true)
  return self:status()
end
function Node.prototype.deactivate(self)
  self:setActive(false)
  if self.children then
    do
      local i = 1
      while i <= #self.children do
        self.children[i]:deactivate()
        i = i + 1
      end
    end
  end
end
Fallback = __TS__Class()
Fallback.name = "Fallback"
__TS__ClassExtends(Fallback, Node)
function Fallback.prototype.____constructor(self, children)
  if children == nil then
    children = {}
  end
  Node.prototype.____constructor(self, "?", FALLBACK, children or ({}))
end
function Fallback.prototype.tick(self)
  -- print("tick Fallback")
  self:setActive(true)
  do
    local i = 1
    while i <= #self.children do
      local s = self.children[i]:tick()
      self:setStatus(s)
      if s == RUNNING or s == SUCCESS then
        return self:status()
      end
      i = i + 1
    end
  end
  self:setStatus(FAILED)
  return self:status()
end
Sequence = __TS__Class()
Sequence.name = "Sequence"
__TS__ClassExtends(Sequence, Node)
function Sequence.prototype.____constructor(self, children)
  if children == nil then
    children = {}
  end
  Node.prototype.____constructor(self, "→", SEQUENCE, children)
end
function Sequence.prototype.tick(self)
  -- print("tick Seq")
  self:setActive(true)
  do
    local i = 1
    while i <= #self.children do
      local s = self.children[i]:tick()
      self:setStatus(s)
      if s == RUNNING or s == FAILED then
        return self:status()
      end
      i = i + 1
    end
  end
  self:setStatus(SUCCESS)
  return self:status()
end
Parallel = __TS__Class()
Parallel.name = "Parallel"
__TS__ClassExtends(Parallel, Node)
function Parallel.prototype.____constructor(self, successCount, children)
  if children == nil then
    children = {}
  end
  Node.prototype.____constructor(self, "⇉", PARALLEL, children or ({}))
  self.successCount = successCount
end
function Parallel.prototype.tick(self)
  self:setActive(true)
  local succeeded = 0
  local failed = 0
  local kidCount = #self.children
  do
    local i = 1
    while i <= #self.children do
      local s = self.children[i]:tick()
      if s == SUCCESS then
        succeeded = succeeded + 1
      end
      if s == FAILED then
        failed = failed + 1
      end
      i = i + 1
    end
  end
  local st = RUNNING
  if succeeded >= self.successCount then
    st = SUCCESS
  elseif failed > kidCount - self.successCount then
    st = FAILED
  end
  self:setStatus(st)
  return st
end
Action = __TS__Class()
Action.name = "Action"
__TS__ClassExtends(Action, Node)
function Action.prototype.____constructor(self, name, onActivation, status)
  -- print("---------- Action Constructor ------------")
  if onActivation == nil then
    onActivation = nil
  end
  if status == nil then
    status = RUNNING
  end
  Node.prototype.____constructor(self, name, ACTION)
  self.actionActivationCallback = {} -- __TS__New(Array)
  if onActivation then
    -- print("$$$$$$", name, onActionActivation)
    table.insert(self.actionActivationCallback, onActivation)
  end
  self:setStatus(status)
end
function Action.prototype.onActivation(self, callback)
  table.insert(self.actionActivationCallback, callback)
end
function Action.prototype.setActive(self, isActive)
  Node.prototype.setActive(self, isActive)
  --print("######",self.name, #self.actionActivationCallback)
  for i = 1, #self.actionActivationCallback do
    self.actionActivationCallback[i](nil, self)
  end
end
Condition = __TS__Class()
Condition.name = "Condition"
__TS__ClassExtends(Condition, Node)
function Condition.prototype.____constructor(self, name, hasNot, status)
  if status == nil then
    status = FAILED
  end
  Node.prototype.____constructor(self, name, CONDITION)
  self.hasNot = hasNot
  self:setStatus(status)
end
BehaviorTree = __TS__Class()
BehaviorTree.name = "BehaviorTree"
function BehaviorTree.prototype.____constructor(self, root, line, ____error)
  if line == nil then
    line = nil
  end
  if ____error == nil then
    ____error = nil
  end
  self.root = root
  self.actions = __TS__New(Map)
  self.conditions = __TS__New(Map)
  self.line = line
  self.error = ____error
  if self.root then
    self:extractActionsAndConditions(self.root)
  end
  self.actionActivationCallbacks = {} -- __TS__New(Array)
  local thisTree = self
  self.onAnyActionActivation = function(self, actionNode)
    -- thisTree.actionActivationCallbacks:forEach(function(____, callback) return callback(nil, actionNode) end)
    for i = 1, #thisTree.actionActivationCallbacks do
      thisTree.actionActivationCallbacks[i](nil, actionNode)
    end
  end
  --
  -- self.actions:forEach(function(____, actions)
  --     return actions:forEach(function(____, a)
  --       return a:onActivation(self.onAnyActionActivation)
  --     end)
  --   end)

  self.actions:forEach(
    function(____, a)
      -- print("forEach")
      -- for k, v in pairs(a) do print("", k, v) end
      for i = 1, #a do
        -- print("", i, a[i].name)
        if a[i].onActivation then
          a[i]:onActivation(self.onAnyActionActivation)
        end
      end
    end
  )

  -- --
  -- for k, actions in pairs(self.actions) do
  --   if type(actions)=='table' then
  --     for key, a in pairs(actions) do
  --       -- print(":::::", actions)
  --       --for k, v in pairs(a[1]) do print(k, v) end
  --       if a.onActivation then
  --         print("@@@@@@")
  --         a:onActivation(self.onAnyActionActivation)
  --       end
  --     end
  --   end
  -- end

  self._id = 0
end
function BehaviorTree.prototype.setId(self, id)
  self._id = id
end
function BehaviorTree.prototype.getId(self)
  return self._id
end
function BehaviorTree.prototype.extractActionsAndConditions(self, node)
  if __TS__InstanceOf(node, Action) then
    addToArrayMap(nil, self.actions, node.name, node)
  elseif __TS__InstanceOf(node, Condition) then
    addToArrayMap(nil, self.conditions, node.name, node)
  end
  if node.children then
    for k, c in pairs(node.children) do
      self:extractActionsAndConditions(c)
    end
  end
end
function BehaviorTree.prototype.setConditionStatus(self, name, status)
  if self.conditions:has(name) then
    for k, c in pairs(self.conditions:get(name)) do
      c:setStatus(status)
    end
  end
end
function BehaviorTree.prototype.setActionStatus(self, name, status)
  if self.actions:has(name) then
    --self.actions:get(name):forEach(function(____, a) return a:setStatus(status) end)
    for i = 1, #self.actions:get(name) do
      self.actions:get(name)[i]:setStatus(status)
    end
  end
end
function BehaviorTree.prototype.onActionActivation(self, callback)
  --  self.actionActivationCallbacks:push(callback)
  self.actionActivationCallbacks[#self.actionActivationCallbacks + 1] = callback
end
function BehaviorTree.fromJson(self, treeAsJson)
  local rootNode = BehaviorTree:nodeFromJson(treeAsJson.root)
  return __TS__New(BehaviorTree, rootNode, treeAsJson.line, treeAsJson.error)
end
function BehaviorTree.nodeFromJson(self, nodeAsJson)
  local node
  repeat
    local ____switch82 = nodeAsJson.kind
    local ____cond82 = ____switch82 == FALLBACK
    if ____cond82 then
      node = fallback(nil)
      break
    end
    ____cond82 = ____cond82 or ____switch82 == SEQUENCE
    if ____cond82 then
      node = sequence(nil)
      break
    end
    ____cond82 = ____cond82 or ____switch82 == PARALLEL
    if ____cond82 then
      node = parallel(nil, nodeAsJson.successCount)
      break
    end
    ____cond82 = ____cond82 or ____switch82 == ACTION
    if ____cond82 then
      node = action(nil, nodeAsJson.name, nil, nodeAsJson.nodeStatus)
      break
    end
    ____cond82 = ____cond82 or ____switch82 == CONDITION
    if ____cond82 then
      node = condition(nil, nodeAsJson.name, nodeAsJson.hasNot, nodeAsJson.nodeStatus)
      break
    end
    do
      error(__TS__New(Error, ("Unexpected node kind: " .. tostring(nodeAsJson.kind)) .. "."), 0)
    end
  until true
  if nodeAsJson.children then
    node.children =
      nodeAsJson.children:map(
      function(____, child)
        return self:nodeFromJson(child)
      end
    )
  end
  return node
end
function BehaviorTree.fromText(self, treeAsText)
  return parse(nil, treeAsText)
end
function BehaviorTree.prototype.tick(self)
  -- print("tick 1")
  if self.root then
    self.root:tick()
  end
end
SAMPLE_TREE =
  "\n?\n|    ->\n|    |    (Ghost Close)\n|    |    ?\n|    |    |    ->\n|    |    |    |    !(Ghost Scared)\n|    |    |    |    (Power Pill Close)\n|    |    |    |    [Eat Power Pill]\n|    |    |    ->\n|    |    |    |    (Ghost Scared)\n|    |    |    |    [Chase Ghost]\n|    |    |    [Avoid Ghost]\n|    =1\n|    |    [Eat Pills]\n|    |    [Eat Fruit]\n"
--- Gets friendly status
--
-- @param status tree node status
-- @returns user-friendly status string
function getFriendlyStatus(self, status)
  repeat
    local ____switch127 = status
    local ____cond127 = ____switch127 == FAILED
    if ____cond127 then
      return "Failed"
    end
    ____cond127 = ____cond127 or ____switch127 == SUCCESS
    if ____cond127 then
      return "Success"
    end
    ____cond127 = ____cond127 or ____switch127 == RUNNING
    if ____cond127 then
      return "Running"
    end
    do
      return "Unknown"
    end
  until true
end
if type(exports) ~= "nil" and exports then
  exports.bt = {
    BehaviorTree = BehaviorTree,
    parse = parse,
    SUCCESS = SUCCESS,
    FAILED = FAILED,
    RUNNING = RUNNING,
    fallback = fallback,
    sequence = sequence,
    parallel = parallel,
    condition = condition,
    action = action,
    FALLBACK = FALLBACK,
    SEQUENCE = SEQUENCE,
    PARALLEL = PARALLEL,
    CONDITION = CONDITION,
    ACTION = ACTION,
    SAMPLE_TREE = SAMPLE_TREE,
    getFriendlyStatus = getFriendlyStatus
  }
else
  return {
    BehaviorTree = BehaviorTree,
    parse = parse,
    SUCCESS = SUCCESS,
    FAILED = FAILED,
    RUNNING = RUNNING,
    fallback = fallback,
    sequence = sequence,
    parallel = parallel,
    condition = condition,
    action = action,
    FALLBACK = FALLBACK,
    SEQUENCE = SEQUENCE,
    PARALLEL = PARALLEL,
    CONDITION = CONDITION,
    ACTION = ACTION,
    SAMPLE_TREE = SAMPLE_TREE,
    getFriendlyStatus = getFriendlyStatus
  }
end
