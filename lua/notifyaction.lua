local full_opts = {
  BufWritePost = {
    message = "保存成功"
  }
}

local function verify_setup()
  require("notify").setup(
    {
      background_colour = "#000000",
      minimum_width = 25,
      timeout = 1000
    }
  )
  vim.notify = require("notify")
end

local function notify_action(action_type)
  local message = full_opts[action_type]["message"]
  vim.notify(message)
end

local function notify_action_augroup()
  vim.cmd [[augroup NotifyAction]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufWritePost * lua require"notifyaction".notify_action("BufWritePost")]]
  vim.cmd [[augroup END]]
end

local setup = function(opts)
  opts = opts or {}
  notify_action_augroup()
  vim.defer_fn(
    function()
      verify_setup()
    end,
    1000
  )
end

return {
  setup = setup,
  notify_action = notify_action
}
