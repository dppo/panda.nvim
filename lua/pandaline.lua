local full_opts = {
  icon_enable = true,
  simple_mode = {
    width = 60,
    filetype = {"NvimTree"},
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

local function current_tab_windows()
  local tab_wins = {}
  for _, tab in ipairs(vim.fn.gettabinfo()) do
    if tab.tabnr == vim.fn.tabpagenr() then
      tab_wins = tab.windows
    end
  end
  return tab_wins
end

local function table_find(table, str)
  for k, v in ipairs(table) do
    if v == str then
      return k
    end
  end
end

local function is_simple_mode(win, type_name)
  local simple_mode = full_opts["simple_mode"]
  local filetype = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype")
  local type_index = table_find(simple_mode["ignore_type"], type_name)
  local search_index = table_find(simple_mode["filetype"], filetype)
  return type_index ~= nil and (vim.fn.winwidth(win) <= full_opts["simple_mode"]["width"] or search_index ~= nil)
end

local function is_inactive_mode(type_name)
  local inactive_mode = full_opts["inactive_mode"]
  local type_index = table_find(inactive_mode["ignore_type"], type_name)
  return type_index ~= nil
end

local function mode_name()
  local mode = vim.fn.mode()
  local mode_info = full_opts["mode"][mode]
  local name = mode_info.name
  vim.api.nvim_command("hi PandaLineViMode guibg=" .. mode_info.bg .. " guifg=" .. mode_info.fg)
  return name
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

local function FileInfo(win, is_cur)
  if is_cur ~= true and is_inactive_mode("file") then
    return ""
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local file_path = vim.api.nvim_buf_get_name(buf)
  local status_line = ""
  if full_opts["icon_enable"] == true and file_path ~= nil then
    local extension = file_path:match("^.*%.(.*)$") or ""
    local icon = require "nvim-web-devicons".get_icon(file_path, extension)
    if icon ~= nil then
      status_line = "%#" .. "PandalineDevIcon" .. extension .. "# " .. icon .. "%##"
    end
  end
  return status_line .. "%#PandaLineFile# %t%m %##"
end

local function git_branch()
  local cwd = vim.loop.cwd()
  local git_command = "cd " .. cwd .. " && " .. full_opts["git"]["command"] .. " branch --show-current"
  local branch_info = vim.fn.systemlist(git_command)
  for _, v in pairs(branch_info) do
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
  if full_opts["icon_enable"] == true then
    local icon = full_opts["git"]["icon"]
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
  if full_opts["git"]["enable"] == true then
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
  for _, tab in ipairs(vim.fn.gettabinfo()) do
    if tab.tabnr == vim.fn.tabpagenr() then
      for k, win in ipairs(tab.windows) do
        vim.api.nvim_win_set_option(win, "statusline", " ")
        load_win_statusline(win, k == vim.fn.winnr())
      end
    end
  end
end

local function pandaline_augroup()
  vim.cmd [[augroup PandaLine]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufEnter * lua require"pandaline".load_wins_statusline()]]
  vim.cmd [[autocmd WinEnter * lua require"pandaline".load_wins_statusline()]]
  vim.cmd [[augroup END]]
end

local function load_pandaline_theme()
  local theme = full_opts["theme"]
  for k, v in pairs(theme) do
    local bg = v["bg"]
    local fg = v["fg"]
    if bg == nil and fg == nil then
      break
    end
    local color_command = "hi " .. k .. " "
    if bg ~= nil then
      color_command = color_command .. "guibg=" .. bg .. " "
    end
    if fg ~= nil then
      color_command = color_command .. "guifg=" .. fg
    end
    vim.api.nvim_command(color_command)
  end
end

local function tableMerge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        tableMerge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

local function load_web_icon()
  local web_devicons = require("nvim-web-devicons")
  local has_loaded = web_devicons.has_loaded()
  if has_loaded ~= true then
    web_devicons.setup()
  end
  -- change all icon bgcolor
  local icons = web_devicons.get_icons()
  for _, icon_data in pairs(icons) do
    if icon_data.color and icon_data.name then
      local hl_group = icon_data.name and "PandalineDevIcon" .. icon_data.name
      if hl_group then
        vim.api.nvim_command(
          "highlight! " ..
            hl_group .. " guifg=" .. icon_data.color .. " guibg=" .. full_opts["theme"]["PandaLineFile"].bg
        )
      end
    end
  end
end

local function choose_win_statusline(win, show_item)
  local mid_space = full_opts["choose_space"]
  local mid = mid_space .. string.upper(show_item) .. mid_space
  local width = vim.api.nvim_win_get_width(win)
  local space = string.rep(" ", math.floor((width - #mid) / 2))
  local left_fill = "%#PandaLineChooseWinFill#" .. space .. "%##"
  local right_fill = "%#PandaLineChooseWinFill#" .. space
  return left_fill .. "%#PandaLineChooseWin#" .. mid .. "%##" .. right_fill
end

local function choose_win()
  local used_win_count = 0
  local wins = current_tab_windows()
  for k, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config["relative"] == "" then
      used_win_count = used_win_count + 1
      local show_item = full_opts["quick_choose"][k]
      vim.api.nvim_win_set_option(win, "statusline", choose_win_statusline(win, show_item))
    end
  end
  vim.api.nvim_command("redraw")
  vim.api.nvim_command("echohl WarningMsg | echo 'choose > ' | echohl None")
  local c = vim.fn.nr2char(vim.fn.getchar())
  vim.api.nvim_command("normal :esc<CR>")

  load_wins_statusline()

  local choose_index = table_find(full_opts["quick_choose"], c)
  if choose_index ~= nil and choose_index ~= vim.fn.winnr() and choose_index <= used_win_count then
    vim.api.nvim_command("exe " .. choose_index .. " . 'wincmd w'")
  end
end

local setup = function(opts)
  tableMerge(full_opts, opts or {})
  if full_opts["icon_enable"] == true then
    load_web_icon()
  end
  load_pandaline_theme()
  pandaline_augroup()
end

return {
  mode_name = mode_name,
  load_wins_statusline = load_wins_statusline,
  choose_win = choose_win,
  setup = setup
}
