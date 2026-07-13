local ns = vim.api.nvim_create_namespace("indent")

local char = require "core.indent-char"

local left_col
local range_beg
local range_end

---@param lnum integer
---@return integer
local function get_indent(lnum)
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
  if line == "" then
    return math.max(
      vim.fn.indent(vim.fn.nextnonblank(lnum)),
      vim.fn.indent(vim.fn.prevnonblank(lnum))
    )
  else
    return vim.fn.indent(lnum)
  end
end

local highlight = vim.api.nvim_get_hl_id_by_name "@function"

local width = vim.fn.shiftwidth()
local cursor_indent_level

local indent_hl = 0
local function on_colorscheme()
  vim.api.nvim_set_hl(0, "IndentGuides", {
    link = "NonText",
    default = true,
  })
  indent_hl = vim.api.nvim_get_hl_id_by_name("IndentGuides")
end
on_colorscheme()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = on_colorscheme
})

---@param i integer
---@param lnum integer
---@return number
local function get_hl(i, lnum)
  return (i == cursor_indent_level and lnum >= range_beg and lnum <= range_end)
      and highlight
      or indent_hl
end

---@type vim.api.keyset.set_decoration_provider
local indent_handler = {
  on_win = function(_, winid, bufnr, top, bot)
    if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then return false end

    vim.api.nvim_buf_call(bufnr, function()
      left_col = vim.fn.winsaveview().leftcol
      width = vim.fn.shiftwidth()
      local cursor_lnum = unpack(vim.api.nvim_win_get_cursor(winid))

      range_beg = top
      range_end = bot + 1

      local indent = get_indent(cursor_lnum)

      if get_indent(cursor_lnum + 1) > indent then
        range_beg = cursor_lnum
        cursor_indent_level = indent / width + 1
        for lnum = cursor_lnum + 2, bot do
          if get_indent(lnum) <= indent then
            range_end = lnum - 1
            break
          end
        end
      else
        cursor_indent_level = indent / width
        for lnum = cursor_lnum - 1, top, -1 do
          if get_indent(lnum) < indent then
            range_beg = lnum + 1
            break
          end
        end
        for lnum = cursor_lnum + 1, bot do
          if get_indent(lnum) < indent then
            range_end = lnum - 1
            break
          end
        end
      end
    end)
  end,
  on_line = function(_, _, bufnr, row)
    local lnum = row + 1
    vim.api.nvim_buf_call(bufnr, function()
      local raw_indent = get_indent(lnum)
      local i = 0
      for raw_col = 0, raw_indent - 1, width do
        i = i + 1
        local col = raw_col - left_col
        if col >= 0 then
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
            virt_text = { { char, get_hl(i, lnum) } },
            virt_text_win_col = col,
            ephemeral = true,
            hl_mode = 'combine',
            undo_restore = false,
          })
        end
      end
    end)
  end,
}

---@type integer?
local last_redraw_row
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  callback = function(arg)
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    if row == last_redraw_row then return end
    last_redraw_row = row
    vim.api.nvim__redraw {
      valid = true,
      buf = arg.buf,
      range = { 0, -1 },
    }
  end,
  group = vim.api.nvim_create_augroup("redraw indent", { clear = true })
})

local current_handler
---@param handler vim.api.keyset.set_decoration_provider
local function set_handler(handler)
  current_handler = handler
  vim.api.nvim_set_decoration_provider(ns, current_handler)
end

set_handler(indent_handler)

return {
  toggle = function()
    set_handler(current_handler == indent_handler and {} or indent_handler)
  end,
}
