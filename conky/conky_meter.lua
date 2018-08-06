-- conky_meter.lua
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
	-- status: 1 == ON, 0 == OFF - basic setting to completely turn on/off certain function of conky display
	-- x,y are origin coordinates common to all elements - top-left corner of the window

	cpu		= {status = 1,		x = 0,		y = 0},
	top		= {status = 1,		x = 140,	y = 0},
	txt		= {status = 1,		x = 300,	y = 150},
	gpu		= {status = 1,		x = 185,	y = 200},
	mem		= {status = 1,		x = 20,		y = 150},
	net		= {status = 1,		x = 295,	y = 350,		interface = 'wlp6s0'},
	hdd		= {status = 1,		x = 20,		y = 230},
	scale 	= {					x = 1.0,	y = 1.0}					-- scale everything (from top-left corner) - may require bigger window in conky_meter.conf
}

fonts = {
	header = 'Petit Formal Script',
	serif = 'Liberation Serif',
	mono = 'Liberation Mono',
	sans = 'Liberation Sans'
}


-------------------------------------------------------------------------------
-- Slightly finer adjustment of each visual
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- CPU
cpu_gauge_common = {
		core_no = 8,													-- No. of logic threads (2*physical cores for Intel i7)
		max_value = 100,												-- maximal value for an indicator (100% for CPU gauge)

		x = 75,						y = 85,								-- center position
		x_offset = 75,				y_offset = 0,						-- offset for left and right gauge; combined with large radius it can be achieved to look like bended lines close together

		radius = 110,													-- radius of innermost gauge ( innermost line is radius-(thickness/2) )
		angle_start = (180-20),	angle_stop = (180+30),					-- 0°==3 o'clock, 90°==6 o'clock, 180°==9 o'clock
		gap = 10														-- gap between each gauge
}

cpu_gauge_settings = {
	background = {
		name = 'background',											-- do not change
		status = 1,														-- 1 == has background, 0 == no background
		count = 0,														-- count is not used for background -> leave at 0
		width = 5,														-- should be =< gauge_gap
--		thickness = 0,													-- thickness not used for background
		rgb = 0xFFFFFF,				alpha = 0.05,
		line_cap = CAIRO_LINE_CAP_BUTT
	},
	bar = {
		name = 'bar',													-- do not change
		status = 1,														-- 1 == has indicator bars, 0 == no indicator bars - no point in the gauge without an indicator unles it has indicator_bar
		count = 0,														-- count is not used for bars -> leave at 0
		width = 5,														-- width should be <= gauge_gap
--		thickness = 0,													-- thickness not used for bars
		rgb = 0xFFFFFF,				alpha = 0.1,
		line_cap = CAIRO_LINE_CAP_BUTT									-- should be the same as background_line_cap
	},
	notch = {
		name = 'notch',													-- do not change
		status = 1,														-- 1 == has % marking, 0 == no marks
		count = 4,														-- how many notches are on the scale (+1 because of 0 position) - 100%/notch_count, has to be positive value
		width = 7,														-- width should be =< gauge_gap
		thickness = 0.4,												-- thickness is in degrees
		rgb = 0xB8860B,				alpha = 0.6,
		line_cap = CAIRO_LINE_CAP_BUTT									-- leave it at BUTT or it will look ugly
	},
	indicator = {
		name = 'indicator',												-- do not change
		status = 1,														-- 1 == has indicator, 0 == no indicator - no point in the gauge without an indicator unles it has indicator_bar
		count = 0,														-- count is not used for indicator -> leave at 0
		width = 5,														-- width should be <= gauge_gap;
		thickness = 0.8,												-- thickness is in degrees
		rgb = 0x80DD00,				alpha = 1.0,
		line_cap = CAIRO_LINE_CAP_BUTT									-- leave it at BUTT or it will look ugly
	}
}

cpu_text = {
	-- Main section - marking of indicator group (e.g. "CPU")
	cpu = {
		status = 1,					group = 'cpu',						-- status:1==ON, 0==OFF; don't change group
		x = 52,						y = 85,								-- origin position
		size = 20,					font = fonts.header,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_BOLD,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.6,
		text_pre	= 'Cpu',
		text_conky	= '',
		text_post	= ''
	},
	-- Temperature visualization
	temp = {
		status = 1,					group = 'cpu',						-- status:1==ON, 0==OFF; don't change group
		x = 60,						y = 110,							-- origin position
		size = 14,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0x80DD00,				alpha = 0.3,
		text_pre	= '',
		text_conky	= '${hwmon 1 temp § 1.0 0.0}',
		oper = 'MAX',				iter = {1, 2, 3, 4, 5},				--iteration '§' symbol over "iter" elements to find "oper" (oper values are 'MIN', 'MAX', 'SUM')
		text_post	= '°C',
		-- alarms
		mid	= 55,	mid_rgb	= 0xCCCC00,		mid_alpha	= 0.4,			-- alarm at mid values
		hi	= 70,	hi_rgb	= 0xFF0000,		hi_alpha	= 0.5			-- alarm at high values
	},
	-- Frequency visualization
	freq = {
		status = 1,					group = 'cpu',						-- status:1==ON, 0==OFF; don't change group
		x = 52,						y = 20,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xCCCC00,				alpha = 0.3,
		text_pre	= '',
		text_conky	= '${freq_g §}',
		oper = 'AVG',				iter = {1, 2, 3, 4, 5, 6, 7, 8},	--iteration '§' symbol over "iter" elements to find "oper" (oper values are 'MIN', 'MAX', 'SUM')
		text_post	= ' GHz',
		mid	= 2.4,	mid_rgb	= 0xCCCC00,		mid_alpha	= 0.4,			-- alarm at mid values
		hi	= 4.0,	hi_rgb	= 0xCCCC00,		hi_alpha	= 0.5			-- alarm at high values
	},
	-- Average percentage visualization
	proc = {
		status = 1,					group = 'cpu',						-- status:1==ON, 0==OFF; don't change group
		x = 63,						y = 50,								-- origin position
		size = 14,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xDDDD00,				alpha = 0.5,
		text_pre	= '',
		text_conky	= '${cpu cpu0}',									-- cpu0 == average cpu load - does not have to iterate over X cores
--		oper = 'AVG',				iter = {1, 2, 3, 4, 5, 6, 7, 8},	-- iteration '§' symbol over "iter" elements to find "oper" (oper values are 'MIN', 'MAX', 'SUM')
		text_post	= '%'
--		mid	= 2.4,	mid_rgb	= 0x00FFFF,		mid_alpha	= 1.0,			-- alarm at mid values
--		hi	= 4.0,	hi_rgb	= 0xFF0000,		hi_alpha	= 1.0			-- alarm at high values
	},
}

