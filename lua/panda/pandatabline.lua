local full_opts = {
  icon_enable = true,
  show_at_least = 2,
  title = "NeoVim",
  theme = {
    PandaTabLineFill = {
      bg = "#282c34",
      fg = "#FFFFFF"
    },
    PandaTabLineCurrentFile = {
      bg = "#282c34",
      fg = "#abb2bf"
    },
    PandaTabLineFile = {
      bg = "#3e4452",
      fg = "#abb2bf"
    },
    PandaTabLineTitle = {
      bg = "#98c379",
      fg = "#282c34"
    }
  }
}

local function LogoInfo(name)
  local icon = require "nvim-web-devicons".get_icon(name, name)
  return "%#" .. "PandaTablineDevIcon" .. name .. "# " .. icon .. "%##"
end

local function SpaceFill()
  return "%#PandaTabLineFill#"
end

local function TabInfo(tab)
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab)))
  if name == nil or name == "" then
    name = "[未命名]"
  end
  name = vim.fn.fnamemodify(name, ":t")
  local group = "PandaTabLineFile"
  if tab == vim.api.nvim_get_current_tabpage() then
    group = "PandaTabLineCurrentFile"
  end
  return "%#" .. group .. "#" .. "   " .. name .. "   " .. "%##"
end

function _G.PandaTabline()
  local tabline = LogoInfo("vim")
  tabline = tabline .. "%#PandaTabLineTitle# " .. full_opts.title .. " %##"
  for _, tab in pairs(vim.api.nvim_list_tabpages()) do
    tabline = tabline .. TabInfo(tab)
  end
  return tabline .. SpaceFill()
end

local function load_tabline()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs >= full_opts.show_at_least then
    vim.o.showtabline = 2
  else
    vim.o.showtabline = 0
  end
end

local function load_tabline_theme()
  for k, v in pairs(full_opts.theme) do
    if v.bg == nil and v.fg == nil then
      break
    end
    local color_command = "hi " .. k .. " "
    if v.bg ~= nil then
      color_command = color_command .. "guibg=" .. v.bg .. " "
    end
    if v.fg ~= nil then
      color_command = color_command .. "guifg=" .. v.fg
    end
    vim.api.nvim_command(color_command)
  end
end

local function load_web_icon()
  local web_devicons = require("nvim-web-devicons")
  if not web_devicons.has_loaded() then
    web_devicons.setup()
  end
  -- change all icon bg color
  for _, icon in pairs(web_devicons.get_icons()) do
    if icon.color and icon.name then
      local hl_group = icon.name and "PandaTablineDevIcon" .. icon.name
      if hl_group then
        vim.api.nvim_command(
          "highlight! " .. hl_group .. " guifg=" .. icon.color .. " guibg=" .. full_opts.theme.PandaTabLineTitle.bg
        )
      end
    end
  end
end

local function tableline_augroup()
  vim.api.nvim_create_autocmd(
    {"VimEnter", "TabNew", "TabClosed"},
    {
      group = vim.api.nvim_create_augroup("PandaTabLine", {clear = true}),
      callback = function()
        load_tabline()
      end
    }
  )
  vim.o.tabline = "%!v:lua.PandaTabline()"
end

local setup = function(opts)
  full_opts = vim.tbl_deep_extend("force", full_opts, opts or {})
  if full_opts.icon_enable == true then
    load_web_icon()
  end
  load_tabline_theme()
  tableline_augroup()
end

return {
  setup = setup
}
