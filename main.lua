-- name: Level Picker
-- description: Easily view and warp to all levels, modded or vanilla.

-- Max possible level number (`u16`).  
-- *(Based on `CustomLevelInfo` in `smlua_level_utils.h`)*
local MAX_LEVEL_NUMBER = 65535

local COLOR_ERROR = "\\#FF0000\\"
local COLOR_DEFAULT = "\\#FFFFFF\\"
local COLOR_YELLOW = "\\#CCCC00\\"
local COLOR_AQUA = "\\#88EEAA\\"

-- Array of levels, or `nil` if `scan_levels` has not been called yet.
local levels = nil ---@type table | nil
-- Whether or not to show the HUD
local show_hud = false

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

local function list_levels()
  if levels == nil then
    return
  end

  ---@param level CustomLevelInfo
  ---@param idx integer
  for idx,level in pairs(levels) do
    local message = string.format(
      COLOR_AQUA .. "%d: " .. COLOR_DEFAULT .. level.fullName .. " (" .. level.shortName .. ")",
      idx
    )

    djui_chat_message_create(message)
  end

  djui_chat_message_create(COLOR_YELLOW .. "NOTE: If a level listed more than once, it probably exists for multiple game modes." .. COLOR_DEFAULT)
end

---@param num string
local function try_warp_to_level(num)
  if levels == nil then
    return
  end

  -- Attempt to parse level number    
  local level_num = tonumber(num)
  if level_num == nil then
    djui_chat_message_create(COLOR_ERROR .. "Invalid level number." .. COLOR_DEFAULT)
    return
  end

  --- @type CustomLevelInfo | nil
  local level = levels[level_num]
  if level == nil then
    djui_chat_message_create(COLOR_ERROR .. "Unknown level." .. COLOR_DEFAULT)
    return
  end

  djui_chat_message_create(COLOR_AQUA .. "Warping to \"" .. level.fullName .. "\"..." .. COLOR_DEFAULT)
  warp_to_level(level.levelNum, 1, 0)
end

-- TODO: Match on shortName and fullName too
hook_chat_command("lp", "({number}) List and teleport to available levels", function (msg)
  if levels == nil then
    levels = scan_levels()
  end

  if msg:len() > 0 then
    try_warp_to_level(msg)
    return true
  end

  -- List available levels
  list_levels()
  return true

end)











-- Initialize screen-size based variables, they will be kept up to date via `update_screen_size_variables`

local screen_width = djui_hud_get_screen_width()
local screen_height = djui_hud_get_screen_height()
local hud_width = screen_width * 3/4
local hud_height = screen_height * 3/4
local hud_x = screen_width / 2 - hud_width / 2
local hud_y = screen_height / 2 - hud_height / 2

local function update_screen_size_variables()
  screen_width = djui_hud_get_screen_width()
  screen_height = djui_hud_get_screen_height()
  hud_width = screen_width * 3/4
  hud_height = screen_height * 3/4
  hud_x = screen_width / 2 - hud_width / 2
  hud_y = screen_height / 2 - hud_height / 2
end


local BTN_CLOSE = 0
local MAX_BTN = 3 -- TODO: Will need to take into account some pages will have less options
local selected_btn = BTN_CLOSE

local function hud_render()
  if show_hud == false then
    return
  end 

  -- update screen-size based variables
  update_screen_size_variables()


  -- Render hud backdrop
  djui_hud_set_color(0, 0, 0, 200)
  djui_hud_render_rect(
    hud_x, hud_y,
    hud_width, hud_height
  )

  -- Render close button
  lp_text_button(hud_x + hud_width - 100 - 5, hud_y + 5, "Close", selected_btn == BTN_CLOSE, 100, true)

  lp_text_button(hud_x + 5, hud_y + 45, "Test button", selected_btn == 1)
  lp_text_button(hud_x + 5, hud_y + 85, "Test button hightlighted", selected_btn == 2)
  lp_text_button(hud_x + 5, hud_y + 125, "Test button truncated", selected_btn == 3, 220, true)
end


local JOYSTICK_COOLDOWN = 5
local cooldown_timer = 0

--- @param m MarioState
local function mario_update(m)
  if m.playerIndex ~= 0 then return end
  if show_hud == false then return end 

  m.freeze = 1

  if m.controller.buttonPressed & B_BUTTON ~= 0
  or m.controller.buttonPressed & A_BUTTON ~= 0 and selected_btn == BTN_CLOSE then
    show_hud = false
    return
  end

  -- Handle joystick cooldown
  cooldown_timer = cooldown_timer - 1
  -- if our stick is at 0, then set joystickCooldown to 0
  if m.controller.stickY == 0 then cooldown_timer = 0 end
  -- exit early if not ready for another input
  if cooldown_timer > 0 then return end

  if m.controller.stickY < -0.5 then
    selected_btn = selected_btn + 1
    if selected_btn > MAX_BTN then selected_btn = 0 end
    cooldown_timer = JOYSTICK_COOLDOWN
    play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
  end

  if m.controller.stickY > 0.5 then
    selected_btn = selected_btn - 1
    if selected_btn < 0 then selected_btn = MAX_BTN end
    cooldown_timer = JOYSTICK_COOLDOWN
    play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
  end
end


hook_chat_command("lph", "Show level picker HUD", function (msg)
  show_hud = true
end)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)