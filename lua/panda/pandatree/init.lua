local util = require "panda.util"
local draw = require "panda.pandatree.draw"
local action = require "panda.pandatree.action"
local is_buf_match_name = util.is_buf_match_name

local setting = util.read_setting_config()
local win_width = setting["win_width"]
local buf_name = setting["buf_name"]

local is_init = false
local wait_sync = false
local last_tab_exist_tree = false
local show_tree = {}
local open_tree = {}

local buf_options = {
    buftype = "nofile",
    modifiable = false,
    filetype = "pandatree"
}

-- 获取当前所在window
local function get_current_window()
    local current_window = nil
    -- 获取当前tab number
    local tab_pagenr = vim.fn.tabpagenr()
    -- 根据tab number 获取当前tab对象
    for _, tab in ipairs(vim.fn.gettabinfo()) do
        if tab_pagenr == tab.tabnr then
            current_window = tab.windows[vim.fn.winnr()]
        end
    end
    return current_window
end

-- 获取当前tab下的treewindow
local function get_cur_tab_tree_window()
    local tree_window = nil
    -- 获取当前tab number
    local tab_pagenr = vim.fn.tabpagenr()
    for _, tab in ipairs(vim.fn.gettabinfo()) do
        -- TODO 从tree开启tabnew，bufname显示为tree name
        if tab_pagenr == tab.tabnr and #tab.windows > 1 then
            for _, window in ipairs(tab.windows) do
                local buf = vim.api.nvim_win_get_buf(window)
                if is_buf_match_name(buf, buf_name) then
                    tree_window = window
                end
            end
        end
    end
    return tree_window
end

local function get_tree_buffer()
    local tree_buffer = nil
    local all_buffer = vim.fn.range(1, vim.fn.bufnr('$'))
    for _, buffer in ipairs(all_buffer) do
        if is_buf_match_name(buffer, buf_name) then tree_buffer = buffer end
    end
    return tree_buffer
end

local function load_buf_keymap(buf)
    local mappings = {
        ["<cr>"] = "enter_row",
        ["h"] = "upper_stage",
        ["l"] = "lower_stage",
        ["r"] = "redraw_tree_buffer",
        ["<C-v>"] = 'open_file_with_vsplit'
    }
    for k, v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, "n", k,
                                    ":lua require'panda.pandatree'." .. v ..
                                        "()<cr>", {
            nowait = true,
            silent = true,
            noremap = true
        })
    end
end

local function new_tree_buffer()
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer, buf_name)
    for k, v in pairs(buf_options) do
        vim.api.nvim_buf_set_option(buffer, k, v)
    end
    return buffer
end

local function new_tree_window()
    vim.api.nvim_command("vsplit")
    vim.api.nvim_command("wincmd H")
    vim.api.nvim_command("vertical resize " .. win_width)
    -- 获取创建的window
    local current_window = get_current_window()
    -- 判断是否存在同名buffer
    local tree_buffer = get_tree_buffer()
    if tree_buffer == nil then
        tree_buffer = new_tree_buffer()
        vim.api.nvim_win_set_buf(current_window, tree_buffer)
        -- 加载buf按键映射
        load_buf_keymap(tree_buffer)
    end
    -- 给创建的window添加buffer
    vim.api.nvim_win_set_buf(current_window, tree_buffer)
    -- 绘制tree
    show_tree = draw.draw_tree(tree_buffer, open_tree)
end

local function close_tree_window(window) vim.api.nvim_win_close(window, true) end

local function init_augroup()
    vim.cmd [[augroup PandaTree]]
    vim.cmd [[autocmd!]]
    vim.cmd [[autocmd TabEnter * lua require"panda.pandatree".wait_sync_tab_tree()]]
    vim.cmd [[autocmd TabLeave * lua require"panda.pandatree".tab_leave()]]
    vim.cmd [[autocmd BufEnter * lua require"panda.pandatree".sync_tab_tree()]]
    vim.cmd [[autocmd ColorScheme * lua require"panda.pandatree.color".load_color()]]
    vim.cmd [[autocmd WinEnter * lua require"panda.pandatree".resize_tree_window()]]
    vim.cmd [[autocmd BufWinEnter * lua require"panda.pandatree".resize_tree_window()]]
    vim.cmd [[autocmd BufEnter * lua require"panda.pandatree".prevent_other_buffers()]]
    vim.cmd [[augroup END]]
    -- 加载颜色
    require"panda.pandatree.color".load_color()
    -- 标记初始化完成
    is_init = true
