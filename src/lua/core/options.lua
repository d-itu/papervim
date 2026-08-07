vim.o.clipboard = "unnamedplus"

vim.o.mouse = "ar"
vim.o.mousemoveevent = true

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1

vim.o.wrap = false
vim.o.cursorline = true
vim.o.showmode = false

vim.opt.mousescroll = { 'ver:1', 'hor:2' }

vim.o.laststatus = 3 -- always and only last window
vim.o.showtabline = 2
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
  foldinner = ' ',
  fold = ' ',
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
vim.opt.shada = { '!', "'0", "<0", "@0", "h", "r/tmp/", "r/private/" }

vim.o.spell = true
vim.o.spelloptions = "noplainbuffer,camel"

vim.o.updatetime = 1

function _G.pad()
  if vim.wo.number or vim.wo.relativenumber then return ' ' end
  return ""
end

vim.o.signcolumn = 'yes'
vim.o.statuscolumn = "%s%l%C%{v:lua.pad()}"

vim.o.foldlevelstart = 99
vim.o.foldtext = "v:lua.foldtext()"
vim.o.foldcolumn = "auto"

local function get_hl(row, col)
  local inspect = vim.inspect_pos(0, row, col)
  return vim.iter {
    inspect.extmarks,
    inspect.semantic_tokens,
    inspect.treesitter,
    inspect.syntax,
  }:flatten(1):map(function(x) return x.hl_group end):totable()
end

function _G.foldtext()
  local text = vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, false)[1]
  local chunks = {}
  for i = 1, #text do
    chunks[i] = { text:sub(i, i), get_hl(vim.v.foldstart - 1, i - 1) }
  end
  table.insert(chunks, {
    " ⋯ ", { "@comment", "LspInlayHint" }
  })
  return chunks
end
