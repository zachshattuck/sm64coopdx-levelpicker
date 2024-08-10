-- name: Level Picker
-- description: Easily view and warp to all levels, modded or vanilla.

-- Max possible level number (`u16`).  
-- *(Based on `CustomLevelInfo` in `smlua_level_utils.h`)*
local MAX_LEVEL_NUMBER = 65535

local COLOR_ERROR = "\\#FF0000\\"
local COLOR_DEFAULT = "\\#FFFFFF\\"
local COLOR_YELLOW = "\\#CCCC00\\"
local COLOR_AQUA = "\\#88EEAA\\"


local function scan_levels()
  local levels = {}
  for i = 1, MAX_LEVEL_NUMBER, 1 do
    local level = smlua_level_util_get_info(i)
    if level then
      table.insert(levels, level)
    end
  end
  return levels
end
local levels = scan_levels()


local function list_levels()
  -- level: CustomLevelInfo
  for idx,level in pairs(levels) do
    local is_vanilla = level_is_vanilla_level(level.levelNum)
    local idx_and_name = string.format(COLOR_AQUA .. "%d:" .. COLOR_DEFAULT .. " %s", idx, level.fullName)
    local full_string
    if is_vanilla then
      full_string = idx_and_name .. " (Vanilla)"
    else
      full_string = idx_and_name .. COLOR_YELLOW .. " (Modded)" .. COLOR_DEFAULT
    end

    djui_chat_message_create(full_string)
  end
end

hook_chat_command("lp", "List available levels", function (msg)

  if msg:len() > 0 then
    -- Attempt to parse level number    
    local levelNum = tonumber(msg)
    if levelNum == nil then
      djui_chat_message_create(COLOR_ERROR .. "Invalid level number." .. COLOR_DEFAULT)
      return true
    end

    -- level: CustomLevelInfo | nil
    local level = levels[levelNum]
    if level == nil then
      djui_chat_message_create(COLOR_ERROR .. "Unknown level." .. COLOR_DEFAULT)
      return true
    end

    djui_chat_message_create(COLOR_AQUA .. "Warping to \"" .. level.fullName .. "\"..." .. COLOR_DEFAULT)
    warp_to_level(level.levelNum, 1, 0)

    return true
  end

  -- List available levels
  list_levels()
  return true

end)