-------------------------------------------------------------------------------
-- TOP
top_text = {
	-- name programs with most CPU load
	cpu_header = {
		status = 1,					group = 'top',						-- status:1==ON, 0==OFF; don't change group
		x = 5,						y = 13,								-- origin position
		dx = 0,						dy = 0,								-- listing offset
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.5,
		text_pre	= 'Top CPU',
		text_conky	= '',
		text_post	= ''
	},
	-- list load for programs TOP_CPU
	cpu_name = {
		status = 1,					group = 'top',						-- status:1==ON, 0==OFF; don't change group
		x = 50,						y = 25,								-- origin position
		dx = 6,						dy = 11,							-- listing offset
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.4,
		text_pre	= '\\ ',
		text_conky	= '${top name §}',
		oper = 'LIST',				iter = {1, 2, 3, 4, 5},				--iteration '§' symbol over "iter" elements to find "oper" (oper values use only 'LIST')
		text_post	= ''
	},
	-- list load for programs TOP_CPU
	cpu_perc = {
		status = 1,					group = 'top',						-- status:1==ON, 0==OFF; don't change group
		x = 0,						y = 25,								-- origin position
		dx = 5,						dy = 11,							-- listing offset
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.4,
		text_pre	= '',
		text_conky	= '${top cpu §}',
		oper = 'LIST',				iter = {1, 2, 3, 4, 5},				-- iteration '§' symbol over "iter" elements to find "oper" (oper values use only 'LIST')
		text_post	= ''
	},
	mem_header = {
		status = 1,					group = 'top',						-- status:1==ON, 0==OFF; don't change group
		x = 40,						y = 88,								-- origin position
		dx = 0,						dy = 0,								-- listing offset
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.5,
		text_pre	= 'Top Memory',
		text_conky	= '',
		text_post	= ''
	},
	-- list load for programs TOP_CPU
	mem_name = {
		status = 1,					group = 'top',						-- status:1==ON, 0==OFF; don't change group
		x = 70,						y = 100,							-- origin position
		dx = -6,					dy = 11,							-- listing offset
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.4,
		text_pre	= '/ ',
		text_conky	= '${top_mem name §}',
		oper = 'LIST',				iter = {1, 2, 3, 4, 5},				-- iteration '§' symbol over "iter" elements to find "oper" (oper values use only 'LIST')
		text_post	= ''
	},
	-- list load for programs TOP_CPU
	mem_perc = {
		status = 1,					group = 'top',						-- status:1==ON, 0==OFF; don't change group
		x = 20,						y = 100,							-- origin position
		dx = -6,					dy = 11,							-- listing offset
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.4,
		text_pre	= '',
		text_conky	= '${top_mem mem §}',
		oper = 'LIST',				iter = {1, 2, 3, 4, 5},				-- iteration '§' symbol over "iter" elements to find "oper" (oper values use only 'LIST')
		text_post	= ''
	}
}

-------------------------------------------------------------------------------
-- TXT
misc_txt = {
	desktop_value = {
		status = 1,					group = 'txt',						-- status:1==ON, 0==OFF; don't change group
		x = 60,						y = 20,								-- origin position
		size = 24,					font = fonts.serif,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xebc900,				alpha = 0.5,
		text_pre	= '',
		text_conky	= '${desktop}',
		text_post	= '',
	},
	uptime_text = {
		status = 1,					group = 'txt',						-- status:1==ON, 0==OFF; don't change group
		x = 10,						y = 26,								-- origin position
		size = 11,					font = fonts.serif,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.5,
		text_pre	= 'Uptime:',
		text_conky	= '',
		text_post	= '',
	},
	uptime_value = {
		status = 1,					group = 'txt',						-- status:1==ON, 0==OFF; don't change group
		x = 0,						y = 40,								-- origin position
		size = 12,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0x10AABB,				alpha = 0.7,
		text_pre	= '',
		text_conky	= '${uptime}',
		text_post	= '',
	}
}

-------------------------------------------------------------------------------
-- GPU
gpu_gauge_common = {
		x = 53,						y = 90,								-- origin position
		x_scale = 1.0,				y_scale = 0.45,						-- change deformation of x and y axis
		radius = 45,
		angle_start = (90+50),		angle_stop = (90-10),				-- 0°==3 o'clock, 90°==6 o'clock, 180°==9 o'clock
}

gpu_gauge_settings = {
	background = {
		name = 'background',											-- do not change
		status = 1,														-- 1 == has background, 0 == no background
		count = 0,														-- count is not used for background -> leave at 0
		width = 7,														-- should be =< gauge_gap
--		thickness = 0,													-- thickness not used for background
		rgb = 0xFFFFFF,				alpha = 0.05,
		line_cap = CAIRO_LINE_CAP_BUTT
	},
	bar = {
		name = 'bar',													-- do not change
		status = 1,														-- 1 == has indicator bars, 0 == no indicator bars - no point in the gauge without an indicator unles it has indicator_bar
		count = 0,														-- count is not used for bars -> leave at 0
		width = 7,														-- width should be <= gauge_gap
--		thickness = 0,													-- thickness not used for bars
		rgb = 0xFFFFFF,				alpha = 0.1,
		line_cap = CAIRO_LINE_CAP_BUTT									-- should be the same as background_line_cap
	},
	notch = {
		name = 'notch',													-- do not change
		status = 1,														-- 1 == has % marking, 0 == no marks
		count = 10,														-- how many notches are on the scale (+1 because of 0 position) - 100%/notch_count, has to be positive value
		width = 7,														-- width should be =< gauge_gap
		thickness = 1.8,												-- thickness is in degrees
		rgb = 0xB8860B,				alpha = 0.6,
		line_cap = CAIRO_LINE_CAP_BUTT									-- leave it at BUTT or it will look ugly
	},
	indicator = {
		name = 'indicator',												-- do not change
		status = 1,														-- 1 == has indicator, 0 == no indicator - no point in the gauge without an indicator unles it has indicator_bar
		count = 0,														-- count is not used for indicator -> leave at 0
		width = 7,														-- width should be <= gauge_gap;
		thickness = 3.0,												-- thickness is in degrees
		rgb = 0x80DD00,				alpha = 1.0,
		line_cap = CAIRO_LINE_CAP_BUTT									-- leave it at BUTT or it will look ugly
	}
}

