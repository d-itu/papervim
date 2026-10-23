return function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  if vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= "" then
    vim.v.errmsg = ""
    local ok, err = pcall(vim.api.nvim_win_close, win, false)
    if not ok then
      vim.api.nvim_echo({ { vim.v.errmsg ~= "" and vim.v.errmsg or err } }, true, { err = true })
    end
    return
  end

  if vim.api.nvim_get_option_value("modified", { buf = buf }) then
    vim.api.nvim_echo({ { "No write since last change" } }, true, { err = true })
    return
  end

  local list, _pos = unpack(vim.fn.getjumplist())
  ---@param entry vim.fn.getjumplist.ret.item
  ---@type vim.fn.getjumplist.ret.item
  local entry = vim.iter(list):rfind(function(entry)
    return vim.fn.buflisted(entry.bufnr) == 1 and entry.bufnr ~= buf
  end)

  if entry then
    vim.api.nvim_win_set_buf(win, entry.bufnr)
    vim.api.nvim_win_set_cursor(win, { entry.lnum, entry.col })
  else
    vim.api.nvim_win_set_buf(win, vim.iter(vim.api.nvim_list_bufs())
      :filter(function(b)
        return b ~= buf
            and vim.fn.buflisted(b) == 1
            and vim.bo[b].buftype == ''
      end)
      :last()
      or vim.api.nvim_create_buf(true, false))
  end

  if #vim.fn.win_findbuf(buf) == 0 then
    vim.api.nvim_buf_delete(buf, {})
  end
end
