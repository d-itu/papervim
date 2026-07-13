vim.cmd.packadd "blink.indent"

local indent = require "blink.indent"

local indent_char = require "core.indent-char"

indent.setup {
  blocked = {
    filetypes = {
      include_defaults = true,
      'fyler_finder',
    },
  },
  static = {
    char = indent_char,
    highlights = { "NonText" },
  },
  scope = {
    char = indent_char,
    highlights = { "@function" },
  },
}

indent.enable()