gpu_text = {
	gpu = {
		status = 1,					group = 'gpu',						-- status:1==ON, 0==OFF; don't change group
		x = 22,						y = 40,								-- origin position
		size = 18,					font = fonts.header,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_BOLD,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.6,
		text_pre	= 'Gpu',
		text_conky	= '',
		text_post	= ''
	},
	temp = {
		status = 1,					group = 'gpu',						-- status:1==ON, 0==OFF; don't change group
		x = 23,						y = 60,								-- origin position
		size = 14,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0x80DD00,				alpha = 0.3,
		text_pre	= '',
		text_conky	= '${nvidia gputemp}',
		text_post	= '°C',
		-- alarms
		mid	= 55,	mid_rgb	= 0xCCCC00,		mid_alpha	= 0.4,			-- alarm at mid values
		hi	= 70,	hi_rgb	= 0xFF0000,		hi_alpha	= 0.5			-- alarm at high values
	},
	fan_mark = {
		status = 1,					group = 'gpu',						-- status:1==ON, 0==OFF; don't change group
		x = 66,						y = 38,								-- origin position
		size = 10,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_BOLD,								-- NORMAL, BOLD
		rgb = 0x10AABB,				alpha = 0.5,
		text_pre	= 'Fan',
		text_conky	= '',
		text_post	= '',
	},
	fan_val = {
		status = 1,					group = 'gpu',						-- status:1==ON, 0==OFF; don't change group
		x = 55,						y = 50,								-- origin position
		size = 10,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_BOLD,								-- NORMAL, BOLD
		rgb = 0x10AABB,				alpha = 0.5,
		text_pre	= '',
		text_conky	= '${nvidia fanlevel}',
		text_post	= '%',
--		mid	= 55,	mid_rgb	= 0xCCCC00,		mid_alpha	= 0.4,			-- alarm at mid values
--		hi	= 70,	hi_rgb	= 0xFF0000,		hi_alpha	= 0.5			-- alarm at high values
	}
}

-------------------------------------------------------------------------------
-- MEM
mem_curve = {
	common = {
		x_start = 0,		y_start = 0,
		x_end = 330,		y_end = 100,
		rec_p = 200,													-- dictates how precise is the graph (precision = 1/rec_p)
		height = 7,														-- "thickness" of the graph
		gap = 0.2,														-- gap between each mark on the graph
		amplitude = -30,												-- amplitude of the sine wave of the graph
	},
	used = {
		rgb = 0x70CC00,		alpha = 0.50,
		line_cap = CAIRO_LINE_CAP_ROUND									-- 'BUTT', 'ROUND', 'SQUARE' change shape of each small mark on the graph
	},
	buffer = {
		rgb = 0xBBB36D,		alpha = 0.40,
		line_cap = CAIRO_LINE_CAP_ROUND
	},
	cache = {
		rgb = 0x20F0F0,		alpha = 0.15,
		line_cap = CAIRO_LINE_CAP_ROUND
	},
	free = {
		rgb = 0xFFFFFF,		alpha = 0.15,
		line_cap = CAIRO_LINE_CAP_ROUND
	}
}

mem_text = {
	mem = {
		status = 1,					group = 'mem',						-- status:1==ON, 0==OFF; don't change group
		x = 53,						y = 27,								-- origin position
		size = 18,					font = fonts.header,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_BOLD,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.6,
		text_pre	= 'Memory',
		text_conky	= '',
		text_post	= ''
	},
	used = {
		status = 1,					group = 'mem',						-- status:1==ON, 0==OFF; don't change group
		x = 71,						y = 45,								-- origin position
		size = 14,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0x70CC00,				alpha = 0.5,
		text_pre	= 'Used: ',
		text_conky	= '${memperc}',
		text_post	= '%'
	},
}

-------------------------------------------------------------------------------
-- NET
net_common = {
	interface = master_settings.net.interface,							-- network interface - better not change it here since it is quite burried in the settings
	graph = 1,															-- 1:ON, 0:OFF graph printing
	style = 'BAR',														-- style is 'LINE' for only contour, 'BAR' for filled bargraph
	height = 560,				history = 280,							-- height is Y size of the whole graph, history ~ number of updates to show
	scale_max_height = 60
}

net_graph = {
	mid = {
		command = nil,
		table = {},
		thickness = 0.5,		direction = 0.0,						-- direction also affects scale
		rgb = 0xFFFFFF,			alpha_start = 0.3,		alpha_stop = 0.0,
		line_cap = CAIRO_LINE_CAP_ROUND									-- 'BUTT', 'ROUND', 'SQUARE' change shape of each small mark on the graph
	},
	up = {
		command = 'upspeedf',
		table = {},
		thickness = 0.8,		direction = 1.0,						-- direction also affects scale
		rgb = 0xEE7000,			alpha_start = 0.15,		alpha_stop = 0.0,
		line_cap = CAIRO_LINE_CAP_ROUND									-- 'BUTT', 'ROUND', 'SQUARE' change shape of each small mark on the graph
	},
	down = {
		command = 'downspeedf',
		table = {},
		thickness = 0.8,		direction = -1.0,						-- direction also affects scale
		rgb = 0x70EE00,			alpha_start = 0.15,		alpha_stop = 0.0,
		line_cap = CAIRO_LINE_CAP_ROUND									-- 'BUTT', 'ROUND', 'SQUARE' change shape of each small mark on the graph
	}
}

