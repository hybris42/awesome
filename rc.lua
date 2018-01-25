--------------------------------
-- Standard awesome libraries --
--------------------------------
local awful, beautiful, gears, naughty, wibox = require("awful"), require("beautiful"), require("gears"), require("naughty"), require("wibox")
local string, tostring, os, capi              = string, tostring, os, {mouse = mouse, screen = screen}
require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup").widget

--------------------
-- Error handling --
--------------------
if awesome.startup_errors then naughty.notify({title = "errors during startup", text = awesome.startup_errors}) end
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                                             if in_error then return end
                                             in_error = true
                                             naughty.notify({title = "error", text = err})
                                             in_error = false
                                          end)
end

-------------------
-- Basic theming --
-------------------
theme                                                                            = {}
theme.font                                                                       = "Ubuntu Mono 10"
theme.bg_normal, theme.bg_focus, theme.bg_urgent, theme.bg_minimize              = "#000000", "#000000", "#ff0000", "#444444"
theme.fg_normal, theme.fg_focus, theme.fg_urgent, theme.fg_minimize              = "#999999", "#ffffff", "#ffffff", "#000000"
theme.border_width, theme.border_normal, theme.border_focus, theme.border_marked = "1", "#444444", "#ffffff", "#990000"
beautiful.init(theme)


--------------------
-- Some functions --
--------------------
change_tag_name = function() awful.spawn.easy_async('rofi -p "Tag name: " -lines 1 -dmenu',
                                                    function(stdout, stderr, reason, exit_code)
                                                       if stdout ~= '\n' and stdout ~= '' then mouse.screen.selected_tag.name = mouse.screen.selected_tag.index .. ":" .. stdout
                                                       else mouse.screen.selected_tag.name = mouse.screen.selected_tag.index end
                                                   end)
end
spawn_ssh = function() awful.spawn.with_shell('ls /home/hybris/dev/bearstech/bearstech/infra/host | sed "s/^/1 root@/" > /home/hybris/.cache/rofi-2.sshcache && rofi -lines 50 -modi ssh -show ssh') end

----------
-- Keys --
----------
modkey     = "Mod4"
globalkeys = awful.util.table.join({},
           awful.key({modkey, "Control"}, "r",     awesome.restart,                                                                     {description = "Reload awesome",                             group = "Awesome"}),
           awful.key({modkey, "Control"}, "q",     awesome.quit,                                                                        {description = "Quit awesome",                               group = "Awesome"}),
           awful.key({modkey}, "h",                hotkeys_popup.show_help,                                                             {description = "Show this help",                             group = "Awesome"}),

           awful.key({modkey}, "Return",           function() awful.spawn("urxvtc") end,                                                {description = "Spawn a terminal",                           group = "Launcher"}),
           awful.key({modkey}, "F2",               function() awful.spawn('rofi -modi run -show run') end,                              {description = "Launcher",                                   group = "Launcher"}),
           awful.key({modkey}, "e",                function() awful.spawn("emacsclient -c -n") end,                                     {description = "Spawn an emacs",                             group = "Launcher"}),
           awful.key({modkey}, "F3",               spawn_ssh,                                                                           {description = "Spawn a terminal, SSH to the given address", group = "Launcher"}),

           awful.key({modkey}, "Left",             awful.tag.viewprev,                                                                  {description = "Move to previous tag",                       group = "Tag"}),
           awful.key({modkey}, "Right",            awful.tag.viewnext,                                                                  {description = "Move to next tag",                           group = "Tag"}),
           awful.key({modkey}, "Escape",           awful.tag.history.restore,                                                           {description = "Move to previously selected tag",            group = "Tag"}),
           awful.key({modkey}, "s",                function() awful.screen.focus(screen.count() - mouse.screen.index + 1) end,          {description = "Switch to selected tag on the other screen", group = "Tag"}),
           awful.key({modkey}, "F1",               change_tag_name,                                                                     {description = "Change tag name",                            group = "Tag"}),
           awful.key({modkey}, "j",                function() awful.spawn('rofi -modi window -show window') end,                        {description = "Switch tag by selecting window",             group = "Tag"}),
           awful.key({modkey}, "space",            function() awful.layout.inc({awful.layout.suit.fair, awful.layout.suit.max}, 1) end, {description = "Switch between 'fair' and 'max' layouts",    group = "Tag"}),

           awful.key({modkey}, "Tab",              function() awful.client.focus.byidx(1) end,                                          {description = "Select next client",                         group = "Client"}),
           awful.key({modkey, "Shift"}, "Tab",     function() awful.client.focus.byidx(-1) end,                                         {description = "Select previous client",                     group = "Client"}),
           awful.key({modkey, "Shift"}, "Left",    function() awful.client.focus.bydirection("left") end,                               {description = "Select client on the left",                  group = "Client"}),
           awful.key({modkey, "Shift"}, "Right",   function() awful.client.focus.bydirection("right") end,                              {description = "Select client on the right",                 group = "Client"}),
           awful.key({modkey, "Shift"}, "Up",      function() awful.client.focus.bydirection("up") end,                                 {description = "Select client on the top",                   group = "Client"}),
           awful.key({modkey, "Shift"}, "Down",    function() awful.client.focus.bydirection("down") end,                               {description = "Select client on the bottom",                group = "Client"}),
           awful.key({modkey, "Control"}, "Left",  function() awful.client.swap.bydirection("left") end,                                {description = "Swap with client on the left",               group = "Client"}),
           awful.key({modkey, "Control"}, "Right", function() awful.client.swap.bydirection("right") end,                               {description = "Swap with client on the right",              group = "Client"}),
           awful.key({modkey, "Control"}, "Up",    function() awful.client.swap.bydirection("up") end,                                  {description = "Swap with client on the top",                group = "Client"}),
           awful.key({modkey, "Control"}, "Down",  function() awful.client.swap.bydirection("down") end,                                {description = "Swap with client on the bottom",             group = "Client"}))



