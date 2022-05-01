local nvim_root = string.gsub(os.getenv("MYVIMRC"), "init.lua", "")
local package_root = nvim_root .. "lua/panda/"
local utf8 = require "lua-utf8"

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function index_of(values, item)
    local index = {}
    for k, v in pairs(values) do index[v] = k end
    return index[item]
end

local function get_path(str, sep)
    sep = sep or '/'
    return str:match("(.*" .. sep .. ")")
end

local function get_name(path)
    if path == nil then return "" end
    local file_path = get_path(path)
    if file_path == nil then return path end
    return string.gsub(path, file_path, "")
end

local function get_extension(filename) return filename:match(".+%.(%w+)$") end

local function load_config(path, setting)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local json = require"cjson".decode(content)
        for k, v in pairs(json) do setting[k] = v end
    end
end

local function read_setting_config()
    local setting = {}
    load_config(package_root .. "/panda-setting.json", setting)
    load_config(nvim_root .. "panda-setting.json", setting)
    return setting
end

local function sort_by_name(element1, elemnet2)
    if element1 == nil or elemnet2 == nil or element1.mode == nil or
        elemnet2.mode == nil then return false end
    if element1.mode ~= elemnet2.mode then
        return element1.mode < elemnet2.mode
    end
    local name1 = element1.name
    if name1 ~= nil then name1 = string.lower(name1) end
    local name2 = elemnet2.name
    if name2 ~= nil then name2 = string.lower(name2) end
    return name1 < name2
end

local function v_include(tab, value)
    for k, v in pairs(tab) do if v == value then return k end end
    return -1
end

local function firstToUpper(str)
    local newStr = string.gsub(str, "[%.,%$,%-,%+,#,%%,%?,%*,%[,%]]", "_")
    return (newStr:gsub("^%l", string.upper))
end

local function handler_line_name(name, max_width, space)
    local new_name = ""
    if utf8.width(name) > max_width then
        local idx = utf8.widthindex(name, max_width)
        new_name = utf8.sub(name, 1, idx)
        -- 再次验证名称是否过长，防止截取后，中文占两格
        if utf8.width(new_name) > max_width then
            new_name = utf8.sub(name, 1, idx - 1) .. " "
        end
    else
        new_name = name .. string.rep(space, max_width - utf8.width(name))
    end
    return new_name
end

local function is_buf_match_name(buf, name)
    if not vim.api.nvim_buf_is_loaded(buf) then return false end
    return vim.api.nvim_buf_get_name(buf):match(".*/" .. name .. "$")
end

return {
    tablelength = tablelength,
    index_of = index_of,
    get_path = get_path,
    get_name = get_name,
    get_extension = get_extension,
    read_setting_config = read_setting_config,
    sort_by_name = sort_by_name,
    v_include = v_include,
    firstToUpper = firstToUpper,
    handler_line_name = handler_line_name,
    is_buf_match_name = is_buf_match_name
}
