local ui = require "papervim.picker.ui"
local icons = require "papervim.icons"

---@alias picker.filetype "file" | "directory" | "link" | "fifo" | "socket" | "char" | "block" | "unknown"

---@param filename string
---@param type picker.filetype
---@param executable boolean?
---@param buf integer
---@param row integer
local function render_item(filename, type, executable, buf, row)
  local icon, icon_hl, hl, link = "?", nil, nil, nil
  if type == "file" then
    icon, icon_hl = icons.get('file', filename)
    if executable then hl = "MiniIconsGreen" end
  elseif type == "directory" then
    icon, icon_hl = icons.get('directory', filename)
    hl = "Directory"
  elseif type == "link" then
    icon, icon_hl = "", "MiniIconsPurple"
    link = vim.uv.fs_readlink(filename)
    if not link then hl = "Error" end
  elseif type == "fifo" then
    icon, icon_hl = "󰟥", "MiniIconsRed"
    hl = icon_hl
  elseif type == "socket" then
    icon, icon_hl = "󰐧", "MiniIconsRed"
    hl = icon_hl
  elseif type == "char" then
    icon, icon_hl = "󰌓", "MiniIconsYellow"
    hl = icon_hl
  elseif type == "block" then
    icon, icon_hl = "󰋊", "MiniIconsYellow"
    hl = icon_hl
  end

  local cursor = ui.cursor(buf, row)
  cursor.append(icon, icon_hl)
  cursor.append " "
  cursor.append(filename, hl)
  if link then
    cursor.append " -> "
    cursor.append(link, "NonText")
  end
end

return {
  render_item = render_item,
  ---@param path string
  ---@param buf integer?
  preview = function(path, buf)
    if not buf then
      buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = 'wipe'
    end
    local row = 0
    for filename, type in vim.fs.dir(path, {}) do
      local stat = vim.uv.fs_stat(vim.fs.joinpath(path, filename))
      render_item(filename, type, stat and stat.mode % 0100 == 0, buf, row)
      row = row + 1
    end
    return buf
  end,
}
