require "core.options"
require "core.mapping"
require "core.autocmd"
require "core.colorscheme"

local group = require "core.augroup"

--- @param event vim.api.keyset.events|vim.api.keyset.events[]
--- @param callback fun()
local function lazy(event, callback)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    callback = callback,
    once = true,
    desc = "lazy load"
  })
end

lazy('FileType', function()
  require 'plugins.lsp'
  require 'plugins.dropbar'
end)

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
  require "core.ui"
  require "core.statusline"
  require "core.tabline"

  require "plugins.fzf"
  require "plugins.which-key"
end)

if vim.fn.argc() == 1 then
  local path = vim.fn.argv()[1]
  if vim.fn.isdirectory(path) == 1 then
    vim.api.nvim_set_current_dir(path)
  else
    local dir = vim.fs.dirname(path)
    if vim.fn.isdirectory(dir) == 1 then
      vim.api.nvim_set_current_dir(dir)
    end
  end
end

vim.filetype.add {
  extension = {
    nisba = 'nisba',
    ll = 'llvm',
  },
}
