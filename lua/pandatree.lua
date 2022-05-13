local utf = require "lua-utf8"
local pl_path = require "pl.path"
local lfs = require "lfs"

local full_opts = {
  icon_enable = true,
  win_width = 31,
  tree_name = "PandaTree",
  show_hidden = true,
  hidden_reg = "^[.].*",
  indent_symbol = " ",
  folder_indent = "  ",
  root_name = " [ROOT] ",
  buf_opts = {
    swapfile = false,
    buftype = "nofile",
    modifiable = false,
    filetype = "PandaTree",
    bufhidden = "wipe",
    buflisted = false
  },
  win_opts = {
    relativenumber = false,
    number = false,
    list = false,
    foldenable = false,
    winfixwidth = true,
    spell = false,
    wrap = false
  },
  git = {
    enable = true,
    command = "git"
  },
  theme = {
    PandaTree = {
      bg = "NONE",
      fg = "#FFFFFF"
    },
    PandaTreeRoot = {
      bg = "NONE",
      fg = "#D19A66"
    },
    PandaTreeFile = {
      bg = "NONE",
      fg = "#abb2bf"
    },
    PandaTreeIndent = {
      bg = "NONE",
      fg = "#000000"
    }
  },
  icon = {
    folder_root = {
      icon = "",
      color = "#d19a66",
      name = "Folder_root"
    },
    folder = {
      icon = " ",
      color = "#61afef",
      name = "Folder"
    },
    folder_open = {
      icon = " ",
      color = "#61afef",
      name = "Folder_open"
    },
    folder_node_modules = {
      icon = " ",
      color = "#61afef",
      name = "Folder_node_modules"
    },
    folder_node_modules_open = {
      icon = " ",
      color = "#61afef",
      name = "Folder_node_modules_open"
    },
    default = {
      icon = "",
      color = "#abb2bf",
      name = "Default"
    }
  }
}

local tmp_data = {
  isSetUp = false,
  showHidden = true,
  openTree = {},
  tree = {},
  gitStatus = {}
}

local function v_include(tab, value)
  for k, v in pairs(tab) do
    if v == value then
      return k
    end
  end
  return nil
end

local function win_is_not_float(win)
  return vim.api.nvim_win_get_config(win).relative == ""
end

local function win_is_tree(win)
  return vim.api.nvim_win_is_valid(win) and win_is_not_float(win) and vim.api.nvim_win_get_var(win, full_opts.tree_name)
end

local function tabpage_list_not_tree_wins()
  local not_tree_wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not win_is_tree(win) and win_is_not_float(win) then
      table.insert(not_tree_wins, win)
    end
  end
  return not_tree_wins
end

local function tabpage_tree_win()
  local tree_win = nil
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win_is_tree(win) then
      tree_win = win
    end
  end
  return tree_win
end

local function win_set_default_tree_name()
  vim.api.nvim_win_set_var(0, full_opts.tree_name, false)
end

local function wins_set_default_tree_name()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_set_var(win, full_opts.tree_name, false)
  end
end

local function buf_set_keymap(buf)
  local mappings = {
    ["<cr>"] = "enter_row",
    ["."] = "togger_show_hidden",
    ["r"] = "draw_tree"
    -- ["h"] = "upper_stage",
    -- ["l"] = "lower_stage",
    -- ["<C-v>"] = "open_file_with_vsplit"
  }
  for k, v in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(
      buf,
      "n",
      k,
      ":lua require'pandatree'." .. v .. "()<cr>",
      {
        nowait = true,
        silent = true,
        noremap = true
      }
    )
  end
end

local function create_tree_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, full_opts.tree_name)
  for k, v in pairs(full_opts.buf_opts) do
    vim.api.nvim_buf_set_option(buf, k, v)
  end
  buf_set_keymap(buf)
  return buf
end

