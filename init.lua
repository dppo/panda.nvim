local fn = vim.fn
fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  _G.packer_bootstrap =
    fn.system(
    {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path
    }
  )
end

require("packer").startup {
  function(use, use_rocks)
    use {"wbthomason/packer.nvim"}
    use "joshdick/onedark.vim"
    use {
      "williamboman/nvim-lsp-installer",
      {
        "neovim/nvim-lspconfig",
        config = require "lsp".setup()
      }
    }
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-buffer"
    use "saadparwaiz1/cmp_luasnip"
    use "L3MON4D3/LuaSnip"
    use {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate"
    }
    use "windwp/nvim-autopairs"
    use "windwp/nvim-ts-autotag"
    use "mhartington/formatter.nvim"
    use "dstein64/nvim-scrollview"
    use {
      "kyazdani42/nvim-tree.lua",
      requires = {
        "kyazdani42/nvim-web-devicons"
      }
    }
    use "easymotion/vim-easymotion"
    use "lukas-reineke/indent-blankline.nvim"
    use {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup()
      end
    }
    use "preservim/nerdcommenter"
    use {
      "nvim-telescope/telescope.nvim",
      requires = {{"nvim-lua/plenary.nvim"}}
    }
    use "rcarriga/nvim-notify"

    use_rocks {"lua-cjson", "luafilesystem", "luautf8", "penlight"}

    if packer_bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    luarocks = {
      python_cmd = "python3"
    }
  }
}

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

require("pandaline").setup()
-- require("pandatree").setup()
require("notifyaction").setup()

require "theme".auto_load_color_scheme()
-- require "panda.pandaline".pandaline_augroup()

vim.api.nvim_exec(
  [[
autocmd BufEnter,FocusGained,InsertLeave * call IM_SelectDefault()
let g:im_default = 'com.apple.keylayout.ABC'
function! IM_SelectDefault()
  let b:saved_im = system("im-select")
  if v:shell_error
    unlet b:saved_im
  else
    let l:a = system("im-select " . g:im_default)
  endif
endfunction
]],
  false
)

local actions = require("telescope.actions")
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close
      }
    }
  }
}

require "nvim-tree".setup {}

vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1

vim.g.NERDCreateDefaultMappings = 0
vim.g.NERDSpaceDelims = 1
vim.g.NERDTrimTrailingWhitespace = 1
vim.g.NERDCustomDelimiters = {
  javascript = {
    left = "//",
    right = "",
    leftAlt = "{/*",
    rightAlt = "*/}"
  }
}

-- autopairs
require("nvim-autopairs").setup {}
-- If you want insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({map_char = {tex = ""}}))
-- add a lisp filetype (wrap my-function), FYI: Hardcoded = { "clojure", "clojurescript", "fennel", "janet" }
cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"

-- autotag
require "nvim-treesitter.configs".setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
  indent = {
    enable = true
  },
  autotag = {
    enable = true
  }
}

-- format
local prettier = function()
  return {
    exe = "prettier",
    args = {
      "--stdin-filepath",
      vim.api.nvim_buf_get_name(0),
      "--bracket-same-line",
      "--bracket-spacing",
      "--no-single-quote",
      "--arrow-parens",
      "always"
    },
    stdin = true
  }
end

local luafmt = function()
  return {
    exe = "luafmt",
    args = {"--indent-count", 2, "--stdin"},
    stdin = true
  }
end

require("formatter").setup(
  {
    logging = false,
    filetype = {
      yaml = {
        prettier
      },
      javascript = {
        prettier
      },
      javascriptreact = {
        prettier
      },
      typescript = {
        prettier
      },
      typescriptreact = {
        prettier
      },
      lua = {
        luafmt
      }
    }
  }
)

require("scrollview").setup(
  {
    excluded_filetypes = {"NvimTree", "PandaTree"},
    current_only = true
  }
)

local luasnip = require "luasnip"
cmp.setup(
  {
    completion = {
      completeopt = "menu,menuone,noinsert"
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end
    },
    mapping = cmp.mapping.preset.insert(
      {
        ["<CR>"] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true
        }
      }
    ),
    sources = cmp.config.sources(
      {
        {name = "nvim_lsp"},
        {name = "luasnip"}
      },
      {
        {name = "buffer"},
        {name = "path"}
      }
    )
  }
)

-- keymap
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", ":lua require'pandaline'.choose_win()<CR>", {silent = true})
vim.keymap.set("n", "<leader>cf", ":Format<CR>", {silent = true})
vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", {silent = true})
vim.keymap.set("n", "<leader>e", ":lua require'pandatree'.togger_tree()<CR>", {silent = true})
vim.keymap.set("n", "<leader>ss", "<Plug>(easymotion-s2)", {})
vim.keymap.set("", "<leader>cc", "<Plug>NERDCommenterToggle", {})
vim.keymap.set("", "<leader>cm", "<Plug>NERDCommenterMinimal", {})

vim.keymap.set("n", "<leader>ff", ":lua require('telescope.builtin').find_files()<CR>", {})
vim.keymap.set("n", "<leader>fg", ":lua require('telescope.builtin').live_grep()<CR>", {})
vim.keymap.set("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<CR>", {})
vim.keymap.set("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<CR>", {})
