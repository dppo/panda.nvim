local util = require "panda.util"
local git = require "panda.pandatree.git"

local setting = util.read_setting_config()
local icon = setting["icon"]
local prefix = setting["color_scheme_prefix"]

local function attrdir(path, tree, open_tree, level)
    local lfs = require "lfs"
    local sort_data = {}
    for dir_obj in lfs.dir(path) do
        if dir_obj ~= "." and dir_obj ~= ".." then
            local file_path = path .. "/" .. dir_obj
            local attr = lfs.attributes(file_path)
            local item = {
                path = file_path,
                name = dir_obj,
                level = level,
                indent = string.rep(setting["indent_symbol"], level)
            }
            if type(attr) == "table" then
                for k, v in pairs(attr) do item[k] = v end
            end
            table.insert(sort_data, item)
        end
    end
    table.sort(sort_data, util.sort_by_name)

    for _, v in pairs(sort_data) do
        if v.mode == "directory" then
            table.insert(tree, v)
            if util.v_include(open_tree, v.path) ~= -1 then
                local icon_key = "folder_open"
                local icon_key1 = "folder_" .. v.name .. "_open"
                local icon_key2 = "folder_" .. v.name
                if icon[icon_key1] ~= nil then
                    icon_key = icon_key1
                elseif icon[icon_key2] ~= nil then
                    icon_key = icon_key2
                end
                v["icon"] = icon[icon_key]
                v["group"] = icon_key
                attrdir(v.path, tree, open_tree, level + 1)
            else
                local icon_key = "folder"
                local icon_key1 = "folder_" .. v.name
                if icon[icon_key1] ~= nil then
                    icon_key = icon_key1
                end
                v["icon"] = icon[icon_key]
                v["group"] = icon_key
            end
        else
            local icon_key = "default"
            local icon_key1 = util.get_extension(v.name)
            if icon[icon_key1] ~= nil then icon_key = icon_key1 end
            v["icon"] = icon[icon_key]
            v["group"] = icon_key
            table.insert(tree, v)
        end
    end
end

local function draw_tree(buf, open_tree)
    local git_status = git.load_git_status()
    -- 加载文件目录
    local cwd = vim.loop.cwd()
    local tree = {}
    attrdir(cwd, tree, open_tree, 1)
    -- 文件树排版
    local git_icon = setting["git"]["icon"]
    local folder_name_space = setting["folder_name_space"]
    -- 根目录
    local root_name = icon["root"]["symbol"] .. setting["root_name"] ..
                          util.get_name(cwd)
    local lines = {
        util.handler_line_name(root_name, setting["win_width"] - 2,
                               setting["space"]) .. "  "
    }
    local hl_color = {
        {
            {
                group = prefix .. util.firstToUpper("root"),
                line = 0,
                col_start = 0,
                col_end = -1
            }
        }
    }
    -- 子目录
    for k, v in pairs(tree) do
        local key = v.path
        if v.mode == "directory" then key = key .. "/" end
        local status = git_status[key] or {"unmodified", "unmodified"}
        local status_icon = ""
        for _, v in pairs(status) do
            status_icon = status_icon .. git_icon[v]
        end
        local line_name = v.indent .. v.icon.symbol .. folder_name_space ..
                              v.name
        table.insert(lines,
                     util.handler_line_name(line_name, setting["win_width"] - 2,
                                            setting["space"]) .. status_icon)
        local line_color = {}
        local icon_color = {
            group = prefix .. util.firstToUpper(v.group),
            line = k,
            col_start = #v.indent,
            col_end = #line_name
        }
        if v.mode ~= "directory" then
            local icon_end = #(v.indent .. v.icon.symbol)
            icon_color.col_end = icon_end
            table.insert(line_color, {
                group = prefix .. util.firstToUpper("default"),
                line = k,
                col_start = icon_end + #folder_name_space,
                col_end = #line_name
            })
        end
        table.insert(line_color, icon_color)
        table.insert(hl_color, line_color)
    end
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    for _, v in pairs(hl_color) do
        for _, v2 in pairs(v) do
            vim.api.nvim_buf_add_highlight(buf, -1, v2.group, v2.line,
                                           v2.col_start, v2.col_end)
        end
    end
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    return tree
end

return {draw_tree = draw_tree}
