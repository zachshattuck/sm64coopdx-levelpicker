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
local levels_count = 0
-- Whether or not to show the HUD
local show_hud = false

local function scan_and_set_levels()
  levels = {}
  levels_count = 0
  for i = 1, MAX_LEVEL_NUMBER, 1 do
    local level = smlua_level_util_get_info(i)
    if level then
      table.insert(levels, level)
      levels_count = levels_count + 1
    end
  end

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
    scan_and_set_levels()
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

local level_row_width = hud_width*7/8
local rows_per_page = math.floor(
  (hud_height - 150) / 45
)

local btn_next_page = rows_per_page + 1
local btn_prev_page = rows_per_page + 2

local hud_page = 1
local BTN_CLOSE = 0
local selected_btn = BTN_CLOSE

local function update_screen_size_variables()
  screen_width = djui_hud_get_screen_width()
  screen_height = djui_hud_get_screen_height()
  hud_width = screen_width * 3/4
  hud_height = screen_height * 3/4
  hud_x = screen_width / 2 - hud_width / 2
  hud_y = screen_height / 2 - hud_height / 2

  level_row_width = hud_width*3/4

  local new_rows_per_page = math.floor((hud_height - 150) / 45)
  if new_rows_per_page ~= rows_per_page then
    hud_page = 1
    selected_btn = 0
  end
  rows_per_page = new_rows_per_page

  btn_next_page = rows_per_page + 1
  btn_prev_page = rows_per_page + 2
end


local function hud_render()
  if show_hud == false then return end 
  if levels == nil then scan_and_set_levels() end

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

  -- Exit early if no levels
  if levels_count == 0 then
    djui_hud_print_text("No levels to display.",
      screen_width/2 - djui_hud_measure_text("No levels to display.")/2,
      screen_height/2,
    1)
    return
  end

  -- Render rows
  local i = 1
  local page_start_idx = rows_per_page * (hud_page - 1) + 1
  for idx,level in pairs(levels) do
    if idx < page_start_idx
    or idx >= page_start_idx + rows_per_page then
      goto continue -- wtf lua..
    end

    lp_text_button(
      (screen_width/2) - (level_row_width/2),
      hud_y + 45 + 45*i,
      level.fullName .. " (" .. level.shortName .. ")",
      selected_btn == i,
      level_row_width
    )

    i = i + 1
    if i > rows_per_page then break end
    ::continue::
  end  

  -- Render page controls and current page
  local total_pages = math.ceil(levels_count / rows_per_page)

  djui_hud_set_color(255, 255, 255, 255)
  local current_page_text = string.format("Page %d/%d", hud_page, total_pages)
  djui_hud_print_text(
    current_page_text,
    (screen_width/2) - (djui_hud_measure_text(current_page_text)/2),
    hud_y + hud_height - 60,
    1
  )


  lp_text_button(
    (screen_width/2) + (level_row_width/2) - 120,
    hud_y + hud_height - 60,
    "Next",
    selected_btn == btn_next_page,
    120,
    true
  )

  lp_text_button(
    (screen_width/2) - (level_row_width/2),
    hud_y + hud_height - 60,
    "Previous",
    selected_btn == btn_prev_page,
    120,
    true
  )

end


local function advance_selection()
  selected_btn = selected_btn + 1

  -- How many rows on this page?

  local total_pages = math.ceil(levels_count / rows_per_page)
  local rows_on_this_page = rows_per_page
  if hud_page == total_pages then rows_on_this_page = levels_count % rows_per_page end

  -- Move to next page btn if done with rows
  if selected_btn == rows_on_this_page+1 then
    selected_btn = btn_next_page

  -- Move to start if beyond prev page button
  elseif selected_btn > btn_prev_page then
    selected_btn = 0
  end
end

local function retreat_selection()
  selected_btn = selected_btn - 1

  -- If beyond first button move to end
  if selected_btn < 0 then selected_btn = btn_prev_page end

  local total_pages = math.ceil(levels_count / rows_per_page)
  local rows_on_this_page = rows_per_page
  if hud_page == total_pages then rows_on_this_page = levels_count % rows_per_page end

  -- Move to last row in this page if less than next page button
  if selected_btn == btn_next_page - 1 then selected_btn = rows_on_this_page end
end

-- Handle "click" (pressing A on a button)
local function handle_click()
  local total_pages = math.ceil(levels_count / rows_per_page)
  local page_start_idx = rows_per_page * (hud_page - 1) + 1

  if selected_btn == btn_next_page then
    hud_page = hud_page + 1
    -- This should never be allowed to happen (buttons are toggled), but just in case
    if hud_page > total_pages then hud_page = total_pages end
    return
  elseif selected_btn == btn_prev_page then
    hud_page = hud_page - 1
    -- This should never be allowed to happen (buttons are toggled), but just in case
    if hud_page < 1 then hud_page = 1 end
    return
  else
    try_warp_to_level(page_start_idx + selected_btn - 1)
    show_hud = false
  end

end

local JOYSTICK_COOLDOWN = 5
local cooldown_timer = 0

--- @param m MarioState
local function mario_update(m)
  if m.playerIndex ~= 0 then return end
  if show_hud == false then return end 

  m.freeze = 1

  -- Explicitly check for close request
  if m.controller.buttonPressed & B_BUTTON ~= 0
  or m.controller.buttonPressed & A_BUTTON ~= 0 and selected_btn == BTN_CLOSE then
    show_hud = false
    return
  end

  -- Handle other presses
  if m.controller.buttonPressed & A_BUTTON ~= 0 then
    handle_click()
  end

  -- Handle joystick cooldown
  cooldown_timer = cooldown_timer - 1
  -- if our stick is at 0, then set joystickCooldown to 0
  if m.controller.stickY == 0 then cooldown_timer = 0 end
  -- exit early if not ready for another input
  if cooldown_timer > 0 then return end

  if m.controller.stickY < -0.5 then
    advance_selection()
    cooldown_timer = JOYSTICK_COOLDOWN
    play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
  end

  if m.controller.stickY > 0.5 then
    retreat_selection()
    cooldown_timer = JOYSTICK_COOLDOWN
    play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
  end
end


hook_chat_command("lph", "Show level picker HUD", function (msg)
  show_hud = true
end)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)