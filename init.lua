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
require("keymap")
