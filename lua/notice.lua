local full_opts = {
  BufWritePost = {
    message = "保存成功",
    type = "info"
  },
  UnChanged = {
    message = "当前Buffer暂未保存",
    type = "error"
  }
}

local function setup()
  require("notify").setup(
    {
      background_colour = "#282c34",
      minimum_width = 25,
      timeout = 1000,
      stages = "fade"
    }
  )
  vim.notify = require("notify")
end

local function notify_action_augroup()
  local group = vim.api.nvim_create_augroup("Notice", {clear = true})
  vim.api.nvim_create_autocmd(
    "BufWritePost",
    {
      group = group,
      callback = function()
        vim.notify(full_opts.BufWritePost.message, full_opts.BufWritePost.type)
      end
    }
  )
  vim.api.nvim_create_autocmd(
    "BufLeave",
    {
      group = group,
      callback = function()
        if vim.fn.getbufinfo(vim.api.nvim_get_current_buf())[1].changed == 1 then
          vim.notify(full_opts.UnChanged.message, full_opts.UnChanged.type)
        end
      end
    }
  )
end

notify_action_augroup()
setup()
