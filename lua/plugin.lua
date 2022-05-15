-- easymotion
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1

-- nerdcommenter
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

-- Indent blankline
require("indent_blankline").setup {
  char = "┊"
}

-- treesitter
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

require("format")
require("notice")
require("completion")
