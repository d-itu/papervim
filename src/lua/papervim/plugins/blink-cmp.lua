vim.cmd.packadd "blink.lib"
vim.cmd.packadd "blink.cmp"

local cmp = require "blink.cmp"

local symbols = require "papervim.symbols"

---@param ctx blink.cmp.API
---@return boolean?
local function toggle(ctx)
  if ctx.is_menu_visible() then
    return ctx.hide()
  else
    return ctx.show()
  end
end

---@param op string
---@return fun(cmp: blink.cmp.API): boolean?
local function fallthrough(op)
  ---@param ctx blink.cmp.API
  return function(ctx)
    ctx[op]()
  end
end

cmp.setup {
  keymap = {
    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<Left>'] = { 'snippet_backward', 'fallback' },
    ['<Right>'] = { 'snippet_forward', 'fallback' },
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    ['<C-Space>'] = { toggle, 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },
  snippets = {},
  completion = {
    keyword = {
      range = "full",
    },
    trigger = {},
    list = {
      selection = {
        preselect = false,
      },
    },
    menu = {
      draw = {
        -- treesitter = { 'lsp' },
        columns = {
          { 'kind_icon' },
          { 'label',      'label_description', gap = 1 },
          { 'source_name' },
        },
        components = {
          source_name = {
            width = { max = 4 },
            text = function(ctx) return ctx.source_name end,
          },
        },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 0,
    },
    ghost_text = { enabled = true, },
  },
  signature = {
    enabled = true,
    trigger = {
      show_on_keyword = true,
      show_on_insert = true,
    }
  },
  sources = {
    providers = {
      lsp = {
        score_offset = 2,
      },
      path = {
        opts = {
          show_hidden_files_by_default = true,
        },
      },
      buffer = {
        score_offset = -5,
      },
    },
  },
  appearance = {
    nerd_font_variant = "normal",
    kind_icons = symbols.cmp.from_str,
  },
  cmdline = {
    keymap = {
      ['<Tab>'] = { 'show_and_insert', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'show_and_insert', 'select_prev', 'fallback' },
      ['<Left>'] = { fallthrough 'hide', 'fallback' },
      ['<Right>'] = { fallthrough 'hide', 'fallback' },
    },
    completion = {
      list = {
        selection = { preselect = false },
      },
      menu = { auto_show = true },
    },
  },
}
