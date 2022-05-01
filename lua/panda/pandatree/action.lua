local util = require "panda.util"

local is_buf_match_name = util.is_buf_match_name

local setting = util.read_setting_config()
local buf_name = setting["buf_name"]

local function togger_folder(item, open_tree)
    local path = item["path"]
    local index = util.v_include(open_tree, path)
    if index ~= -1 then
        if setting["close_auto_fold"] then
            local new_open_tree = {}
            for _, v in pairs(open_tree) do
                if string.sub(v, 1, #path) ~= path then
                    table.insert(new_open_tree, v)
                end
            end
            open_tree = new_open_tree
        else
            table.remove(open_tree, index)
        end
    else
        table.insert(open_tree, path)
    end
    return open_tree
end

local function open_new_file(item)
    vim.api.nvim_command("vsplit " .. item.path)
    vim.api.nvim_command("wincmd h")
    vim.api.nvim_command("vertical resize " .. setting["win_width"])
    vim.api.nvim_command("wincmd l")
end

local function get_tab_not_tree_window()
    local not_tree_window = nil
    local tab_pagenr = vim.fn.tabpagenr()
    for _, tab in ipairs(vim.fn.gettabinfo()) do
        if tab_pagenr == tab.tabnr then
            for _, window in ipairs(tab.windows) do
                local buf = vim.api.nvim_win_get_buf(window)
                if not_tree_window == nil and
                    not is_buf_match_name(buf, buf_name) then
                    not_tree_window = window
                end
            end
        end
    end
    return not_tree_window
end

local function enter_file(item)
    local not_tree_window = get_tab_not_tree_window()
    if not_tree_window ~= nil then
        vim.api.nvim_set_current_win(not_tree_window)
        vim.api.nvim_command("edit " .. item.path)
    else
        open_new_file(item)
    end
end

return {
    togger_folder = togger_folder,
    enter_file = enter_file
}
