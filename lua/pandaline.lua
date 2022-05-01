local full_opts = {
  icon_enable = true,
  simple_mode = {
    width = 40,
    filetype = {"NvimTree"},
    ignore_type = {"git", "location"}
  },
  git = {
    enable = true,
    command = "git",
    icon = ""
  },
  theme = {
    PandaLineFill = {
      bg = "#FF0000",
      fg = "#FF0000"
    },
    PandaLineFile = {
      bg = "#FF0000",
      fg = "#FFFFFF"
    },
    PandaLineGit = {
      bg = "#FF0000",
      fg = "#000000"
    },
    PandaLineLocation = {
      bg = "#FF0000",
      fg = "#000000"
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
  }
}

local function mode_name()
  local mode = vim.fn.mode()
  local mode_info = full_opts["mode"][mode]
  local name = mode_info.name
  vim.api.nvim_command("hi PandaLineViMode guibg=" .. mode_info.bg .. " guifg=" .. mode_info.fg)
  return name
end

local function VIMode()
  return "%#PandaLineViMode# " .. [[%{luaeval('require("pandaline").mode_name()')}]] .. " %##"
end

local function SpaceFill()
  return "%#PandaLineFill#"
end

local function FileInfo(win)
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

local function is_simple_mode(win, type_name)
  local type_index = require("pl.tablex").search(full_opts["simple_mode"]["ignore_type"], type_name)
  local filetype = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype")
  local search_index = require("pl.tablex").search(full_opts["simple_mode"]["filetype"], filetype)
  return type_index ~= nil and (vim.fn.winwidth(win) <= full_opts["simple_mode"]["width"] or search_index ~= nil)
end

local function GitBranch(win)
  local branch_name = git_branch()
  local simple_mode = is_simple_mode(win, "git")
  if branch_name == nil or simple_mode then
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

local function CursorLocation(win)
  local simple_mode = is_simple_mode(win, "git")
  if simple_mode then
    return ""
  end
  local status_line = "%l:%c"
  return "%#PandaLineLocation#  " .. status_line .. "  %##"
end

local function load_win_statusline(win, is_cur)
  local status_line = ""
  if is_cur then
    status_line = VIMode()
  end
  if full_opts["git"]["enable"] == true then
    status_line = status_line .. GitBranch(win)
  end
  status_line = status_line .. FileInfo(win)
  status_line = status_line .. SpaceFill()
  -- right
  status_line = status_line .. "%="
  status_line = status_line .. CursorLocation(win)
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

local setup = function(opts)
  opts = opts or {}
  tableMerge(full_opts, opts)
  -- vim.pretty_print(full_opts)
  if full_opts["icon_enable"] == true then
    load_web_icon()
  end
  load_pandaline_theme()
  pandaline_augroup()
end

return {
  mode_name = mode_name,
  load_wins_statusline = load_wins_statusline,
  setup = setup
}