net_text = {
	net = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = -12,					y = -51,								-- origin position
		size = 20,					font = fonts.header,
		slant = CAIRO_FONT_SLANT_ITALIC,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_BOLD,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.6,
		text_pre	= 'Net',
		text_conky	= '',
		text_post	= ''
	},
	ip = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = -50,					y = -38,								-- origin position
		size = 12,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0x10AABB,				alpha = 0.7,
		text_pre	= '',
		text_conky	= string.format('${addr %s}', master_settings.net.interface),
		text_post	= ''
	},
	upspeed_text = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = 18,						y = -24,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.5,
		text_pre	= 'Up',
		text_conky	= '',
		text_post	= ''
	},
	downspeed_text = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = -47,						y = -24,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.5,
		text_pre	= 'Down',
		text_conky	= '',
		text_post	= ''
	},
	upspeed = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = 13,						y = -13,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = net_graph.up.rgb,				alpha = 0.6,
		text_pre	= '',
		text_conky	= string.format('${upspeedf %s}', master_settings.net.interface),
		text_post	= ''
	},
	downspeed = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = -47,						y = -13,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = net_graph.down.rgb,				alpha = 0.6,
		text_pre	= '',
		text_conky	= string.format('${downspeedf %s}', master_settings.net.interface),
		text_post	= ''
	},
	upspeed_unit = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = 13,						y = -2,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.4,
		text_pre	= '',
		text_conky	= '',
		text_post	= 'KiB/s'
	},
	downspeed_unit = {
		status = 1,					group = 'net',						-- status:1==ON, 0==OFF; don't change group
		x = -47,						y = -2,								-- origin position
		size = 11,					font = fonts.mono,
		slant = CAIRO_FONT_SLANT_NORMAL,								-- NORMAL, ITALIC, OBLIQUE
		weight = CAIRO_FONT_WEIGHT_NORMAL,								-- NORMAL, BOLD
		rgb = 0xFFFFFF,				alpha = 0.4,
		text_pre	= '',
		text_conky	= '',
		text_post	= 'KiB/s'
	}
}

