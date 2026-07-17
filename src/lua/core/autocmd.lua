local group = require "core.augroup"

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function()
    if vim.bo.buftype == "" then
      vim.wo.statuscolumn = "%s%l%C "
    else
      vim.wo.statuscolumn = ""
    end
  end,
  desc = "set statuscolumn"
})

vim.api.nvim_create_autocmd("BufWrite", {
  group = group,
  callback = function()
    vim.fn.mkdir(vim.fs.dirname(vim.fn.expand "%"), "p")
  end,
  desc = "mkdir before write",
})

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
  desc = "start treesitter highlight",
})

local function on_colorscheme()
  local function reverse(name)
    local fill = vim.api.nvim_get_hl(0, { name = name, link = false })
    if fill.reverse then
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      vim.api.nvim_set_hl(0, name, {
        reverse = false,
        fg = fill.bg or normal.fg,
        bg = fill.fg or normal.fg,
      })
    end
  end
  reverse "TabLineFill"
  reverse "TabLine"
  reverse "TabLineSel"
  reverse "StatusLine"
  reverse "StatusLineNC"
  reverse "StatusTermLine"
  reverse "StatusTermLineNC"
end
on_colorscheme()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = on_colorscheme,
  desc = "modify tabline and statusline highlight",
})

vim.api.nvim_create_autocmd("StdinReadPost", {
  group = group,
  callback = function()
    vim.bo.buftype = "nofile"
  end,
  once = true,
  desc = "set buftype when read from stdin",
})

vim.api.nvim_create_user_command('Messages', require 'core.message'.show, {})
