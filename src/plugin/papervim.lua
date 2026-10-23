local group = require "papervim.augroup"

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
  require "papervim.plugins.catppuccin"
  vim.cmd.packadd "kanagawa.nvim"
  require "papervim.plugins.rose-pine"
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
  require 'papervim.plugins.dropbar'
end)

lazy('FileType', function()
  require "papervim.plugins.render-markdown"
  require "render-markdown".buf_enable()
end, "markdown")

lazy({ 'InsertEnter', 'CmdlineEnter' }, function()
  require 'papervim.plugins.blink-cmp'
  require 'papervim.plugins.nvim-autopairs'
  require 'papervim.plugins.nvim-ts-autotag'
  require 'papervim.plugins.minuet-ai'
end)

lazy("BufEnter", function()
  require "papervim.plugins.fyler"
  -- trigger callback of `fyler`
  vim.api.nvim_exec_autocmds('BufEnter', {})

  require 'papervim.plugins.nvim-surround'
  require 'papervim.plugins.babel'
  require 'papervim.plugins.indentify'
end)

lazy("UIEnter", function()
  require "papervim.statusline"
  require "papervim.tabline"

  require "papervim.plugins.which-key"
end)

require "papervim.ui"
require "papervim.options"
require "papervim.mapping"
require "papervim.autocmd"
require "papervim.lsp"
require "papervim.picker"
require "papervim.session"
