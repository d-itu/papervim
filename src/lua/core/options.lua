vim.o.clipboard = "unnamedplus"

vim.o.mouse = "a"
vim.o.mousemoveevent = true

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

vim.o.number = true
vim.o.relativenumber = true
-- vim.o.signcolumn = 'no'
vim.o.numberwidth = 1

vim.o.wrap = false
vim.o.cursorline = true
vim.o.showmode = false

vim.opt.mousescroll = { 'ver:1', 'hor:2' }

vim.o.laststatus = 3 -- always and only last window
vim.o.cmdheight = 0
vim.o.list = true
vim.opt.listchars = {
  trail = '·',
  extends = '󰶻',
  precedes = '󰶺',
  nbsp = '±',
  tab = "󰌒 ",
}
vim.opt.fillchars:append {
  foldopen = '',
  foldclose = '',
  foldsep = ' ',
  vert = ' ',
}
vim.opt.guicursor = {
  "n-v-sm:block",
  "i-c-ci-ve:ver25",
  "r-cr-o:hor20",
  "a:-Cursor/lCursor",
}

vim.o.title = true
vim.o.titlestring = "%t"

vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.splitright = true
vim.o.splitkeep = 'screen'

vim.opt.whichwrap:append "<,>,[,],h,l"

vim.o.undofile = true
vim.o.swapfile = false

vim.o.spelloptions = "noplainbuffer,camel"

