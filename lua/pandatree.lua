local utf = require "lua-utf8"
local pl_path = require "pl.path"

local full_opts = {
  icon_enable = true,
  win_width = 31,
  tree_name = "PandaTree",
  show_hidden = true,
  hidden_reg = "^[.].*",
  indent_symbol = " ",
  folder_indent = "  ",
  root_name = " [ROOT] ",
  buffer_option = {
    swapfile = false,
    buftype = "nofile",
    modifiable = false,
    filetype = "pandatree",
    bufhidden = "wipe",
    buflisted = false
  },
  window_option = {
    relativenumber = false,
    number = false,
    list = false,
    foldenable = false,
    winfixwidth = true,
    spell = false,
    wrap = false
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
  tree = {}
}

local function v_include(tab, value)
  for k, v in pairs(tab) do
    if v == value then
      return k
    end
  end
  return nil
end

local function is_buf_match_name(buf, name)
  if not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end
  return vim.api.nvim_buf_get_name(buf):match(".*/" .. name .. "$")
end

local function verify_is_tree_window(window)
  return vim.api.nvim_win_is_valid(window) and vim.api.nvim_win_get_config(window).relative == "" and
    vim.api.nvim_win_get_var(window, full_opts.tree_name)
end

local function current_tab_not_tree_window()
  local not_tree_windows = {}
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not verify_is_tree_window(window) and vim.api.nvim_win_get_config(window).relative == "" then
      table.insert(not_tree_windows, window)
    end
  end
  return not_tree_windows
end

local function current_tab_tree_window()
  local tree_window = nil
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if verify_is_tree_window(window) then
      tree_window = window
    end
  end
  return tree_window
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

local function set_win_default_var()
  vim.api.nvim_win_set_var(0, full_opts.tree_name, false)
end

local function set_all_win_default_var()
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    vim.api.nvim_win_set_var(window, full_opts.tree_name, false)
  end
end

local function current_tree_buffer()
  local tree_buffer = nil
  for _, buffer in pairs(vim.api.nvim_list_bufs()) do
    if is_buf_match_name(buffer, full_opts.tree_name) then
      tree_buffer = buffer
    end
  end
  return tree_buffer
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

local function scandir(path, level)
  local lfs = require "lfs"
  local sort_data = {}
  for dir_obj in lfs.dir(path) do
    if dir_obj ~= "." and dir_obj ~= ".." then
      local file_path = path .. pl_path.sep .. dir_obj
      if
        not tmp_data.showHidden or
          (tmp_data.showHidden and not string.match(pl_path.basename(file_path), full_opts.hidden_reg))
       then
        local attr = lfs.attributes(file_path)
        local item = {
          path = file_path,
          name = dir_obj,
          level = level,
          indent = full_opts.indent_symbol .. string.rep(full_opts.folder_indent, level - 1)
        }
        if type(attr) == "table" then
          for k, v in pairs(attr) do
            item[k] = v
          end
        end
        table.insert(sort_data, item)
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

local function handler_show_file_name(file_name)
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
  return new_file_name
end

local function draw_tree()
  tmp_data.tree = {}
  scandir(vim.loop.cwd(), 1)
  -- 排版
  local lines = {}
  local hl_color = {}
  for k, v in pairs(tmp_data.tree) do
    if v.root == true then
      local root_name =
        v.indent .. (v.icon or full_opts.indent_symbol) .. full_opts.root_name .. string.upper(pl_path.basename(v.path))
      table.insert(lines, handler_show_file_name(root_name))
    else
      local file_name = v.indent .. (v.icon or full_opts.indent_symbol) .. full_opts.indent_symbol .. v.name
      table.insert(lines, handler_show_file_name(file_name))
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

  local tree_buffer = current_tree_buffer()
  vim.api.nvim_buf_set_option(tree_buffer, "modifiable", true)
  vim.api.nvim_buf_set_lines(tree_buffer, 0, -1, false, lines)
  for _, v in pairs(hl_color) do
    for _, v2 in pairs(v) do
      vim.api.nvim_buf_add_highlight(tree_buffer, -1, v2.group, v2.line, v2.col_start, v2.col_end)
    end
  end
  vim.api.nvim_buf_set_option(tree_buffer, "modifiable", false)
end

local function togger_show_hidden()
  tmp_data.showHidden = not tmp_data.showHidden
  draw_tree()
end

local function get_cursor_row()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  return tmp_data.tree[row]
end

local function open_new_file(item)
  vim.api.nvim_command("vsplit " .. item.path)
  vim.api.nvim_command("wincmd h")
  vim.api.nvim_command("vertical resize " .. full_opts.win_width)
  vim.api.nvim_command("wincmd l")
end

local function open_file(item)
  local not_tree_windows = current_tab_not_tree_window()
  if vim.tbl_isempty(not_tree_windows) then
    open_new_file(item)
  else
    if vim.tbl_count(not_tree_windows) == 1 then
      vim.api.nvim_set_current_win(not_tree_windows[1])
    else
      require "pandaline".choose_specify_windows(not_tree_windows)
    end
    vim.api.nvim_command("edit " .. item.path)
  end
end

local function enter_row()
  local item = get_cursor_row()
  if item ~= nil then
    if item.root == true then
      return
    end
    if item.mode == "file" then
      open_file(item)
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

local function load_buffer_keymap(buffer)
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
      buffer,
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

local function new_tree_buffer()
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buffer, full_opts.tree_name)
  for k, v in pairs(full_opts.buffer_option) do
    vim.api.nvim_buf_set_option(buffer, k, v)
  end
  load_buffer_keymap(buffer)
  return buffer
