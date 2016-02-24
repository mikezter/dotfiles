local wibox     = require "wibox"
local beautiful = require "beautiful"
local gears     = require "gears"
local awful     = require "awful"

local text_width = beautiful.mpd_text_width

local function split(s,re)
  local find,sub,append = string.find, string.sub, table.insert
  local i1,ls = 1,{}
  if not re then re = '%s+' end
  if re == '' then return {s} end
  while true do
    local i2,i3 = find(s,re,i1,plain)
    if not i2 then
      local last = sub(s,i1)
      if last ~= '' then append(ls,last) end
      if #ls == 1 and ls[1] == '' then
        return {}
      else
        return ls
      end
    end
    append(ls,sub(s,i1,i2-1))
    i1 = i3+1
  end
end

local function chars(str)
  res = {}
  for i = 1, #str do
    res[i] = str:sub(i,i)
  end
  return res
end

position = 1
function scroll_text(s, l)
  if s == nil then
    return ''
  end

  local s = song
  if position + l > #s then
    position = 1
  end
  if position + l > #s then
    l = #s
  end

  c = chars(s)
  setmetatable(c, {__index = function() return ' ' end})
  r = ''
  for i = position, position + l do
    r = r .. c[i]
  end

  position = position + 1

  return r
end

song, playing, duration = "", false, ""
local function mpd_status()
  local file = assert(io.popen('/usr/bin/mpc', 'r'))
  local output = file:read('*all')
  file:close()

  a = split(output, "\n")

  if #a < 2 then
    song, playing, duration = nil, nil, nil
    return
  end

  b = split(a[2], " +")
  song, playing, duration = a[1], (b[1] == '[playing]'), b[3]
  song = string.gsub(song, '&', '&amp;')
end

local text = wibox.widget.textbox()
local icon = wibox.widget.imagebox()
icon:set_image('/home/mike/toto/dotfiles/.config/awesome/icons/pause.png')

text.width = text_width

local widget = wibox.layout.fixed.horizontal()
widget:add(icon)
widget:add(text)

awful.tooltip({
  objects = {widget},
  timer_function = function()
    if song == nil or duration == nil then
      return "no song"
    else
      return song .. " - " .. duration
    end
  end
})

widget:buttons(awful.util.table.join(awful.button({}, 1, function()
  awful.util.spawn('mpc toggle -q')
end)))

local function update()
  mpd_status()
  text:set_markup('<span font="Monospace">' .. scroll_text(song, text_width) .. '</span>')
  if playing then
    icon:set_image('/home/mike/toto/dotfiles/.config/awesome/icons/play.png')
  else
    icon:set_image('/home/mike/toto/dotfiles/.config/awesome/icons/pause.png')
  end
end

local mpd_timer = gears.timer({ timeout = 1 })
mpd_timer:connect_signal("timeout", update)
mpd_timer:start()

return widget
