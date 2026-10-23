require "papervim.plugins.gitsigns"

local f = require 'papervim.format'
local group = require 'papervim.augroup'

local hl_from_mode = {
  n = { 'PVModeNormal', '@function', },
  i = { 'PVModeInsert', '@string', },
  v = { 'PVModeVisual', '@keyword', },
  V = { 'PVModeVisualLine', '@keyword.import', },
  t = { 'PVModeTerminal', '@label', },
  c = { 'PVModeCmdline', '@macro', },
  R = { 'PVModeReplace', '@constant', },
  r = { 'PVModePrompt', '@macro', },
  s = { 'PVModeSelect', '@type', },
  S = { 'PVModeSelectLine', '@type', },
  [''] = { 'PVModeVisualBlock', '@keyword.import', },
  [''] = { 'PVModeSelectBlock', '@class', },
}

local function set_mode_colors()
  for _, entry in pairs(hl_from_mode) do
    local name, template = unpack(entry)
    vim.api.nvim_set_hl(0, name, {
      fg = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false }).bg,
      bg = vim.api.nvim_get_hl(0, { name = template, link = false }).fg,
      default = true,
    })
  end
  vim.api.nvim_set_hl(0, 'PVMode', {
    link = hl_from_mode[vim.fn.mode()][1] or "StatusLine"
  })
end

vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function()
    vim.api.nvim_set_hl(0, 'PVMode', {
      link = hl_from_mode[vim.fn.mode()][1] or "StatusLine"
    })
  end,
  group = group,
})

local function on_hl()
  set_mode_colors()
  vim.api.nvim_set_hl(0, "PVShowCmd", {
    fg = vim.api.nvim_get_hl(0, { name = "@function", link = false }).fg,
    default = true,
    italic = true,
  })
end

on_hl()
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = on_hl,
  group = group,
})

---@return string
function _G.branch()
  local head = vim.b.gitsigns_head
  if head and #head > 0 then
    return " 󰘬 " .. head
  end
  return ""
end

local diff_hl = {
  'Added',
  'Changed',
  'Removed',
}
local diff_icons = {
  '',
  '',
  '',
}
function _G.diff()
  local dict = vim.b.gitsigns_status_dict
  if not dict then return "" end
  return vim.iter { dict.added or 0, dict.changed or 0, dict.removed or 0 }
      :enumerate()
      :filter(function(_, x) return x ~= 0 end)
      :map(function(idx, count)
        return f("%#{}# {} {}", diff_hl[idx], diff_icons[idx], count)
      end)
      :join('')
end

vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function()
    vim.api.nvim__redraw { statusline = true }
  end,
})

if not _G.showcmd then
  function _G.showcmd()
    return ""
  end
end

function _G.message()
  vim.cmd "message"
end

vim.o.statusline = table.concat {
  "%#PVMode#  ",
  "%#StatusLine#%{v:lua.branch()}",
  "%<",
  "%{%v:lua.vim.diagnostic.status()%}",
  "%=",
  "%#PVShowCmd#%{v:lua.showcmd()}",
  "%{%v:lua.diff()%}",
  "%#StatusLine# %{&filetype}",
  " %p%%%L %l:%c",
  " %@v:lua.message@ %T",
}