end

local function togger_tree()
    local tree_window = get_cur_tab_tree_window()
    if tree_window == nil then
        if not is_init then init_augroup() end
        new_tree_window()
    else
        close_tree_window(tree_window)
    end
end

-- 当前tab如果只存在tree，自动关闭
local function check_auto_close_tab()
    local tab_pagenr = vim.fn.tabpagenr()
    for _, tab in ipairs(vim.fn.gettabinfo()) do
        if tab_pagenr == tab.tabnr and #tab.windows == 1 then
            local buf = vim.api.nvim_win_get_buf(tab.windows[0])
            if is_buf_match_name(buf, buf_name) then
                vim.api.nvim_command("q")
            end
        end
    end
end

local function wait_sync_tab_tree() wait_sync = true end

local function tab_leave()
    local cur_tree_window = get_cur_tab_tree_window()
    last_tab_exist_tree = cur_tree_window ~= nil
end

local function sync_tab_tree()
    if wait_sync then
        local cur_tree_window = get_cur_tab_tree_window()
        if last_tab_exist_tree and cur_tree_window == nil then
            -- 同步显示treewindow
            new_tree_window()
        elseif not last_tab_exist_tree and cur_tree_window ~= nil then
            -- 取消显示当前treewindow
            close_tree_window(cur_tree_window)
        end
    end
    wait_sync = false
    -- 当前tab如果只存在tree，自动关闭
    check_auto_close_tab()
end

-- action
local function get_cursor_row()
    local cur_tree_window = get_cur_tab_tree_window()
    local row = vim.api.nvim_win_get_cursor(cur_tree_window)[1]
    if row > 1 then
        local item = show_tree[row - 1]
        return item
    end
    return nil
end

local function redraw_tree_buffer()
    local tree_buffer = get_tree_buffer()
    if tree_buffer ~= nil then
        show_tree = draw.draw_tree(tree_buffer, open_tree)
    end
end

local function enter_row()
    local item = get_cursor_row()
    if item ~= nil then
        if item["mode"] == "file" then
            action.enter_file(item)
        else
            open_tree = action.togger_folder(item, open_tree)
        end
        redraw_tree_buffer()
    end
end

local function upper_stage()
    local cwd = vim.loop.cwd()
    vim.api.nvim_command("cd " .. util.get_path(cwd))
    redraw_tree_buffer()
end

local function lower_stage()
    local item = get_cursor_row()
    if item ~= nil then
        if item["mode"] == "file" then
            action.enter_file(item)
        else
            vim.api.nvim_command("cd " .. item["path"])
            redraw_tree_buffer()
        end
    end
end

local function open_file_with_vsplit()
    local item = get_cursor_row()
    if item ~= nil then
        if item["mode"] == "file" then
            vim.api.nvim_command("vsplit" .. " " .. item.path)
        end
    end
end

local function resize_tree_window()
    local tree_window = get_cur_tab_tree_window()
    local cur_window = get_current_window()
    if cur_window == tree_window then
        vim.api.nvim_command("vertical resize " .. setting["win_width"])
    else
        vim.api.nvim_set_current_win(tree_window)
        vim.api.nvim_command("vertical resize " .. setting["win_width"])
        vim.api.nvim_set_current_win(cur_window)
    end
end

local function prevent_other_buffers()
    if vim.fn.bufname("#") == buf_name and vim.fn.bufname("%") ~= buf_name and
        vim.fn.winnr("$") > 1 then
        local tree_window = get_cur_tab_tree_window()
        if tree_window == nil then
            vim.cmd [[let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf]]
        end
    end
    if vim.fn.bufname("%") == buf_name then redraw_tree_buffer() end
end

return {
    togger_tree = togger_tree,
    tab_leave = tab_leave,
    wait_sync_tab_tree = wait_sync_tab_tree,
    sync_tab_tree = sync_tab_tree,
    enter_row = enter_row,
    upper_stage = upper_stage,
    lower_stage = lower_stage,
    redraw_tree_buffer = redraw_tree_buffer,
    open_file_with_vsplit = open_file_with_vsplit,
    resize_tree_window = resize_tree_window,
    prevent_other_buffers = prevent_other_buffers
}
