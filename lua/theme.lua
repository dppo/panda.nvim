local function load_color_scheme()
  -- system
  vim.cmd [[hi Normal guibg=NONE ctermbg=NONE]]
  vim.cmd [[hi SignColumn guibg=NONE ctermbg=NONE]]
  vim.cmd [[hi VertSplit guibg=NONE guifg=#455a64 ctermbg=NONE ctermfg=239]]
  vim.cmd [[hi EndOfBuffer guibg=NONE guifg=#282c34 ctermbg=NONE ctermfg=249]]

  -- pandaline
  vim.cmd [[autocmd ColorScheme * hi Statusline guibg=NONE ctermbg=NONE]]
  vim.cmd [[autocmd ColorScheme * hi PandaLineViMode guifg=#282c34]]
  vim.cmd [[autocmd ColorScheme * hi PandaLineFile guibg=#38393f ctermbg=NONE guifg=#eeeeee ctermfg=15]]
  vim.cmd [[autocmd ColorScheme * hi PandaLineGit guibg=#38393f ctermbg=NONE guifg=#eeeeee ctermfg=15]]
  vim.cmd [[autocmd ColorScheme * hi PandaLineFill guibg=#38393f ctermbg=NONE]]
  vim.cmd [[autocmd ColorScheme * hi PandaLineDim guibg=#5c6370 ctermbg=NONE guifg=#2c323d ctermfg=15]]
  vim.cmd [[autocmd ColorScheme * hi PandaLinePercent guibg=#61afef ctermbg=NONE guifg=#2c323d ctermfg=15]]
  vim.cmd [[autocmd ColorScheme * hi def link PandaTabLineExplorer Number]]
  vim.cmd [[autocmd ColorScheme * hi PandaTabLineNomal guibg=#5c6370 ctermbg=NONE guifg=#2c323d ctermfg=15]]
  vim.cmd [[autocmd ColorScheme * hi PandaTabLineSelected guibg=#61afef ctermbg=NONE guifg=#2c323d ctermfg=15]]
  vim.cmd [[autocmd ColorScheme * hi PandaTabLineFill guibg=NONE ctermbg=NONE]]

  -- pandawin
  vim.cmd [[hi PandaWinMid guibg=#61afef guifg=#2c323d]]
  vim.cmd [[hi PandaWinFill guibg=#38393f]]

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
