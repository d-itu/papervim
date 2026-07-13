vim.cmd.packadd "babel.nvim"

---@diagnostic disable-next-line: missing-fields
require "babel".setup {
  target = "zh",
  ---@diagnostic disable-next-line: missing-fields
  float = {
    border = "none",
    mode = "cursor",
    auto_close = true,
  },
}
