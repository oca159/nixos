local wezterm = require("wezterm")

local act = wezterm.action
local mux = wezterm.mux

-- https://wezfurlong.org/wezterm/config/files.html
local config = wezterm.config_builder()

-- plugins
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local wezsesh = wezterm.plugin.require("https://github.com/oca159/wezsesh.wezterm")

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

wezsesh.setup({
  inline_preview = true,
  default_session = {
    startup_command = "nvim",
    preview_command = "",
  },
  workspace_formatter = function(label, choice)
    local prefix = "[path]"
    local display_color = "#cdd6f4"
    if choice.kind == "workspace" then
      prefix = ": "
      display_color = "#fab387"
    elseif choice.kind == "zoxide" then
      prefix = ": "
    elseif choice.kind == "session" then
      prefix = ": "
      display_color = "#89b4fa"
    end

    local text = string.format("%s %s", prefix, label)
    if choice.preview and choice.preview ~= "" then
      text = text .. " -- " .. choice.preview
    end

    return wezterm.format({
      { Attribute = { Italic = false } },
      { Foreground = { Color = display_color } },
      { Background = { Color = "#1e1e2e" } },
      { Text = prefix .. label },
    })
  end,
  sessions = {
    {
      name = "aws credentials",
      path = "~/.aws",
      startup_command = "nvim credentials",
    },
    {
      name = "dotfiles",
      path = "~/dotfiles",
      startup_command = "nvim",
    },
    {
      name = "nix",
      path = "~/dotfiles/nix",
      startup_command = "nvim flake.nix",
    },
    {
      name = "tmux",
      path = "~/dotfiles/tmux",
      startup_command = "nvim tmux.conf",
    },
    {
      name = "wezterm",
      path = "~/dotfiles/wezterm",
      startup_command = "nvim wezterm.lua",
    },
  },
})

wezsesh.apply_to_config(config, {
  hide_duplicates = true,
  hide_active = true,
})

config.cell_width = 1.0
config.check_for_updates = false
config.color_scheme = "Catppuccin Mocha" -- https://wezfurlong.org/wezterm/colorschemes/
config.font = wezterm.font("BlexMono Nerd Font Mono", { weight = "Medium", italic = false })
config.font_size = 14
config.hide_tab_bar_if_only_one_tab = false
config.line_height = 1.1
config.window_decorations = "RESIZE"
-- https://wezfurlong.org/wezterm/config/lua/config/window_padding.html
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Keybindings
local keys = {
  -- Your requested additions
  {
    key = "r",
    mods = "SUPER",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  {
    key = "R",
    mods = "SUPER",
    action = act.PromptInputLine({
      description = "Rename current workspace",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    }),
  },
  {
    key = "t",
    mods = "SUPER",
    action = act.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "|",
    mods = "CMD",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "-",
    mods = "CMD",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  -- Existing workspace keys
  { key = "p", mods = "CMD",        action = wezsesh.switch_workspace() },
  { key = "d", mods = "CTRL|SHIFT", action = act.SwitchToWorkspace({ name = "dotfiles" }) },

  -- Move to start of line (CMD + Left)
  {
    key = "LeftArrow",
    mods = "SUPER",
    action = act.SendString("\x01"), -- Sends CTRL+A
  },
  -- Move to end of line (CMD + Right)
  {
    key = "RightArrow",
    mods = "SUPER",
    action = act.SendString("\x05"), -- Sends CTRL+E
  },
  -- Delete entire line (CMD + Backspace/Delete)
  {
    key = "Backspace",
    mods = "SUPER",
    action = act.SendString("\x15"), -- Sends CTRL+U (standard shell 'delete line')
  },
  -- Move word by word
  {
    key = "LeftArrow",
    mods = "OPT",
    action = act.SendString("\x1bb"), -- ESC + b
  },
  {
    key = "RightArrow",
    mods = "OPT",
    action = act.SendString("\x1bf"), -- ESC + f
  },

  -- Delete word by word (Option + Backspace)
  {
    key = "Backspace",
    mods = "OPT",
    action = act.SendString("\x17"), -- CTRL + W (standard shell 'delete word')
  },

  -- Close pane or tab
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action_callback(function(window, pane)
      local tab = window:active_tab()
      local panes = tab:panes()

      if #panes > 1 then
        -- If there is more than one pane, close the focused one
        window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)
      else
        -- If only one pane exists, close the entire tab
        window:perform_action(act.CloseCurrentTab({ confirm = false }), pane)
      end
    end),
  },
}

config.audible_bell = "Disabled"

config.colors = {
  visual_bell = "#202020",
  tab_bar = {
    background = "#1e1e2e",
    active_tab = {
      bg_color = "transparent",
      fg_color = "#fab387",
    },
    inactive_tab = {
      bg_color = "transparent",
      fg_color = "#cba6f7",
    },
  },
}

config.keys = keys

bar.apply_to_config(config, {
  position = "bottom",
  max_width = 32,
  padding = {
    left = 1,
    right = 1,
    tabs = {
      left = 1,
      right = 2,
    },
  },
  separator = {
    space = 1,
    left_icon = wezterm.nerdfonts.fa_long_arrow_right,
    right_icon = wezterm.nerdfonts.fa_long_arrow_left,
    field_icon = wezterm.nerdfonts.indent_line,
  },
  modules = {
    zoom = {
      enabled = false,
      icon = wezterm.nerdfonts.md_fullscreen,
      color = 4,
    },
    pane = {
      enabled = false,
      icon = wezterm.nerdfonts.cod_multiple_windows,
      color = 7,
    },
    username = {
      enabled = false,
      icon = wezterm.nerdfonts.fa_user,
      color = 6,
    },
    hostname = {
      enabled = false,
      icon = wezterm.nerdfonts.cod_server,
      color = 8,
    },
    clock = {
      enabled = false,
      icon = wezterm.nerdfonts.md_calendar_clock,
      format = "%H:%M",
      color = 5,
    },
    cwd = {
      enabled = false,
      icon = wezterm.nerdfonts.oct_file_directory,
      color = 7,
    },
    spotify = {
      enabled = false,
      icon = wezterm.nerdfonts.fa_spotify,
      color = 3,
      max_width = 64,
      throttle = 15,
    },
  },
})

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
-- you can put the rest of your Wezterm config here
smart_splits.apply_to_config(config, {
  -- the default config is here, if you'd like to use the default keys,
  -- you can omit this configuration table parameter and just use
  -- smart_splits.apply_to_config(config)

  -- directional keys to use in order of: left, down, up, right
  direction_keys = { "h", "j", "k", "l" },
  -- if you want to use separate direction keys for move vs. resize, you
  -- can also do this:
  -- modifier keys to combine with direction_keys
  modifiers = {
    move = "CTRL",   -- modifier to use for pane movement, e.g. CTRL+h to move left
    resize = "META", -- modifier to use for pane resize, e.g. META+h to resize to the left
  },
  -- log level to use: info, warn, error
  -- log_level = "info",
})

return config
