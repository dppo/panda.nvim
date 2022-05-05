local lspinstaller = require "nvim-lsp-installer"
local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  local opts = {noremap = true, silent = true}
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", ":lua require('telescope.builtin').lsp_definitions()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local enhance_server_opts = {
  ["sumneko_lua"] = function(opts)
    opts.settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = runtime_path
        },
        diagnostics = {
          globals = {"vim"}
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true)
        },
        telemetry = {
          enable = false
        }
      }
    }
  end
}

local setup = function()
  lspinstaller.setup {
    ensure_installed = {"sumneko_lua", "tsserver"},
    automatic_installation = true
  }
  for _, server in ipairs(lspinstaller.get_installed_servers()) do
    local opts = {
      capabilities = capabilities,
      on_attach = on_attach
    }
    if enhance_server_opts[server.name] then
      enhance_server_opts[server.name](opts)
    end
    lspconfig[server.name].setup(opts)
  end
end

return {
  setup = setup
}
