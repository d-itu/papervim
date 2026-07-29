local group = require "core.augroup"

---@param event vim.api.keyset.events|vim.api.keyset.events[]
---@param callback fun()
---@param pattern? string | string[]
local function lazy(event, callback, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = callback,
    once = true,
    desc = "lazy load"
  })
end

lazy("ColorSchemePre", function()
  require "plugins.catppuccin"
  vim.cmd.packadd "kanagawa.nvim"
  require "plugins.rose-pine"
end)

vim.cmd.colorscheme "fruitparade"

vim.filetype.add {
  extension = {
    nisba = 'nisba',
    ll = 'llvm',
  },
}

vim.treesitter.language.register("bash", "sh")
vim.treesitter.language.register("json", "jsonc")

lazy('FileType', function()
  require 'plugins.dropbar'
end)

lazy('FileType', function()
  require "plugins.render-markdown"
  require "render-markdown".buf_enable()
end, "markdown")

lazy({ 'InsertEnter', 'CmdlineEnter' }, function()
  require 'plugins.blink-cmp'
  require 'plugins.nvim-autopairs'
  require 'plugins.nvim-ts-autotag'
  require 'plugins.minuet-ai'
end)

lazy("BufEnter", function()
  require "plugins.fyler"
  -- trigger callback of `fyler`
  vim.api.nvim_exec_autocmds('BufEnter', {})

  require 'plugins.nvim-surround'
  require 'plugins.nvim-scrollbar'
  require 'plugins.babel'
  require 'plugins.indentify'
end)

lazy("UIEnter", function()
  require "core.statusline"
  require "core.tabline"

  require "plugins.fzf"
  require "plugins.which-key"
end)

require "core.ui"
require "core.options"
require "core.mapping"
require "core.autocmd"
require "core.lsp"
require "core.session"
