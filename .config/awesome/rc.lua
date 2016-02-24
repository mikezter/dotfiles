local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- package.path = package.path .. ';' .. '/home/mike/toto/dotfiles/.config/awesome/?.lua'


naughty.config.presets.normal.opacity   = 0.8
naughty.config.presets.low.opacity      = 0.8
naughty.config.presets.critical.opacity = 0.8

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    if in_error then
      return
    end

    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "error",
      text = err
    })

    in_error = false
  end)
end

beautiful.init("/home/mike/.config/awesome/theme.lua")

local layout = require("layout")

terminal = "terminator"
modkey   = "Mod4"

tags = {}
for s = 1, screen.count() do
  tags[s] = awful.tag({ 1, 2, 3, 4, 5}, s, layout)
end

mywibox = {}
promptbox = {}

taglist = {}
taglist.buttons = awful.button({ }, 1, awful.tag.viewonly)

tasklist = {}

-- --------------------
-- widgets
-- --------------------

package.path = package.path .. ';' .. '/home/mike/.config/awesome' .. '/widgets/?.lua'

clock  = require("widgets/clock")
xkb    = require("widgets/xkb")

separator = wibox.widget.textbox()
separator:set_markup("    ")

tasklist.buttons = awful.button({ }, 1, function (c)
  if c == client.focus then
    c.minimized = true
  else
    c.minimized = false
    client.focus = c
    c:raise()
  end
end)

for s = 1, screen.count() do
  promptbox[s] = awful.widget.prompt()
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)
  tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist.buttons)

  mywibox[s] = awful.wibox({ position = "top", screen = s })

  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(taglist[s])
  left_layout:add(promptbox[s])

  local right_layout = wibox.layout.fixed.horizontal()

  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(separator)
  right_layout:add(xkb.widget)
  right_layout:add(separator)
  right_layout:add(clock)

  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(tasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end

root.buttons(awful.util.table.join(
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

globalkeys = awful.util.table.join(
  awful.key({ modkey, }, "Left",   awful.tag.viewprev),
  awful.key({ modkey, }, "Right",  awful.tag.viewnext),
  awful.key({ modkey, }, "Escape", awful.tag.history.restore),
  awful.key({ modkey, }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, }, "l", function() awful.util.spawn('i3lock -c 000000') end),
  awful.key({ modkey, }, "a", function() awful.client.focus.global_bydirection("left") end ),
  awful.key({ modkey, }, "d", function() awful.client.focus.global_bydirection("right") end),
  awful.key({ modkey, }, "w", function() awful.client.focus.global_bydirection("up") end ),
  awful.key({ modkey, }, "s", function() awful.client.focus.global_bydirection("down") end),
  awful.key({ modkey, }, "space", xkb.switch),
  awful.key({ modkey, }, "Tab", function()
    awful.client.focus.byidx(1)
  end),
  awful.key({ modkey, "Shift"       }, "Tab", function()
    awful.client.focus.byidx(-1)
  end),
  awful.key({ modkey, "Control" }, "n", awful.client.restore),
  awful.key({ modkey },            "r", function() promptbox[mouse.screen]:run() end),
  awful.key({ modkey, }, "b", function()
    local matcher = function(c)
      return awful.rules.match(c, {role = "browser"})
    end
    awful.client.run_or_raise("google-chrome", matcher)
  end),
  awful.key({ modkey, }, "k", function()
    local matcher = function(c)
      return awful.rules.match(c, {class = "Keepassx"})
    end
    awful.client.run_or_raise("keepassx", matcher)
  end),



  -- Media Keys
  --awful.key({}, "XF86AudioNext", function()
    --awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
  --end),
  --awful.key({}, "XF86AudioPrev", function()
    --awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
  --end),
  --awful.key({}, "XF86AudioPlay", function()
    --awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
  --end),

  -- Volume
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
  end),
  awful.key({}, "XF86AudioLowerVolume", function()
    awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ -- -5%")
  end),
  awful.key({}, "XF86AudioMute",        function()
    awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
  end)
)

local function view(i)
  return function()
    local screen = mouse.screen
    if tags[screen][i] then
      awful.tag.viewonly(tags[screen][i])
    end
  end
end

local function toggle(i)
  return function()
    local screen = mouse.screen
    if tags[screen][i] then
      awful.tag.viewtoggle(tags[screen][i])
    end
  end
end

local function move_to(i)
  return function()
    if client.focus and tags[client.focus.screen][i] then
      awful.client.movetotag(tags[client.focus.screen][i])
    end
  end
end

local function add_to(i)
  return function()
    if client.focus and tags[client.focus.screen][i] then
      awful.client.toggletag(tags[client.focus.screen][i])
    end
  end
end


for i = 1, 5 do
  globalkeys = awful.util.table.join(
  globalkeys,
  awful.key({ modkey },                     "#" .. i + 9, view(i)),
  awful.key({ modkey, "Control" },          "#" .. i + 9, toggle(i)),
  awful.key({ modkey, "Shift" },            "#" .. i + 9, move_to(i)),
  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, add_to(i))
  )
end

root.keys(globalkeys)

local function fullscreen(c)
  c.fullscreen = not c.fullscreen
end

local function kill(c)
  c:kill()
end

local function maximize(c)
  c.maximized_horizontal = not c.maximized_horizontal
  c.maximized_vertical   = not c.maximized_vertical
end

local function minimize(c)
  c.minimized = true
end

local function focus(c)
  c.minimized = false
  client.focus = c
  c:raise()
end

local function on_focus(c)
  c.border_color = beautiful.border_focus
  c.opacity = 1
  focus(c)
end

local function on_unfocus(c)
  c.border_color = beautiful.border_normal
  c.opacity      = 0.85
end

local function on_mouseover(c)
  client.focus = c
end

local function on_manage(c, startup)
  c:connect_signal("mouse::enter", on_mouseover)

  if awesome.startup then
    return
  end

  awful.client.setslave(c)

  if not c.size_hints.user_position and not c.size_hints.program_position then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
  end
end

local buttons = awful.util.table.join(
  awful.button({ },        1, focus),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize,move)
)

local keys = awful.util.table.join(
  awful.key({ modkey,        }, "f", fullscreen),
  awful.key({ modkey, "Shift"}, "c", kill),
  awful.key({ modkey,        }, "n", minimize),
  awful.key({ modkey,        }, "m", maximize)
)

awful.rules.rules = {
  -- sets the client key bindings
  -- on all clients
  {
    rule = {},
    properties = {
      border_width     = beautiful.border_width,
      size_hints_honor = false,
      border_color     = beautiful.border_normal,
      focus            = true,
      keys             = keys,
      buttons          = buttons,
      opacity          = 0.85,
      focus_opacity    = 1
    }
  },

  -- specific rules
  {
    rule = {
      class = "mpv"
    },
    properties = {
      floating = true,
      opacity  = 1
    }
  },

  {
    rule = {
      name = "Terminator Preferences"
    },
    properties = {
      floating = true
    }
  },

  {
    except = {
      role = "browser"
    },
    properties = {
      tag = tags[1][1]
    }
  }

}

client.connect_signal("manage",  on_manage)
client.connect_signal("focus",   on_focus)
client.connect_signal("unfocus", on_unfocus)
