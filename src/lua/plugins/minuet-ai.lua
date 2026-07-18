vim.cmd.packadd "minuet-ai.nvim"

require "minuet".setup {
  virtualtext = {
    keymap = {
      accept = "",
      accept_line = "<C-S-L>",
      next = "",
      prev = "<C-S-\\>",
    },
  },
}
