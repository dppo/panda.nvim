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
