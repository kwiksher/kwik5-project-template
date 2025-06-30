-- Code created by Kwik - Copyright: kwiksher.com {{year}}
-- Version: {{vers}}
-- Project: {{ProjName}}
--
transition.callback = transition.to ;
local util = require(kwikGlobal.ROOT.."lib.util")
--
function _copy(t)
    local new_table = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            new_table[k] = _copy(v)
        else
            new_table[k] = v
        end
    end
    return new_table
end

function makeDiff(from, to)
    local diff_table = {}
    for k, v in pairs(from) do
      -- print("", k)
      if type(v) == "table" then  -- v = {0.1, 0.2. 0.3}
        if util.isArray(v) then
          local ret = {}
          for ii, vv in next, v do
            ret[#ret+1] = v[ii]-vv
          end
          diff_table[k] = ret
        else
          --diff_table[k] = makeDiff(v ,to[k])
        end
      elseif type(v) == "number" then
        -- print(k, to[k], v)
          diff_table[k] = to[k]-v
      end
    end
    return diff_table
end

function setEffect(from, diff_table, val)
  local value = {}
    for k, v in pairs(diff_table) do
          -- print(k)
        if type(v) == "table" then
          -- print("table:"..k)
          if util.isArray(v) then
            local ret = {}
            for ii, vv in next, v do
              -- print(ii, vv)
              if vv ~=0 then -- no difference
                ret[#ret+1] = vv*val
              else
                ret[#ret+1] = from[k][ii]
              end
            end
            value[k] = ret
          else
            value[k] = setEffect(from[k], v, val)
          end
        else
            -- print(k, from[k] + v*val)
            if k == "xStep" or k =="yStep" then
              value[k] = from[k] + math.floor(v*val)
            else
              value[k] = from[k] + v*val
            end
        end
    end
    return value
end


function transition.kwikFilter(obj, params)
  local _obj =  obj ;
  local ease = params.ease or easing.linear
  local time = params.time
  local delay = params.delay
  local complete = params.onComplete
  local loop = params.loop

  local from =   params.filterTable.from
  local to = params.filterTable.to
  -- print("--------from")
  -- printTable(from)
  -- print("--------to")
  -- printTable(to)
  -- -- local to = params.filterTable.get()
  params.filterTable:set(params.effect, from)
  local diffTable = makeDiff(from, to)
  local t = nil ;
  local p = {} --hold parameters here
  --Set up proxy
  local proxy = {step = 0} ;
  local mt

  if( _obj and _obj.fill and _obj.fill.effect ) then
      mt = {
      __index = function(t,k)
        return t["step"]
      end,
      __newindex = function (t,k,v)
        -- print(k)
        if k=="_paused" then
          _obj.isPlay = false
        elseif k == "_resume" then
          _obj.isPlay = true
        else
          if(_obj.fill and _obj.fill.effect and _obj.isPlay) then
            local value = setEffect(from, diffTable, v)
            params.filterTable:set(params.effect, _obj.fill.effect, value)
          end
          t["step"] = v ;
        end
      end
    }
  end
  p.iterations       = loop or 1
  p.time       = time or 1000 ; --defaults to 1 second
  p.delay      = delay or 0 ;
  p.transition = ease ;
  p.colorScale = 1 ;
  p.onComplete = complete;
  setmetatable(proxy,mt) ;
  _obj.isPlay = true
  t = transition.to(proxy,p , 1 )  ;
  return t
end