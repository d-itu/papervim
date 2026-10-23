vim.cmd.packadd "nvim-surround"

require "nvim-surround".setup {
  surrounds = {
    ["("] = {
      add = { "(", ")" },
    },
    ["["] = {
      add = { "[", "]" },
    },
    ["<"] = {
      add = { "<", ">" },
    },
  },
}

vim.keymap.set("x", "s", "<Plug>(nvim-surround-visual)", {
  desc = "Add a surrounding pair around a visual selection"
})
