local util = require "panda.util"

local setting = util.read_setting_config()

local function load_git_status()
    local git_status = {}
    local git = setting["git"]

    local cwd = vim.loop.cwd()
    local command = 'cd "' .. cwd .. '" && "' .. git["command"] ..
                        '" status --porcelain=v1 -u'
    local status_list = vim.fn.systemlist(command)
    for _, v in pairs(status_list) do
        if string.find(v, "fatal: not a git repository") == nil then
            local path = v:sub(4, -1)
            if path:match("%->") ~= nil then
                path = path:gsub("^.* %-> ", "")
            end
            local full_path = cwd .. "/" .. path
            local status_map = {}
            for k, v in pairs(git["map"][v:sub(0, 2)]) do
                status_map[k] = v
            end
            git_status[full_path] = status_map
            local dir_path = util.get_path(full_path)
            git_status[dir_path] = {"unmodified", "mixed"}
        end
    end
    return git_status
end

return {load_git_status = load_git_status}