for i = 1, 9
do
   globalkeys = awful.util.table.join(globalkeys,
              awful.key({modkey}, "#" .. i + 9,            function() awful.screen.focused().tags[i]:view_only() end),
              awful.key({modkey, "Shift"}, "#" .. i + 9,   function() if client.focus then client.focus:move_to_tag(client.focus.screen.tags[i]) end end),
              awful.key({modkey, "Control"}, "#" .. i + 9, function() awful.tag.viewtoggle(awful.screen.focused().tags[i]) end))
end
root.keys(globalkeys)

clientkeys = awful.util.table.join({},
           awful.key({modkey}, "f",           function(c) c.maximized = not c.maximized end),
           awful.key({modkey, "Shift"}, "c",  function(c) c:kill() end),
           awful.key({modkey, "Shift"}, "s",  function(c) c:move_to_screen() end))
clientbuttons = awful.button({modkey}, 1,     function(c) awful.mouse.client.move(c) end)

-------------
-- Display --
-------------
awful.screen.connect_for_each_screen(function(s)
   awful.tag({1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42}, s, awful.layout.suit.fair)
   s.topbox = awful.wibar({position = "top", screen = s, height = 14})
   s.topbox:setup({layout = wibox.layout.align.horizontal,
                   {layout = wibox.layout.fixed.horizontal, awful.widget.taglist(s, awful.widget.taglist.filter.noempty), wibox.widget.textbox(" | ")},
                   awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, nil),
                   {layout = wibox.layout.fixed.horizontal, wibox.widget.systray(), wibox.widget.textbox(" | "), wibox.widget.textclock("<span color='" .. theme.fg_focus .. "'>%d/%m/%Y %R</span>")}})
   gears.wallpaper.maximized("/home/hybris/.wallpaper", s, "#000000")
end)

awful.rules.rules = {{rule = {}, properties = {border_width = beautiful.border_width, focus = awful.client.focus.filter, size_hints_honor = false, keys = clientkeys, buttons = clientbuttons}}}

client.connect_signal("manage", function (c)
                         if awesome.startup then
                            awful.placement.no_overlap(c)
                            awful.placement.no_offscreen(c)
                         end
end)
client.connect_signal("mouse::enter", function(c)
                         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then client.focus = c end
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-------------
-- Autorun --
-------------
awful.spawn.with_shell("urxvtc -e '' 2> /dev/null || urxvtd > /tmp/urxvtd.log 2>&1")
awful.spawn.with_shell("xmodmap ~/.xmodmaprc")
awful.spawn.with_shell("emacsclient -e '()' > /dev/null 2>&1 || emacs --daemon > /tmp/emacs.log 2>&1")
awful.spawn.with_shell("killall xbindkeys 2> /dev/null      ; xbindkeys")
awful.spawn.with_shell("killall nm-applet 2> /dev/null      ; nm-applet")
awful.spawn.with_shell("killall pasystray 2> /dev/null      ; pasystray")
awful.spawn.with_shell("killall blueman-applet 2> /dev/null ; blueman-applet > /dev/null 2>&1")
awful.spawn.with_shell("killall conky 2> /dev/null          ; conky -q")
awful.spawn.with_shell("ps aux | grep batterymon | grep -v grep || python /home/hybris/dev/misc/batterymon-clone/batterymon -t 24x24_wide")
