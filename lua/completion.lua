-- autopairs
require("nvim-autopairs").setup(
  {
    disable_filetype = {"vim"}
  }
)

-- cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({map_char = {tex = ""}}))
-- cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"

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
        },
        ["<Tab>"] = cmp.mapping(
          function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end,
          {"i", "s"}
        ),
        ["<S-Tab>"] = cmp.mapping(
          function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            elseif cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
          {"i", "s"}
        )
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
