require "plugins.gitsigns"

local f = require 'core.format'
local group = require 'core.augroup'

local hl_from_mode = {
  n = { 'PVModeNormal', 'Function', },
  i = { 'PVModeInsert', 'String', },
  v = { 'PVModeVisual', 'Keyword', },
  V = { 'PVModeVisualLine', 'Include', },
  t = { 'PVModeTerminal', 'Label', },
  c = { 'PVModeCmdline', 'Constant', },
  R = { 'PVModeReplace', '@variable.builtin', },
  r = { 'PVModePrompt', '@macro', },
  s = { 'PVModeSelect', '@lsp.type.interface', },
  S = { 'PVModeSelectLine', '@punctuation', },
  [''] = { 'PVModeVisualBlock', '@variable.parameter', },
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
  vim.api.nvim_set_hl(0, 'Mode', {
    link = hl_from_mode[vim.fn.mode()][1] or "StatusLine"
  })
end

vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function()
    vim.api.nvim_set_hl(0, 'Mode', {
      ---@diagnostic disable-next-line: undefined-field
      link = hl_from_mode[vim.fn.mode()][1] or "StatusLine"
    })
  end,
  group = group,
})

local function on_hl()
  set_mode_colors()
  vim.api.nvim_set_hl(0, "StatusLineVisual", {
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

local visual_size = ""
function _G.visual_size() return visual_size end

---@param f 'line' | 'col'
---@return integer
local function count(f)
  local x = vim.fn[f]('v')
  local y = vim.fn[f]('.')
  return math.max(x, y) - math.min(x, y) + 1
end

local function update_visual_count()
  local mode = vim.fn.mode()
  if mode == 'v' then
    local l = count 'line'
    if l > 1 then
      visual_size = ("%d lines selected"):format(l)
    else
      visual_size = ("%d cols selected"):format(count 'col')
    end
  elseif mode == 'V' then
    visual_size = ("%d lines selected"):format(count 'line')
  elseif mode == '' then
    visual_size = ("%dL x %dC selected"):format(count 'line', count 'col')
  else
    visual_size = ""
  end
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

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV]*:*",
  callback = function()
    update_visual_count()
    vim.api.nvim__redraw { statusline = true }
  end,
  group = group,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[^vV]*:[vV]*",
  callback = function()
    update_visual_count()
    vim.api.nvim__redraw { statusline = true }

    if not line_count_cb then
      line_count_cb = vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          update_visual_count(vim.fn.mode())
        end,
        group = group,
      })
    end
  end,
  group = group,
})

local diff_hl = {
  'DiagnosticOk',
  'DiagnosticWarn',
  'DiagnosticError',
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

vim.o.statusline = table.concat {
  "%#Mode#  ",
  "%#StatusLine#%{v:lua.branch()}",
  "%<",
  "%{%v:lua.vim.diagnostic.status()%}",
  "%=",
  "%#StatusLineVisual#%{v:lua.visual_size()}",
  "%{%v:lua.diff()%}",
  "%#StatusLine# %{&filetype}",
  " %p%%%L %l:%c",
  " %@v:lua.require'core.message'.show@ %T",
}
