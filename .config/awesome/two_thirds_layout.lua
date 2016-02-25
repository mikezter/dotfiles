local math      = math
local ipairs    = ipairs

local function arrange(screen)
  if #screen.clients == 0 then
    return
  end

  local width = {
    math.ceil(screen.workarea.width * 2 / 3),
    math.floor(screen.workarea.width * 1 / 3) - 3
  }

  local height = screen.workarea.height - 2

  for i, client in ipairs(screen.clients) do
    x = screen.workarea.x
    if i > 1 then
      x = x + width[1] + 1
    end

    y = screen.workarea.y

    client:geometry({
      x      = x,
      y      = y,
      height = height,
      width  = width[i]
    })
  end
end

return {
  arrange = arrange,
  name = "two_thirds"
}

