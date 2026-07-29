require "plugins.gitsigns"

local f = require 'core.format'
local group = require 'core.augroup'

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

---@type integer?
local line_count_cb
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV]*:[^vV]*",
  callback = function()
    if line_count_cb then
      vim.api.nvim_del_autocmd(line_count_cb)
      line_count_cb = nil
    end
  end,
  group = group,
})

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
