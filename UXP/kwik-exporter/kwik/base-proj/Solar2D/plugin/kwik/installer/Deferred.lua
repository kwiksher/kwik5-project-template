--Deferred
-- http://codea.io/talk/discussion/2510/lua-implementations-of-jquery-s-callbacks-and-deferred

local function example1()
    function Request(url, paramTable)
        local deferred = Deferred()
        local function _success(data) deferred:resolve(data) end
        local function _fail(err) deferred:reject(err) end
        http.request(url, _success, _fail, paramTable)
        return deferred:promise()
    end

    function setup()
        myRequest = Request('http://twolivesleft.com/Codea/logo.png')
            :done(function(img)
                myImage = img
            end)
            :fail(function(err)
                print('image download failed:', err)
            end)
            :always(function()
                print('always called, regardless of success or failure')
            end)
    end

    function draw()
        if myImage then
            sprite(myImage, WIDTH/2, HEIGHT/2)
        end
    end
end

local function example2()
    local def = Deferred()
    def:done(function(str)
        print(str)
    end)
    def:resolve('hello!')  -- callback above will be executed now
    -- will be executed immediately since deferred has been resolved
    def:done(function(str)
        print(str .. ' after the fact!');
    end)
end

local pairs, ipairs = pairs, ipairs
local type = type
local unpack = unpack
local select = select

local function _extend(target, ...)
    for _, t in ipairs{...} do
        for k, v in pairs(t) do
            target[k] = v
        end
    end
    return target
end

local _methods = {
    {'resolve', 'done'},
    {'reject', 'fail'},
    {'progress', 'notify'}
}

function Deferred(func)
    local _state, deferred, promise = 'pending', {}, {}
    local _done = Callbacks('once', 'memory')
    local _fail = Callbacks('once', 'memory')
    local _progress = Callbacks('memory')

    _done:add(function()
        _state = 'resolved'
        _fail:disable()
        _progress:lock()
    end)

    _fail:add(function()
        _state = 'rejected'
        _done:disable()
        _progress:lock()
    end)

    function promise:state() return _state end

    function promise:always(...)
        deferred:done(...):fail(...)
        return self
    end

    --params: fnDone, fnFail, fnProgress
    function promise:pipe(...)
        local fns = {...}
        return Deferred(function(newDefer)
            for i, method in ipairs(_methods) do
                local fn = (type(fns[i]) == 'function') and fns[i]
                deferred[method[2]](deferred, function(...)
                    local returned = fn and fn(...)
                    if returned and type(returned.promise) == 'function' then
                        returned:promise()
                            :done(function(...) newDefer:resolve(...) end)
                            :fail(function(...) newDefer:reject(...) end)
                            :progress(function(...) newDefer:notify(...) end)
                    else
                        newDefer[method[1]](newDefer, ...)
                    end
                end)
            end

            fns = nil
        end):promise()
    end

    function promise:promise(obj)
        return (obj) and _extend(obj, promise) or promise
    end

    function promise:done(...)
        _done:add(...)
        return self
    end

    function promise:fail(...)
        _fail:add(...)
        return self
    end

    function promise:progress(...)
        _progress:add(...)
        return self
    end

    function deferred:resolve(...)
        _done:fire(...)
        return self
    end

    function deferred:reject(...)
        _fail:fire(...)
        return self
    end

    function deferred:notify(...)
        _progress:fire(...)
        return self
    end

    promise:promise(deferred)
    if func then func(deferred) end
    return deferred
end

function when(...)
    local resolveValues = {...}
    local length, first = #resolveValues, resolveValues[1]

    local remaining = length
    if length == 1 and type(first.promise) ~= 'function' then
        remaining = 0
    end

    local resolveContexts, progressValues, progressContexts
    local deferred = (remaining == 1) and first or Deferred()

    local function updateFunc(inst, i, contexts, values)
        return function(...)
            contexts[i] = inst
            values[i] = (select('#', ...) > 1) and {...} or select(1, ...)
            if values == progressValues then
                deferred:notify(unpack(progressValues))
            else
                remaining = remaining - 1
                if remaining == 0 then
                    deferred:resolve(unpack(resolveValues))
                end
            end
        end
    end

    if length > 1 then
        progressValues, progressContexts, resolveContexts = {}, {}, {}
        for i = 1, length do
            local rv = resolveValues[i]
            if rv and type(rv.promise) == 'function' then
                rv:promise()
                    :progress(updateFunc(rv, i, progressContexts, progressValues))
                    :done(updateFunc(rv, i, resolveContexts, resolveValues))
                    :fail(function(...) deferred:reject(...) end)
            else
                remaining = remaining - 1
            end
        end
    end

    if remaining == 0 then
        deferred:resolve(unpack(resolveValues))
    end

    return deferred:promise()
end