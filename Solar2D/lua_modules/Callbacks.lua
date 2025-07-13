-- Callbacks
-- http://codea.io/talk/discussion/2510/lua-implementations-of-jquery-s-callbacks-and-deferred
local pairs, ipairs = pairs, ipairs
local select, type, unpack = select, type, unpack
local tinsert, tremove = table.insert, table.remove

local function _has(list, fn)
    if list and fn then
        for i, cb in ipairs(list) do
            if cb == fn then return true, i end
        end
    end

    return false
end

local function _add(list, unique, ...)
    local _args = {...}
    for idx, arg in ipairs(_args) do
        local _type = type(arg)
        if _type == 'function' then
            if not(unique and _has(list, arg)) then
                tinsert(list, arg)
            end
        elseif _type == 'table' then
            _add(list, unique, unpack(arg))
        end
    end
end

-- options: once, memory, unique, stopOnFalse
Callbacks = function(...)
    local opt = {...}
    if next(opt) then
        for _, option in ipairs(opt) do opt[option] = true end
    end

    local this, list, stack = {}, {}, (not opt.once) and {} or nil
    local firing, fired, firingLength, firingStart, firingIndex, memory

    local function fire(...)
        memory = opt.memory and {...} or nil
        fired, firing, firingIndex = true, true, firingStart or 1
        firingStart, firingLength = 1, #list

        while list and (firingIndex <= firingLength) do
            local ret = list[firingIndex](...)

            if opt.stopOnFalse and (ret == false) then
                memory = nil
                break
            end

            firingIndex = firingIndex + 1
        end

        firing = false

        if list then
            if stack then
                if #stack > 0 then
                    fire(tremove(stack, 1))
                end
            elseif memory then
                list = {}
            else
                this:disable()
            end
        end
    end

    function this:add(...)
        if list then
            local start = #list + 1
            _add(list, opt.unique, ...)

            if firing then
                firingLength = #list
            elseif memory then
                firingStart = start
                fire(unpack(memory))
            end
        end

        return self
    end

    function this:remove(...)
        if list then
            for _, arg in ipairs{...} do
                local inList, index = _has(list, arg)
                while inList do
                    tremove(list, index)
                    if firing then
                        if index <= firingLength then
                            firingLength = firingLength - 1
                        end
                        if index <= firingIndex then
                            firingIndex = firingIndex - 1
                        end
                    end
                    inList, index = _has(list, arg)
                end
            end
        end

        return self
    end

    function this:fire(...)
        if list and ((not fired) or stack) then
            if firing then
                tinsert(stack, {...})
            else
                fire(...)
            end
        end
        return self
    end

    function this:fired() return fired end

    function this:empty()
        list = {}
        firingLength = 0
        return self
    end

    function this:has(fn)
        return fn and _has(list, fn) or (list and #list > 0)
    end

    function this:disable()
        list, stack, memory = nil
        return self
    end

    function this:disabled() return not list end

    function this:lock()
        stack = nil
        if not memory then self:disable() end
        return self
    end

    function this:locked() return not stack end

    return this
end