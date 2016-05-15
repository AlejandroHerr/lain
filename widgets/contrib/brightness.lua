--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local read_pipe    = require("lain.helpers").read_pipe

local wibox        = require("wibox")
local math         = { floor  = math.floor }

local tonumber     = tonumber

local setmetatable = setmetatable

-- Basic template for custom widgets
-- lain.widgets.brightness
local brightness     = {}

function brightness:change(diff)
    os.execute('xbacklight ' .. diff)
    brightness.update()
    brightness.notifier()
end

if not brightness.notification then 
    brightness.notification = {}
end
function brightness:notifier()
    local maxBars = 20
    local num_bars = math.floor(maxBars * (brightness_now / 100.0))
    local msg = ''
    if brightness_now > 50 then
        msg = '🔆'
    else
        msg = '🔅'
    end
    msg = msg .. ' [' .. string.rep('|', num_bars) .. string.rep(' ', maxBars - string.rep('|', num_bars):len()) .. ']'

    brightness.notification = naughty.notify({
        text = msg,
        timeout = 5,
        font = beautiful.notification.presets.brightness.font,
        replaces_id = brightness.notification.id
    })
end

function brightness:destroy()
    naughty.destroy(brightness.notification)
end

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 60
    local cmd      = args.cmd or ""
    local settings = args.settings or function() end

    brightness.widget = wibox.widget.textbox('')

    function brightness.update()
        brightness_now = read_pipe('xbacklight -get')
        brightness_now = math.floor(tonumber(brightness_now)+0.5)
        widget = brightness.widget
        settings()
    end

    newtimer(cmd, timeout, brightness.update)

    return setmetatable(brightness, { __index = brightness.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
