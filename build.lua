vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
}, { load = false })

vim.cmd.packadd 'nvim-treesitter'
local languages = {
  'bash', 'c', 'caddy', 'cpp', 'css', 'desktop',
  'diff', 'dtd', 'git_config', 'gitcommit', 'glsl',
  'hyprlang', 'ini', 'javascript', 'json', 'kdl',
  'kitty', 'kotlin', 'lua', 'make', 'markdown',
  'markdown_inline', 'meson', 'objdump', 'odin',
  'python', 'regex', 'rust', 'scss', 'ssh_config',
  'toml', 'typescript', 'vim', 'wgsl', 'xml',
  'yaml', 'yuck', 'zig',
}
require 'nvim-treesitter'.install(languages, { summary = true }):wait()
