require "plugins.gitsigns"

vim.cmd.packadd "nvim-scrollbar"
require "scrollbar.handlers.gitsigns".setup()
require "scrollbar".setup {
  hide_if_all_visible = false,
  handle = {
    blend = 0,
    highlight = "PmenuThumb",
  },
  excluded_filetypes = {
    "fyler_finder",
  },
  excluded_buftypes = {
    "nofile",
    "prompt"
  },
}
