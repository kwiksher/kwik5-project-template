local name = ...
local parent = name:match("(.-)[^%.]+$")

local json = require( "json" )
require(parent.."Deferred")
require(parent.."Callbacks")

local download        = require(parent.."download")
local view            = require(parent.."view")
local assets          = require(parent.."assets")

local STATE = {
  updateAvailable = {
      {text = "update"},
      {text = "skip"},
  },
  message = "Do you like to updade kwik modules?",
}

--
---------------------------
local M = {}
--
M.ask = function()
    local deferred = Deferred()
    local choices = {}
    for k, v in pairs (STATE.updateAvailable) do
        if v.text then
            table.insert(choices, v.text)
        end
    end

    view.onClick = function(event)
        for k, v in pairs (choices) do print(k, v) end
        if ( event.action == "clicked" ) then
            deferred:resolve(choices[event.index])
        end
    end
    view:message(choices, STATE.message)
    return deferred:promise()
end

local showUpdater = function()
    download:processUpdate(function (event)
        if event.name == "error" then
            view:showError()
            print(json.prettify(event))
            view:hideSpinner()
        elseif event.name == "started" then
          view:showSpinner()
        elseif event.name == "ended" then
          view:hideSpinner()
          assets:save(event.commands)
        end
    end)
end

M.init = function()
  -- timer.performWithDelay(3000, function()
  --   view:showSpinner()
  -- end)
  assets:init()
  download.isNewVersion():done(function(isNew)
      if isNew then
        view:showVersions(assets)
        M.ask()
        :done(function(answer)
          print(answer)
          if answer == 'update' then
                showUpdater()
          end
        end)
      end
  end)
end
--
return M