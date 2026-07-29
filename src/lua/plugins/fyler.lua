vim.cmd.packadd "fyler.nvim"

require "plugins.mini-icons"

local fyler = require "fyler"

local home = os.getenv "HOME"
function _G.fyler_path()
  local url = vim.fn.expand "%"
  local path = url:sub(#"fyler-file://" + 1)
  if home then path = path:gsub(home, "~") end
  return path
end

local function hl()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  vim.api.nvim_set_hl(0, "FylerWinBar", {
    fg = normal.fg,
    bold = true,
    italic = true,
    default = true,
  })
end
hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = hl,
  group = require "core.augroup",
})

fyler.setup {
  integrations = {
    icon = "mini_icons",
  },
  follow_current_file = false,
  extensions = {
    git = {
      enabled = true,
    },
  },
  kind = "split_left_most",
  kind_presets = {
    split_left_most = {
      width = 32,
    }
  },
  win_opts = {
    spell = false,
    cursorline = true,
    winbar = " %#FylerWinBar#%{v:lua.fyler_path()}",
  },
  mappings = {
    n = {
      ['<BS>'] = {
        action = 'visit',
        args = { parent = true },
      },
      ['<CR>'] = {
        action = 'select',
        args = { close = true },
      },
      ['<C-S>'] = {
        action = 'mutate',
      },
      ['<C-V>'] = {
        action = 'fallback',
      },
      ['\\s'] = {
        action = 'select',
        args = { split = true },
      },
      H = {
        action = 'toggle_ui',
        args = { 'hidden_items' },
      },
      ['\\v'] = {
        action = 'select',
        args = { vsplit = true },
      },
    },
  },
  ---@diagnostic disable-next-line: missing-fields
  ui = {
    indent_guides = true,
  },
}
vim.keymap.set("n", "\\e", fyler.toggle, { desc = "Toggle Explorer" })
