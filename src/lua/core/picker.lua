vim.ui.select = require "core.picker.ui_select"

---@class picer.provider
---@field key string
---@field desc string

---@type table<string, picer.provider>
local providers = {
  buffers = { key = 'b', desc = 'Pick buffers' },
  colorscheme = { key = 'c', desc = 'Pick colorscheme' },
  ripgrep = { key = 'w', desc = 'Live grep' },
  fd = { key = 'f', desc = 'Finder' },
}

for name, info in pairs(providers) do
  vim.keymap.set('n', '\\f' .. info.key, function()
    require("core.picker.providers." .. name) {}
  end, { desc = info.desc })
end