local function panda_tree_buf()
  local tree_buf = nil
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "filetype") == full_opts.buf_opts.filetype then
      tree_buf = buf
    end
  end
  if tree_buf == nil then
    tree_buf = create_tree_buf()
  end
  return tree_buf
end

local function win_get_cursor_row()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  return tmp_data.tree[row]
end

local function smart_open_file(buf, path)
  local free_wins = {}
  for _, win in pairs(tabpage_list_not_tree_wins()) do
    if vim.fn.getbufinfo(vim.api.nvim_win_get_buf(win))[1].changed == 0 then
      table.insert(free_wins, win)
    end
  end
  local is_edit = false
  local free_wins_count = vim.tbl_count(free_wins)
  if free_wins_count == 0 then
    if buf then
      vim.api.nvim_command("vs sb" .. buf)
    else
      vim.api.nvim_command("vs" .. path)
    end
  elseif free_wins_count == 1 then
    vim.api.nvim_set_current_win(free_wins[1])
    is_edit = true
  else
    require "pandaline".choose_specify_windows(free_wins)
    is_edit = true
  end
  if is_edit then
    if buf then
      vim.api.nvim_win_set_buf(free_wins[1], buf)
    else
      vim.api.nvim_command("edit " .. path)
    end
  end
end

local function sort_by_name(element1, elemnet2)
  if element1 == nil or elemnet2 == nil or element1.mode == nil or elemnet2.mode == nil then
    return false
  end
  if element1.mode ~= elemnet2.mode then
    return element1.mode < elemnet2.mode
  end
  local name1 = element1.name
  if name1 ~= nil then
    name1 = string.lower(name1)
  end
  local name2 = elemnet2.name
  if name2 ~= nil then
    name2 = string.lower(name2)
  end
  return name1 < name2
end

local function load_web_icon()
  local web_devicons = require("nvim-web-devicons")
  if not web_devicons.has_loaded() then
    web_devicons.setup()
  end
  web_devicons.set_icon(full_opts.icon or {})
  -- change all icon bgcolor
  for _, icon in pairs(web_devicons.get_icons()) do
    if icon.color and icon.name then
      local hl_group = icon.name and "PandaTreeDevIcon" .. icon.name
      if hl_group then
        vim.api.nvim_command(
          "highlight! " .. hl_group .. " guifg=" .. icon.color .. " guibg=" .. full_opts.theme.PandaTree.bg
        )
      end
    end
  end
end

local function load_pandatree_theme()
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

local function scandir(path, level)
  local sort_data = {}
  for dir_obj in lfs.dir(path) do
    if dir_obj ~= "." and dir_obj ~= ".." then
      local file_path = pl_path.join(path, dir_obj)
      if
        not tmp_data.showHidden or
          (tmp_data.showHidden and not string.match(pl_path.basename(file_path), full_opts.hidden_reg))
       then
        table.insert(
          sort_data,
          vim.tbl_deep_extend(
            "force",
            {
              path = file_path,
              name = dir_obj,
              level = level,
              indent = full_opts.indent_symbol .. string.rep(full_opts.folder_indent, level - 1)
            },
            lfs.attributes(file_path)
          )
        )
      end
    end
  end
  table.sort(sort_data, sort_by_name)

  local web_devicons = require("nvim-web-devicons")

  if level == 1 then
    table.insert(
      sort_data,
      0,
      {
        mode = "directory",
        name = "root",
        path = vim.loop.cwd(),
        indent = "",
        root = true
      }
    )
  end

  for _, v in pairs(sort_data) do
    if v.mode == "directory" then
      table.insert(tmp_data.tree, v)
      if vim.tbl_contains(tmp_data.openTree, v.path) then
        local icon_key = "folder_open"
        local icon_key1 = "folder_" .. v.name .. "_open"
        local icon_key2 = "folder_" .. v.name
        if web_devicons.get_icon(icon_key1, icon_key1) ~= nil then
          icon_key = icon_key1
        elseif web_devicons.get_icon(icon_key2, icon_key2) ~= nil then
          icon_key = icon_key2
        end
        v.icon = web_devicons.get_icon(icon_key, icon_key)
        v.group = icon_key
        scandir(v.path, level + 1)
      else
        local icon_key = "folder"
        local icon_key1 = "folder_" .. v.name
        if web_devicons.get_icon(icon_key1, icon_key1) ~= nil then
          icon_key = icon_key1
        end
        v.icon = web_devicons.get_icon(icon_key, icon_key)
        v.group = icon_key
      end
    else
      local extension = v.path:match("^.*%.(.*)$") or ""
      local icon = web_devicons.get_icon(v.path, extension)
      if icon == nil then
        extension = "default"
      end
      v.icon =
        string.rep(full_opts.indent_symbol, utf.width(full_opts.icon.folder.icon) - 1) ..
        web_devicons.get_icon(extension)
      v.group = extension:gsub("^%l", string.upper)
      table.insert(tmp_data.tree, v)
    end
  end
