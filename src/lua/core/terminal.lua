---@param buf? integer
---@return integer
local function new_terminal_buf(buf)
  local buf = buf or vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_call(buf, function()
    vim.fn.jobstart(vim.o.shell, { term = true })
  end)
  return buf
end

---@type integer?
local terminal_win
local function split_terminal()
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_close(terminal_win, true)
  else
    local buf = vim.iter(vim.api.nvim_list_bufs())
        :find(function(buf)
          return vim.fn.buflisted(buf) == 1 and vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal"
        end) or new_terminal_buf()
    terminal_win = vim.api.nvim_open_win(buf, true, {
      split = "below",
      style = "minimal",
    })
    vim.cmd.startinsert()
  end
end

return {
  new_terminal_buf = new_terminal_buf,
  split_terminal = split_terminal,
  terminal_win = function()
    return terminal_win
  end,
}
