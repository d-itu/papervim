require "papervim.plugins.mini-icons"

---@alias icons.category 'default' | 'directory' | 'extension' | 'file' | 'filetype' | 'lsp' | 'os'

---@type { get: fun(category: icons.category, name: string): glyph: string, highlight: string, is_default: boolean }
local icons = require "mini.icons"

return icons