end

local function handler_show_file_name(file_path, file_name)
  local max_file_name_width = full_opts.win_width - 2
  local new_file_name = file_name
  local idx, offset, width = utf.widthindex(file_name, max_file_name_width - 1)
  if width ~= nil then
    if offset ~= width then
      new_file_name = utf.sub(file_name, 1, idx - 1) .. full_opts.indent_symbol
    else
      new_file_name = utf.sub(file_name, 1, idx)
    end
    new_file_name = new_file_name .. "…"
  else
    new_file_name = file_name .. string.rep(full_opts.indent_symbol, max_file_name_width - utf.width(file_name))
  end
  if vim.tbl_contains(vim.tbl_keys(tmp_data.gitStatus), file_path) then
    new_file_name = new_file_name .. tmp_data.gitStatus[file_path]
  else
    new_file_name = new_file_name .. string.rep(full_opts.indent_symbol, 2)
  end
  return new_file_name
end

local function load_git_status()
  local command = 'cd "' .. vim.loop.cwd() .. '" && "' .. full_opts.git.command .. '" status --porcelain=v1 -u'
  for _, v in pairs(vim.fn.systemlist(command)) do
    if string.find(v, "fatal: not a git repository") == nil then
      local path = v:sub(4, -1)
      if path:match("%->") ~= nil then
        path = path:gsub("^.* %-> ", "")
      end
      local full_path = pl_path.join(vim.loop.cwd(), path)
      tmp_data.gitStatus[full_path] = v:sub(0, 2)
    end
  end
end

local function draw_tree()
  tmp_data.tree = {}
  tmp_data.gitStatus = {}
  load_git_status()
  scandir(vim.loop.cwd(), 1)
  -- 排版
  local lines = {}
  local hl_color = {}
  for k, v in pairs(tmp_data.tree) do
    if v.root == true then
      local root_name =
        v.indent .. (v.icon or full_opts.indent_symbol) .. full_opts.root_name .. string.upper(pl_path.basename(v.path))
      table.insert(lines, handler_show_file_name(v.path, root_name))
    else
      local file_name = v.indent .. (v.icon or full_opts.indent_symbol) .. full_opts.indent_symbol .. v.name
      table.insert(lines, handler_show_file_name(v.path, file_name))
    end
    local line_color = {
      {
        group = "PandaTreeIndent",
        line = k - 1,
        col_start = 1,
        col_end = #v.indent
      }
    }
    table.insert(
      line_color,
      {
        group = "PandaTreeDevIcon" .. v.group:gsub("^%l", string.upper),
        line = k - 1,
        col_start = #v.indent,
        col_end = #v.indent + #v.icon
      }
    )
    if v.root == true then
      table.insert(
        line_color,
        {
          group = "PandaTreeRoot",
          line = k - 1,
          col_start = #v.indent + #v.icon,
          col_end = -1
        }
      )
    else
      table.insert(
        line_color,
        {
          group = "PandaTreeFile",
          line = k - 1,
          col_start = #v.indent + #v.icon,
          col_end = -1
        }
      )
    end
    table.insert(hl_color, line_color)
  end

  local tree_buf = panda_tree_buf()
  vim.api.nvim_buf_set_option(tree_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, lines)
  for _, v in pairs(hl_color) do
    for _, v2 in pairs(v) do
      vim.api.nvim_buf_add_highlight(tree_buf, -1, v2.group, v2.line, v2.col_start, v2.col_end)
    end
  end
  vim.api.nvim_buf_set_option(tree_buf, "modifiable", false)
