vim.cmd [[
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
]]

--Remap space as leader key
vim.keymap.set({"n", "v"}, "<Space>", "<Nop>", {silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>e", require("panda.pandatree").togger_tree)
vim.keymap.set("n", "<leader>w", require("panda.pandaline").choose_win)
vim.keymap.set("n", "<leader>ss", "<Plug>(easymotion-s2)")
vim.keymap.set("n", "<leader>cf", require("format").format)
vim.keymap.set({"n", "v"}, "<leader>cc", "<Plug>NERDCommenterToggle")
vim.keymap.set({"n", "v"}, "<leader>cm", "<Plug>NERDCommenterMinimal")

-- gitsign
vim.keymap.set("n", "<leader>gi", "<cmd>Gitsigns preview_hunk<CR>")
vim.keymap.set("n", "<leader>gn", "<cmd>Gitsigns next_hunk<CR>")
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns prev_hunk<CR>")
vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns reset_hunk<CR>")

--fzf
vim.keymap.set("n", "<leader>ff", "<cmd>Files<CR>")
vim.keymap.set("n", "<leader>fa", "<cmd>RG<CR>")
vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<CR>")
vim.keymap.set("n", "<leader>fh", "<cmd>History<CR>")
vim.keymap.set("n", "<leader>fg", "<cmd>GFiles?<CR>")
vim.keymap.set(
  "v",
  "<leader>fa",
  function()
    vim.cmd('noau normal! "vy"')
    local content = vim.fn.getreg("v")
    vim.api.nvim_command("RG " .. content)
  end
)
vim.keymap.set(
  "n",
  "<leader>fw",
  function()
    local current_word = vim.call("expand", "<cword>")
    vim.api.nvim_command("RG " .. current_word)
  end
)

-- copy to system clipboard
vim.keymap.set(
  "v",
  "<leader>y",
  function()
    vim.cmd('noau normal! "vy"')
    local content = vim.fn.getreg("v")
    vim.fn.setreg("+", content)
    vim.fn.setreg('"', content)
    vim.api.nvim_out_write("Copied to system clipboard! \n")
  end,
  {
    nowait = true,
    silent = true,
    noremap = true
  }
)
