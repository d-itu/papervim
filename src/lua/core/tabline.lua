require 'plugins.mini-icons'

local f = require 'core.format'
local mini_icon = require "mini.icons"

---@param buf integer
function _G.switch_buffer(buf)
  vim.api.nvim_win_set_buf(0, buf)
end

---@alias diag_count table<vim.diagnostic.Severity, integer>

---@param count diag_count
---@return integer?
local function diag_severity_most(count)
  for i = 1, 4 do
    if count[i] then return i end
  end
end

---@param count diag_count
---@return integer
local function diag_sum(count)
  return vim.iter(count):fold(0, function(x, y) return x + y end)
end

local diag_hl = require 'core.diagnostic_hl'

local group = require 'core.augroup'
vim.api.nvim_create_autocmd('DiagnosticChanged', {
  group = group,
  callback = function()
    vim.api.nvim__redraw {
      tabline = true,
    }
  end,
})

local function reverse(name)
  local fill = vim.api.nvim_get_hl(0, { name = name, link = false })
  if fill.reverse then
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    vim.api.nvim_set_hl(0, name, {
      reverse = false,
      fg = fill.bg or normal.fg,
      bg = fill.fg or normal.fg,
    })
  end
end

local function on_colorscheme()
  reverse "TabLineFill"
  reverse "TabLine"
  reverse "TabLineSel"
end
on_colorscheme()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = on_colorscheme,
})

---@param buf integer
---@return string
local function render_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local filename = name == '' and "[No Name]" or vim.fs.basename(name)
  local hl = vim.api.nvim_get_current_buf() == buf and "TabLineSel" or "TabLine"
  local icon, icon_hl, is_default = mini_icon.get("filetype", vim.bo[buf].filetype)
  local icon = is_default and "" or f("%${}${} ", icon_hl, icon)
  local diag_count = vim.diagnostic.count(buf)
  local diag_severity = diag_severity_most(diag_count)
  local diag_sum = diag_sum(diag_count)
  local diag = diag_severity and f("%${}${} ", diag_hl[diag_severity], diag_sum) or ""
  local modified = vim.bo[buf].modified and "%$DiffViewStatusModified$ " or ""
  return f("%{}@v:lua.switch_buffer@%#{}# {}%#{}#{} {}{}%T", buf, hl, icon, hl, filename, diag, modified)
end

local buf_to_delete
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(arg)
    buf_to_delete = arg.buf
    vim.api.nvim__redraw { tabline = true }
  end
})

function _G.tabline_normal()
  local result = vim.iter(vim.api.nvim_list_bufs())
      :filter(vim.api.nvim_buf_is_loaded)
      :filter(function(buf) return buf ~= buf_to_delete end)
      :filter(function(buf) return vim.bo[buf].buftype == '' end)
      :map(render_buffer)
      :join('') .. "%#TabLineFill#"
  buf_to_delete = nil
  return result
end

vim.o.tabline = "%{%v:lua.tabline_normal()%}"
