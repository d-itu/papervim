require 'plugins.mini-icons'

local f = require 'core.format'
local mini_icon = require "mini.icons"

---@param buf integer
---@param button 'l' | 'm' | 'r'
function _G.buffer_click(buf, _, button)
  if button == 'l' then
    vim.api.nvim_win_set_buf(0, buf)
  elseif button == 'r' and buf ~= vim.api.nvim_get_current_buf() then
    local ok = pcall(vim.api.nvim_buf_delete, buf, {})
    if not ok then
      vim.api.nvim_echo({ { vim.v.errmsg } }, true, { err = true })
      return
    end
  end
end

---@param tab integer
function _G.tabpage_click(tab)
  vim.api.nvim_set_current_tabpage(tab)
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
  local modified = vim.bo[buf].modified and "%$Changed$ " or ""
  return f("%{}@v:lua.buffer_click@%#{}# {}%#{}#{} {}{}%T", buf, hl, icon, hl, filename, diag, modified)
end

---@param tab integer
---@return string
local function render_tabpage(tab)
  local hl = vim.api.nvim_get_current_tabpage() == tab and "TabLineSel" or "TabLine"
  return f("%{}@v:lua.tabpage_click@%#{}# {} %T", tab, hl, tab % 10)
end

local buf_to_delete
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(arg)
    buf_to_delete = arg.buf
    vim.api.nvim__redraw { tabline = true }
  end
})

function _G.tabline_normal()
  local buffers = vim.iter(vim.api.nvim_list_bufs())
      :filter(function(buf) return buf ~= buf_to_delete and vim.fn.buflisted(buf) == 1 end)
      :map(render_buffer)
      :join('') .. "%#TabLineFill#"
  buf_to_delete = nil
  local tabpages = vim.api.nvim_list_tabpages()
  local tabpages = #tabpages > 1
      and vim.iter(vim.api.nvim_list_tabpages()):map(render_tabpage):join('')
      or ""
  return buffers .. '%=' .. tabpages
end

vim.o.tabline = "%{%v:lua.tabline_normal()%}"