end

local function new_tree_window()
  vim.api.nvim_command("vsplit")
  vim.api.nvim_command("wincmd H")
  vim.api.nvim_command("vertical resize " .. full_opts.win_width)
  vim.api.nvim_win_set_var(0, full_opts.tree_name, true)

  for k, v in pairs(full_opts.window_option) do
    vim.api.nvim_win_set_option(0, k, v)
  end

  local tree_buffer = current_tree_buffer()
  if tree_buffer == nil then
    tree_buffer = new_tree_buffer()
  end
  vim.api.nvim_win_set_buf(0, tree_buffer)
  draw_tree()
end

local function prevent_other_buffers()
  if verify_is_tree_window(vim.api.nvim_get_current_win()) and vim.fn.bufname("%") ~= full_opts.tree_name then
    local buffer = vim.fn.bufnr()
    local tree_buffer = current_tree_buffer()
    if tree_buffer == nil then
      tree_buffer = new_tree_buffer()
    end
    vim.api.nvim_win_set_buf(0, tree_buffer)
    draw_tree()
    local not_tree_windows = current_tab_not_tree_window()
    if #not_tree_windows > 0 then
      vim.api.nvim_win_set_buf(not_tree_windows[1], buffer)
      vim.api.nvim_set_current_win(not_tree_windows[1])
    end
  end
end

local function check_auto_close()
  local not_tree_windows = current_tab_not_tree_window()
  if #not_tree_windows == 0 then
    vim.api.nvim_command("q")
  end
end

local function pandatree_augroup()
  local au_group = vim.api.nvim_create_augroup("PandaTree", {clear = true})
  vim.api.nvim_create_autocmd(
    {"WinNew", "VimEnter"},
    {
      group = au_group,
      callback = function()
        set_win_default_var()
      end
    }
  )
  vim.api.nvim_create_autocmd(
    {"BufEnter"},
    {
      group = au_group,
      callback = function()
        check_auto_close()
        prevent_other_buffers()
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
  pandatree_augroup()
  set_all_win_default_var()
end

local togger_tree = function()
  if not tmp_data.isSetUp then
    setup()
  end
  local tree_window = current_tab_tree_window()
  if tree_window == nil then
    new_tree_window()
  else
    vim.api.nvim_win_close(tree_window, true)
  end
end

return {
  togger_tree = togger_tree,
  setup = setup,
  enter_row = enter_row,
  togger_show_hidden = togger_show_hidden,
  draw_tree = draw_tree
}
