local full_opts = {
  icon_enable = true,
  simple_mode = {
    width = 60,
    filetype = {"NvimTree", "PandaTree"},
    ignore_type = {"vimode", "git", "location", "percent", "encoding"}
  },
  inactive_mode = {
    ignore_type = {"vimode", "git", "location"}
  },
  git = {
    enable = true,
    command = "git",
    icon = ""
  },
  theme = {
    Statusline = {
      bg = "NONE"
    },
    PandaLineFill = {
      bg = "#282c34",
      fg = "#FFFFFF"
    },
    PandaLineFile = {
      bg = "#282c34",
      fg = "#abb2bf"
    },
    PandaLineGit = {
      bg = "#3e4452",
      fg = "#abb2bf"
    },
    PandaLineLocation = {
      bg = "#61afef",
      fg = "#3e4452"
    },
    PandaLinePercent = {
      bg = "#3e4452",
      fg = "#abb2bf"
    },
    PandaLineEncoding = {
      bg = "#282c34",
      fg = "#abb2bf"
    },
    PandaLineChooseWin = {
      bg = "#61afef",
      fg = "#3e4452"
    },
    PandaLineChooseWinFill = {
      bg = "#282c34",
      fg = "#FFFFFF"
    }
  },
  mode = {
    n = {name = "NORMAL", bg = "#98c379", fg = "#282c34"},
    i = {name = "INSERT", bg = "#61afef", fg = "#282c34"},
    c = {name = "COMMAND", bg = "#98c379", fg = "#282c34"},
    v = {name = "VISUAL", bg = "#c678dd", fg = "#282c34"},
    V = {name = "V-LINE", bg = "#c678dd", fg = "#282c34"},
    ["\22"] = {name = "V-BLOCK", bg = "#c678dd", fg = "#282c34"},
    R = {name = "REPLACE", bg = "#e06c75", fg = "#282c34"},
    t = {name = "TERMINAL", bg = "#61afef", fg = "#282c34"},
    s = {name = "SELECT", bg = "#e5c07b", fg = "#282c34"},
    S = {name = "S-LINE", bg = "#e5c07b", fg = "#282c34"},
    [""] = {name = "S-BLOCK", bg = "#e5c07b", fg = "#282c34"}
  },
  quick_choose = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
  },
  choose_space = "    "
}

local function is_simple_mode(window, type_name)
  local filetype = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(window), "filetype")
  return vim.tbl_contains(full_opts.simple_mode.ignore_type, type_name) and
    (vim.fn.winwidth(window) <= full_opts.simple_mode.width or
      vim.tbl_contains(full_opts.simple_mode.filetype, filetype))
end

local function is_inactive_mode(type_name)
  return vim.tbl_contains(full_opts.inactive_mode.ignore_type, type_name)
end

local function mode_name()
  local mode_info = full_opts.mode[vim.fn.mode()]
  vim.api.nvim_command("hi PandaLineViMode guibg=" .. mode_info.bg .. " guifg=" .. mode_info.fg)
  return mode_info.name
end

local function VIMode(is_cur)
  if is_cur ~= true and is_inactive_mode("vimode") then
    return ""
  end
  return "%#PandaLineViMode# " .. [[%{luaeval('require("pandaline").mode_name()')}]] .. " %##"
end

local function SpaceFill()
  return "%#PandaLineFill#"
end

local function FileInfo(window, is_cur)
  if is_cur ~= true and is_inactive_mode("file") then
    return ""
  end
  local file_path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(window))
  local status_line = ""
  if full_opts.icon_enable == true and file_path ~= nil then
    local extension = file_path:match("^.*%.(.*)$") or ""
    local icon = require "nvim-web-devicons".get_icon(file_path, extension)
    if icon ~= nil then
      status_line = "%#" .. "PandalineDevIcon" .. extension .. "# " .. icon .. "%##"
    end
  end
  return status_line .. "%#PandaLineFile# %t%m %##"
end

local function git_branch()
  local git_command = "cd " .. vim.loop.cwd() .. " && " .. full_opts.git.command .. " branch --show-current"
  for _, v in pairs(vim.fn.systemlist(git_command)) do
    if string.find(v, "fatal: not a git repository") == nil then
      return v
    end
  end
end

local function GitBranch(win, is_cur)
  local type_name = "git"
  local branch_name = git_branch()
  if branch_name == nil or is_simple_mode(win, type_name) then
    return ""
  end
  if is_cur ~= true and is_inactive_mode(type_name) then
    return ""
  end
  local status_line = "%#PandaLineGit#"
  if full_opts.icon_enable == true then
    local icon = full_opts.git.icon
    if icon ~= nil then
      status_line = status_line .. " " .. icon
    end
  end
  status_line = status_line .. " " .. branch_name .. " %##"
  return status_line
end