-------------------------------------------------------------------------------
-- HDD/SSD
hdd_all = {
	root = {	
		common = {
				fs = '/',												-- file system that should be listed - also change text section
				x_offset = 0,				y_offset = 0,				-- offset xy from HDD origin - moves gauges and text alike
				x = 53,						y = 90,						-- origin position of gauges
				x_scale = 1.0,				y_scale = 0.5,				-- change deformation of x and y axis
				max_value = 100,										-- maximal value on the gauge -> 100%
				radius = 45,
				angle_start = 90,			angle_stop = 0				-- 0°==3 o'clock, 90°==6 o'clock, 180°==9 o'clock
		},
		gauge = {
			background = {
				name = 'background',									-- do not change
				status = 1,												-- 1 == has background, 0 == no background
				count = 0,												-- count is not used for background -> leave at 0
				width = 7,												-- should be =< gauge_gap
				rgb = 0xFFFFFF,				alpha = 0.05,
				line_cap = CAIRO_LINE_CAP_BUTT
			},
			bar = {
				name = 'bar',											-- do not change
				status = 1,												-- 1 == has indicator bars, 0 == no indicator bars - no point in the gauge without an indicator unles it has indicator_bar
				count = 0,												-- count is not used for bars -> leave at 0
				width = 7,												-- width should be <= gauge_gap
				rgb = 0xFFFFFF,				alpha = 0.2,
				line_cap = CAIRO_LINE_CAP_BUTT							-- should be the same as background_line_cap
			},
			notch = {
				name = 'notch',											-- do not change
				status = 1,												-- 1 == has % marking, 0 == no marks
				count = 10,												-- how many notches are on the scale (+1 because of 0 position) - 100%/notch_count, has to be positive value
				width = 7,												-- width should be =< gauge_gap
				thickness = 1.8,										-- thickness is in degrees
				rgb = 0xB8860B,				alpha = 0.6,
				line_cap = CAIRO_LINE_CAP_BUTT							-- leave it at BUTT or it will look ugly
			},
			indicator = {
				name = 'indicator',										-- do not change
				status = 1,												-- 1 == has indicator, 0 == no indicator - no point in the gauge without an indicator unles it has indicator_bar
				count = 0,												-- count is not used for indicator -> leave at 0
				width = 7,												-- width should be <= gauge_gap;
				thickness = 3.0,										-- thickness is in degrees
				rgb = 0x80DD00,				alpha = 1.0,
				line_cap = CAIRO_LINE_CAP_BUTT							-- leave it at BUTT or it will look ugly
			}
		},
		text = {
			name = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 60,						y = 68,						-- origin position
				size = 18,					font = fonts.header,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0xFFFFFF,				alpha = 0.6,
				text_pre	= 'Root',
				text_conky	= '',
				text_post	= ''
			},
			free_mark = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 41,						y = 38,						-- origin position
				size = 10,					font = fonts.mono,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0x10AABB,				alpha = 0.5,
				text_pre	= 'Free',
				text_conky	= '',
				text_post	= ''
			},
			free = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 17,						y = 50,						-- origin position
				size = 12,					font = fonts.mono,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0x10AABB,				alpha = 0.7,
				text_pre	= '',
				text_conky	= '${fs_free /}',
				text_post	= ' GiB'									-- ' KiB', ' MiB', ' GiB', ' TiB' will do conversion from bytes to single decimal
			}
		}
	},
	home = {	
		common = {
				fs = '/home',														-- file system that should be listed - also change text section
				x_offset = 35,				y_offset = 95,				-- offset xy from HDD origin - moves gauges and text alike
				x = 53,						y = 90,						-- origin position of gauges
				x_scale = 1.0,				y_scale = 0.5,				-- change deformation of x and y axis
				max_value = 100,										-- maximal value on the gauge -> 100%
				radius = 45,
				angle_start = 90,			angle_stop = 0				-- 0°==3 o'clock, 90°==6 o'clock, 180°==9 o'clock
		},
		gauge = {
			background = {
				name = 'background',									-- do not change
				status = 1,												-- 1 == has background, 0 == no background
				count = 0,												-- count is not used for background -> leave at 0
				width = 7,												-- should be =< gauge_gap
				rgb = 0xFFFFFF,				alpha = 0.05,
				line_cap = CAIRO_LINE_CAP_BUTT
			},
			bar = {
				name = 'bar',											-- do not change
				status = 1,												-- 1 == has indicator bars, 0 == no indicator bars - no point in the gauge without an indicator unles it has indicator_bar
				count = 0,												-- count is not used for bars -> leave at 0
				width = 7,												-- width should be <= gauge_gap
				rgb = 0xFFFFFF,				alpha = 0.2,
				line_cap = CAIRO_LINE_CAP_BUTT							-- should be the same as background_line_cap
			},
			notch = {
				name = 'notch',											-- do not change
				status = 1,												-- 1 == has % marking, 0 == no marks
				count = 10,												-- how many notches are on the scale (+1 because of 0 position) - 100%/notch_count, has to be positive value
				width = 7,												-- width should be =< gauge_gap
				thickness = 1.8,										-- thickness is in degrees
				rgb = 0xB8860B,				alpha = 0.6,
				line_cap = CAIRO_LINE_CAP_BUTT							-- leave it at BUTT or it will look ugly
			},
			indicator = {
				name = 'indicator',										-- do not change
				status = 1,												-- 1 == has indicator, 0 == no indicator - no point in the gauge without an indicator unles it has indicator_bar
				count = 0,												-- count is not used for indicator -> leave at 0
				width = 7,												-- width should be <= gauge_gap;
				thickness = 3.0,										-- thickness is in degrees
				rgb = 0x80DD00,				alpha = 1.0,
				line_cap = CAIRO_LINE_CAP_BUTT							-- leave it at BUTT or it will look ugly
			}
		},
		text = {
			name = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 60,						y = 68,						-- origin position
				size = 18,					font = fonts.header,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0xFFFFFF,				alpha = 0.6,
				text_pre	= '/home',
				text_conky	= '',
				text_post	= ''
			},
			free_mark = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 41,						y = 38,						-- origin position
				size = 10,					font = fonts.mono,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0x10AABB,				alpha = 0.5,
				text_pre	= 'Free',
				text_conky	= '',
				text_post	= ''
			},
			free = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 17,						y = 50,						-- origin position
				size = 12,					font = fonts.mono,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0x10AABB,				alpha = 0.7,
				text_pre	= '',
				text_conky	= '${fs_free /home}',
				text_post	= ' GiB'									-- ' KiB', ' MiB', ' GiB', ' TiB' will do conversion from bytes to single decimal
			}
		}
	},
	storage = {	
		common = {
				fs = '/storage',										-- file system that should be listed - also change text section
				x_offset = 70,				y_offset = 190,				-- offset xy from HDD origin - moves gauges and text alike
				x = 53,						y = 90,						-- origin position of gauges
				x_scale = 1.0,				y_scale = 0.5,				-- change deformation of x and y axis
				max_value = 100,										-- maximal value on the gauge -> 100%
				radius = 45,
				angle_start = 90,			angle_stop = 0				-- 0°==3 o'clock, 90°==6 o'clock, 180°==9 o'clock
		},
		gauge = {
			background = {
				name = 'background',									-- do not change
				status = 1,												-- 1 == has background, 0 == no background
				count = 0,												-- count is not used for background -> leave at 0
				width = 7,												-- should be =< gauge_gap
				rgb = 0xFFFFFF,				alpha = 0.05,
				line_cap = CAIRO_LINE_CAP_BUTT
			},
			bar = {
				name = 'bar',											-- do not change
				status = 1,												-- 1 == has indicator bars, 0 == no indicator bars - no point in the gauge without an indicator unles it has indicator_bar
				count = 0,												-- count is not used for bars -> leave at 0
				width = 7,												-- width should be <= gauge_gap
				rgb = 0xFFFFFF,				alpha = 0.2,
				line_cap = CAIRO_LINE_CAP_BUTT							-- should be the same as background_line_cap
			},
			notch = {
				name = 'notch',											-- do not change
				status = 1,												-- 1 == has % marking, 0 == no marks
				count = 10,												-- how many notches are on the scale (+1 because of 0 position) - 100%/notch_count, has to be positive value
				width = 7,												-- width should be =< gauge_gap
				thickness = 1.8,										-- thickness is in degrees
				rgb = 0xB8860B,				alpha = 0.6,
				line_cap = CAIRO_LINE_CAP_BUTT							-- leave it at BUTT or it will look ugly
			},
			indicator = {
				name = 'indicator',										-- do not change
				status = 1,												-- 1 == has indicator, 0 == no indicator - no point in the gauge without an indicator unles it has indicator_bar
				count = 0,												-- count is not used for indicator -> leave at 0
				width = 7,												-- width should be <= gauge_gap;
				thickness = 3.0,										-- thickness is in degrees
				rgb = 0x80DD00,				alpha = 1.0,
				line_cap = CAIRO_LINE_CAP_BUTT							-- leave it at BUTT or it will look ugly
			}
		},
		text = {
			name = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 60,						y = 68,						-- origin position
				size = 18,					font = fonts.header,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0xFFFFFF,				alpha = 0.6,
				text_pre	= '/storage',
				text_conky	= '',
				text_post	= ''
			},
			free_mark = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 41,						y = 38,						-- origin position
				size = 10,					font = fonts.mono,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0x10AABB,				alpha = 0.5,
				text_pre	= 'Free',
				text_conky	= '',
				text_post	= ''
			},
			free = {
				status = 1,					group = 'hdd',				-- status:1==ON, 0==OFF; don't change group
				x = 17,						y = 50,						-- origin position
				size = 12,					font = fonts.mono,
				slant = CAIRO_FONT_SLANT_ITALIC,						-- NORMAL, ITALIC, OBLIQUE
				weight = CAIRO_FONT_WEIGHT_BOLD,						-- NORMAL, BOLD
				rgb = 0x10AABB,				alpha = 0.7,
				text_pre	= '',
				text_conky	= '${fs_free /storage}',
				text_post	= ' GiB'									-- ' KiB', ' MiB', ' GiB', ' TiB' will do conversion from bytes to single decimal
			}
		}
	}
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
-- convert degree to radian
function degree_to_rad(degree)
	return (degree / 180 * math.pi)
end

