local screenWidth = djui_hud_get_screen_width()
local screenHeight = djui_hud_get_screen_height()

local timer = 0

local function hud_render()
  if gGlobalSyncTable.showHud == false then
    return
  end

  djui_hud_set_color(0, 0, 0, 255)
  djui_hud_render_rect(0, 0, screenWidth, screenHeight)

  -- djui_hud_print_text("Hello from levelpicker!", 100, 100, 1)
  local text = "Hello from levelpicker!"
  djui_hud_set_color(100, 255, 100, 255)
  djui_hud_print_text(text, (screenWidth - djui_hud_measure_text(text)) / 2, 50, 1)

  -- Keep screen size variables up to date
  screenWidth = djui_hud_get_screen_width()
  screenHeight = djui_hud_get_screen_height()

  timer = timer + 1
  if timer == 60*5 then
    gGlobalSyncTable.showHud = false
  end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)