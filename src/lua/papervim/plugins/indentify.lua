vim.cmd.packadd "indentify"

local terms = {
  ["xterm-kitty"] = true,
  ["xterm-ghostty"] = true,
  foot = true,
}

require "indentify".setup {
  char = terms[vim.env.TERM] and "🭱" or "▏"
}
