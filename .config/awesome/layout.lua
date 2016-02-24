local math      = math
local ipairs    = ipairs
local beautiful = require("beautiful")

local function number_of_columns(screen)
  return math.ceil(math.sqrt(#screen.clients))
end

local function number_of_rows(screen)
  local n = math.ceil(math.sqrt(#screen.clients))

  if (n * (n - 1)) >= #screen.clients then
    n = n - 1
  end

  return n
end

local function cell_width(screen)
  local n   = number_of_columns(screen)
  local b   = beautiful.border_width
  local gap = beautiful.client_gap
  return (screen.workarea.width - (n - 1) * gap) / n - 2 * b
end

local function cell_height(screen)
  local n   = number_of_rows(screen)
  local b   = beautiful.border_width
  local gap = beautiful.client_gap
  return (screen.workarea.height - (n - 1) * gap) / n - 2 * b
end

local function arrange(screen)
  if #screen.clients == 0 then
    return
  end

  local height = math.floor(cell_height(screen))
  local width  = math.floor(cell_width(screen))
  local border = beautiful.border_width
  local gap    = beautiful.client_gap
  local cols   = number_of_columns(screen)
  local rows   = number_of_rows(screen)
  local xfill  = screen.workarea.width - (width + 2 * border) * cols - (gap * (cols - 1))
  local yfill  = screen.workarea.height - (height + 2 * border) * rows - (gap * (rows - 1))

  for i, client in ipairs(screen.clients) do
    local x = screen.workarea.x + ((i - 1) % cols) * (width + 2 * border + gap)
    local y = screen.workarea.y + (math.ceil(i / cols) - 1) * (height + 2 * border + gap)

    local height = height
    local width  = width

    if i % cols == 0 then
      width = width + xfill
    end

    if i > (cols * (rows - 1)) then
      height = height + yfill
    end

    client:geometry({
      x      = x,
      y      = y,
      height = height,
      width  = width
    })
  end
end

return {
  arrange = arrange
}
