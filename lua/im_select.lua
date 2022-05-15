local tmp_data = {
  cmd = "im-select",
  im_default = "com.apple.keylayout.ABC"
}

local function im_reset_select()
  local current_im = vim.fn.system(tmp_data.cmd)
  if string.find(current_im, tmp_data.im_default) == nil then
    vim.fn.system(tmp_data.cmd .. " " .. tmp_data.im_default)
  end
end

local au_group = vim.api.nvim_create_augroup("IM_Select", {clear = true})
vim.api.nvim_create_autocmd(
  {"BufEnter", "InsertLeave", "FocusGained"},
  {
    group = au_group,
    callback = function()
      im_reset_select()
    end
  }
)