-------------------------------------------------------------------------------
-- Generic text printing procedure
function print_text(cr, setting, dx, dy)
	if setting.status == 0 then return end	-- text is disabled

	local str, str_tmp = '', ''				-- printable text
	local tmp_val = 0

	--Font format text
	cairo_select_font_face(cr, setting.font, setting.slant, setting.weight)
	cairo_set_font_size(cr, setting.size)

	-- If there is something to fetch from conky do so
	if (setting.iter ~= nil) and (setting.oper ~= nil) then
		str_tmp = 0
		for iii in pairs(setting.iter) do
			--Make sure you are only feeding it with numbers and not strings
			tmp_val = string.gsub(setting.text_conky, '§', iii)
			tmp_val = conky_parse(tmp_val)

			-- What operation should be done with this new value
			if setting.oper == 'SUM' or setting.oper == 'AVG' then

				str_tmp = tonumber(str_tmp) + tonumber(tmp_val)
			elseif setting.oper == 'MAX' then
				if tonumber(str_tmp) < tonumber(tmp_val) then str_tmp = tonumber(tmp_val) end
			elseif setting.oper == 'MIN' then
				if tonumber(str_tmp) > tonumber(tmp_val) then str_tmp = tonumber(tmp_val) end
			elseif setting.oper == 'LIST' then
				-- print list in dx,dy ascendin order
				-- Combine all text samples together and print on screen
				-- Probably only useful for listing TOP processes
				cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha))
				cairo_move_to(cr, master_settings[setting.group].x + setting.x + dx * (iii-1), master_settings[setting.group].y + setting.y + dy * (iii-1) )	-- text position; WARNING (iii-1) is a dirty hack that states for example ${top name 1} has 0 offset
				str = string.format('%s%s%s', setting.text_pre, tmp_val, setting.text_post)
				cairo_show_text (cr, str)
			else
				return	-- some error in setting files
			end
		end
		
		if setting.oper == 'LIST' then return end -- if the main operation was listing then everything is already done

		if setting.oper == 'AVG' then str_tmp = string.format('%.1f', str_tmp / #setting.iter) end

	elseif string.find(setting.text_conky, '§') == nil then
		str_tmp = conky_parse(setting.text_conky)
	else
		return	-- Some error in settings declarations
	end
	
	-- Move to text printing position
	cairo_move_to(cr, master_settings[setting.group].x + setting.x + dx, master_settings[setting.group].y + setting.y + dy)

	-- Color alarms - especially useful for temperatures
	if (setting.hi ~= nil) and (tonumber(str_tmp) > setting.hi) then
		cairo_set_source_rgba(cr, convert_rgba_split(setting.hi_rgb, setting.hi_alpha))
	elseif (setting.mid ~= nil) and (tonumber(str_tmp) > setting.mid) then
		cairo_set_source_rgba(cr, convert_rgba_split(setting.mid_rgb, setting.mid_alpha))
	else
		cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha))
	end

	-- Dirty hack - since values are printed in bytes from Conky it would be better to show them in human readable format (kiB, MiB, GiB, TiB)
	if setting.text_post == ' KiB' then str_tmp = string.format('%.1f', str_tmp / 1024) end
	if setting.text_post == ' MiB' then str_tmp = string.format('%.1f', str_tmp / 1048576) end
	if setting.text_post == ' GiB' then str_tmp = string.format('%.1f', str_tmp / 1073741824) end
	if setting.text_post == ' TiB' then str_tmp = string.format('%.1f', str_tmp / 1099511627776) end

	-- Combine all text samples together and print on screen
	str = string.format('%s%s%s', setting.text_pre, str_tmp, setting.text_post)
	cairo_show_text (cr, str)

	cairo_stroke (cr)
end


-------------------------------------------------------------------------------
-- Create CPU gauges
function draw_cpu_gauges(cr, cpu_no, setting, common_setting)

	if setting.status == 0 then return end	-- gauge is disabled

	local cpu_r = common_setting.radius + (common_setting.gap * math.floor((cpu_no-1)/2))
	local start, stop = 0, 0
	local cpu_x, cpu_y = 0, 0

	local angle = (common_setting.angle_stop - common_setting.angle_start)
		while (angle < 0) do angle = angle + 360 end
		increment = angle / common_setting.max_value
	local str = ''			-- string that should be passed to conky
	local percentage = 0	-- value of cpu load taken from conky

	for iii = 0, setting.count do

		cpu_x, cpu_y = master_settings.cpu.x + common_setting.x, master_settings.cpu.y + common_setting.y

		if setting.name == 'indicator' then
			str = string.format('${%s%s}','cpu cpu', cpu_no)
			percentage = tonumber(conky_parse(str))
			start = common_setting.angle_start + increment*percentage
			stop = common_setting.angle_start + increment*percentage + setting.thickness

		elseif setting.name == 'bar' then
			str = string.format('${%s%s}','cpu cpu', cpu_no)
			percentage = tonumber(conky_parse(str))
			start = common_setting.angle_start
			stop = common_setting.angle_start + increment*percentage

		elseif setting.name == 'background' then
			start = common_setting.angle_start
			stop = common_setting.angle_stop

		elseif setting.name == 'notch' then
			increment = angle / setting.count
			start = common_setting.angle_start + iii * increment
			stop = common_setting.angle_start + iii * increment + setting.thickness
		else
			return
		end

		-- draw config
		cairo_set_line_width(cr, setting.width)
		cairo_set_line_cap(cr, setting.line_cap)
		cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha))

		if cpu_no % 2 == 1 then		-- left side
			cpu_x, cpu_y = cpu_x + common_setting.x_offset, cpu_y + common_setting.y_offset
			cairo_arc(cr, cpu_x, cpu_y, cpu_r, degree_to_rad(start), degree_to_rad(stop))
		else						-- right side
			cpu_x, cpu_y = cpu_x - common_setting.x_offset, cpu_y - common_setting.y_offset
			start = -1 * (start - 180)		-- mirror symetry against Y axis
			stop = -1 * (stop - 180)		-- mirror symetry against Y axis
			cairo_arc_negative(cr, cpu_x, cpu_y, cpu_r, degree_to_rad(start), degree_to_rad(stop))
		end

		cairo_stroke(cr)
	end
end

-------------------------------------------------------------------------------
-- Draw everything for CPU - gauges, text
function draw_cpu(cr)

	if master_settings.cpu.status == 0 then return end	-- CPU visualisation disabled

	-- CPU texts
	for iii in pairs(cpu_text) do
		print_text(cr, cpu_text[iii], 0, 0)
	end

	-- CPU Gauges
	if cpu_gauge_common.core_no > 0 then
		for cpu_no = 1, cpu_gauge_common.core_no do
			for jjj in pairs(cpu_gauge_settings) do
				draw_cpu_gauges(cr, cpu_no, cpu_gauge_settings[jjj], cpu_gauge_common)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- List top processes (CPU and MEM)
function draw_top(cr)
	if master_settings.top.status == 0 then return end	-- no top visualisation
	for iii in pairs(top_text) do
		print_text(cr, top_text[iii], top_text[iii].dx, top_text[iii].dy)
	end
