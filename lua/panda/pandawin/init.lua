local prefix = "pandawin_"
local statusline_bankup = {}
local statusline_map = {}
local show_list = {
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z"
}
local mid_space = "    "

local function get_tab_windows()
  local tab_wins = {}
  for _, tab in ipairs(vim.fn.gettabinfo()) do
    if tab.tabnr == vim.fn.tabpagenr() then
      tab_wins = tab.windows
    end
  end
  return tab_wins
end

local function win_statusline(win, show_item)
  local mid = mid_space .. string.upper(show_item) .. mid_space
  local width = vim.api.nvim_win_get_width(win)
  local space = string.rep(" ", math.floor((width - #mid) / 2))
  local left_fill = "%#PandaWinFill#" .. space .. "%##"
  local right_fill = "%#PandaWinFill#" .. space
  return left_fill .. "%#PandaWinMid#" .. mid .. "%##" .. right_fill
end

local function backup_win_statusline()
  statusline_bankup = {}
  local wins = get_tab_windows()
  for k, win in ipairs(wins) do
    -- 备份当前statusline内容
    local statusline = vim.api.nvim_win_get_option(win, "statusline")
    local bankup_key = prefix .. win
    statusline_bankup[bankup_key] = statusline
    -- 临时显示操作指示
    local show_item = show_list[k]
    local map_key = prefix .. show_item
    statusline_map[map_key] = win
    vim.api.nvim_win_set_option(win, "statusline", win_statusline(win, show_item))
  end
  vim.api.nvim_command("redraw")
  vim.api.nvim_command("echohl WarningMsg | echo 'choose > ' | echohl None")
  local c = vim.fn.nr2char(vim.fn.getchar())
  vim.api.nvim_command("normal :esc<CR>")
  for _, win in ipairs(wins) do
    local bank_key = prefix .. win
    vim.api.nvim_win_set_option(win, "statusline", statusline_bankup[bank_key])
  end
  local choose_win = statusline_map[prefix .. c]
  if choose_win ~= nil then
    local cur_win = vim.fn.winnr()
    local choose_index = require("panda.util").index_of(show_list, c)
    if choose_index ~= nil and choose_index ~= cur_win and choose_index <= #wins then
      vim.api.nvim_command("exe " .. choose_index .. " . 'wincmd w'")
    end
  end
  vim.api.nvim_command(":doautocmd User ChooseWinCompleted")
end

local function choose_win()
  backup_win_statusline()
end

local function empty()
end

return {choose_win = choose_win, empty = empty}
