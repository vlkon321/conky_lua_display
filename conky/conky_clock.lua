-- conky_clock.lua
--
-- author        : vlkon
-- version       : 20180805_01
-- conky version : conky 1.10.6_pre compiled Thu Dec 29 16:29:51 UTC 2016 for Linux 4.1.37-1-MANJARO x86_64
--
-- license:
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
-------------------------------------------------------------------------------

require 'cairo'

master_settings = {
    clock = {status = 1,    x = 160.0,      y = 80.0},      -- origin position - in this case it is bottom-center of the clock ":"
    date =  {status = 1,    x = 290.0,      y = 100.0},     -- origin position - top-right corner of day number
    scale = {               x = 1.0,        y = 1.0}        -- scale from top-left corner
}


-------------------------------------------------------------------------------
-- Slightly finer adjustment of each visual
-------------------------------------------------------------------------------

clock = {
    x_offset = 12.0,                                        -- offset hours and minutes from the center
    y_offset = 7.0,                                         -- offset colon ":" along y-direction from the center
    size = 100.0,
    font = 'Alex Brush',
    slant = CAIRO_FONT_SLANT_NORMAL,
    weight = CAIRO_FONT_WEIGHT_NORMAL,
    rgb = 0x000000,
    alpha = 0.9
}

date = {
    day = {
        status = 1,                                         -- 1:ON, 0:OFF
        x_offset = -3.0,            y_offset = 0.0,             -- offset from origin (top-right corner of a day number)
        size = 52.0,                                        -- font size
        font = 'Alex Brush',
        slant = CAIRO_FONT_SLANT_NORMAL,
        weight = CAIRO_FONT_WEIGHT_NORMAL,
        rgb = 0xB8860B,
        alpha = 0.8,
        text = '${time %_d}',
        x_align = 'RIGHT'                                   -- 'LEFT', 'RIGHT' x-alignment of the text
    },
    month = {
        status = 1,                                         -- 1:ON, 0:OFF
        x_offset = 5.0,         y_offset = 0.0,             -- offset from origin (top-right corner of a day number)
        size = 28.0,                                        -- font size
        font = 'Petit Formal Script',
        slant = CAIRO_FONT_SLANT_NORMAL,
        weight = CAIRO_FONT_WEIGHT_NORMAL,
        rgb = 0xFFFFFF,
        alpha = 0.6,
        text = '${time %B}',
        x_align = 'LEFT'                                    -- 'LEFT', 'RIGHT' x-alignment of the text
    },
    year = {
        status = 1,                                         -- 1:ON, 0:OFF
        x_offset = 50.0,            y_offset = 30.0,                -- offset from origin (top-right corner of a day number)
        size = 26.0,                                        -- font size
        font = 'Alex Brush',
        slant = CAIRO_FONT_SLANT_NORMAL,
        weight = CAIRO_FONT_WEIGHT_NORMAL,
        rgb = 0xA0A0A0,
        alpha = 0.5,
        text = '${time %Y}',
        x_align = 'LEFT'                                    -- 'LEFT', 'RIGHT' x-alignment of the text
    },
    wday = {
        status = 1,                                         -- 1:ON, 0:OFF
        x_offset = 0.0,         y_offset = 55.0,                -- offset from origin (top-right corner of a day number)
        size = 20.0,                                        -- font size
        font = 'Petit Formal Script',
        slant = CAIRO_FONT_SLANT_NORMAL,
        weight = CAIRO_FONT_WEIGHT_NORMAL,
        rgb = 0xD0D0D0,
        alpha = 0.6,
        text = '${time %A}',
        x_align = 'RIGHT'                                   -- 'LEFT', 'RIGHT' x-alignment of the text
    },
}


-------------------------------------------------------------------------------
-- Functions start here
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- converts color in hex to decimal R,G,B values and pass along alpha value
function convert_rgba_split(rgb, alpha)
    return ((rgb / 0x10000) % 0x100) / 255.0, ((rgb / 0x100) % 0x100) / 255.0, (rgb % 0x100) / 255.0, alpha
end


