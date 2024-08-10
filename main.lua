-- name: Level Picker
-- description: Easily view and warp to all levels, modded or vanilla.

-- Max possible level number (`u16`).  
-- *(Based on `CustomLevelInfo` in `smlua_level_utils.h`)*
local MAX_LEVEL_NUMBER = 65535


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


local function levelpicker()
  -- level: CustomLevelInfo
  for idx,level in pairs(levels) do
    local is_vanilla = level_is_vanilla_level(level.levelNum)
    local idx_and_name = string.format("\\#88EEAA\\%d:\\#FFFFFF\\ %s", idx, level.fullName)
    local full_string
    if is_vanilla then
      full_string = string.format("%s (%s)", idx_and_name, "Vanilla")
    else
      full_string = string.format("%s (%s)", idx_and_name, "\\#FF0000\\Vanilla\\#FFFFFF\\")
    end

    log_to_console(full_string, CONSOLE_MESSAGE_INFO)
  end
end

-- Scan levels, set up command hook
hook_chat_command("lp", "List available levels", levelpicker)