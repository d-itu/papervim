local desc = function(desc)
  return {
    silent = true,
    desc = desc,
    noremap = true,
  }
end

vim.keymap.set('n', '<C-a>', 'ggVG', desc 'Select All')
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
vim.keymap.set('n', '<leader>q', ':q!', desc 'Quit')
vim.keymap.set('n', '<leader>qa', ':qa!', desc 'Quit All')

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', desc 'Window Left')
vim.keymap.set('n', '<C-j>', '<C-w>j', desc 'Window Down')
vim.keymap.set('n', '<C-k>', '<C-w>k', desc 'Window Up')
vim.keymap.set('n', '<C-l>', '<C-w>l', desc 'Window Right')

-- Buffer Navigation
vim.keymap.set('n', '<C-Tab>', vim.cmd.bn, desc 'Buffer Next')
vim.keymap.set('n', '<S-Tab>', vim.cmd.bp, desc 'Buffer Previous')

vim.keymap.set('n', '\\x', function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  if vim.api.nvim_get_option_value("modified", { buf = buf }) then
    vim.api.nvim_echo({ { "No write since last change" } }, true, { err = true })
    return
  end

  local list, _pos = unpack(vim.fn.getjumplist())
  ---@param entry vim.fn.getjumplist.ret.item
  ---@type vim.fn.getjumplist.ret.item
  local entry = vim.iter(list):rfind(function(entry)
    return vim.fn.buflisted(entry.bufnr) == 1 and entry.bufnr ~= buf
  end)

  if entry then
    vim.api.nvim_win_set_buf(win, entry.bufnr)
    vim.api.nvim_win_set_cursor(win, { entry.lnum, entry.col })
  else
    vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
  end

  if #vim.fn.win_findbuf(buf) == 0 then
    vim.api.nvim_buf_delete(buf, {})
  end
end, desc 'Close Current Buffer')

-- Tab Navigation
vim.keymap.set('n', '<M-Tab>', vim.cmd.tabnext, desc 'Tab Next')
vim.keymap.set('n', '<M-S-Tab>', vim.cmd.tabprevious, desc 'Tab Previous')
vim.keymap.set('n', '<leader><Tab>', vim.cmd.tabnext, desc 'Tab Next')

-- Window Resizing
vim.keymap.set('n', '<C-Up>', '<cmd>resize +1<CR>', desc 'Resize Up')
vim.keymap.set('n', '<C-Down>', '<cmd>resize -1<CR>', desc 'Resize Down')
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize +1<CR>', desc 'Resize Left')
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize -1<CR>', desc 'Resize Right')

-- Search
vim.keymap.set('n', '', function() vim.o.hlsearch = false end, desc 'Disable Highlight Search')
vim.keymap.set({ "n", "x", "o" }, "n", function()
  if vim.v.searchforward == 1 then return 'n' else return 'N' end
end, { expr = true, desc = "Search Next" })
vim.keymap.set({ "n", "x", "o" }, "N", function()
  if vim.v.searchforward == 1 then return 'N' else return 'n' end
end, { expr = true, desc = "Search Prev" })

vim.keymap.set('v', 'p', 'P', desc 'Paste') -- paste without yank
vim.keymap.set('v', '<', '<gv', desc 'Indent Left')
vim.keymap.set('v', '>', '>gv', desc 'Indent Right')

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
vim.keymap.set('n', 'gco', 'oVcx<cmd>normal gcc<cr>fxa<bs>', desc 'Add Comment Bellow')

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
  local client = vim.lsp.get_clients({ method = 'textDocument/selectionRange', bufnr = 0 })[1]
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

  vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, mouse.column - 1 })

  local url = vim.fn.expand "<cfile>"
  if url:match 'https?://' then
    vim.ui.open(url)
    return
  end

  vim.api.nvim_feedkeys("", "n", false)
end, { desc = 'Goto or open item under mouse' })
