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

-- fzf
require("lspfuzzy").setup {
  methods = "all",
  jump_one = true,
  save_last = true,
  callback = nil,
  fzf_preview = {
    "right:+{2}-/2"
  },
  fzf_action = {
    ["ctrl-t"] = "tab split",
    ["ctrl-v"] = "vsplit",
    ["ctrl-x"] = "split"
  },
  fzf_modifier = ":~:.",
  fzf_trim = true
}

-- colorizer
require "colorizer".setup(
  {"*"},
  {
    RGB = true,
    RRGGBB = true,
    names = true,
    RRGGBBAA = true
  }
)

require("format")
require("notice")
require("completion")
require("git")
