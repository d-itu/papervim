---@alias location { path: string, row: integer, col: integer }

---@param location location
local function callback(location)
  if vim.fs.normalize(location.path) ~= vim.fs.normalize(vim.fn.expand "%") then
    vim.cmd.edit(location.path)
  end
  vim.api.nvim_win_set_cursor(0, { location.row + 1, location.col })
end


---@param buf integer
---@param row integer
---@param col integer
---@return boolean
return function(buf, row, col)
  ---@type location[]
  local result = {}
  for _, entry in ipairs(vim.lsp.inlay_hint.get { bufnr = buf }) do
    local client = vim.lsp.get_client_by_id(entry.client_id)
    if not client then goto continue end
    local hint = entry.inlay_hint

    local position = hint.position
    if position.line ~= row or position.character ~= col then goto continue end

    local label = hint.label
    if type(label) ~= "table" then goto continue end
    ---@cast label lsp.InlayHintLabelPart[]
    for _, part in ipairs(label) do
      local path = vim.uri_to_fname(part.location.uri)
      if vim.fn.filereadable(path) == 1 then
        local start = part.location.range.start
        table.insert(result, { path = path, row = start.line, col = start.character })
      end
    end

    ::continue::
  end

  if #result == 0 then return false end
  if #result == 1 then
    callback(result[1])
    return true
  end

  vim.ui.select(result, {
    format_item = function(location)
      return ("%s:%d:%d"):format(location.path, location.row, location.col)
    end,
    preview_item = function(location)
      local buf = vim.api.nvim_create_buf(false, true)
      _ = location
      -- TODO: preview
      vim.bo[buf].bufhidden = 'wipe'
      return { buf = buf }
    end,
  }, callback)
  return true
end
