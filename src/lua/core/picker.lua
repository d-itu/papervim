local fuzzy = require "core.picker.fuzzy"

---@generic T
---@param items T[]
---@param opts vim.ui.select.Opts
---@param on_choice fun(item: T|nil, idx: integer|nil)
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(items, opts, on_choice)
  fuzzy.show(items, {
    format = opts.format_item or tostring,
    on_choice = function(idx)
      if idx then
        on_choice(items[idx], idx)
      else
        on_choice(nil, nil)
      end
    end,
    use_preview_win = opts.preview_item ~= nil,
    preview = function(idx, win)
      if not idx then
        vim.api.nvim_win_set_buf(win, require "core.empty_buf")
        return
      end

      local result = opts.preview_item(items[idx]) or {}
      vim.api.nvim_win_set_buf(win, result.buf or require "core.empty_buf")
      if result.pos then
        pcall(vim.api.nvim_win_set_cursor, win, result.pos)
      end
    end,
  })
end

---@class picer.provider
---@field key string
---@field desc string

---@type table<string, picer.provider>
local providers = {
  buffers = { key = 'b', desc = 'Pick buffers' },
  colorscheme = { key = 'c', desc = 'Pick colorscheme' },
  ripgrep = { key = 'w', desc = 'Live grep' },
}

for name, info in pairs(providers) do
  vim.keymap.set('n', '\\f' .. info.key, function()
    require("core.picker.providers." .. name)()
  end, { desc = info.desc })
end
