return {
  show = function()
    local msgs = vim.fn.execute("messages")

    vim.cmd("botright new")

    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(msgs, "\n"))

    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
  end
}
