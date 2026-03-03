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
vim.keymap.set('n', '<C-Tab>', vim.cmd.bn, desc 'Buffer Previous')
vim.keymap.set('n', '<S-Tab>', vim.cmd.bp, desc 'Buffer Previous')
-- vim.keymap.set('n', '<M-q>', require 'utils.buffer_delete', desc 'Buffer Delete')
-- vim.keymap.set('n', '<leader>x', require 'utils.buffer_delete', desc 'Buffer Delete')

-- Tab Navigation
vim.keymap.set('n', '<M-Tab>', vim.cmd.tabnext, desc 'Tab Next')
vim.keymap.set('n', '<M-S-Tab>', vim.cmd.tabprevious, desc 'Tab Previous')
vim.keymap.set('n', '<leader><Tab>', vim.cmd.tabnext, desc 'Tab Next')

-- Window Resizing
vim.keymap.set('n', '<C-Up>', '<cmd>resize +1<CR>', desc 'Resize Up')
vim.keymap.set('n', '<C-Down>', '<cmd>resize -1<CR>', desc 'Resize Down')
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize +1<CR>', desc 'Resize Left')
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize -1<CR>', desc 'Resize Right')

vim.keymap.set({ "n", "x", "o" }, "n", function()
  vim.o.hlsearch = true
  if vim.v.searchforward == 1 then return 'n' else return 'N' end
end, { expr = true, desc = "Search Next" })

vim.keymap.set({ "n", "x", "o" }, "N", function()
  vim.o.hlsearch = true
  if vim.v.searchforward == 1 then return 'N' else return 'n' end
end, { expr = true, desc = "Search Prev" })

vim.keymap.set({ "n", "x" }, "#", function()
  vim.o.hlsearch = true
  return "#"
end, { expr = true, desc = "Search Forward" })

vim.keymap.set({ "n", "x" }, "*", function()
  vim.o.hlsearch = true
  return "*"
end, { expr = true, desc = "Search Backward" })

-- vim.keymap.set('n', '', require 'utils.exit_hlsearch')

vim.keymap.set('v', 'p', 'P', desc 'Paste') -- paste without yank
vim.keymap.set('v', '<', '<gv', desc 'Indent Left')
vim.keymap.set('v', '>', '>gv', desc 'Indent Right')

vim.keymap.set('n', 'q:', '<Nop>', { noremap = true })
vim.keymap.set('n', 'q;', 'q:', { noremap = true })

vim.keymap.set('n', '<C-LeftMouse>', function()
  vim.cmd [[exe "silent normal! \<LeftMouse>"]]

  -- gx
  local uri = vim.fn.expand "<cfile>"
  if uri:match 'https?://' then
    vim.ui.open(uri)
    return
  end

  local _, err = pcall(vim.api.nvim_command, [[silent normal! ]])
  if err then vim.notify_once(err:match ': (.*)', vim.log.levels.WARN) end
end, desc 'Open URI or Jump')

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
