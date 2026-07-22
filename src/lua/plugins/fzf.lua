---@diagnostic disable: missing-fields

vim.cmd.packadd "fzf-lua"

local fzf = require "fzf-lua"

local actions = require "fzf-lua.actions"

fzf.setup {
  winopts = {
    border = "none",
    preview = {
      border = "none",
      winopts = {
        winhighlight = "FloatBorder:FzfLuaPreviewBorder,NormalFloat:NormalNC,Normal:NormalNC",
      },
    },
  },
  fzf_colors = { true },
  fzf_opts = {
    ["--prompt"] = " > "
  },
  hls = {
    preview_normal = "NormalNC",
  },
  grep = {
    actions = {
      ["ctrl-g"] = { actions.grep_lgrep },
      ["ctrl-r"] = { actions.toggle_ignore },
    },
  },
  previewers = {
    builtin = {
      render_markdown = { enabled = false },
      snacks_image = { enabled = false },
    },
  },
  files = {
    git_icons = true,
  },
}

vim.api.nvim_set_keymap("n", "\\ff", "", {
  callback = fzf.files,
  desc = "fzf file",
})
vim.api.nvim_set_keymap("n", "\\fw", "", {
  callback = fzf.live_grep,
  desc = "fzf live_grep",
})

vim.keymap.set('n', 'grr', function()
  fzf.lsp_references {
    includeDeclaration = false
  }
end, { desc = "Lsp References" })
vim.keymap.set('n', 'gri', fzf.lsp_implementations, { desc = "Lsp References" })

fzf.register_ui_select()
