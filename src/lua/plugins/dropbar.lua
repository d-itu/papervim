vim.cmd.packadd "dropbar.nvim"

require "plugins.mini-icons"
local mini_icons = require "mini.icons"

local group = require 'core.augroup'
local symbols = require "core.symbols"

local symbols_ext = {
  Array = " ",
  Boolean = " ",
  Key = " ",
  Namespace = " ",
  Null = " ",
  Number = "󰎠 ",
  Object = "󰘦 ",
  Package = " ",
  String = "󱆨 ",
  BlockMappingPair = '󰅩 ',
  BreakStatement = '󰙧 ',
  Call = '󰃷 ',
  CaseStatement = '󱃙 ',
  ContinueStatement = '→ ',
  Copilot = ' ',
  Declaration = '󰙠 ',
  Delete = ' ',
  DoStatement = '󰑖 ',
  Element = '󰅩 ',
  ForStatement = '󰑖 ',
  GotoStatement = '󰁔 ',
  Identifier = ' ',
  IfStatement = '󰇉 ',
  List = '󰅪 ',
  Log = '󰦪 ',
  Lsp = ' ',
  Macro = '󰁌 ',
  MarkdownH1 = '󰉫 ',
  MarkdownH2 = '󰉬 ',
  MarkdownH3 = '󰉭 ',
  MarkdownH4 = '󰉮 ',
  MarkdownH5 = '󰉯 ',
  MarkdownH6 = '󰉰 ',
  Pair = ' ',
  Regex = ' ',
  Repeat = '󰑖 ',
  Return = '󰌑 ',
  Rule = '󰅩 ',
  RuleSet = '󰅩 ',
  Scope = '󰅩 ',
  Section = '󰅩 ',
  Specifier = '󰦪 ',
  Statement = '󰞷 ',
  SwitchStatement = '󰺟 ',
  Table = '󰅩 ',
  Terminal = ' ',
  Type = ' ',
  Variable = ' ',
  WhileStatement = '󰑖 ',
}

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "modified",
  callback = function()
    if vim.api.nvim_buf_get_name(0) == ''
        and not vim.bo.modified then
      vim.wo.winbar = ""
    end
  end,
  group = group,
})

local disable_for_filetypes = {
  "fzf",
}

require 'dropbar'.setup {
  bar = {
    enable = function(buf, win)
      if vim.wo[win].winbar ~= '' then return false end
      if vim.tbl_contains(disable_for_filetypes, vim.bo[buf].filetype) then return false end
      if vim.bo[buf].buftype == "terminal" then return end
      if vim.api.nvim_buf_get_name(buf) == '' then
        return vim.bo[buf].filetype ~= '' and vim.bo.modified
      end
      return true
    end,
    attach_events = {
      'TermOpen',
      'BufEnter',
      'BufWinEnter',
      'BufWritePost',
      'FileType',
      'ModeChanged',
    },
  },
  icons = {
    enable = true,
    kinds = {
      ---@param path string path to the directory
      ---@return string: icon for the directory
      ---@return string?: highlight group for the icon
      dir_icon = function(path)
        local glyph, hl = mini_icons.get('directory', path)
        return glyph .. ' ', hl
      end,
      ---@param path string path to the file
      ---@return string: icon for the file
      ---@return string?: highlight group for the icon
      file_icon = function(path)
        local icon, hl = mini_icons.get('file', path)
        return icon .. ' ', hl
      end,
      symbols = vim.tbl_extend('keep', vim.tbl_map(function(x) return x .. ' ' end, symbols.cmp.from_str), symbols_ext),
    },
    ui = {
      bar = {
        separator = ' ',
        extends = '…',
      },
      menu = {
        separator = ' ',
        indicator = ' ',
      },
    },
  },
}
