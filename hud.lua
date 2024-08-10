local screenWidth = djui_hud_get_screen_width()
local screenHeight = djui_hud_get_screen_height()

local timer = 0
local per_page = 5

local hud_width = screenWidth*3/4
local hud_height = screenHeight*3/4

local row_width = screenWidth*3/4
local row_height = 30

local s = gPlayerSyncTable[0]

-- Signals to stop rendering hud and resets some UI state
local function cleanup_hud()
  s.lpShowHud = false
  s.lpPage = 1
end

local function hud_render()
  if !s.lpShowHud or !s.lpLevels then
    return
  end

  djui_hud_set_color(0, 0, 0, 150)
  djui_hud_render_rect(screenWidth/2 - hud_width/2, screenHeight/2-hud_height/2, hud_width, hud_height)

  local text = "Hello from levelpicker!"
  djui_hud_set_color(100, 255, 100, 255)
  djui_hud_print_text(text, (screenWidth - djui_hud_measure_text(text)) / 2, 50, 1)

  -- for i = s.lpPage, s.lpPage+per_page, 1 do
  --   local level_idx = s*per_page + i
  --   local row_x = screenWidth / 2 - row_width - 2
  --   local row_y = 50 + (row_height + 2) * 1

  --   djui_hud_set_color(100, 100, 100, 255)
  --   djui_hud_render_rect(row_x, row_y, row_width, row_height)

  --   local level = s.lpLevels[level_idx]
  --   if level == nil then
  --     djui_hud_set_color(255, 0, 0, 255)
  --     djui_hud_print_text("uh oh", 0, 0, 1)
  --     return
  --   end
  --   local message = level.fullName .. " (" .. level.shortName .. ")"

  --   djui_hud_set_color(100, 255, 100, 255)
  --   djui_hud_render_rect(message, row_x, row_y, 1)
  -- end

  -- Keep screen size variables up to date
  screenWidth = djui_hud_get_screen_width()
  screenHeight = djui_hud_get_screen_height()

  timer = timer + 1
  if timer == 60*5 then
    cleanup_hud()
  end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)