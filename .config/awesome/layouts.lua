toto_layout = require("toto_layout")
two_thirds_layout = require("two_thirds_layout")
-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    two_thirds_layout,
    toto_layout,
    awful.layout.suit.tile.left,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.magnifier
}
-- }}}

return layouts
