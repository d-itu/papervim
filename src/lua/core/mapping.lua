---@param desc string
---@return vim.keymap.set.Opts
local desc = function(desc)
  return {
    silent = true,
    desc = desc,
    noremap = true,
  }
end

vim.keymap.set('n', '<C-a>', 'ggVG', desc 'Select all')
vim.keymap.set("", 'x', '"_x', desc 'Cut')
vim.keymap.set({ 'n', 'i' }, '<C-s>', vim.cmd.write, desc 'Save')

vim.keymap.set({ 'n', 'x' }, 'j', 'gj', desc 'Down')
vim.keymap.set({ 'n', 'x' }, 'k', 'gk', desc 'Up')
vim.keymap.set({ 'n', 'x' }, '<Down>', 'gj', desc 'Down')
vim.keymap.set({ 'n', 'x' }, '<Up>', 'gk', desc 'Up')

vim.keymap.set({ 'n', 'x' }, '+', '', desc 'Increase')
vim.keymap.set({ 'n', 'x' }, '-', '', desc 'Decrease')
vim.keymap.set('x', 'g+', 'g', desc 'Increase')
vim.keymap.set('x', 'g-', 'g', desc 'Decrease')

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', desc 'Window left')
vim.keymap.set('n', '<C-j>', '<C-w>j', desc 'Window down')
vim.keymap.set('n', '<C-k>', '<C-w>k', desc 'Window up')
vim.keymap.set('n', '<C-l>', '<C-w>l', desc 'Window right')

-- Window Resizing
vim.keymap.set('n', '<C-Up>', '<cmd>resize +1<CR>', desc 'Resize up')
vim.keymap.set('n', '<C-Down>', '<cmd>resize -1<CR>', desc 'Resize down')
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize +1<CR>', desc 'Resize left')
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize -1<CR>', desc 'Resize right')

vim.keymap.set('n', '\\x', function() require "core.close_buf"() end, desc 'Close Current Buffer')

-- Search
vim.keymap.set('n', '', function() vim.o.hlsearch = false end, desc 'Disable highlight search')
vim.keymap.set({ "n", "x", "o" }, "n", function()
  if vim.v.searchforward == 1 then return 'n' else return 'N' end
end, { expr = true, desc = "Search next" })
vim.keymap.set({ "n", "x", "o" }, "N", function()
  if vim.v.searchforward == 1 then return 'N' else return 'n' end
end, { expr = true, desc = "Search prev" })

vim.keymap.set('v', 'p', 'P', desc 'Paste') -- paste without yank
vim.keymap.set('v', '<', '<gv', desc 'Indent left')
vim.keymap.set('v', '>', '>gv', desc 'Indent right')

vim.keymap.set('n', 'q:', '<Nop>', { noremap = true })
vim.keymap.set('n', 'q;', 'q:', { noremap = true })

vim.keymap.set('x', '/', function()
  return require 'vim._comment'.operator() .. 'gvj'
end, {
  expr = true,
  desc = 'toggle comment'
})
vim.keymap.set('n', '<leader>/', function()
  return require 'vim._comment'.operator() .. '_j'
end, {
  expr = true,
  desc = 'toggle comment'
})
vim.keymap.set('n', 'gco', 'oVcx<cmd>normal gcc<cr>fxa<bs>', desc 'Add comment bellow')

vim.keymap.set('n', '<CR>', 'viw')

-- Incremental Selection
vim.keymap.set({ 'n', 'x', 'o' }, '<CR>', function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require 'vim.treesitter._select'.select_parent(vim.v.count1)
    return
  end
  local client = vim.lsp.get_clients({ method = 'textDocument/selectionRange', bufnr = 0 })[1]
  if client then
    vim.lsp.buf.selection_range(vim.v.count1)
    return
  end
  vim.cmd "normal! viw"
end, { desc = 'Select parent (outer) node' })

vim.keymap.set({ 'x', 'o' }, '<BS>', function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require 'vim.treesitter._select'.select_child(vim.v.count1)
    return
  end
  local client = vim.lsp.get_clients { method = 'textDocument/selectionRange', bufnr = 0 }[1]
  if client then
    vim.lsp.buf.selection_range(-vim.v.count1)
    return
  end
  vim.cmd "normal! \b"
end, { desc = 'Select child (inner) node' })

vim.keymap.set('n', "<C-LeftMouse>", function()
  local mouse = vim.fn.getmousepos()
  local inlay_hint = require "core.inlay_hint"
  if inlay_hint(0, mouse.line - 1, mouse.column - 1) then return end

  vim.api.nvim_set_current_win(mouse.winid)
  vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, mouse.column - 1 })

  local url = vim.fn.expand "<cfile>"
  if url:match 'https?://' then
    vim.ui.open(url)
    return
  end

  vim.api.nvim_feedkeys("", "n", false)
end, { desc = 'Goto or open item under mouse' })

local terminal = require "core.terminal"
vim.keymap.set({ 'n', 't' }, "<C-`>", terminal.split_terminal, { desc = "Split terminal" })
vim.keymap.set({ 'n', 't' }, [[\\]], terminal.split_terminal, { desc = "Split terminal" })
