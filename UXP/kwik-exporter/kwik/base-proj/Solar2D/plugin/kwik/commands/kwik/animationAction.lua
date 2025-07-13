local M = {}
--
function M:pause(anim)
  anim:pause()
end
--
function M:resume(anim)
  if anim.type == "transition" then
    anim:resume()
  elseif anim.to then
    anim.to:play()
  end
end
--
function M:play(anim)
  if anim.type == "transition" then
    anim:resume()
  else
    if anim.from then
      anim.from:toBeginning()
      anim.from:play()
    elseif anim.to then
      anim.to:toBeginning()
      anim.to:play()
    end
  end
end

-- Play animations randomly
function M:playRandom(UI, playOnce, filter)
  local animations = UI.animations
  local playableAnims = {}
  local playedAnims = UI.playedAnimations or {}

  -- Initialize played animations tracking if doesn't exist
  if not UI.playedAnimations then
    UI.playedAnimations = {}
    playedAnims = UI.playedAnimations
  end

  -- Collect all animations that match filter criteria and haven't been played (if playOnce is true)
  for name, anim in pairs(animations) do
    local shouldInclude = true

    -- Apply filter if provided
    if filter and filter ~= "" then
      shouldInclude = string.find(name, filter) ~= nil
    end

    -- Check if already played (when playOnce is true)
    if playOnce and playedAnims[name] then
      shouldInclude = false
    end

    if shouldInclude then
      table.insert(playableAnims, {name = name, anim = anim})
    end
  end

  -- If we have animations to play
  if #playableAnims > 0 then
    -- Select random animation
    local randomIndex = math.random(1, #playableAnims)
    local selectedAnim = playableAnims[randomIndex]

    -- Mark as played if playOnce is true
    if playOnce then
      playedAnims[selectedAnim.name] = true
    end

    -- Play the animation
    if selectedAnim.anim.type == "transition" then
      selectedAnim.anim:resume()
    else
      if selectedAnim.anim.from then
        selectedAnim.anim.from:toBeginning()
        selectedAnim.anim.from:play()
      elseif selectedAnim.anim.to then
        selectedAnim.anim.to:toBeginning()
        selectedAnim.anim.to:play()
      end
    end

    return selectedAnim.name
  end

  return nil
end

function M:playSequential(UI, playOnce, filter)
  local animations = UI.animations
  local playableAnims = {}
  local playedAnims = UI.playedAnimations or {}

  -- Initialize tracking objects if they don't exist
  if not UI.playedAnimations then
    UI.playedAnimations = {}
    playedAnims = UI.playedAnimations
  end

  if not UI.currentAnimIndex then
    UI.currentAnimIndex = 1
  end

  -- Collect all animations that match filter criteria and haven't been played (if playOnce is true)
  for name, anim in pairs(animations) do
    local shouldInclude = true

    -- Apply filter if provided
    if filter and filter ~= "" then
      shouldInclude = string.find(name, filter) ~= nil
    end

    -- Check if already played (when playOnce is true)
    if playOnce and playedAnims[name] then
      shouldInclude = false
    end

    if shouldInclude then
      table.insert(playableAnims, {name = name, anim = anim})
    end
  end

  -- Sort animations by name for consistent sequencing
  table.sort(playableAnims, function(a, b) return a.name < b.name end)

  -- If we have animations to play
  if #playableAnims > 0 then
    -- Reset index if out of bounds
    if UI.currentAnimIndex > #playableAnims then
      UI.currentAnimIndex = 1
    end

    -- Get the next animation in sequence
    local selectedAnim = playableAnims[UI.currentAnimIndex]

    -- Mark as played if playOnce is true
    if playOnce then
      playedAnims[selectedAnim.name] = true
    end

    -- Increment for next call
    UI.currentAnimIndex = UI.currentAnimIndex + 1

    -- Play the animation
    if selectedAnim.anim.type == "transition" then
      selectedAnim.anim:resume()
    else
      if selectedAnim.anim.from then
        selectedAnim.anim.from:toBeginning()
        selectedAnim.anim.from:play()
      elseif selectedAnim.anim.to then
        selectedAnim.anim.to:toBeginning()
        selectedAnim.anim.to:play()
      end
    end

    return selectedAnim.name
  end

  return nil
end--
--
return M