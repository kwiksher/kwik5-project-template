local M = {}

function M:play(UI, name, params)
  local t = {}

  -- If params is not nil or empty, parse it into table t
  if params and params ~= "" then
    -- Split the params string by "&" to get key-value pairs
    for pair in params:gmatch("([^&]+)") do
      -- Split each pair by "=" to get key and value
      local key, value = pair:match("([^=]+)=?(.*)")

      -- Convert numeric values from string to number
      if value and tonumber(value) then
        value = tonumber(value)
      -- Convert boolean values from string to boolean
      elseif value == "true" then
        value = true
      elseif value == "false" then
        value = false
      end

      -- Add to table
      t[key] = value
    end
  end

  UI.scene:dispatchEvent({name=name, params = t})
end

function M:playRandom(UI, playOnce, filter)
  local actions = UI.scene:getCommands()
  local playableActions = {}
  local playedActions = UI.playedActions or {}

  -- Initialize played actions tracking if doesn't exist
  if not UI.playedActions then
    UI.playedActions = {}
    playedActions = UI.playedActions
  end

  -- Collect all actions that match filter criteria and haven't been played (if playOnce is true)
  for name, action in pairs(actions) do
    local shouldInclude = true

    -- Apply filter if provided
    if filter and filter ~= "" then
      shouldInclude = string.find(name, filter) ~= nil
    end

    -- Check if already played (when playOnce is true)
    if playOnce and playedActions[name] then
      shouldInclude = false
    end

    if shouldInclude then
      table.insert(playableActions, {name = name, action = action})
    end
  end

  -- If we have actions to play
  if #playableActions > 0 then
    -- Select random action
    local randomIndex = math.random(1, #playableActions)
    local selectedAction = playableActions[randomIndex]

    -- Mark as played if playOnce is true
    if playOnce then
      playedActions[selectedAction.name] = true
    end

    -- Execute the action
    UI.scene:dispatchEvent({name = selectedAction.name})

    return selectedAction.name
  end

  return nil
end

function M:playSequential(UI, playOnce, filter)
  local actions = UI.scene:getCommands()
  local playableActions = {}
  local playedActions = UI.playedActions or {}

  -- Initialize tracking objects if they don't exist
  if not UI.playedActions then
    UI.playedActions = {}
    playedActions = UI.playedActions
  end

  if not UI.currentActionIndex then
    UI.currentActionIndex = 1
  end

  -- Collect all actions that match filter criteria and haven't been played (if playOnce is true)
  for name, action in pairs(actions) do
    local shouldInclude = true

    -- Apply filter if provided
    if filter and filter ~= "" then
      shouldInclude = string.find(name, filter) ~= nil
    end

    -- Check if already played (when playOnce is true)
    if playOnce and playedActions[name] then
      shouldInclude = false
    end

    if shouldInclude then
      table.insert(playableActions, {name = name, action = action})
    end
  end

  -- Sort actions by name for consistent sequencing
  table.sort(playableActions, function(a, b) return a.name < b.name end)

  -- If we have actions to play
  if #playableActions > 0 then
    -- Reset index if out of bounds
    if UI.currentActionIndex > #playableActions then
      UI.currentActionIndex = 1
    end

    -- Get the next action in sequence
    local selectedAction = playableActions[UI.currentActionIndex]

    -- Mark as played if playOnce is true
    if playOnce then
      playedActions[selectedAction.name] = true
    end

    -- Increment for next call
    UI.currentActionIndex = UI.currentActionIndex + 1

    -- Execute the action
    UI.scene:dispatchEvent({name = selectedAction.name})

    return selectedAction.name
  end

  return nil
end
--
return M