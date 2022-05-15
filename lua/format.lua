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

local filetypes = {
  json = {
    prettier
  },
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

require("formatter").setup(
  {
    logging = false,
    filetype = filetypes
  }
)

local function format()
  local current_buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")
  if vim.tbl_contains(vim.tbl_keys(filetypes), filetype) then
    vim.api.nvim_command("FormatWrite")
  elseif vim.tbl_count(vim.lsp.buf_get_clients(current_buf)) > 0 then
    vim.api.nvim_command("lua vim.lsp.buf.formatting()")
  else
    vim.api.nvim_err_writeln("暂无对应的格式化工具")
  end
end

return {
  format = format
}
