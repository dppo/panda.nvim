vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.scrolloff = 5
vim.o.updatetime = 250
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.backup = false
vim.o.writebackup = false
vim.o.hidden = true
-- tabsize
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
-- style
vim.o.showmode = false
vim.o.laststatus = 2
vim.o.number = true
vim.o.cursorline = true
vim.o.splitright = true
vim.o.wrap = true
vim.o.showtabline = 1
vim.o.breakindent = true
vim.o.completeopt = "menu,menuone,noinsert"

vim.o.syntax = "on"
vim.o.termguicolors = true
vim.cmd "colorscheme onedark"

local function load_basic_theme()
  -- system
  vim.cmd [[hi Normal guibg=NONE ctermbg=NONE]]
  vim.cmd [[hi SignColumn guibg=NONE ctermbg=NONE]]
  vim.cmd [[hi VertSplit guibg=NONE guifg=#455a64 ctermbg=NONE ctermfg=239]]
  vim.cmd [[hi EndOfBuffer guibg=NONE guifg=#282c34 ctermbg=NONE ctermfg=249]]
  -- ScrollView
  vim.cmd [[hi ScrollView guibg=#FFFFFF]]
end
-- first refresh theme
load_basic_theme()

local system_group = vim.api.nvim_create_augroup("SystemGroup", {clear = true})
vim.api.nvim_create_autocmd(
  "ColorScheme",
  {
    group = system_group,
    callback = function()
      load_basic_theme()
    end
  }
)

-- don't auto comment new line
vim.api.nvim_create_autocmd(
  "FileType",
  {
    group = system_group,
    callback = function()
      vim.cmd [[setlocal formatoptions-=cro]]
    end
  }
)

-- vertical open help
vim.api.nvim_create_autocmd(
  "BufWinEnter",
  {
    group = system_group,
    pattern = {"*.txt"},
    callback = function()
      local filetype = vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "filetype")
      if filetype == "help" then
        vim.api.nvim_command("wincmd L")
      end
    end
  }
)

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd(
  "BufReadPost",
  {
    group = system_group,
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]]
  }
)

-- show cursor line only in active window
local cursor_group = vim.api.nvim_create_augroup("CursorLine", {clear = true})
vim.api.nvim_create_autocmd(
  {"InsertLeave", "WinEnter"},
  {
    group = cursor_group,
    pattern = "*",
    command = "set cursorline"
  }
)
vim.api.nvim_create_autocmd(
  {"InsertEnter", "WinLeave"},
  {
    group = cursor_group,
    pattern = "*",
    command = "set nocursorline"
  }
)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", {clear = true})
vim.api.nvim_create_autocmd(
  "TextYankPost",
  {
    group = highlight_group,
    pattern = "*",
    callback = function()
      vim.highlight.on_yank()
    end
  }
)
