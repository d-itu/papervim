require "plugins.gitsigns"

vim.cmd.packadd "nvim-scrollbar"
require "scrollbar.handlers.gitsigns".setup()
---@diagnostic disable-next-line: undefined-field
require "scrollbar".setup {
  excluded_filetypes = {
    "fyler_finder",
  },
  excluded_buftypes = {
    "nofile",
  },
}