end


-------------------------------------------------------------------------------
-- Miscellaneous text
function draw_txt(cr)
	if master_settings.txt.status == 0 then return end	-- no top visualisation
	for iii in pairs(misc_txt) do
		print_text(cr, misc_txt[iii], 0, 0)
	end
end


-------------------------------------------------------------------------------
-- Create GPU gauges
function draw_gpu_gauges(cr, setting, common_setting)

	if setting.status == 0 then return end	-- gauge is disabled

	local gpu_r = common_setting.radius
	local start, stop = 0, 0
	local gpu_x, gpu_y = common_setting.x, common_setting.y		-- no master setting - it is later in "translate" operation

	local increment = (common_setting.angle_stop - common_setting.angle_start)
		while (increment < 0) do increment = increment + 360 end
		increment = increment / tonumber(conky_parse('${nvidia memmax}'))
	local value = tonumber(conky_parse('${nvidia memused}'))			-- value of gpu memory load taken from conky

	for iii = 0, setting.count do

		if setting.name == 'indicator' then
			start = common_setting.angle_start + increment*value
			stop = common_setting.angle_start + increment*value + setting.thickness

		elseif setting.name == 'bar' then
			start = common_setting.angle_start
			stop = common_setting.angle_start + increment*value

		elseif setting.name == 'background' then
			start = common_setting.angle_start
			stop = common_setting.angle_stop

		elseif setting.name == 'notch' then
			increment = common_setting.angle_stop - common_setting.angle_start
				while (increment < 0) do increment = increment + 360 end
				increment = increment / setting.count
			start = common_setting.angle_start + iii * increment
			stop = common_setting.angle_start + iii * increment + setting.thickness

		else
			return	-- error in settings
		end
		
		-- draw config
		cairo_set_line_width(cr, setting.width)
		cairo_set_line_cap(cr, setting.line_cap)
		cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha))

		cairo_save (cr)	-- save status before deformation
		
		-- deformation
		cairo_translate (cr, master_settings.gpu.x, master_settings.gpu.y)	-- new origin
		cairo_scale (cr, common_setting.x_scale, common_setting.y_scale)

		cairo_arc(cr, gpu_x, gpu_y, gpu_r, degree_to_rad(start), degree_to_rad(stop))

		cairo_stroke(cr)
		cairo_restore (cr)	--restore status before deformation

	end
end


-------------------------------------------------------------------------------
-- GPU visualization
function draw_gpu(cr)
	-- Print all GPU texts	
	if master_settings.gpu.status == 0 then return end	-- no gpu visualisation
	for iii in pairs(gpu_text) do
		print_text(cr, gpu_text[iii], 0, 0)
	end

	--Draw GPU gauge - pretty much only memory indicator
	for jjj in pairs(gpu_gauge_settings) do
		draw_gpu_gauges(cr, gpu_gauge_settings[jjj], gpu_gauge_common)
	end
end


-------------------------------------------------------------------------------
-- Run memory graph - single mark on the graph
function draw_mem_mark(cr, x, y, height, thickness, style)

	cairo_set_line_width(cr, thickness)
	cairo_set_line_cap(cr, style.line_cap)
	cairo_set_source_rgba(cr, convert_rgba_split(style.rgb, style.alpha))

	cairo_move_to(cr, x, y)
	cairo_rel_line_to(cr, 0, height)

	cairo_stroke(cr)
end


-------------------------------------------------------------------------------
-- Construck memory bar graph
function draw_mem_curve(cr, curve, used_proc, buff_proc, cache_proc)

	cairo_save (cr)	-- save original position before transformation
	cairo_translate (cr, master_settings.mem.x, master_settings.mem.y)	-- new origin == starting (leftmost) point of the curve

	local step_x = (curve.common.x_end - curve.common.x_start) / curve.common.rec_p
	local step_y = (curve.common.y_end - curve.common.y_start) / curve.common.rec_p
	local x, y = 0, 0
	local style

	for iii = 1, (curve.common.rec_p+1) do

		if used_proc >= (iii-1)/curve.common.rec_p then
			style = curve.used
		elseif used_proc+buff_proc >= (iii-1)/curve.common.rec_p then
			style = curve.buffer
		elseif used_proc+buff_proc+cache_proc >= (iii-1)/curve.common.rec_p then
			style = curve.cache		
		else
			style = curve.free
		end

		x = curve.common.x_start + step_x * (iii - 1)
		y = curve.common.y_start - curve.common.amplitude * math.sin(2 * math.pi * ((iii-1)/curve.common.rec_p)) + step_y * (iii - 1)
		draw_mem_mark(cr, x, y, curve.common.height, math.abs(step_x-curve.common.gap), style)
	end

	-- cleanup
	cairo_restore(cr)	--restore status before origin transformation
end


-------------------------------------------------------------------------------
-- Visualize memory usage
function draw_mem(cr)

	if master_settings.mem.status == 0 then return end	-- no memory visualisation

	local total	= tonumber(conky_parse('${memmax}'))
	local used = tonumber(conky_parse('${mem}'))
	local buff = tonumber(conky_parse('${buffers}'))
	local cache = tonumber(conky_parse('${cached}'))

	local used_proc, buff_proc, cache_proc = used / total, buff / total, cache / total

	for iii in pairs(mem_text) do
		print_text(cr, mem_text[iii], 0, 0)
	end

	draw_mem_curve(cr, mem_curve, used_proc, buff_proc, cache_proc)
end


-------------------------------------------------------------------------------
-- Update history
-- return maximal value in the table
function update_table(setting, common)
	if setting.command == nil then return 0 end		-- don't waste resources if there is no update

	local max = 0

	for iii = 1, common.history do
		if iii == common.history then
			setting.table[common.history] = tonumber(conky_parse(string.format('${%s %s}', setting.command, common.interface)))
		else
			setting.table[iii] = setting.table[iii + 1]
		end
		
		if setting.table[iii] > max then max = setting.table[iii] end
	end

	return max
end

