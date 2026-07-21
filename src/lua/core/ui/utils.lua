---@alias content_entry [_, string, integer]

local ns = vim.api.nvim_create_namespace("papervim_ui")

---@param buf integer
local function cursor(buf)
  local row = 0
  local col = 0
  ---@param text string
  ---@param hl? integer | string
  local function append(text, hl)
    local lines = vim.split(text, "\n", {})
    vim.api.nvim_buf_set_text(buf, row, col, row, -1, { lines[1] })
    vim.api.nvim_buf_set_lines(buf, row + 1, -1, false, { unpack(lines, 2) })
    local end_row = row + #lines - 1
    local end_col = #lines[#lines]
    if #lines == 1 then end_col = col + end_col end
    if hl then
      vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
        end_row = end_row,
        end_col = end_col,
        hl_group = hl,
      })
    end
    row = end_row
    col = end_col
  end
  return {
    append = append,
    ---@param content content_entry[]
    render = function(content)
      for _, entry in ipairs(content) do
        local _, text, hl = unpack(entry)
        append(text, hl)
      end
    end,
    row = function() return row end,
    col = function() return col end,
  }
end

return {
  ---@param content content_entry[]
  ---@return string
  concat_content = function(content)
    return vim.iter(content):map(function(entry) return entry[2] end):join('')
  end,
  ns = ns,
  cursor = cursor,
}
