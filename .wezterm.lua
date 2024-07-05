-- Dump any object to string
local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

-- table union: a += b
local function table_union(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then
		error("Illegal argument: a or b are not a 'table' type")
	end
	for k, v in pairs(b) do
		if a[k] ~= nil then
			error(string.format("Duplicate keys detected:\nkey=%q, exist value=%q", dump(k), dump(a[k])))
			return
		end
		a[k] = v
	end
end

-- Define Config class
Config = { inner = {} }

function Config:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	self.inner = {}
	return o
end

function Config:add(t)
	table_union(self.inner, t)
	return self
end

local wezterm = require("wezterm")
local act = wezterm.action
local gui = wezterm.gui

local function format_tabs(tab, tabs)
	local mux_window = wezterm.mux.get_window(tab.window_id)
	local mux_tab_cols = mux_window:active_tab():get_size().cols
	local tab_count = #tabs

	local inactive_tab_cols = math.floor(mux_tab_cols / tab_count)
	local active_tab_cols = mux_tab_cols - (tab_count - 1) * inactive_tab_cols

	local file = wezterm.mux.get_tab(tab.tab_id):active_pane():get_current_working_dir()
	local file_path = file.file_path
	local title = " " .. file_path .. " "
	local title_cols = wezterm.column_width(title)
	local is_active = tab.is_active
	local icon = is_active and " " or " "

	local tab_cols = is_active and active_tab_cols or inactive_tab_cols
	local remaining_cols = math.max(tab_cols - title_cols, 0)
	local right_cols = math.ceil(remaining_cols / 2)
	local left_cols = remaining_cols - right_cols

	local is_zoomed = tab.active_pane.is_zoomed
	local zoom_icon = is_zoomed and " " or " "

	local elements = {
		-- Left padding and icon
		{ Text = wezterm.pad_right(icon, left_cols) },
		-- Centered title
		is_active and { Attribute = { Italic = true } } or {},
		{ Text = title },
		-- Right padding
		{ Text = wezterm.pad_right(zoom_icon, right_cols) },
	}

	local formatted_elements = {}
	for _, item in ipairs(elements) do
		if next(item) ~= nil then
			table.insert(formatted_elements, item)
		end
	end

	return formatted_elements
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	return format_tabs(tab, tabs)
end)

wezterm.on("user-var-changed", function(window, pane, name, value)
	wezterm.log_info("var", name, value)
end)

local launch_menu = {
	default_prog = { "pwsh", "--NoLogo" },
	launch_menu = {
		{ label = "🟣 PowerShell Core", args = { "pwsh" } },
		{ label = "🔵 Windows PowerShell", args = { "powershell" } },
	},
}
local appearance = {
	color_scheme = "ayu",

	font = wezterm.font({ family = "CaskaydiaCove Nerd Font" }),
	font_size = 14.0,

	window_frame = {
		border_left_width = "0.25cell",
		border_right_width = "0.25cell",
		border_bottom_height = "0.125cell",
		border_top_height = "0.125cell",
		border_left_color = "#0063B1",
		border_right_color = "#0063B1",
		border_bottom_color = "#0063B1",
		border_top_color = "#0063B1",
	},
	window_decorations = "RESIZE",

	use_fancy_tab_bar = false,
	show_new_tab_button_in_tab_bar = true,
	tab_bar_at_bottom = false,
	enable_scroll_bar = false,
	hide_tab_bar_if_only_one_tab = false,
	tab_max_width = 99999,
	status_update_interval = 1000,
	colors = {
		tab_bar = {
			active_tab = {
				bg_color = "#0B0E14",
				fg_color = "#CED4DF",
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = "#14171D",
				fg_color = "#54575D",
				intensity = "Normal",
			},
			inactive_tab_hover = {
				bg_color = "#54575D",
				fg_color = "#14171D",
			},
			new_tab = {
				bg_color = "#14171D",
				fg_color = "#FFFFFF",
			},
			background = "#14171D",
		},
	},
}
local keybinding = {
	keys = {
		{
			key = "h",
			mods = "ALT",
			action = act.ActivatePaneDirection("Left"),
		},
		{
			key = "j",
			mods = "ALT",
			action = act.ActivatePaneDirection("Down"),
		},
		{
			key = "k",
			mods = "ALT",
			action = act.ActivatePaneDirection("Up"),
		},
		{
			key = "l",
			mods = "ALT",
			action = act.ActivatePaneDirection("Right"),
		},
		{
			key = "s",
			mods = "ALT",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "v",
			mods = "ALT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "q",
			mods = "ALT",
			action = act.CloseCurrentPane({ confirm = true }),
		},
		{
			key = "LeftArrow",
			mods = "ALT",
			action = act.AdjustPaneSize({ "Left", 1 }),
		},
		{
			key = "RightArrow",
			mods = "ALT",
			action = act.AdjustPaneSize({ "Right", 1 }),
		},
		{
			key = "UpArrow",
			mods = "ALT",
			action = act.AdjustPaneSize({ "Up", 1 }),
		},
		{
			key = "DownArrow",
			mods = "ALT",
			action = act.AdjustPaneSize({ "Down", 1 }),
		},
		{
			key = "z",
			mods = "ALT",
			action = act.TogglePaneZoomState,
		},
	},
}

local mux = {
	unix_domains = { {
		name = "unix",
	} },

	default_gui_startup_args = { "connect", "unix" },
}

return Config:new():add(launch_menu):add(appearance):add(keybinding):add(mux).inner
