local mode_map = {
    n = {name = "NORMAL", color = "#98c379"},
    i = {name = "INSERT", color = "#61afef"},
    c = {name = "COMMAND", color = "#98c379"},
    v = {name = "VISUAL", color = "#c678dd"},
    V = {name = "V-LINE", color = "#c678dd"},
    ["\22"] = {name = "V-BLOCK", color = "#c678dd"},
    R = {name = "REPLACE", color = "#e06c75"},
    t = {name = "TERMINAL", color = "#61afef"},
    s = {name = "SELECT", color = "#e5c07b"},
    S = {name = "S-LINE", color = "#e5c07b"},
    [""] = {name = "S-BLOCK", color = "#e5c07b"}
}

local function mode_name()
    local mode = vim.fn.mode()
    local mode_info = mode_map[mode]
    if mode_info == nil then return mode end
    local name = mode_info.name
    -- local mode_fg = vim.fn.synIDattr(vim.fn.hlID("PandaLineViMode"), "fg")
    vim.api.nvim_command("hi PandaLineViMode guibg=" .. mode_info.color ..
                             " guifg=" .. "#282c34")
    return name
end

function VIMode()
    local mode = "%#PandaLineViMode# " ..
                     [[%{luaeval('require("panda.pandaline").mode_name()')}]] ..
                     " %##"
    return mode
end

function FileSpace()
    local space = "%#PandaLineFile# " .. "%##"
    return space
end

function FileName(win)
    local util = require "panda.util"
    local setting = util.read_setting_config()
    local icon = setting["icon"]
    local buf = vim.api.nvim_win_get_buf(win)
    local file_name = vim.api.nvim_buf_get_name(buf)
    if file_name == nil then file_name = "[未命名]" end
    if #file_name == 0 then file_name = "[未命名]" end
    local extension = util.get_extension(file_name)
    local icon_info = icon[extension]
    local show_name = FileSpace() .. "%#PandaLineFile#" ..
                          util.get_name(file_name) .. "%m" .. "%##" ..
                          FileSpace()
    if icon_info ~= nil then
        local icon_fg = icon_info.color
        local icon_bg = "#ff0000"
        local icon_hl_group = "PandaFileIcon" .. extension
        vim.api.nvim_command("hi " .. icon_hl_group .. " guibg=" .. icon_bg ..
                                 " guifg=" .. icon_fg)
        return
            FileSpace() .. "%#" .. icon_hl_group .. "#" .. icon_info.symbol ..
                "%##" .. show_name
    end
    return show_name
end

local function load_win_statusline(win, is_cur)
    local status_line = " "
    if is_cur then status_line = VIMode() end
    status_line = status_line .. FileName(win)
    vim.api.nvim_win_set_option(win, "statusline", status_line)
end

local function pandaline_augroup()
    vim.cmd [[augroup PandaLine]]
    vim.cmd [[autocmd!]]
    vim.cmd [[autocmd BufEnter * lua require"panda.pandaline".reload_win_statusline()]]
    vim.cmd [[augroup END]]
end

local function reload_win_statusline()
    for _, tab in ipairs(vim.fn.gettabinfo()) do
        if tab.tabnr == vim.fn.tabpagenr() then
            for k, win in ipairs(tab.windows) do
                vim.api.nvim_win_set_option(win, "statusline", " ")
                load_win_statusline(win, k == vim.fn.winnr())
            end
        end
    end
end

return {
    pandaline_augroup = pandaline_augroup,
    reload_win_statusline = reload_win_statusline,
    mode_name = mode_name
}
