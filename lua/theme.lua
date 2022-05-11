local function load_color_scheme()
  -- system
  vim.cmd [[hi Normal guibg=NONE ctermbg=NONE]]
  vim.cmd [[hi SignColumn guibg=NONE ctermbg=NONE]]
  vim.cmd [[hi VertSplit guibg=NONE guifg=#455a64 ctermbg=NONE ctermfg=239]]
  vim.cmd [[hi EndOfBuffer guibg=NONE guifg=#282c34 ctermbg=NONE ctermfg=249]]

  -- ScrollView
  vim.cmd [[hi ScrollView guibg=#FFFFFF]]
end

local function auto_load_color_scheme()
  vim.cmd [[augroup PandaTheme]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd ColorScheme * lua require"panda.theme".load_color_scheme()]]
  vim.cmd [[augroup END]]
  -- 立即更新一遍ColorScheme
  load_color_scheme()
end

return {
  auto_load_color_scheme = auto_load_color_scheme,
  load_color_scheme = load_color_scheme
}