end

local function togger_show_hidden()
  tmp_data.showHidden = not tmp_data.showHidden
  draw_tree()
end

local function enter_row()
  local item = win_get_cursor_row()
  if item ~= nil then
    if item.root == true then
      return
    end
    if item.mode == "file" then
      smart_open_file(nil, item.path)
    else
      local index = v_include(tmp_data.openTree, item.path)
      if index ~= nil then
        table.remove(tmp_data.openTree, index)
      else
        table.insert(tmp_data.openTree, item.path)
      end
      draw_tree()
    end
  end
end

local function create_tree_win()
  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("wincmd H")
  vim.api.nvim_command("vertical resize " .. full_opts.win_width)
  vim.api.nvim_win_set_var(0, full_opts.tree_name, true)

  for k, v in pairs(full_opts.win_opts) do
    vim.api.nvim_win_set_option(0, k, v)
  end

  vim.api.nvim_win_set_buf(0, panda_tree_buf())
  draw_tree()
end

local function win_prevent_other_bufs_enter()
  if win_is_tree(vim.api.nvim_get_current_win()) and vim.fn.bufname("%") ~= full_opts.tree_name then
    local prevent_buf = vim.fn.bufnr()
    vim.api.nvim_win_set_buf(0, panda_tree_buf())
    draw_tree()
    smart_open_file(prevent_buf)
  end
end

local function win_check_auto_close()
  local not_tree_wins = tabpage_list_not_tree_wins()
  if vim.tbl_count(not_tree_wins) == 0 then
    vim.api.nvim_command("q")
  end
end

local function win_keep_tree_size()
  local tree_win = tabpage_tree_win()
  if tree_win ~= nil and vim.api.nvim_win_get_width(tree_win) ~= full_opts.win_width then
    vim.api.nvim_win_set_width(tree_win, full_opts.win_width)
  end
end

local function create_pandatree_augroup()
  local au_group = vim.api.nvim_create_augroup("PandaTree", {clear = true})
  vim.api.nvim_create_autocmd(
    {"WinNew", "VimEnter"},
    {
      group = au_group,
      callback = function()
        win_set_default_tree_name()
      end
    }
  )
  vim.api.nvim_create_autocmd(
    {"BufEnter"},
    {
      group = au_group,
      callback = function()
        win_check_auto_close()
        win_prevent_other_bufs_enter()
        win_keep_tree_size()
      end
    }
  )
end

local setup = function(opts)
  tmp_data.isSetUp = true
  full_opts = vim.tbl_deep_extend("force", full_opts, opts or {})
  if full_opts.icon_enable then
    load_web_icon()
  end
  tmp_data.showHidden = full_opts.show_hidden
  load_pandatree_theme()
  create_pandatree_augroup()
  wins_set_default_tree_name()
end

local togger_tree = function()
  if not tmp_data.isSetUp then
    setup()
  end
  local tree_win = tabpage_tree_win()
  if tree_win == nil then
    create_tree_win()
  else
    vim.api.nvim_win_close(tree_win, true)
  end
end

return {
  togger_tree = togger_tree,
  setup = setup,
  enter_row = enter_row,
  togger_show_hidden = togger_show_hidden,
  draw_tree = draw_tree
}
