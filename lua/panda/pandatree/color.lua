local util = require "panda.util"

local setting = util.read_setting_config()
local icon = setting["icon"]
local prefix = setting["color_scheme_prefix"]

local function load_color()
    for k, v in pairs(icon) do
        if #v.color > 0 then
            vim.api.nvim_command(
                "highlight! " .. prefix .. util.firstToUpper(k) .. " guifg=" ..
                    v.color)
        end
    end
end

return {load_color = load_color}