-------------------------------------------------------------------------------
-- Line graph for net usage
function draw_net_line(cr, setting, common)
	local max_value = update_table(setting, common)
	
	local d_y = common.height / (common.history)
	local d_alpha = - (setting.alpha_stop - setting.alpha_start) / (common.history)	-- negative because graph is drawn from the end to the front
	
	local scale = 0
		if max_value ~= 0 then scale = common.scale_max_height / max_value end

	cairo_set_line_width(cr, setting.thickness)
	cairo_set_line_cap(cr, setting.line_cap)

	local x, y = 0, 0

	
	for iii = 2, common.history + 1 do					-- index 1 is end of the graph already defined by move_to operation
		cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha_stop + (iii-1) * d_alpha))

		x = master_settings.net.x + setting.direction * scale * setting.table[iii-1]
		y = master_settings.net.y + common.height - (iii - 2) * d_y
		cairo_move_to(cr, x, y)

		x = master_settings.net.x + setting.direction * scale * setting.table[iii]
		y = master_settings.net.y + common.height - (iii - 1) * d_y
		cairo_line_to(cr, x, y)

		cairo_stroke(cr)
	end
end

-------------------------------------------------------------------------------
-- Bar graph for net usage
function draw_net_bar(cr, setting, common)

	if setting.command == nil then return end		-- middle line has no point in bar graph

	local max_value = update_table(setting, common)
	
	local thickness = common.height / (common.history)
	local d_alpha = - (setting.alpha_stop - setting.alpha_start) / (common.history)	-- negative because graph is drawn from the end to the front
	
	local scale = 0
		if max_value ~= 0 then scale = common.scale_max_height / max_value end

	cairo_set_line_width(cr, thickness)
	cairo_set_line_cap(cr, setting.line_cap)

	local x, y = 0, 0

	for iii = 1, common.history do
		cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha_stop + (iii - 1/2) * d_alpha))

		x = master_settings.net.x
		y = master_settings.net.y + common.height - (iii - 1/2) * thickness
		cairo_move_to(cr, x, y)

		x = master_settings.net.x + setting.direction * scale * setting.table[iii]
		y = master_settings.net.y + common.height - (iii - 1/2) * thickness
		cairo_line_to(cr, x, y)

		cairo_stroke(cr)
	end
end

-------------------------------------------------------------------------------
-- Everything for net view
function draw_net(cr)

	if master_settings.net.status == 0 then return end	-- no memory visualisation
	
	local net_state = tonumber(conky_parse(string.format('${if_up %s}1${endif}', master_settings.net.interface)))
	if net_state ~= 1 then return end	-- no net interface is enabled

	for iii in pairs(net_text) do
		print_text(cr, net_text[iii], 0, 0)
	end
	
	if net_common.graph == 1 then
		for iii in pairs(net_graph) do
			if net_common.style == 'LINE' then
				draw_net_line(cr, net_graph[iii], net_common)
			elseif net_common.style == 'BAR' then
				draw_net_bar(cr, net_graph[iii], net_common)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- Create HDD/SSD gauges
function draw_hdd_gauges(cr, setting, common_setting)

	if setting.status == 0 then return end	-- gauge is disabled

	local hdd_r = common_setting.radius
	local start, stop = 0, 0
	local hdd_x, hdd_y = common_setting.x, common_setting.y		-- no master setting - it is later in "translate" operation

	local angle = (common_setting.angle_stop - common_setting.angle_start)
		while (angle < 0) do angle = angle + 360 end
		increment = angle / common_setting.max_value
	local value = tonumber(conky_parse(string.format('${fs_used_perc %s}', common_setting.fs)))			-- % value of filled hdd memory

	for iii = 0, setting.count do

		if setting.name == 'indicator' then
			start = common_setting.angle_start + increment * value
			stop = common_setting.angle_start + increment * value + setting.thickness

		elseif setting.name == 'bar' then
			start = common_setting.angle_start
			stop = common_setting.angle_start + increment * value

		elseif setting.name == 'background' then
			start = common_setting.angle_start
			stop = common_setting.angle_stop

		elseif setting.name == 'notch' then
			increment = angle / setting.count
			start = common_setting.angle_start + iii * increment
			stop = common_setting.angle_start + iii * increment + setting.thickness

		else
			return	-- error in settings
		end
		
		-- draw config
		cairo_set_line_width(cr, setting.width)
		cairo_set_line_cap(cr, setting.line_cap)
		cairo_set_source_rgba(cr, convert_rgba_split(setting.rgb, setting.alpha))

		cairo_save (cr)	-- save status before deformation
		
		-- deformation
		cairo_translate (cr, master_settings.hdd.x, master_settings.hdd.y)	-- new origin
		cairo_scale (cr, common_setting.x_scale, common_setting.y_scale)

		cairo_arc(cr, hdd_x, hdd_y, hdd_r, degree_to_rad(start), degree_to_rad(stop))

		cairo_stroke(cr)
		cairo_restore (cr)	--restore status before deformation
	end
end


-------------------------------------------------------------------------------
-- hdd visualization
function draw_hdd(cr)

	if master_settings.hdd.status == 0 then return end	-- no hdd visualisation

	for iii in pairs(hdd_all) do
		cairo_save(cr)
		cairo_translate(cr, hdd_all[iii].common.x_offset, hdd_all[iii].common.y_offset)	-- offset each hdd entry relative to common hdd origin (hdd origin is then translated by master_settings as well)

			-- Print all GPU texts
			for jjj in pairs(hdd_all[iii].text) do
				print_text(cr, hdd_all[iii].text[jjj], 0, 0)
			end

			--Draw GPU gauge - pretty much only memory indicator
			for kkk in pairs(hdd_all[iii].gauge) do
				draw_hdd_gauges(cr, hdd_all[iii].gauge[kkk], hdd_all[iii].common)
			end

		cairo_restore(cr)
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
    local display = cairo_create(cs)
    local updates = tonumber(conky_parse('${updates}'))

	cairo_save (display)
	cairo_scale (display, master_settings.scale.x, master_settings.scale.y) 	-- If you don't want to use a amagnifying glass this scales everything

	if master_settings.net.status == 1 and updates == 2 then	-- allocate GLOBAL memory to keep track of net speed history
		for jjj in pairs(net_graph)	do	
			for iii = 1, net_common.history + 1 do
				net_graph[jjj].table[iii] = 0
			end
		end
	end

    if updates > 3 then
		
		draw_cpu(display)
		draw_top(display)
		draw_txt(display)
		draw_gpu(display)
		draw_mem(display)
		draw_net(display)
		draw_hdd(display)

    end

	cairo_restore(display)

	cairo_destroy(display)
    cairo_surface_destroy(cs)
end
