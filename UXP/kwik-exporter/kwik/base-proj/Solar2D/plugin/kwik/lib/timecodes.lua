local M = {}

function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function parse_fountain(script)
  local lines = string.split(script, "\n")
  local dialogue = {}
  local current_character = nil


  for _, line in ipairs(lines) do
    local trimmed = trim(line)
      if string.upper(line) == line and trimmed ~= "" then
          current_character = trimmed
      elseif current_character and trimmed ~= "" then
          table.insert(dialogue, {current_character, trimmed})
      end
  end

  return dialogue
end

local function estimate_duration(text, words_per_minute)
  local word_count = #string.split(text, " ")
  return (word_count / words_per_minute) * 60
end

local function format_timecode(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local seconds = math.floor(seconds % 60)

  local frames = math.floor((seconds % 1) * 24)

  return string.format("%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
end


local function generate_timecodes(dialogue)
  local current_time = 0
  local timecoded_dialogue = {}

  for _, v in ipairs(dialogue) do
      local character, line = unpack(v)
      local duration = estimate_duration(line, 150)
      local start_time = current_time
      local end_time = current_time + duration
      -- table.insert(timecoded_dialogue, {character, line, format_timecode(start_time), format_timecode(end_time)})
      table.insert(timecoded_dialogue, {character, line, start_time, end_time})
      current_time = end_time + 1
  end

  return timecoded_dialogue
end


M.parse_fountain = parse_fountain
M.generate = generate_timecodes

return M