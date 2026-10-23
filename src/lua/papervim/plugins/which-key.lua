vim.cmd.packadd "which-key.nvim"

require "which-key".setup {
  win = {
    no_overlap = false,
  },
  layout = {
    width = {},
  },
  icons = {
    mappings = false,
  },
  replace = {
    desc = {},
  },
  defer = function() end,
}
