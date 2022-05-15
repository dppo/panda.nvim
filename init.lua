local fn = vim.fn
fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
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
    use {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      requires = {"windwp/nvim-ts-autotag"}
    }
    use {
      "hrsh7th/nvim-cmp",
      requires = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
        "windwp/nvim-autopairs"
      }
    }
    use "kyazdani42/nvim-web-devicons"
    use "easymotion/vim-easymotion"
    use "lukas-reineke/indent-blankline.nvim"
    use "dstein64/nvim-scrollview"
    use "rcarriga/nvim-notify"
    use "mhartington/formatter.nvim"
    use "preservim/nerdcommenter"
    use {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup()
      end
    }
    use {
      "nvim-telescope/telescope.nvim",
      requires = {{"nvim-lua/plenary.nvim"}}
    }
    use_rocks {"luafilesystem", "luautf8", "penlight"}
  end,
  config = {
    luarocks = {
      python_cmd = "python3"
    }
  }
}

require("basic")
require("im_select")
require("panda")
require("plugin")

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

-- keymap
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", ":lua require'panda.pandaline'.choose_win()<CR>", {silent = true})
vim.keymap.set("n", "<leader>cf", ":Format<CR>", {silent = true})
vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", {silent = true})
vim.keymap.set("n", "<leader>e", ":lua require'panda.pandatree'.togger_tree()<CR>", {silent = true})
vim.keymap.set("n", "<leader>ss", "<Plug>(easymotion-s2)", {})
vim.keymap.set("", "<leader>cc", "<Plug>NERDCommenterToggle", {})
vim.keymap.set("", "<leader>cm", "<Plug>NERDCommenterMinimal", {})

vim.keymap.set("n", "<leader>ff", ":lua require('telescope.builtin').find_files()<CR>", {})
vim.keymap.set("n", "<leader>fg", ":lua require('telescope.builtin').live_grep()<CR>", {})
vim.keymap.set("n", "<leader>fb", ":lua require('telescope.builtin').buffers()<CR>", {})
vim.keymap.set("n", "<leader>fh", ":lua require('telescope.builtin').help_tags()<CR>", {})
