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

-- Gitsigns
require("gitsigns").setup {
  signs = {
    add = {text = "+"},
    change = {text = "~"},
    delete = {text = "_"},
    topdelete = {text = "‾"},
    changedelete = {text = "~"}
  }
}

-- Indent blankline
require("indent_blankline").setup {
  char = "┊",
  filetype_exclude = {
    "lspinfo",
    "packer",
    "checkhealth",
    "help",
    "man",
    "",
    "startify"
  }
}

-- scrollview
require("scrollview").setup(
  {
    excluded_filetypes = {"PandaTree", "startify"},
    current_only = true
  }
)

-- startify
vim.g.startify_change_to_dir = 0
vim.g.startify_change_to_vcs_root = 1

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
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false
  }
}

-- fzf
vim.g.fzf_layout = {
  window = {
    width = 0.7,
    height = 0.9
  }
}

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

-- comment
require("Comment").setup(
  {
    mappings = false,
    pre_hook = function(ctx)
      if vim.bo.filetype == "typescriptreact" then
        local U = require("Comment.utils")

        local type = ctx.ctype == U.ctype.line and "__default" or "__multiline"

        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require("ts_context_commentstring.utils").get_visual_start_location()
        end

        return require("ts_context_commentstring.internal").calculate_commentstring(
          {
            key = type,
            location = location
          }
        )
      end
    end
  }
)

-- term
require("toggleterm").setup {
  open_mapping = nil,
  on_open = function(term)
    vim.keymap.set("t", "<esc>", "<cmd>ToggleTerm<CR>", {silent = false, noremap = true, buffer = term.bufnr})
    if vim.fn.mapcheck("<leader>tt", "t") ~= "" then
      vim.keymap.del("t", "<leader>tt", {buffer = term.bufnr})
    end
  end,
  on_close = function()
    require("panda.pandatree").draw_tree()
  end,
  highlights = {
    FloatBorder = {
      link = "Comment"
    }
  },
  insert_mappings = false,
  direction = "float",
  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.68)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.86)
    end
  }
}

require("format")
require("notice")
require("completion")
