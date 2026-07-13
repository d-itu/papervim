require "core.options"
require "core.mapping"

local group = require "core.augroup"

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  callback = function() vim.hl.on_yank() end,
  desc = 'yank',
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function()
    if not pcall(vim.treesitter.start) then return end
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    if not lang then return end
    if vim.treesitter.query.get(lang, "folds") then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function()
    require 'plugins.lsp'
    require 'plugins.dropbar'
  end,
  once = true,
})

vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
  group = group,
  callback = function()
    require 'plugins.blink-cmp'
    require 'plugins.nvim-autopairs'
    require 'plugins.nvim-ts-autotag'
  end,
  once = true,
})

vim.api.nvim_create_user_command('Messages', require 'core.message'.show, {})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function()
    require "plugins.fyler"
    vim.api.nvim_exec_autocmds('BufEnter', {})

    require 'plugins.nvim-surround'
    require 'plugins.nvim-scrollbar'
    require 'plugins.babel'
    require 'plugins.indentify'
  end,
  once = true,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function()
    if vim.bo.buftype == "" then
      vim.wo.statuscolumn = "%s%l%C "
    else
      vim.wo.statuscolumn = ""
    end
  end,
})

require "core.colorscheme"
require "core.statusline"
require "core.tabline"

require "plugins.fzf"
require "plugins.which-key"

if vim.fn.argc() == 1 then
  local path = vim.fn.argv()[1]
  if vim.fn.isdirectory(path) == 1 then
    vim.cmd.chdir(path)
  else
    local dir = vim.fs.dirname(path)
    if vim.fn.isdirectory(dir) == 1 then
      vim.cmd.chdir(dir)
    end
  end
end

if vim.o.shellpipe then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.o.modified = false
    end,
    once = true,
  })
end

vim.cmd.packadd "nvim-treesitter"

vim.filetype.add {
  extension = {
    nisba = 'nisba',
    ll = 'llvm',
  },
}
