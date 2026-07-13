vim.cmd.packadd "fyler.nvim"

require "plugins.mini-icons"

local fyler = require "fyler"

local home = os.getenv "HOME" or ""
function _G.fyler_path()
  local url = vim.fn.expand "%"
  local path = url:sub(#"fyler-file://" + 1)
  return path:gsub(home, "~")
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "fyler_finder",
  callback = function()
    vim.wo.spell = false
    vim.wo.cursorline = true
    vim.wo.winbar = " %#FylerWinBar#%{v:lua.fyler_path()}"
    -- TODO: dim background
    -- vim.wo.winhighlight = "Normal:FylerNormal"
  end,
  group = require "core.augroup",
})
vim.keymap.set("n", "\\e", fyler.toggle, { desc = "Toggle Explorer" })