-------------------------------------------------------------------------------
-- print clock in 24h format "HH:MM" with fixed position of ":"
function draw_clock(cr)

    if master_settings.clock.status == 0 then return end    -- no date visualisation

    local x_org = master_settings.clock.x       -- clock origin
    local y_org = master_settings.clock.y
    local x, y = 0, 0               -- generic position variables

    local fe=cairo_font_extents_t:create()
    tolua.takeownership(fe)     -- garbage collection - don't know if used correctly or if it is even needed

    local te=cairo_text_extents_t:create()
    tolua.takeownership(te)     -- garbage collection - don't know if used correctly or if it is even needed

    -- get current time
    local hour = conky_parse('${time %0H}')
    local minute = conky_parse('${time %0M}')
        -- string.format('%02d', tonumber(conky_parse('${time %H}')))   -- possible formating

    cairo_set_font_size(cr, clock.size)
    cairo_set_source_rgba (cr,convert_rgba_split(clock.rgb, clock.alpha))
    cairo_select_font_face (cr, clock.font, clock.slant, clock.weight)

    cairo_font_extents (cr, fe)

    -- print ":"
    cairo_text_extents (cr, ':', te)
    x = x_org - te.x_bearing - te.width / 2
    y = y_org  - fe.ascent/2 + te.height/2 + clock.y_offset
    cairo_move_to (cr, x, y)
    cairo_show_text (cr, ':')

    -- print hours
    cairo_text_extents (cr, hour, te)
    x = x_org - te.x_bearing - te.width - clock.x_offset
    y = y_org
    cairo_move_to (cr, x, y)
    cairo_show_text (cr, hour)

    --print minutes
    cairo_text_extents (cr, minute, te)
    x = x_org - te.x_bearing + clock.x_offset
    y = y_org
    cairo_move_to (cr, x, y)
    cairo_show_text (cr, minute)
end


-------------------------------------------------------------------------------
-- draw each element present in date
function date_part(cr, x_org, y_org, setting)
    if setting.status == 0 then return end  -- no date element visualisation

    local text = conky_parse(setting.text)

    local fe=cairo_font_extents_t:create()
    tolua.takeownership(fe)     -- garbage collection - don't know if used correctly or if it is even needed

    local te=cairo_text_extents_t:create()
    tolua.takeownership(te)     -- garbage collection - don't know if used correctly or if it is even needed

    cairo_set_font_size(cr, setting.size)
    cairo_set_source_rgba (cr,convert_rgba_split(setting.rgb, setting.alpha))
    cairo_select_font_face (cr, setting.font, setting.slant, setting.weight)

    cairo_font_extents (cr, fe)

    cairo_text_extents (cr, text, te)

        if setting.x_align == 'RIGHT' then
            x = x_org - te.x_bearing  - te.width + setting.x_offset
        elseif setting.x_align == 'LEFT' then
            x = x_org - te.x_bearing + setting.x_offset
        else
            return      -- error in config
        end
    y = y_org + fe.ascent + setting.y_offset    --"+fe.ascent" instead of "-te.y_bearing" also possible but it holds different values depending on the text

    cairo_move_to (cr, x, y)
    cairo_show_text (cr, text)

end


-------------------------------------------------------------------------------
-- main date procedure
function draw_date(cr)

    if master_settings.date.status == 0 then return end -- no date visualisation

    for iii in pairs(date)  do
        date_part(cr, master_settings.date.x, master_settings.date.y, date[iii])
    end
end


-------------------------------------------------------------------------------
-- Main function called by conky
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main function called by conky
function conky_main()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display,
                                        conky_window.drawable,
                                        conky_window.visual,
                                        conky_window.width,
                                        conky_window.height)
    local cr = cairo_create(cs)

    local updates = tonumber(conky_parse('${updates}'))

    cairo_save (cr)
    cairo_scale (cr, master_settings.scale.x, master_settings.scale.y)  -- If you don't want to use a amagnifying glass this scales everything

    if updates > 3 then

        draw_clock(cr)
        draw_date(cr)

    end

    cairo_restore(cr)                                                   -- restore scale setting to 1.0,1.0

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
