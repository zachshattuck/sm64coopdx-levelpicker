
--- @param x number
--- @param y number
--- @param text string
--- @param highlighted boolean?
--- @param width_override number? Optionally override width
--- @param center boolean? If width_override is wider than rendered text, should the text be centered
function text_button(x, y, text, highlighted, width_override, center)

  local BUTTON_HEIGHT = 35
  local BORDER_SIZE = 1
  local SIDE_PADDING = 10

  local text_width = djui_hud_measure_text(text)
  local adjusted_text = text
  local text_x = x + BORDER_SIZE + SIDE_PADDING
  local text_y = y + BORDER_SIZE

  --- @type number Width of the button
  local button_width

  if(width_override) then -- User wants a specific width, truncate text if necessary
    button_width = width_override

    local char_size = djui_hud_measure_text("a")
    local max_allowed_chars = math.floor(button_width / char_size)

    -- If provided text is too wide to fit in given width override, truncate the text
    if text:len() > max_allowed_chars then
      adjusted_text = string.sub(text, 1, max_allowed_chars)
      text_width = djui_hud_measure_text(adjusted_text)
    end

    -- If button is wider than rendered text and the user wants to center it, adjust text_x
    if center and ((text_width + (SIDE_PADDING*2)) < button_width) then
      text_x = x + (button_width/2) - (text_width/2)
    end

  else
    button_width = text_width + (SIDE_PADDING*2)
  end


  -- 1px outline
  if highlighted == true then
    djui_hud_set_color(230, 230, 50, 255)
  else 
    djui_hud_set_color(255, 255, 255, 255)
  end
  djui_hud_render_rect(
    x, y,
    button_width, BUTTON_HEIGHT
  )

  -- main button body
  djui_hud_set_color(0, 0, 0, 255)
  djui_hud_render_rect(
    x + BORDER_SIZE, y + BORDER_SIZE,
    button_width - (BORDER_SIZE*2), BUTTON_HEIGHT - (BORDER_SIZE*2)
  )


  -- text
  if highlighted == true then
    djui_hud_set_color(230, 230, 50, 255)
  else 
    djui_hud_set_color(255, 255, 255, 255)
  end
  djui_hud_print_text(adjusted_text, text_x, text_y, 1)
end