local function CursorLocation(win, is_cur)
  local type_name = "location"
  if is_simple_mode(win, type_name) then
    return ""
  end
  if is_cur ~= true and is_inactive_mode(type_name) then
    return ""
  end
  local status_line = "%l:%c"
  return "%#PandaLineLocation#  " .. status_line .. "  %##"
end

local function LinePercent(win, is_cur)
  local type_name = "percent"
  if is_simple_mode(win, type_name) then
    return ""
  end
  if is_cur ~= true and is_inactive_mode(type_name) then
    return ""
  end
  return "%#PandaLinePercent# %p%% %##"
end

local function FileEncoding(win, is_cur)
  local type_name = "encoding"
  if is_simple_mode(win, type_name) then
    return ""
  end
  if is_cur ~= true and is_inactive_mode(type_name) then
    return ""
  end
  return "%#PandaLineEncoding# %{&fileencoding} %##"
end

local function load_win_statusline(win, is_cur)
  local status_line = VIMode(is_cur)
  if full_opts.git.enable == true then
    status_line = status_line .. GitBranch(win, is_cur)
  end
  status_line = status_line .. FileInfo(win, is_cur)
  status_line = status_line .. SpaceFill()
  -- right
  status_line = status_line .. "%="
  status_line = status_line .. FileEncoding(win, is_cur)
  status_line = status_line .. LinePercent(win, is_cur)
  status_line = status_line .. CursorLocation(win, is_cur)
  vim.api.nvim_win_set_option(win, "statusline", status_line)
end

local function load_wins_statusline()
  for k, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    vim.api.nvim_win_set_option(window, "statusline", " ")
    load_win_statusline(window, k == vim.fn.winnr())
  end
end

local function pandaline_augroup()
  vim.api.nvim_create_autocmd(
    {"BufEnter", "WinEnter"},
    {
      group = vim.api.nvim_create_augroup("PandaLine", {clear = true}),
      callback = function()
        load_wins_statusline()
      end
    }
  )
end

local function load_pandaline_theme()
  for k, v in pairs(full_opts.theme) do
    if v.bg == nil and v.fg == nil then
      break
    end
    local color_command = "hi " .. k .. " "
    if v.bg ~= nil then
      color_command = color_command .. "guibg=" .. v.bg .. " "
    end
    if v.fg ~= nil then
      color_command = color_command .. "guifg=" .. v.fg
    end
    vim.api.nvim_command(color_command)
  end
end

local function load_web_icon()
  local web_devicons = require("nvim-web-devicons")
  if not web_devicons.has_loaded() then
    web_devicons.setup()
  end
  -- change all icon bg color
  for _, icon in pairs(web_devicons.get_icons()) do
    if icon.color and icon.name then
      local hl_group = icon.name and "PandalineDevIcon" .. icon.name
      if hl_group then
        vim.api.nvim_command(
          "highlight! " .. hl_group .. " guifg=" .. icon.color .. " guibg=" .. full_opts.theme.PandaLineFile.bg
        )
      end
    end
  end
end

local function choose_win_statusline(win, show_item)
  local mid = full_opts.choose_space .. string.upper(show_item) .. full_opts.choose_space
  local space = string.rep(" ", math.floor((vim.api.nvim_win_get_width(win) - #mid) / 2))
  local left_fill = "%#PandaLineChooseWinFill#" .. space .. "%##"
  local right_fill = "%#PandaLineChooseWinFill#" .. space
  return left_fill .. "%#PandaLineChooseWin#" .. mid .. "%##" .. right_fill
end

local function choose_specify_windows(windows)
  local window_mark = {}
  for k, window in ipairs(windows) do
    if vim.api.nvim_win_get_config(window).relative == "" then
      local show_item = full_opts.quick_choose[k]
      window_mark[show_item] = window
      vim.api.nvim_win_set_option(window, "statusline", choose_win_statusline(window, show_item))
    end
  end
  vim.api.nvim_command("redraw")
  vim.api.nvim_command("echohl WarningMsg | echo 'choose > ' | echohl None")
  local c = vim.fn.nr2char(vim.fn.getchar())
  vim.api.nvim_command("normal :esc<CR>")

  load_wins_statusline()

  local choose_window = window_mark[c]
  if choose_window ~= nil then
    vim.api.nvim_set_current_win(choose_window)
  end
end

local function choose_win()
  choose_specify_windows(vim.api.nvim_tabpage_list_wins(0))
end

local setup = function(opts)
  full_opts = vim.tbl_deep_extend("force", full_opts, opts or {})
  if full_opts.icon_enable == true then
    load_web_icon()
  end
  load_pandaline_theme()
  pandaline_augroup()
end

return {
  mode_name = mode_name,
  choose_win = choose_win,
  choose_specify_windows = choose_specify_windows,
  setup = setup
}
