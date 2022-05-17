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
vim.keymap.set("n", "<leader>fw", "<cmd>Rg<CR>")
vim.keymap.set("x", "<leader>fw", 'y:Rg <C-R>"<CR>')
vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<CR>")
vim.keymap.set("n", "<leader>fh", "<cmd>History<CR>")
vim.keymap.set("n", "<leader>fg", "<cmd>GFiles?<CR>")

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
